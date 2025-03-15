const std = @import("std");
const log = @import("root.zig");


pub fn main() !void {
    log.setLogLevel(log.LogLevel.trace);
    log.withTime(true);
    log.withThreadName(true);

    log.trace(@src(), "Tracing!", .{});
    log.debug(@src(), "User got data!", .{});
    log.info(@src(), "Here's info!", .{});
    log.warn(@src(), "Wow! Isn't it a warning???", .{});
    log.fatal(@src(), "HOLY CRAP! This is fatal!", .{});

    log.withThreadName(false);
    log.withTime(true);

    log.trace(@src(), "Tracing lol!", .{});
    log.debug(@src(), "User got data!", .{});
    log.info(@src(), "Here's info!", .{});
    log.warn(@src(), "Wow! Isn't it a warning???", .{});
    log.fatal(@src(), "HOLY CRAP! This is fatal!", .{});

    log.withTime(false);
    log.withThreadName(true);

    log.trace(@src(), "Tracing lol!", .{});
    log.debug(@src(), "User got data!", .{});
    log.info(@src(), "Here's info!", .{});
    log.warn(@src(), "Wow! Isn't it a warning???", .{});
    log.fatal(@src(), "HOLY CRAP! This is fatal!", .{});

    log.withTime(false);
    log.withThreadName(false);

    log.trace(@src(), "Tracing lol!", .{});
    log.debug(@src(), "User got data!", .{});
    log.info(@src(), "Here's info!", .{});
    log.warn(@src(), "Wow! Isn't it a warning???", .{});
    log.fatal(@src(), "HOLY CRAP! This is fatal!", .{});
}
