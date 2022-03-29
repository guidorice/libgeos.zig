/// Reads one geometry and does high-performance prepared geometry operations
/// to place random points inside it.
///
/// (the description says "random points", however the example C code is not
/// randomized.)
///
/// Ported from src/geos/examples/capi_prepared.c
const c = @cImport({
    @cInclude("zig_handlers.h");
    @cInclude("geos_c.h");
});
const std = @import("std");
const handlers = @import("default_handlers");

const ArrayList = std.ArrayList;
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator(.{});

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var gpa = GeneralPurposeAllocator{};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Send notice and error messages to our stdout handler
    c.initGEOS(handlers.shimNotice, handlers.shimError);

    // Clean up the global context
    defer c.finishGEOS();
    errdefer c.finishGEOS();

    // One concave polygon
    const wkt = "POLYGON ((189 115, 200 170, 130 170, 35 242, 156 215, 210 290, 274 256, 360 190, 267 215, 300 50, 200 60, 189 115))";

    // Read the WKT into geometry objects
    const reader = c.GEOSWKTReader_create();
    defer c.GEOSWKTReader_destroy(reader);

    const geom = c.GEOSWKTReader_read(reader, wkt);
    defer c.GEOSGeom_destroy(geom);

    // Check for parse success.
    if (geom == null) {
        // TODO: parse failure actually results in an unhandled C++ exception (see known issues)
        return error.GEOSWKTParseFailure;
    }

    // Prepare the geometry
    const prep_geom = c.GEOSPrepare(geom);
    defer c.GEOSPreparedGeom_destroy(prep_geom);

    // Read bounds of geometry
    var xmin: f64 = 0;
    var xmax: f64 = 0;
    var ymin: f64 = 0;
    var ymax: f64 = 0;
    if (c.GEOSGeom_getXMin(geom, &xmin) == 0) {
        // geos returns 0 on empty geometry.
        return error.GEOSInvalidOperation;
    }
    if (c.GEOSGeom_getXMax(geom, &xmax) == 0) {
        return error.GEOSInvalidOperation;
    }
    if (c.GEOSGeom_getYMin(geom, &ymin) == 0) {
        return error.GEOSInvalidOperation;
    }
    if (c.GEOSGeom_getYMax(geom, &ymax) == 0) {
        return error.GEOSInvalidOperation;
    }

    // Set up the point generator
    // Generate all the points in the bounding box
    // of the input polygon.
    const steps: u8 = 10;
    const xstep: f64 = (xmax - xmin) / @intToFloat(f64, steps);
    const ystep: f64 = (ymax - ymin) / @intToFloat(f64, steps);

    // Place to hold points to output
    //      The example C code allocated a [steps*steps] array of pointers.
    //      Instead, use zig std library ArrayList.
    var geoms = ArrayList(?*c.GEOSGeometry).init(allocator);
    defer geoms.deinit();

    // Test all the points in the polygon bounding box
    // and only keep those that intersect the actual polygon.
    var i: u8 = 0;
    var j: u8 = 0;
    while (i < steps) : (i += 1) {
        while (j < steps) : (j += 1) {
            // Make a point in the point grid
            const x = xmin + xstep * @intToFloat(f64, i);
            const y = ymin + ystep * @intToFloat(f64, j);
            const pt = c.GEOSGeom_createPointFromXY(x, y) orelse return error.GEOSInvalidOperation;

            // Check if the point and polygon intersect
            if (c.GEOSPreparedIntersects(prep_geom, pt) != '0') {
                // Save the ones that do
                try geoms.append(pt);
            } else {
                // Clean up the ones that don't
                c.GEOSGeom_destroy(pt);
            }
        }
    }

    // Put the successful geoms inside a geometry for WKT output
    const result = c.GEOSGeom_createCollection(c.GEOS_MULTIPOINT, geoms.items.ptr, @intCast(c_uint, geoms.items.len));
    defer c.GEOSGeom_destroy(result);

    // The GEOSGeom_createCollection() only takes ownership of the
    // geometries, not the array container, so we can free the container now.
    //
    // (See defer statement above)

    // Convert result to WKT
    const writer = c.GEOSWKTWriter_create();
    defer c.GEOSWKTWriter_destroy(writer);

    // Trim trailing zeros off output
    c.GEOSWKTWriter_setTrim(writer, 1);
    c.GEOSWKTWriter_setRoundingPrecision(writer, 3);
    const wkt_result = c.GEOSWKTWriter_write(writer, result);
    defer c.GEOSFree(wkt_result);

    // Print answer
    try stdout.print("Input Polygon:\n{s}\n\n", .{wkt});
    try stdout.print("Output Points:\n{s}\n\n", .{wkt_result});

    // | Clean up everything we allocated
    // | Clean up the global context
    // |-> *see zig defer statements above*
}
