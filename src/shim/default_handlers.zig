const std = @import("std");
const builtin = @import("builtin");

pub extern "c" fn shimNotice(format: [*c]const u8, ...) void;
pub extern "c" fn shimError(format: [*c]const u8, ...) void;

/// libgeos notice handler. Is called by C fn shimNotice().
export fn noticeHandler(msg: [*:0]u8) void {
    std.log.info("libgeos: {s}", .{msg});
    defer std.c.free(msg);
}

/// libgeos error handler. Is called by C fn shimError().
/// In contrast to the CAPI example, here we don't call std.os.exit().
export fn errorHandler(msg: [*:0]u8) void {
    std.log.err("libgeos: {s}", .{msg});
    defer std.c.free(msg);
}
