const std = @import("std");
const testing = std.testing;
const LDtk = @import("LDtk.zig");

test "load default/empty ldtk file" {
    const empty_ldtk = @embedFile("test.ldtk");

    const ldtk_root = try LDtk.parse(testing.allocator, empty_ldtk);
    defer ldtk_root.deinit(testing.allocator);

    try testing.expectEqualStrings("1.1.3", ldtk_root.jsonVersion);
    try testing.expectEqualStrings("#40465B", ldtk_root.bgColor);
    try testing.expectEqual(@as(?i64, 256), ldtk_root.worldGridHeight);
    try testing.expectEqual(@as(?i64, 256), ldtk_root.worldGridWidth);
    try testing.expectEqual(@as(?LDtk.WorldLayout, LDtk.WorldLayout.Free), ldtk_root.worldLayout);
    try testing.expect(!ldtk_root.externalLevels);

    try testing.expectEqual(@as(usize, 1), ldtk_root.levels.len);

    const level_0 = ldtk_root.levels[0];
    try testing.expectEqualStrings("Level_0", level_0.identifier);
    try testing.expectEqualStrings("c0773b00-02f0-11ed-bf2c-25905856c5d2", level_0.iid);
    try testing.expectEqualStrings("#696A79", level_0.__bgColor);
    try testing.expectEqual(@as(i64, 0), level_0.uid);
    try testing.expectEqual(@as(i64, 0), level_0.worldX);
    try testing.expectEqual(@as(i64, 0), level_0.worldY);
    try testing.expectEqual(@as(i64, 0), level_0.worldDepth);
    try testing.expectEqual(@as(i64, 256), level_0.pxWid);
    try testing.expectEqual(@as(i64, 256), level_0.pxHei);
    try testing.expectEqual(@as(?[]const u8, null), level_0.externalRelPath);
    try testing.expectEqual(@as(?[]const u8, null), level_0.bgRelPath);
    try testing.expectEqualSlices(LDtk.Neighbour, &[_]LDtk.Neighbour{}, level_0.__neighbours);
    try testing.expectEqualSlices(LDtk.FieldInstance, &[_]LDtk.FieldInstance{}, level_0.fieldInstances);
    try testing.expectEqualSlices(LDtk.LayerInstance, &[_]LDtk.LayerInstance{}, level_0.layerInstances.?);
}
