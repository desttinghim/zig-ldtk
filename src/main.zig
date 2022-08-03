const std = @import("std");
const testing = std.testing;
const LDtk = @import("LDtk.zig");

test "load default/empty ldtk file" {
    const empty_ldtk = @embedFile("empty.ldtk");
    const world = try LDtk.parse(testing.allocator, empty_ldtk);
    _ = world;
}
