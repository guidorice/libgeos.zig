/// GEOS C API example 1 (ported to Zig)
/// Reads two WKT representations and calculates the intersection,
/// prints it out, and cleans up.
const c = @cImport({
    @cInclude("zig_handlers.h");
    @cInclude("geos_c.h");
});
const std = @import("std");
const builtin = @import("builtin");
const handlers = @import("default_handlers");


const convertCStr = std.mem.span;

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();

    // Send notice and error messages to our stdout handler
    c.initGEOS(handlers.shimNotice, handlers.shimError);

    // Two squares that overlap
    const wkt_a = "POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))";
    const wkt_b = "POLYGON((5 5, 15 5, 15 15, 5 15, 5 5))";

    // Read the WKT into geometry objects
    const reader = c.GEOSWKTReader_create();
    const geom_a = c.GEOSWKTReader_read(reader, wkt_a);
    const geom_b = c.GEOSWKTReader_read(reader, wkt_b);

    // Calculate the intersection
    const inter = c.GEOSIntersection(geom_a, geom_b);

    // Convert result to WKT
    const writer = c.GEOSWKTWriter_create();

    // Trim trailing zeros off output
    c.GEOSWKTWriter_setTrim(writer, 1);
    const wkt_inter = c.GEOSWKTWriter_write(writer, inter);

    // Print answer
    try stdout.print("Geometry A:         {s}\n", .{wkt_a});
    try stdout.print("Geometry B:         {s}\n", .{wkt_b});
    try stdout.print("Intersection(A, B): {s}\n", .{convertCStr(wkt_inter)});

    // Clean up everything we allocated
    c.GEOSWKTReader_destroy(reader);
    c.GEOSWKTWriter_destroy(writer);
    c.GEOSGeom_destroy(geom_a);
    c.GEOSGeom_destroy(geom_b);
    c.GEOSGeom_destroy(inter);
    c.GEOSFree(wkt_inter);

    // Clean up the global context
    c.finishGEOS();
}
