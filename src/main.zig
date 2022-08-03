const std = @import("std");
const testing = std.testing;
const LDtk = @import("LDtk.zig");

test "load default/empty ldtk file" {
    const empty_ldtk = @embedFile("test.ldtk");

    const ldtk_root = try LDtk.parse(testing.allocator, empty_ldtk);

    try testing.expectEqualStrings("1.1.3", ldtk_root.jsonVersion);
    try testing.expectEqualStrings("#40465B", ldtk_root.bgColor);
    try testing.expectEqual(@as(?i64, 256), ldtk_root.worldGridHeight);
    try testing.expectEqual(@as(?i64, 256), ldtk_root.worldGridWidth);
    try testing.expectEqual(@as(?LDtk.WorldLayout, LDtk.WorldLayout.Free), ldtk_root.worldLayout);
    try testing.expect(!ldtk_root.externalLevels);
}

