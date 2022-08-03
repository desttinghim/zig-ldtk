const std = @import("std");
const testing = std.testing;

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}
