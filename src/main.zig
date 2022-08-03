const std = @import("std");
const testing = std.testing;
const LDtk = @import("LDtk.zig");

test "load default/empty ldtk file" {
    const empty_ldtk = @embedFile("test.ldtk");

    var parser = std.json.Parser.init(testing.allocator, false);
    defer parser.deinit();

    var value_tree = try parser.parse(empty_ldtk);
    defer value_tree.deinit();

    value_tree.root.dump();

    // Seperate root for easier access
    const root = object(value_tree.root) orelse return error.InvalidRoot;

    // Pull out the more complicated structures
    // const defs = object(root.get("defs")) orelse return error.InvalidDefs;
    const levels = array(root.get("levels")) orelse return error.InvalidLevels;

    // const ldtk_defs = try extract_defs(testing.allocator, defs);
    // defer testing.allocator.free(ldtk_defs);
    const ldtk_levels = try extract_levels(testing.allocator, levels);
    defer testing.allocator.free(ldtk_levels);

    var ldtk_root = LDtk.Root{
        .bgColor = string(root.get("bgColor")) orelse return error.InvalidBGColor,
        // .defs = ldtk_defs,
        .externalLevels = boolean(root.get("externalLevels")) orelse return error.InvalidExternalLevels,
        .jsonVersion = string(root.get("jsonVersion")) orelse return error.InvalidJsonVersion,
        .levels = ldtk_levels,
        .worldGridHeight = integer(root.get("worldGridHeight")) orelse return error.InvalidHeight,
        .worldGridWidth = integer(root.get("worldGridWidth")) orelse return error.InvalidWidth,
        .worldLayout = enum_from_value(LDtk.WorldLayout, root.get("worldLayout")) orelse return error.InvalidWorldLayout,
    };
    if (array(root.get("worlds"))) |worlds| {
        const ldtk_worlds = try extract_worlds(testing.allocator, worlds);
        defer testing.allocator.free(ldtk_worlds);
        ldtk_root.worlds = ldtk_worlds;
    }

    try testing.expectEqualStrings("1.1.3", ldtk_root.jsonVersion);
    try testing.expectEqualStrings("#40465B", ldtk_root.bgColor);
    try testing.expectEqual(@as(?i64, 256), ldtk_root.worldGridHeight);
    try testing.expectEqual(@as(?i64, 256), ldtk_root.worldGridWidth);
    try testing.expectEqual(@as(?LDtk.WorldLayout, LDtk.WorldLayout.Free), ldtk_root.worldLayout);
    try testing.expect(!ldtk_root.externalLevels);
}

// pub fn extract_defs(alloc: std.mem.Allocator, defs_obj: std.json.Value) !LDtk.Definitions {
//     // TODO
// }

pub fn extract_worlds(alloc: std.mem.Allocator, worlds: std.json.Array) ![]LDtk.World {
    var ldtk_worlds = try std.ArrayList(LDtk.World).initCapacity(alloc, worlds.items.len);
    for (worlds.items) |world_value| {
        const world_obj = object(world_value) orelse return error.InvalidWorld;
        const levels_obj = array(world_obj.get("levels")) orelse return error.InvalidWorldLevels;
        const levels = try extract_levels(alloc, levels_obj);
        ldtk_worlds.appendAssumeCapacity(.{
            .identifier = string(world_obj.get("identifier")) orelse return error.InvalidIdentifier,
            .iid = string(world_obj.get("iid")) orelse return error.InvalidIID,
            .levels = levels,
            .worldGridHeight = integer(world_obj.get("worldGridHeight")) orelse return error.InvalidWorldGridHeight,
            .worldGridWidth = integer(world_obj.get("worldGridHeight")) orelse return error.InvalidWorldGridHeight,
            .worldLayout = enum_from_value(LDtk.WorldLayout, world_obj.get("worldLayout")) orelse return error.InvalidWorldLayout,
        });
    }
    return ldtk_worlds.toOwnedSlice();
}

pub fn extract_levels(alloc: std.mem.Allocator, levels: std.json.Array) ![]LDtk.Level {
    var ldtk_levels = try std.ArrayList(LDtk.Level).initCapacity(alloc, levels.items.len);
    defer ldtk_levels.deinit(); // levels will be returned using toOwnedSlice
    for (levels.items) |level_value| {
        const level_obj = object(level_value) orelse return error.InvalidLevel;
        const layer_instances = if (level_obj.get("layerInstances")) |layerInstances| try LDtk.LayerInstance.fromJSONMany(alloc, layerInstances) else null;
        ldtk_levels.appendAssumeCapacity(.{
            .__bgColor = string(level_obj.get("__bgColor")),
            // TODO
            .__bgPos = null,
            // TODO
            .__neighbours = &[_]LDtk.Neighbour{},
            .bgRelPath = string(level_obj.get("bgRelPath")),
            .externalRelPath = string(level_obj.get("externalRelPath")),
            // TODO
            .fieldInstances = &[_]LDtk.FieldInstance{},
            .identifier = string(level_obj.get("identifier")) orelse return error.InvalidIdentifier,
            .iid = string(level_obj.get("iid")) orelse return error.InvalidIID,
            .layerInstances = layer_instances,
            .pxHei = integer(level_obj.get("pxHei")) orelse return error.InvalidPxHei,
            .pxWid = integer(level_obj.get("pxWid")) orelse return error.InvalidPxWid,
            .uid = integer(level_obj.get("uid")) orelse return error.InvalidUID,
            .worldDepth = integer(level_obj.get("worldDepth")) orelse return error.InvalidWorldDepth,
            .worldX = integer(level_obj.get("worldX")) orelse return error.InvalidWorldX,
            .worldY = integer(level_obj.get("worldY")) orelse return error.InvalidWorldY,
        });
    }
    return ldtk_levels.toOwnedSlice();
}

// pub fn extract_layers(alloc: std.mem.Allocator, layers: std.json.Array) ![]LDtk.LayerInstance {
//     var ldtk_layers = try std.ArrayList(LDtk.LayerInstance).initCapacity(alloc, layers.items.len);
//     defer ldtk_layers.deinit(); // levels will be returned using toOwnedSlice
//     for (layers.items) |layer_value| {
//         const layer_obj = object(layer_value) orelse return error.InvalidLayer;
//         const __type = enum_from_value(LDtk.LayerType, layer_obj.get("__type")) orelse return error.InvalidType;
//         const autoLayerTiles = if (__type == .AutoLayer) {} else null;
//         const entityInstances = if (__type == .Entities) {} else null;
//         const gridTiles = if (__type == .Tiles) {} else null;
//         const intGridCsv = if (__type == .IntGrid) {} else null;
//         ldtk_layers.appendAssumeCapacity(.{
//             .__cHei = integer(layer_obj.get("__cHei")) orelse return error.InvalidCHei,
//             .__cWid = integer(layer_obj.get("__cWid")) orelse return error.InvalidCWid,
//             .__gridSize = integer(layer_obj.get("__gridSize")) orelse return error.InvalidGridSize,
//             .__identifier = string(layer_obj.get("__identifier")) orelse return error.InvalidIdentifier,
//             .__opacity = float(layer_obj.get("__opacity")) orelse return error.InvalidOpacity,
//             .__pxTotalOffsetX = integer(layer_obj.get("__pxTotalOffsetX")) orelse return error.InvalidTotalOffsetX,
//             .__pxTotalOffsetY = integer(layer_obj.get("__pxTotalOffsetY")) orelse return error.InvalidTotalOffsetY,
//             .__tilesetDefUid = integer(layer_obj.get("__tilesetDefUid")) orelse return error.InvalidTilesetDefUid,
//             .__tilesetRelPath = integer(layer_obj.get("__tilesetRelPath")) orelse return error.InvalidTilesetRelPath,
//             .__type = __type,
//             .autoLayerTiles = autoLayerTiles,
//             .entityInstances = entityInstances,
//             .gridTiles = gridTiles,
//             .iid = string(layer_obj.get("iid")) orelse return error.InvalidIID,
//             .intGridCsv = integer(layer_obj.get("intGridCsv")) orelse return error.InvalidGridCsv,
//             .levelId = integer(layer_obj.get("__cHei")) orelse return error.InvalidCHei,
//             .overrideTilesetUid = integer(layer_obj.get("__cHei")) orelse return error.InvalidCHei,
//             .pxOffsetX = integer(layer_obj.get("__cHei")) orelse return error.InvalidCHei,
//             .pxOffsetY = integer(layer_obj.get("__cHei")) orelse return error.InvalidCHei,
//             .visible = integer(layer_obj.get("__cHei")) orelse return error.InvalidCHei,
//         });
//     }
//     return ldtk_layers.toOwnedSlice();
// }

fn object(value_opt: ?std.json.Value) ?std.json.ObjectMap {
    const value = value_opt orelse return null;
    return switch (value) {
        .Object => |obj| obj,
        else => null,
    };
}

fn array(value_opt: ?std.json.Value) ?std.json.Array {
    const value = value_opt orelse return null;
    return switch (value) {
        .Array => |arr| arr,
        else => null,
    };
}

fn string(value_opt: ?std.json.Value) ?[]const u8 {
    const value = value_opt orelse return null;
    return switch (value) {
        .String => |str| str,
        else => null,
    };
}

fn boolean(value_opt: ?std.json.Value) ?bool {
    const value = value_opt orelse return null;
    return switch (value) {
        .Bool => |b| b,
        else => null,
    };
}

fn integer(value_opt: ?std.json.Value) ?i64 {
    const value = value_opt orelse return null;
    return switch (value) {
        .Integer => |int| int,
        else => null,
    };
}

fn float(value_opt: ?std.json.Value) ?f64 {
    const value = value_opt orelse return null;
    return switch (value) {
        .Float => |float| float,
        else => null,
    };
}

fn enum_from_value(comptime T: type, value_opt: ?std.json.Value) ?T {
    const value = value_opt orelse return null;
    return switch (value) {
        .String => |str| std.meta.stringToEnum(T, str),
        else => null,
    };
}
