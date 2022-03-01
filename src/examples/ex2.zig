/// Reads one geometry and does high-performance prepared geometry operations
/// to place random points inside it.
///
/// Ported from src/geos/examples/capi_prepared.c
const c = @cImport({
    @cInclude("zig_handlers.h");
    @cInclude("geos_c.h");
});
const std = @import("std");
const builtin = @import("builtin");
const handlers = @import("default_handlers");

const convertCStr = std.mem.span;

pub fn main() anyerror!void {
    // Send notice and error messages to our stdout handler
    c.initGEOS(handlers.shimNotice, handlers.shimError);
     // Clean up the global context (note: in Zig this is paired with the init call) 
    defer c.finishGEOS();
    errdefer c.finishGEOS();

    // One concave polygon
    const wkt = "BADPOLYGON ((189 115, 200 170, 130 170, 35 242, 156 215, 210 290, 274 256, 360 190, 267 215, 300 50, 200 60, 189 115))";

    // Read the WKT into geometry objects
    const reader = c.GEOSWKTReader_create();
    defer c.GEOSWKTReader_destroy(reader);

    const geom = c.GEOSWKTReader_read(reader, wkt);
    defer c.GEOSGeom_destroy(geom);
    // Check for parse success.
    if (geom == null) {
        // TODO: parse failure actually results in an unhandled C++ exception (see Known Issues in Readme)
        return error.WKTParseFailure;
    }

    // Prepare the geometry
    const prep_geom = c.GEOSPrepare(geom);
    defer c.GEOSPreparedGeom_destroy(prep_geom);

    // Read bounds of geometry
    var xmin: ?f64 = null;
    var xmax: ?f64 = null;
    var ymin: ?f64 = null;
    var ymax: ?f64 = null;
    c.GEOSGeom_getXMin(geom, xmin);
    c.GEOSGeom_getXMax(geom, xmax);
    c.GEOSGeom_getYMin(geom, ymin);
    c.GEOSGeom_getYMax(geom, ymax);

}
