const std = @import("std");

// pub fn parse(parser: *std.json.Parser, json_string: []const u8) !std.json.Value {
//     const value_tree = try parser.parse(json_string);
//     value_tree.root.dump();

//     const root_obj = switch (value_tree.root) {
//         .Object => |obj| obj,
//         else => return error.InvalidRoot,
//     };
//     _ = root_obj;
//     // const root = Root {
//     //     name: root_obj.get("name") orelse error.InvalidRoot,
//     //     version: root_obj.get("jsonVersion") orelse error.InvalidRoot,
//     //     defaultPivotX: root_obj.get("defaultPivotX") orelse error.InvalidRoot,
//     //     defaultPivotY: root_obj.get("defaultPivotY") orelse error.InvalidRoot,
//     //     defaultGridSize: root_obj.get("defaultGridSize") orelse error.InvalidRoot,
//     //     name: root_obj.get("name") orelse error.InvalidRoot,
//     // };

//     return Root{};
// }

/// 1. LDtk Json root
pub const Root = struct {
    bgColor: []const u8,
    defs: ?Definitions = null,
    externalLevels: bool,
    jsonVersion: []const u8,
    levels: []Level,
    worldGridHeight: ?i64 = null,
    worldGridWidth: ?i64 = null,
    worldLayout: ?WorldLayout = null,
    worlds: ?[]World = null,
};

/// 1.1. World
pub const World = struct {
    identifier: []const u8,
    iid: []const u8,
    levels: []Level,
    worldGridHeight: i64,
    worldGridWidth: i64,
    worldLayout: WorldLayout,
};

pub const WorldLayout = enum {
    Free,
    GridVania,
    LinearHorizontal,
    LinearVertical,
};

/// 2. Level
pub const Level = struct {
    __bgColor: ?[]const u8,
    __bgPos: ?struct {
        cropRect: [4]f64,
        scale: [2]f64,
        topLeftPx: [2]i64,
    },
    __neighbours: []Neighbour,
    bgRelPath: ?[]const u8,
    externalRelPath: ?[]const u8,
    fieldInstances: []FieldInstance,
    identifier: []const u8,
    iid: []const u8,
    layerInstances: ?[]LayerInstance,
    pxHei: i64,
    pxWid: i64,
    uid: i64,
    worldDepth: i64,
    worldX: i64,
    worldY: i64,
};

pub const Neighbour = struct {
    dir: []const u8,
    levelIid: []const u8,
    levelUid: ?i64 = null,
};

/// 2.1. Layer instance
const LayerInstance = struct {
    __cHei: i64,
    __cWid: i64,
    __gridSize: i64,
    __identifier: []const u8,
    __opacity: f64,
    __pxTotalOffsetX: i64,
    __pxTotalOffsetY: i64,
    __tilesetDefUid: ?i64,
    __tilesetRelPath: ?[]const u8,
    __type: []const u8,
    autoLayerTiles: []TileInstance,
    entityInstances: []EntityInstance,
    gridTiles: []TileInstance,
    iid: []const u8,
    intGridCsv: []i64,
    layerDefUid: i64,
    levelId: i64,
    overrideTilesetUid: ?i64,
    pxOffsetX: i64,
    pxOffsetY: i64,
    visible: bool,
    /// WARNING: this deprecated value is no longer exported since version 1.0.0
    /// Replaced by: intGridCsv
    intGrid: ?[][]const u8 = null,
    // seed: i64,
    // autoTiles: []AutoTile,
};

const __Type = enum {
    IntGrid,
    Entities,
    Tiles,
    AutoLayer,
};

/// 2.2. Tile instance
const TileInstance = struct {
    f: FlipBits,
    px: [2]i64,
    src: [2]i64,
    t: i64,
};

const FlipBits = enum(u4) {
    NoFlip = 0,
    XFlip = 1,
    YFlip = 2,
    XYFlip = 3,
};

/// 2.3. Entity instance
const EntityInstance = struct {
    __grid: [2]i64,
    __identifier: []const u8,
    __pivot: [2]f32,
    __smartColor: []const u8,
    __tags: [][]const u8,
    __tile: ?TilesetRectangle,
    defUid: i64,
    fieldInstances: []FieldInstance,
    height: i64,
    iid: []const u8,
    px: [2]i64,
    width: i64,
};

/// 2.4. Field Instance
pub const FieldInstance = struct {
    __identifier: []const u8,
    __tile: ?TilesetRectangle,
    // TODO: type and value have many possible values and are not always strings.
    // Figure out if we can use JSON.parse for this
    __type: []const u8,
    __value: []const u8,
    defUid: i64,
};

const FieldType = union(enum) {
    Int,
    Float,
    String,
    Enum: []const u8,
    Bool,
};

/// 2.4.2 Field instance entity reference
const FieldInstanceRef = struct {
    entityIid: []const u8,
    layerIid: []const u8,
    levelIid: []const u8,
    worldIid: []const u8,
};

/// 2.4.3 Field instance grid point
const FiledInstanceGridPoint = struct {
    cx: i64,
    cy: i64,
};

/// 3. Definitions
/// Only 2 definitions you might need here are Tilesets and Enums
const Definitions = struct {
    entities: []EntityDefinition,

    enums: []EnumDefinition,
    /// Same as enums, excepts they have a relPath to point to an external source file
    externalEnums: []EnumDefinition,
    layers: []LayerDefinition,
    /// All custom fields available to all levels
    levelFields: []FieldDefinition,
    /// All tilesets
    tilesets: []TilesetDefinition,
};

/// 3.1. Layer definition
const LayerDefinition = struct {
    __type: enum {
        IntGrid,
        Entities,
        Tiles,
        AutoLayer,
    },
    autoSourceLayerDefUid: ?i64,
    displayOpacity: f64,
    gridSize: i64,
    identifier: []const u8,
    intGridValues: []struct { color: []const u8, identifier: ?[]const u8, value: i64 },
    parallaxFactorX: f64,
    parallaxFactorY: f64,
    parallaxScaling: bool,
    pxOffsetX: i64,
    pxOffsetY: i64,
    /// Reference to the default Tileset UID used by this layer definition.
    /// WARNING: some layer instances might use a different tileset. So most of the time, you should probably use the __tilesetDefUid value found in layer instances.
    /// NOTE: since version 1.0.0, the old autoTilesetDefUid was removed and merged into this value.
    tilesetDefUid: ?i64,
    /// Unique Int identifier
    uid: i64,
    /// WARNING: this deprecated value will be removed completely on version 1.2.0+
    /// Replaced by: tilesetDefUid
    autoTilesetDefUid: ?i64 = null,
};

/// 3.1.1. Auto-layer rule definition
const AutoLayerRuleDefinition = opaque {};

/// 3.2. Entity definition
const EntityDefinition = struct {
    color: []const u8,
    height: i64,
    identifier: []const u8,
    nineSliceBorders: [4]i64,
    pivotX: f64,
    pivotY: f64,
    tileRect: TilesetRectangle,
    tileRenderMode: enum { Cover, FitInside, Repeat, Stretch, FullSizeCropped, FullSizeUncropped, NineSlice },
    tilesetId: ?i64,
    uid: i64,
    width: i64,
    /// WARNING: this deprecated value will be removed completely on version 1.2.0+
    /// Replaced by tileRect
    tileId: ?i64 = null,
};

/// 3.2.1. Field definition
const FieldDefinition = []const u8;

/// 3.2.2. Tileset rectangle
const TilesetRectangle = struct {
    h: i64,
    tilesetUid: i64,
    w: i64,
    x: i64,
    y: i64,
};

/// 3.3. Tileset definition
const TilesetDefinition = struct {
    __cHei: i64,
    __cWid: i64,
    customData: []struct {
        data: []const u8,
        tileId: i64,
    },
    embedAtlas: ?enum { LdtkIcons },
    enumTags: []struct {
        enumValueId: []const u8,
        tileIds: []i64,
    },
    identifier: []const u8,
    padding: i64,
    pxHei: i64,
    pxWid: i64,
    relPath: ?[]const u8,
    spacing: i64,
    tags: [][]const u8,
    tagsSourceEnumUid: ?i64,
    tileGridSize: i64,
    uid: i64,
};

/// 3.4. Enum definition
const EnumDefinition = struct {
    externalRelPath: ?[]const u8,
    iconTilesetUid: ?i64,
    identifier: []const u8,
    tags: [][]const u8,
    uid: i64,
    values: []EnumValueDefinition,
};

/// 3.4.1. Enum value definition
const EnumValueDefinition = struct {
    __tileSrcRect: ?[4]i64,
    color: i64,
    id: []const u8,
    tileId: ?i64,
};
