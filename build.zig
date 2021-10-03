const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const dir = try std.fs.cwd().openDir("src", .{ .iterate = true });
    var it = dir.iterate();
    while (try it.next()) |entry| {
        if (entry.kind == .File) {
            const name = std.mem.sliceTo(entry.name, '.');
            const filename = try std.fmt.allocPrint(
                b.allocator,
                "src/{s}",
                .{entry.name},
            );

            const exe = b.addExecutable(name, filename);
            exe.setTarget(target);
            exe.setBuildMode(mode);
            exe.install();

            const run_cmd = exe.run();
            run_cmd.step.dependOn(b.getInstallStep());
            if (b.args) |args| {
                run_cmd.addArgs(args);
            }

            const run_step = b.step(
                name,
                try std.fmt.allocPrint(b.allocator, "Run {s}", .{name}),
            );
            run_step.dependOn(&run_cmd.step);
        }
    }
}
