/// The (future) zig wrapper for the libgeos c library will be defined here.

const std = @import("std");
const c = @cImport({
    @cInclude("zig_handlers.h");
    @cInclude("geos_c.h");
});
const convertCStr = std.mem.span;

pub fn geosVersion() []const u8 {
    return convertCStr(c.GEOSversion());
}
