const c = @cImport({
    @cInclude("zig_handlers.h");
    @cInclude("geos_c.h");
});

const std = @import("std");
const handlers = @import("shim/default_handlers.zig");
const builtin = @import("builtin");
const testing = std.testing;
const expectEqualStrings = testing.expectEqualStrings;
const convertCStr = std.mem.span;

test "GEOSversion" {
    const want = "3.10.2-CAPI-1.16.0";
    const got = convertCStr(c.GEOSversion());
    try testing.expectEqualStrings(got, want);
}

test "shim_notice -> zig notice_handler" {
    // send some printf style args to the notice handler
    handlers.shimNotice("%s %s %s\n", "hello", "from", "zig");
}

test "shim_error -> zig error_handler" {
    // send some printf style args to the log_and_exit handler
    handlers.shimError("%s %s %s\n", "this is a C", "callback", "to zig");
}

test "init/finish" {
    c.initGEOS(handlers.shimNotice, handlers.shimError);
    c.finishGEOS();
}

test "c++ error handler" {
    // Send notice and error messages to our stdout handler
    c.initGEOS(handlers.shimNotice, handlers.shimError);
    // Clean up the global context
    defer c.finishGEOS();
    errdefer c.finishGEOS();

    // badly formatted WKT poly
    const wkt = "BADPOLYGON ((189 115, 200 170, 130 170, 35 242, 156 215, 210 290, 274 256, 360 190, 267 215, 300 50, 200 60, 189 115))";

    // Read the WKT into geometry objects
    const reader = c.GEOSWKTReader_create();
    defer c.GEOSWKTReader_destroy(reader);

    const geom = c.GEOSWKTReader_read(reader, wkt);
    // TODO: the _read call crashes with: `libc++abi: terminating with uncaught exception of type geos::io::ParseException: ParseException: Unknown type: 'BADPOLYGON'`
    defer c.GEOSGeom_destroy(geom);
    try testing.expect(geom != null);
}
