const std = @import("std");
const log = @import("root.zig");
const c = @cImport({
    @cInclude("time.h");
    @cInclude("pthread/pthread.h");
});

pub fn main() !void {
    var buffer: [128]u8 = undefined;
    @memset(&buffer, 0);

    const mainThreadName = "MainThread";
    const setNameResult = c.pthread_setname_np(mainThreadName);
    if (setNameResult != 0) {
        std.debug.print("Failed to set main thread name: {}\n", .{setNameResult});
        return;
    }

    log.setLogLevel(log.LogLevel.trace);
    log.withTime(true);
    log.withThreadID(true);
    log.useThreadName(true);

    log.trace(@src(), "Tracing!", .{});
    log.debug(@src(), "User got data!", .{});
    log.info(@src(), "Here's info!", .{});
    log.warn(@src(), "Wow! Isn't it a warning???", .{});
    log.fatal(@src(), "HOLY CRAP! This is fatal!", .{});

    log.withThreadID(false);
    log.withTime(true);

    log.trace(@src(), "Tracing lol!", .{});
    log.debug(@src(), "User got data!", .{});
    log.info(@src(), "Here's info!", .{});
    log.warn(@src(), "Wow! Isn't it a warning???", .{});
    log.fatal(@src(), "HOLY CRAP! This is fatal!", .{});

    log.withTime(false);
    log.withThreadID(true);

    log.trace(@src(), "Tracing lol!", .{});
    log.debug(@src(), "User got data!", .{});
    log.info(@src(), "Here's info!", .{});
    log.warn(@src(), "Wow! Isn't it a warning???", .{});
    log.fatal(@src(), "HOLY CRAP! This is fatal!", .{});

    log.withTime(false);
    log.withThreadID(false);

    log.trace(@src(), "Tracing lol!", .{});
    log.debug(@src(), "User got data!", .{});
    log.info(@src(), "Here's info!", .{});
    log.warn(@src(), "Wow! Isn't it a warning???", .{});
    log.fatal(@src(), "HOLY CRAP! This is fatal!", .{});
}
