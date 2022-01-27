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
