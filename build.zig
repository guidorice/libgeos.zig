/// this build.zig shows how to link libgeos with an exe and with your unit tests.
const std = @import("std");
const libgeos = @import("src/libgeos.zig");

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

    // setup run-example1 step
    const exe = b.addExecutable("example1", "src/examples/example1.zig");
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
    const run_step = b.step("run-example1", "Run the example1 app");
    run_step.dependOn(&run_cmd.step);
}
