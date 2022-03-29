/// Build a spatial index and search it for a nearest pair.
///
/// Ported from: src/geos/examples/capi_strtree.c
const c = @cImport({
    @cInclude("zig_handlers.h");
    @cInclude("geos_c.h");
});

const std = @import("std");
const builtin = @import("builtin");
const handlers = @import("default_handlers");
const convertCStr = std.mem.span;
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator(.{});

var prng = std.rand.DefaultPrng.init(0);
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

pub fn main() anyerror!void {
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

    var i: usize = 0;
    while (i < npoints) : (i += 1) {
        // Make a random point
        const geom = try geosRandomPoint(range);
        // Store away a reference so we can free it after
        geoms[i] = geom;
        // Add an entry for it to the tree
        c.GEOSSTRtree_insert(tree, geom, geom);
    }

    // Random point to compare to the field
    const geom_random = try geosRandomPoint(range);
    defer c.GEOSGeom_destroy(geom_random);

    // Nearest point in the field to our test point
    const geom_nearest = c.GEOSSTRtree_nearest(tree, geom_random);

    std.log.info("{} {}", .{
        geom_nearest,
        npoints,
    });

    // /* Convert results to WKT */
    // GEOSWKTWriter* writer = GEOSWKTWriter_create();
    // /* Trim trailing zeros off output */
    // GEOSWKTWriter_setTrim(writer, 1);
    // GEOSWKTWriter_setRoundingPrecision(writer, 3);
    // char* wkt_random = GEOSWKTWriter_write(writer, geom_random);
    // char* wkt_nearest = GEOSWKTWriter_write(writer, geom_nearest);
    // GEOSWKTWriter_destroy(writer);

    // /* Print answer */
    // printf(" Random Point: %s\n", wkt_random);
    // printf("Nearest Point: %s\n", wkt_nearest);

    // /* Clean up all allocated objects */
    // /* Destroying tree does not destroy inputs */
    // GEOSSTRtree_destroy(tree);
    // GEOSGeom_destroy(geom_random);
    // /* Destroy all the points in our random field */
    // for (size_t i = 0; i < npoints; i++) {
    //     GEOSGeom_destroy(geoms[i]);
    // }
    // /*
    // * Don't forget to free memory allocated by the
    // * printing functions!
    // */
    // GEOSFree(wkt_random);
    // GEOSFree(wkt_nearest);

    // /* Clean up the global context */
    // finishGEOS();

    // /* Done */
    // return 0;
}
