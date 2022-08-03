const std = @import("std");

pub fn parse(allocator: std.mem.Allocator, json_string: []const u8) !Root {
    @setEvalBranchQuota(10_0000);
    var tokens = std.json.TokenStream.init(json_string);
    const root = try std.json.parse(Root, &tokens, .{ .allocator = allocator });
    return root;
}

pub fn parseFree(allocator: std.mem.Allocator, root: Root) void {
    std.json.parseFree(Root, root, .{ .allocator = allocator });
}

/// 1. LDtk Json root
const Root = struct {
    __header__: __Header__,

    name: []const u8,
    jsonVersion: u64,
    defaultPivotX: f64,
    defaultPivotY: f64,
    defaultGridSize: u64,
    bgColor: []const u8,
    nextUid: u64,

    defs: Definitions,

    levels: []Level,

    worldGridHeight: ?u64 = null,
    worldGridWidth: ?u64 = null,
    worldLayout: ?WorldLayout = null,
    worlds: []World,
};

const __Header__ = struct {
    fileType: []const u8,
    app: []const u8,
    appAuthor: []const u8,
    appVersion: []const u8,
    url: []const u8,
};

/// 1.1. World
const World = struct {
    identifier: []const u8,
    iid: []const u8,
    levels: []Level,
    worldGridHeight: u64,
    worldGridWidth: u64,
    worldLayout: WorldLayout,
};

const WorldLayout = enum {
    Free,
    GridVania,
    LinearHorizontal,
    LinearVertical,
};

/// 2. Level
const Level = struct {
    __bgColor: []const u8,
    __bgPos: ?struct {
        cropRect: [4]f64,
        scale: [2]f64,
        topLeftPx: [2]i64,
    },
    __neighbours: []struct {
        dir: []const u8,
        levelIid: []const u8,
        levelUid: ?u64 = null,
    },
    bgRelPath: ?[]const u8,
    externalRelPath: ?[]const u8,
    fieldInstances: []FieldInstance,
    identifier: []const u8,
    iid: []const u8,
    layerInstances: ?[]LayerInstance,
    pxHei: u64,
    pxWid: u64,
    uid: u64,
    worldDepth: i64,
    worldX: i64,
    worldY: i64,
};

/// 2.1. Layer instance
const LayerInstance = struct {
    __cHei: u64,
    __cWid: u64,
    __gridSize: u64,
    __identifier: []const u8,
    __opacity: f64,
    __pxTotalOffsetX: i64,
    __pxTotalOffsetY: i64,
    __tilesetDefUid: ?u64,
    __tilesetRelPath: ?[]const u8,
    __type: []const u8,
    autoLayerTiles: []TileInstance,
    entityInstances: []EntityInstance,
    gridTiles: []TileInstance,
    iid: []const u8,
    intGridCsv: []u64,
    layerDefUid: u64,
    levelId: u64,
    overrideTilesetUid: ?u64,
    pxOffsetX: u64,
    pxOffsetY: u64,
    visible: bool,
    /// WARNING: this deprecated value is no longer exported since version 1.0.0
    /// Replaced by: intGridCsv
    intGrid: ?[][]const u8 = null,
    // seed: u64,
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
    t: u64,
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
    defUid: u64,
    fieldInstances: []FieldInstance,
    height: u64,
    iid: []const u8,
    px: [2]i64,
    width: u64,
};

/// 2.4. Field Instance
const FieldInstance = struct {
    __identifier: []const u8,
    __tile: ?TilesetRectangle,
    // TODO: type and value have many possible values and are not always strings.
    // Figure out if we can use JSON.parse for this
    __type: []const u8,
    __value: []const u8,
    defUid: u64,
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
    autoSourceLayerDefUid: ?u64,
    displayOpacity: f64,
    gridSize: u64,
    identifier: []const u8,
    intGridValues: []struct { color: []const u8, identifier: ?[]const u8, value: u64 },
    parallaxFactorX: f64,
    parallaxFactorY: f64,
    parallaxScaling: bool,
    pxOffsetX: i64,
    pxOffsetY: i64,
    /// Reference to the default Tileset UID used by this layer definition.
    /// WARNING: some layer instances might use a different tileset. So most of the time, you should probably use the __tilesetDefUid value found in layer instances.
    /// NOTE: since version 1.0.0, the old autoTilesetDefUid was removed and merged into this value.
    tilesetDefUid: ?u64,
    /// Unique Int identifier
    uid: u64,
    /// WARNING: this deprecated value will be removed completely on version 1.2.0+
    /// Replaced by: tilesetDefUid
    autoTilesetDefUid: ?u64 = null,
};

/// 3.1.1. Auto-layer rule definition
const AutoLayerRuleDefinition = opaque {};

/// 3.2. Entity definition
const EntityDefinition = struct {
    color: []const u8,
    height: u64,
    identifier: []const u8,
    nineSliceBorders: [4]i64,
    pivotX: f64,
    pivotY: f64,
    tileRect: TilesetRectangle,
    tileRenderMode: enum { Cover, FitInside, Repeat, Stretch, FullSizeCropped, FullSizeUncropped, NineSlice },
    tilesetId: ?u64,
    uid: u64,
    width: u64,
    /// WARNING: this deprecated value will be removed completely on version 1.2.0+
    /// Replaced by tileRect
    tileId: ?u64 = null,
};

/// 3.2.1. Field definition
const FieldDefinition = []const u8;

/// 3.2.2. Tileset rectangle
const TilesetRectangle = struct {
    h: u64,
    tilesetUid: u64,
    w: u64,
    x: i64,
    y: i64,
};

/// 3.3. Tileset definition
const TilesetDefinition = struct {
    __cHei: u64,
    __cWid: u64,
    customData: []struct {
        data: []const u8,
        tileId: u64,
    },
    embedAtlas: ?enum { LdtkIcons },
    enumTags: []struct {
        enumValueId: []const u8,
        tileIds: []u64,
    },
    identifier: []const u8,
    padding: i64,
    pxHei: u64,
    pxWid: u64,
    relPath: ?[]const u8,
    spacing: i64,
    tags: [][]const u8,
    tagsSourceEnumUid: ?u64,
    tileGridSize: u64,
    uid: u64,
};

/// 3.4. Enum definition
const EnumDefinition = struct {
    externalRelPath: ?[]const u8,
    iconTilesetUid: ?u64,
    identifier: []const u8,
    tags: [][]const u8,
    uid: u64,
    values: []EnumValueDefinition,
};

/// 3.4.1. Enum value definition
const EnumValueDefinition = struct {
    __tileSrcRect: ?[4]i64,
    color: u64,
    id: []const u8,
    tileId: ?u64,
};
