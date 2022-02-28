/// Reads two WKT representations and calculates the intersection,
/// prints it out, and cleans up.
///
/// Thread-safe version of example 1. Uses the re-entrant API.
///
/// Ported from: src/geos/examples/capi_read_ts.c
const c = @cImport({
    @cInclude("zig_handlers.h");
    @cInclude("geos_c.h");
});
const std = @import("std");
const builtin = @import("builtin");
const handlers = @import("default_handlers");

const convertCStr = std.mem.span;

pub fn main() anyerror!void {
    return error.Unimplemented;
}
