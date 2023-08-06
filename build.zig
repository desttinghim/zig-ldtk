const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "zig-ldtk",
        .root_source_file = std.Build.FileSource.relative("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    const main_tests = b.addTest(.{
        .root_source_file = std.Build.FileSource.relative("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_main_tests = b.addRunArtifact(main_tests);
    const main_test_step = b.step("test", "Run unit tests.");
    main_test_step.dependOn(&run_main_tests.step);
}
