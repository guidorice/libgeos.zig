/// GEOS C API example 1 (ported to Zig)
/// Reads two WKT representations and calculates the intersection, prints it out,
/// and cleans up.
const c = @cImport({
    @cInclude("zig_handlers.h");
    @cInclude("geos_c.h");
});
const std = @import("std");
const builtin = @import("builtin");
const convertCStr = std.mem.span;

// TODO: move boilerplate default handlers into src/shim/default_handlers.zig?

pub extern "c" fn shim_notice(format: [*c]const u8, ...) void;
pub extern "c" fn shim_error(format: [*c]const u8, ...) void;

/// libgeos notice handler. Is called by C fn shim_notice().
export fn notice_handler(msg: [*c]u8) void {
    std.log.info("libgeos: {s}", .{msg});
    defer std.c.free(msg);
}

/// libgeos log and exit handler. Is called by C fn shim_error().
/// If is_test, then warns but don't exit().
export fn error_handler(msg: [*c]const u8) void {
    if (!builtin.is_test) {
        std.log.err("libgeos: {s}", .{msg});
        std.os.exit(1);
    } else {
        // just warn and dont exit, otherwise tests will fail
        std.log.warn("libgeos: {s}", .{msg});
    }
}

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();

    // Send notice and error messages to our stdout handler */
    c.initGEOS(shim_notice, shim_error);

    // Two squares that overlap
    const wkt_a = "POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))";
    const wkt_b = "POLYGON((5 5, 15 5, 15 15, 5 15, 5 5))";

    // Read the WKT into geometry objects
    var reader = c.GEOSWKTReader_create();
    var geom_a = c.GEOSWKTReader_read(reader, wkt_a);
    var geom_b = c.GEOSWKTReader_read(reader, wkt_b);

    // Calculate the intersection
    var inter = c.GEOSIntersection(geom_a, geom_b);

    // Convert result to WKT
    var writer = c.GEOSWKTWriter_create();

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
