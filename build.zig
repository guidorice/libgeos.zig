/// this build.zig shows how to link libgeos with an exe and with your unit tests.
const std = @import("std");
const libgeos = @import("src/libgeos.zig");

const Example = struct {
    cmd: []const u8,
    src: []const u8,
    descr: []const u8,
};

const examples = [_]Example{
    Example{
        .cmd = "run-ex1",
        .src = "src/examples/ex1.zig",
        .descr = "Ex 1: Reads two WKT representations and calculates the intersection, prints it out, and cleans up."
    },
    Example{
        .cmd = "run-ex1-ts",
        .src = "src/examples/ex1_threadsafe.zig",
        .descr = "Ex 1 (threadsafe): Same but using re-entrant api.",
    },
    Example{
        .cmd = "run-ex2",
        .src = "src/examples/ex2.zig",
        .descr = "Ex 2: Reads one geometry and does a high-performance prepared geometry operations to place random points inside it."
    },
    Example{
        .cmd = "run-ex3",
        .src = "src/examples/ex3.zig",
        .descr = "Ex 3: Build a spatial index and search it for a nearest pair.",
    },

};

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    // the C api depends on the core C++ lib, so build and link both of them.
    const core_lib = try libgeos.createCore(b, target, mode);
    const capi_lib = try libgeos.createCAPI(b, target, mode);

    // setup unit tests step
    const tests = b.addTest("src/tests.zig");
    core_lib.link(tests, .{});
    capi_lib.link(tests, .{ .import_name = "geos" });
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&tests.step);

    // add all examples
    for (examples) |ex| {
        const exe = b.addExecutable(ex.cmd, ex.src);
        exe.addPackagePath("default_handlers", "src/shim/default_handlers.zig");
        exe.setTarget(target);
        exe.setBuildMode(mode);
        core_lib.link(exe, .{});
        capi_lib.link(exe, .{ .import_name = "geos" });
        exe.install();
        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
        const run_step = b.step(ex.cmd, ex.descr);
        run_step.dependOn(&run_cmd.step);
    }
}
