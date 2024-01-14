const std = @import("std");
const pybadge = @import("pybadge");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(.{
        .name = "cart",
        .root_source_file = .{ .path = "blobs.zig" },
        .target = .{ .cpu_arch = .wasm32, .os_tag = .freestanding },
        .optimize = optimize,
    });

    lib.import_memory = true;
    lib.initial_memory = 65536;
    lib.max_memory = 65536;
    lib.stack_size = 14752;

    // Export WASM-4 symbols
    lib.export_symbol_names = &[_][]const u8{ "start", "update" };

    lib.addModule("wasm4", b.createModule(.{ .source_file = .{ .path = "wasm4.zig" } }));

    b.installArtifact(lib);

    const cart = pybadge.addCart(b.dependency("pybadge", .{}), b, .{
        .name = "blobs",
        .source_file = .{ .path = "blobs.zig" },
        .optimize = optimize,
    });
    pybadge.installCart(b, cart);
}
