/// Build a spatial index and search it for a nearest pair.
///
/// Ported from: src/geos/examples/capi_strtree.c
const c = @cImport({
    @cInclude("zig_handlers.h");
    @cInclude("geos_c.h");
});
const std = @import("std");
const builtin = @import("builtin");
const handlers = @import("default_handlers");

const convertCStr = std.mem.span;

pub fn main() anyerror!void {
    // TODO finish ex3
}
