const c = @cImport({
    @cInclude("geos_c.h");
    @cInclude("zig_handlers.h");
});

const std = @import("std");
const builtin = @import("builtin");
const testing = std.testing;


pub extern "c" fn shim_notice(format: [*c]const u8, ...) void;
pub extern "c" fn shim_error(format: [*c]const u8, ...) void;

/// libgeos notice handler. Is called by C fn shim_notice().
export fn notice_handler(msg: [*c]u8) void {
    std.log.info("libgeos: {s}", .{msg});
    defer std.c.free(msg);
}

/// libgeos log and exit handler. Is called by C fn shim_log_and_exit().
export fn error_handler(msg: [*c]const u8) void {
    if(!builtin.is_test) {
        std.log.err("libgeos: {s}", .{msg});
        std.os.exit(1);
    } else {
        // just warn and dont exit, other test will fail
        std.log.warn("libgeos: {s}", .{msg});
    }
}

test "shim_notice -> zig handler" {
    // send some printf style args to the notice handler
    shim_notice("%s %s %s\n", "hello", "from", "zig");
}

test "shim_log_and_exit -> zig handler" {
    // send some printf style args to the log_and_exit handler
    shim_error("%s %s %s\n", "this is a C", "callback", "to zig");
}

test "c.initGEOS" {
    c.initGEOS(shim_notice, shim_error);
}

// const logExitMessageHandler = std.log.err;

// test "C_initGEOS()" {
//     // TODO: wait for varargs in https://github.com/ziglang/zig/issues/515
//     c.initGEOS(printf, printf);

// }

// test "C_GEOSversion" {
//     const GEOSVersion = c.GEOSVersion;
//     const ver = GEOSVersion();
//     log.info("{s}", .{ ver });
// }

