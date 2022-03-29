/// Build a spatial index and search it for a nearest pair.
///
/// Ported from: src/geos/examples/capi_strtree.c
const c = @cImport({
    @cInclude("zig_handlers.h");
    @cInclude("geos_c.h");
});
const std = @import("std");
const handlers = @import("default_handlers");

var prng = std.rand.DefaultPrng.init(42); // TODO: better random seed
const random = prng.random();

/// Generate a random point in the range of POINT(0..range, 0..range).
/// *Caller owns the returned memory.*
fn geosRandomPoint(range: f64) !*c.GEOSGeometry {
    const x = range * random.float(f64);
    const y = range * random.float(f64);
    // Make a point in the point grid
    const opt_pt = c.GEOSGeom_createPointFromXY(x, y);
    if (opt_pt) |pt| {
        return pt;
    }
    return error.GEOSFailedToCreatePoint;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    // Send notice and error messages to our stdout handler
    c.initGEOS(handlers.shimNotice, handlers.shimError);

    // Clean up the global context
    defer c.finishGEOS();
    errdefer c.finishGEOS();

    // How many points to add to our random field
    const npoints: usize = 10000;

    // The coordinate range of the field (0->100.0)
    const range = 100.0;

    // The tree doesn't take ownership of inputs just holds references, so we
    // keep our point field handy in an array.
    var geoms: [npoints]*c.GEOSGeometry = undefined;

    // The create parameter for the tree is not the number of inputs, it is the
    // number of entries per node. 10 is a good default number to use.
    var tree = c.GEOSSTRtree_create(10);
    defer c.GEOSSTRtree_destroy(tree);

    for (geoms) |*geom_store| {
        // Make a random point
        const geom = try geosRandomPoint(range);
        // Store away a reference so we can free it after
        geom_store.* = geom;
        // Add an entry for it to the tree
        c.GEOSSTRtree_insert(tree, geom, geom);
    }
    defer {
        for (geoms) |*geom_store| {
            c.GEOSGeom_destroy(geom_store.*);
        }
    }

    // Random point to compare to the field
    const geom_random = try geosRandomPoint(range);
    defer c.GEOSGeom_destroy(geom_random);

    // Nearest point in the field to our test point
    const geom_nearest = c.GEOSSTRtree_nearest(tree, geom_random);

    // Convert results to WKT
    const writer = c.GEOSWKTWriter_create();
    defer c.GEOSWKTWriter_destroy(writer);
    // Trim trailing zeros off output
    c.GEOSWKTWriter_setTrim(writer, 1);
    c.GEOSWKTWriter_setRoundingPrecision(writer, 3);
    const wkt_random = c.GEOSWKTWriter_write(writer, geom_random);
    defer c.GEOSFree(wkt_random);
    const wkt_nearest = c.GEOSWKTWriter_write(writer, geom_nearest);
    defer c.GEOSFree(wkt_nearest);

    // Print answer
    try stdout.print("Random Point:    {s}\n", .{wkt_random});
    try stdout.print("Nearest Point:   {s}\n", .{wkt_nearest});

    // | Clean up all allocated objects
    // | Destroying tree does not destroy inputs
    // | Destroy all the points in our random field
    // | Don't forget to free memory allocated by the printing functions!
    // | Clean up the global context
    // |-> see zig defer statements above!
}
