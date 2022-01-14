const std = @import("std");
const log = std.log;
const fs = std.fs;
const mem = std.mem;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const geos_include_dirs = [_][]const u8{
    "/src/vendor/geos/build/capi",
    "/src/vendor/geos/build/include",
    "/src/geos/include",
    "/src/geos/src/deps",
};

pub fn build(b: *std.build.Builder) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const repo_root = comptime fs.path.dirname(@src().file) orelse ".";
    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});
    const lib = b.addStaticLibrary("geos", "src/main.zig");

    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib.linkLibCpp(); // libgeos has C++ stdlib dependencies

    // add libgeos include directories for C headers
    for (geos_include_dirs) |dir| {
        const path = try fs.path.join(alloc, &[_][]const u8{ repo_root, dir });
        defer alloc.free(path);
        lib.addIncludeDir(path);
    }

    // add C/C++ source files
    const libgeos_sources = try findLibGEOSSources(alloc);
    defer alloc.free(libgeos_sources);
    // TODO: adding a mixture of .c and .cpp files. Any advantage to add them separately, with respective flags, e.g. "-std=c++17" or "-std=c99", etc?
    lib.addCSourceFiles(libgeos_sources, &.{ "-g0", "-O" });

    lib.install();

    const main_tests = b.addTest("src/main.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}

/// Walk the libgeos source tree and collect all .c and .cpp source files.
/// *Caller owns the returned memory.*
fn findLibGEOSSources(alloc: Allocator) ![]const []const u8 {
    const repo_root = comptime fs.path.dirname(@src().file) orelse ".";
    const geos_src_path = repo_root ++ "/src/geos/src";
    const libgeos_dir = try fs.openDirAbsolute(geos_src_path, .{ .iterate = true });
    var walker = try libgeos_dir.walk(alloc);
    defer walker.deinit();
    var list = ArrayList([]const u8).init(alloc);
    while (try walker.next()) |entry| {
        if (entry.kind != .File) continue;
        if (mem.endsWith(u8, entry.basename, ".c") or mem.endsWith(u8, entry.basename, ".cpp")) {
            const abs_path = try fs.path.join(alloc, &.{ geos_src_path, entry.path });
            try list.append(abs_path);
        }
    }
    return list.toOwnedSlice();
}
