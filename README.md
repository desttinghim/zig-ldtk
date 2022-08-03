# Zig LDtk

This is a single file library for parsing LDtk JSON files.

## Using

Copy `LDtk.zig` into your project and use like so:

```zig
const LDtk = @import("./LDtk.zig");

// ldtk_file should be a `[]const u8` of the file contents
const ldtk = LDtk.parse(allocator, ldtk_file);
defer ldtk.deinit();

// Now you can access your LDtk data through the `ldtk` struct
for (ldtk.levels) {
    // ...
}
```
Alternatively, add this repository as a git submodule.
