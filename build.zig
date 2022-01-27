const std = @import("std");
const libgeos = @import("src/libgeos.zig");

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const core_lib = try libgeos.createCore(b, target, mode);
    core_lib.step.install();
    const capi_lib = try libgeos.createCAPI(b, target, mode);
    capi_lib.step.install();

    const tests = b.addTest("src/tests.zig");
    core_lib.link(tests, .{});
    capi_lib.link(tests, .{});
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&tests.step);

    const exe = b.addExecutable("example1", "src/examples/example1.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    core_lib.link(exe, .{});
    capi_lib.link(exe, .{});
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run-example1", "Run the example1 app");
    run_step.dependOn(&run_cmd.step);
}
