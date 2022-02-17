/// Reads one geometry and does a high-performance prepared geometry operations
/// to place random points inside it.
///
/// Ported from src/geos/examples/capi_prepared.c
const c = @cImport({
    @cInclude("zig_handlers.h");
    @cInclude("geos_c.h");
});
const std = @import("std");
const builtin = @import("builtin");
const handlers = @import("default_handlers");

const convertCStr = std.mem.span;

pub fn main() anyerror!void {
    // TODO finish ex2
}
