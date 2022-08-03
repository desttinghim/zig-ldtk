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

    defs: Defs,

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
    intGrid: ?[]IntGrid = null,
    // seed: u64,
    // autoTiles: []AutoTile,
};

const __Type = struct {
    IntGrid, Entities, Tiles, AutoLayer,
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
const FieldInstance = struct {};
/// 2.4.2 Field instance entity reference
/// 2.4.3 Field instance grid point
/// 3. Definitions
const Defs = struct {
    layers: []Layer,
    entities: []Entity,
    tilesets: []Tileset,
    enums: []Enum,
    externalEnums: []ExternalEnum,
};

/// 3.1. Layer definition
/// 3.1.1. Auto-layer rule definition
/// 3.2. Entity definition
/// 3.2.1. Field definition
/// 3.2.2. Tileset rectangle
/// 3.3. Tileset definition
/// 3.4. Enum definition
/// 3.4.1. Enum value definition
const Enum = struct {};
