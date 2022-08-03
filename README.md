# Zig LDtk

This is a single file library for parsing LDtk JSON files.

## Usage

Copy `LDtk.zig` into your project, or add this repository as a git submodule.

```zig
const LDtk = @import("./LDtk.zig");

// ldtk_file should be a `[]const u8` of the file contents
const ldtk = LDtk.parse(allocator, ldtk_file);
defer ldtk.deinit();

// Now you can access your LDtk data through the `ldtk` struct
for (ldtk   .levels) {
    // ...
}
```

## Features

- [x] Parse unseperated LDtk file
- [ ] Parse seperated LDtk files
- [ ] Load unseperated LDtk
- [ ] Load seperated LDtk
- [ ] Supported JSON Schema
    - [x] 1. LDtk Json root
        - [x] 1.1. World Generic
    - [x] 2. Level
        - [x] 2.1. Layer instance
        - [x] 2.2. Tile instance Generic
        - [x] 2.3. Entity instance
        - [ ] 2.4. Field instance
            - [ ] 2.4.2. Field instance entity reference Generic
            - [ ] 2.4.3. Field instance grid point Generic
    - [ ] 3. Definitions
        - [ ] 3.1. Layer definition
            - [ ] 3.1.1. Auto-layer rule definition
        - [ ] 3.2. Entity definition
            - [ ] 3.2.1. Field definition Generic
            - [ ] 3.2.2. Tileset rectangle Generic
        - [ ] 3.3. Tileset definition
        - [ ] 3.4. Enum definition
            - [ ] 3.4.1. Enum value definition
