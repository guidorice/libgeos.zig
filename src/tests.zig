const c = @cImport({
    @cInclude("zig_handlers.h");
    @cInclude("geos_c.h");
});

const std = @import("std");
const builtin = @import("builtin");
const testing = std.testing;
const expectEqualStrings = testing.expectEqualStrings;
const convertCStr = std.mem.span;

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
    if(!builtin.is_test) {
        std.log.err("libgeos: {s}", .{msg});
        std.os.exit(1);
    } else {
        // just warn and dont exit, otherwise tests will fail
        std.log.warn("libgeos: {s}", .{msg});
    }
}


test "GEOSversion" {
    const want = "3.10.2-CAPI-1.16.0";
    const got = convertCStr(c.GEOSversion());
    try testing.expectEqualStrings(got, want);
}

test "shim_notice -> zig handler" {
    // send some printf style args to the notice handler
    shim_notice("%s %s %s\n", "hello", "from", "zig");
}

test "shim_log_and_exit -> zig handler" {
    // send some printf style args to the log_and_exit handler
    shim_error("%s %s %s\n", "this is a C", "callback", "to zig");
}

test "init/finish" {
    c.initGEOS(shim_notice, shim_error);
    c.finishGEOS();
}
