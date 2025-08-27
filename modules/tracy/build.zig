const std = @import("std");
const digits2 = std.fmt.digits2;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const tracy_dep = b.dependency("tracy", .{});

    const tracy_enable = b.option(bool, "tracy_enable", "Enable profiling") orelse true;
    const tracy_on_demand = b.option(bool, "tracy_on_demand", "On-demand profiling") orelse false;
    const tracy_callstack: ?u8 = b.option(u8, "tracy_callstack", "Enforce callstack collection for tracy regions");
    const tracy_no_callstack = b.option(bool, "tracy_no_callstack", "Disable all callstack related functionality") orelse false;
    const tracy_no_callstack_inlines = b.option(bool, "tracy_no_callstack_inlines", "Disables the inline functions in callstacks") orelse false;
    const tracy_only_localhost = b.option(bool, "tracy_only_localhost", "Only listen on the localhost interface") orelse false;
    const tracy_no_broadcast = b.option(bool, "tracy_no_broadcast", "Disable client discovery by broadcast to local network") orelse false;
    const tracy_only_ipv4 = b.option(bool, "tracy_only_ipv4", "Tracy will only accept connections on IPv4 addresses (disable IPv6)") orelse false;
    const tracy_no_code_transfer = b.option(bool, "tracy_no_code_transfer", "Disable collection of source code") orelse false;
    const tracy_no_context_switch = b.option(bool, "tracy_no_context_switch", "Disable capture of context switches") orelse false;
    const tracy_no_exit = b.option(bool, "tracy_no_exit", "Client executable does not exit until all profile data is sent to server") orelse false;
    const tracy_no_sampling = b.option(bool, "tracy_no_sampling", "Disable call stack sampling") orelse false;
    const tracy_no_verify = b.option(bool, "tracy_no_verify", "Disable zone validation for C API") orelse false;
    const tracy_no_vsync_capture = b.option(bool, "tracy_no_vsync_capture", "Disable capture of hardware Vsync events") orelse false;
    const tracy_no_frame_image = b.option(bool, "tracy_no_frame_image", "Disable the frame image support and its thread") orelse false;
    // NOTE For some reason system tracing on zig projects crashes tracy, will need to investigate
    const tracy_no_system_tracing = b.option(bool, "tracy_no_system_tracing", "Disable systrace sampling") orelse true;
    const tracy_delayed_init = b.option(bool, "tracy_delayed_init", "Enable delayed initialization of the library (init on first call)") orelse false;
    const tracy_manual_lifetime = b.option(bool, "tracy_manual_lifetime", "Enable the manual lifetime management of the profile") orelse false;
    const tracy_fibers = b.option(bool, "tracy_fibers", "Enable fibers support") orelse false;
    const tracy_no_crash_handler = b.option(bool, "tracy_no_crash_handler", "Disable crash handling") orelse false;
    const tracy_timer_fallback = b.option(bool, "tracy_timer_fallback", "Use lower resolution timers") orelse false;
    const shared = b.option(bool, "shared", "Build the tracy client as a shared libary") orelse false;

    const options = b.addOptions();
    options.addOption(bool, "tracy_enable", tracy_enable);
    options.addOption(bool, "tracy_on_demand", tracy_on_demand);
    options.addOption(?u8, "tracy_callstack", tracy_callstack);
    options.addOption(bool, "tracy_no_callstack", tracy_no_callstack);
    options.addOption(bool, "tracy_no_callstack_inlines", tracy_no_callstack_inlines);
    options.addOption(bool, "tracy_only_localhost", tracy_only_localhost);
    options.addOption(bool, "tracy_no_broadcast", tracy_no_broadcast);
    options.addOption(bool, "tracy_only_ipv4", tracy_only_ipv4);
    options.addOption(bool, "tracy_no_code_transfer", tracy_no_code_transfer);
    options.addOption(bool, "tracy_no_context_switch", tracy_no_context_switch);
    options.addOption(bool, "tracy_no_exit", tracy_no_exit);
    options.addOption(bool, "tracy_no_sampling", tracy_no_sampling);
    options.addOption(bool, "tracy_no_verify", tracy_no_verify);
    options.addOption(bool, "tracy_no_vsync_capture", tracy_no_vsync_capture);
    options.addOption(bool, "tracy_no_frame_image", tracy_no_frame_image);
    options.addOption(bool, "tracy_no_system_tracing", tracy_no_system_tracing);
    options.addOption(bool, "tracy_delayed_init", tracy_delayed_init);
    options.addOption(bool, "tracy_manual_lifetime", tracy_manual_lifetime);
    options.addOption(bool, "tracy_fibers", tracy_fibers);
    options.addOption(bool, "tracy_no_crash_handler", tracy_no_crash_handler);
    options.addOption(bool, "tracy_timer_fallback", tracy_timer_fallback);
    options.addOption(bool, "shared", shared);

    var flags: std.ArrayList([]const u8) = .empty;
    if (tracy_enable) {
        try flags.append(b.allocator, "-DTRACY_ENABLE");
    }
    if (tracy_on_demand) {
        try flags.append(b.allocator, "-DTRACY_ON_DEMAND");
    }
    if (tracy_callstack) |depth| {
        try flags.append(b.allocator, "-DTRACY_CALLSTACK=" ++ digits2(depth));
    }
    if (tracy_no_callstack)
        try flags.append(b.allocator, "-DTRACY_NO_CALLSTACK");
    if (tracy_no_callstack_inlines)
        try flags.append(b.allocator, "-DTRACY_NO_CALLSTACK_INLINES");
    if (tracy_only_localhost)
        try flags.append(b.allocator, "-DTRACY_ONLY_LOCALHOST");
    if (tracy_no_broadcast)
        try flags.append(b.allocator, "-DTRACY_NO_BROADCAST");
    if (tracy_only_ipv4)
        try flags.append(b.allocator, "-DTRACY_ONLY_IPV4");
    if (tracy_no_code_transfer)
        try flags.append(b.allocator, "-DTRACY_NO_CODE_TRANSFER");
    if (tracy_no_context_switch)
        try flags.append(b.allocator, "-DTRACY_NO_CONTEXT_SWITCH");
    if (tracy_no_exit)
        try flags.append(b.allocator, "-DTRACY_NO_EXIT");
    if (tracy_no_sampling)
        try flags.append(b.allocator, "-DTRACY_NO_SAMPLING");
    if (tracy_no_verify)
        try flags.append(b.allocator, "-DTRACY_NO_VERIFY");
    if (tracy_no_vsync_capture)
        try flags.append(b.allocator, "-DTRACY_NO_VSYNC_CAPTURE");
    if (tracy_no_frame_image)
        try flags.append(b.allocator, "-DTRACY_NO_FRAME_IMAGE");
    if (tracy_no_system_tracing)
        try flags.append(b.allocator, "-DTRACY_NO_SYSTEM_TRACING");
    if (tracy_delayed_init)
        try flags.append(b.allocator, "-DTRACY_DELAYED_INIT");
    if (tracy_manual_lifetime)
        try flags.append(b.allocator, "-DTRACY_MANUAL_LIFETIME");
    if (tracy_fibers)
        try flags.append(b.allocator, "-DTRACY_FIBERS");
    if (tracy_no_crash_handler)
        try flags.append(b.allocator, "-DTRACY_NO_CRASH_HANDLER");
    if (tracy_timer_fallback)
        try flags.append(b.allocator, "-DTRACY_TIMER_FALLBACK");
    if (shared and target.result.os.tag == .windows)
        try flags.append(b.allocator, "-DTRACY_EXPORTS");

    const translate_c = b.addTranslateC(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = tracy_dep.path("public/tracy/TracyC.h"),
    });

    for (flags.items) |flag| {
        translate_c.defineCMacroRaw(flag[2..]);
    }

    const tracy_module = b.addModule("tracy", .{
        .root_source_file = b.path("./src/tracy.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "options", .module = options.createModule() },
            .{ .name = "c", .module = translate_c.createModule() },
        },
        .link_libcpp = true,
    });

    tracy_module.addCSourceFile(.{
        .file = tracy_dep.path("./public/TracyClient.cpp"),
        .flags = flags.items,
    });

    if (target.result.os.tag == .windows) {
        tracy_module.linkSystemLibrary("dbghelp", .{});
        tracy_module.linkSystemLibrary("ws2_32", .{});
    }

    tracy_module.addIncludePath(tracy_dep.path("./public"));

    const tracy_lib = b.addLibrary(.{
        .linkage = if (shared) .dynamic else .static,
        .name = "tracy",
        .root_module = tracy_module,
    });

    inline for (tracy_header_files) |header| {
        tracy_lib.installHeader(tracy_dep.path("public/" ++ header), header);
    }

    b.installArtifact(tracy_lib);
}

const tracy_header_files = [_][]const u8{
    "tracy/TracyC.h",
    "tracy/Tracy.hpp",
    "tracy/TracyD3D11.hpp",
    "tracy/TracyD3D12.hpp",
    "tracy/TracyLua.hpp",
    "tracy/TracyOpenCL.hpp",
    "tracy/TracyOpenGL.hpp",
    "tracy/TracyVulkan.hpp",

    "client/TracyArmCpuTable.hpp",
    "client/TracyCallstack.h",
    "client/TracyCallstack.hpp",
    "client/tracy_concurrentqueue.h",
    "client/TracyCpuid.hpp",
    "client/TracyDebug.hpp",
    "client/TracyDxt1.hpp",
    "client/TracyFastVector.hpp",
    "client/TracyKCore.hpp",
    "client/TracyLock.hpp",
    "client/TracyProfiler.hpp",
    "client/TracyRingBuffer.hpp",
    "client/tracy_rpmalloc.hpp",
    "client/TracyScoped.hpp",
    "client/tracy_SPSCQueue.h",
    "client/TracyStringHelpers.hpp",
    "client/TracySysPower.hpp",
    "client/TracySysTime.hpp",
    "client/TracySysTrace.hpp",
    "client/TracyThread.hpp",

    "common/TracyAlign.hpp",
    "common/TracyAlloc.hpp",
    "common/TracyApi.h",
    "common/TracyColor.hpp",
    "common/TracyForceInline.hpp",
    "common/TracyMutex.hpp",
    "common/TracyProtocol.hpp",
    "common/TracyQueue.hpp",
    "common/TracySocket.hpp",
    "common/TracyStackFrames.hpp",
    "common/TracySystem.hpp",
    "common/TracyUwp.hpp",
    "common/TracyVersion.hpp",
    "common/TracyYield.hpp",
    "common/tracy_lz4.hpp",
    "common/tracy_lz4hc.hpp",
};
