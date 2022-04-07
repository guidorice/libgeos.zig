/// Reads two WKT representations and calculates the intersection,
/// prints it out, and cleans up.
///
/// Thread-safe version of example 1. Uses the re-entrant API.
/// Ported from: src/geos/examples/capi_read_ts.c
/// Note: the example does not actually use multi-threading or async functions.
const c = @cImport({
    @cInclude("zig_handlers.h");
    @cInclude("geos_c.h");
});
const std = @import("std");
const handlers = @import("default_handlers");

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();

    // Each thread using the re-entrant API must get its
    // own context handle.
    const context = c.GEOS_init_r();
    defer c.GEOS_finish_r(context);
    errdefer c.GEOS_finish_r(context);

    // The notice/error handlers route message back to the calling
    // application. Here they just print to stdout.
    _ = c.GEOSContext_setNoticeHandler_r(context, handlers.shimNotice);
    _ = c.GEOSContext_setErrorHandler_r(context, handlers.shimError);

    // Two squares that overlap
    const wkt_a = "POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))";
    const wkt_b = "POLYGON((5 5, 15 5, 15 15, 5 15, 5 5))";

    // Read the WKT into geometry objects
    const reader = c.GEOSWKTReader_create_r(context);
    defer c.GEOSWKTReader_destroy_r(context, reader);

    const geom_a = c.GEOSWKTReader_read_r(context, reader, wkt_a);
    defer c.GEOSGeom_destroy_r(context, geom_a);
    const geom_b = c.GEOSWKTReader_read_r(context, reader, wkt_b);
    defer c.GEOSGeom_destroy_r(context, geom_b);

    // Calculate the intersection
    const inter = c.GEOSIntersection_r(context, geom_a, geom_b);
    defer c.GEOSGeom_destroy_r(context, inter);

    // Convert result to WKT
    const writer = c.GEOSWKTWriter_create_r(context);
    defer c.GEOSWKTWriter_destroy_r(context, writer);

    // Trim trailing zeros off output
    c.GEOSWKTWriter_setTrim(writer, 1);
    const wkt_inter = c.GEOSWKTWriter_write_r(context, writer, inter);
    defer c.GEOSFree_r(context, wkt_inter);

    // Print answer
    try stdout.print("Geometry A:         {s}\n", .{wkt_a});
    try stdout.print("Geometry B:         {s}\n", .{wkt_b});
    try stdout.print("Intersection(A, B): {s}\n", .{wkt_inter});

    // | Clean up everything we allocated
    // | Clean up the global context
    // |-> *see zig defer statements above*
}
