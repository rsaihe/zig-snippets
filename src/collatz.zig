const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = &gpa.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Ensure at least one argument was passed.
    if (args.len < 2) {
        try stderr.writeAll("Please provide a positive integer.\n");
        return;
    }

    // Attempt to parse argument as an integer.
    var num = std.fmt.parseUnsigned(u64, args[1], 10) catch {
        try stderr.writeAll("Unable to parse number.\n");
        return;
    };

    // Ensure passed number is positive.
    if (num == 0) {
        try stderr.writeAll("Please provide an integer greater than zero.\n");
        return;
    }

    var iterations: u64 = 0;
    while (num > 1) {
        if (num % 2 == 0) {
            num /= 2;
        } else {
            const mul = @mulWithOverflow(u64, num, 3, &num);
            const add = @addWithOverflow(u64, num, 1, &num);
            if (mul or add) {
                try stdout.print(
                    "Overflowed after {} iterations.\n",
                    .{iterations},
                );
                return;
            }
        }

        if (@addWithOverflow(u64, iterations, 1, &iterations)) {
            try stdout.writeAll("Took too many iterations.\n");
            return;
        }
    }

    try stdout.print("Took {} iterations.\n", .{iterations});
}
