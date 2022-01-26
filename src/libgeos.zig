/// Credit to mattnite, based on https://github.com/mattnite/zig-zlib/blob/a6a72f47c0653b5757a86b453b549819a151d6c7/zlib.zig

const std = @import("std");

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const endsWith = std.mem.endsWith;

fn root() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}

const root_path = root() ++ "/";
const package_path = root_path ++ "/main.zig";
const geos_src_path = root_path ++ "/geos/src";
const shim_src = root_path ++ "/shim/zig_handlers.c";

const geos_include_dirs = [_][]const u8{
    root_path ++ "/vendor/geos/build/capi",
    root_path ++ "/vendor/geos/build/include",
    root_path ++ "/shim",
    root_path ++ "/geos/include",
    root_path ++ "/geos/src/deps",
};

pub const Options = struct {
    import_name: ?[]const u8 = null,
};

pub const Library = struct {
    step: *std.build.LibExeObjStep,

    pub fn link(self: Library, other: *std.build.LibExeObjStep, opts: Options) void {
        for (geos_include_dirs) |dir| {
            other.addIncludeDir(dir);
        }
        other.linkLibrary(self.step);

        if (opts.import_name) |import_name|
            other.addPackagePath(import_name, package_path);
    }
};

pub fn create(b: *std.build.Builder, target: std.zig.CrossTarget, mode: std.builtin.Mode) !Library {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    var ret = b.addStaticLibrary("geos", null);
    ret.setTarget(target);
    ret.setBuildMode(mode);
    ret.linkLibCpp();
    for (geos_include_dirs) |dir| {
        ret.addIncludeDir(dir);
    }
    ret.addCSourceFile(shim_src, &.{"-O"});
    const libgeos_sources = try findLibGEOSSources(alloc);
    defer alloc.free(libgeos_sources);
    // TODO: adding a mixture of .c and .cpp files. Any advantage to add them separately, with respective flags, e.g. "-std=c++17" or "-std=c99", etc?
    ret.addCSourceFiles(libgeos_sources, &.{ "-g0", "-O" });
    return Library{ .step = ret };
}

/// Walk the libgeos source tree and collect all .c and .cpp source files.
/// *Caller owns the returned memory.*
fn findLibGEOSSources(alloc: Allocator) ![]const []const u8 {
    const libgeos_dir = try std.fs.openDirAbsolute(geos_src_path, .{ .iterate = true });
    var walker = try libgeos_dir.walk(alloc);
    defer walker.deinit();
    var list = ArrayList([]const u8).init(alloc);
    while (try walker.next()) |entry| {
        if (entry.kind != .File) continue;
        if (endsWith(u8, entry.basename, ".c") or endsWith(u8, entry.basename, ".cpp")) {
            const abs_path = try std.fs.path.join(alloc, &.{ geos_src_path, entry.path });
            try list.append(abs_path);
        }
    }
    return list.toOwnedSlice();
}
