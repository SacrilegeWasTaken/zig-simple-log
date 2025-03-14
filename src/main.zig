const std = @import("std");
const log = @import("root.zig");

const Lol = struct {
    kek: comptime_int,
};
const Kek = struct {
    lol: Lol,
};


pub fn main() !void {
    log.setLogLevel(log.LogLevel.trace);

    log.withTime(true);
    log.withThreadName(true);

    log.debug("User got data!");
    log.trace("Tracing!");
    log.info("Here's info!");
    log.warn("Wow! Isn't it a warning???");
    log.fatal("HOLY CRAP! This is fatal!");

    log.withThreadName(false);
    log.withTime(true);

    log.debug("User got data!");
    log.trace("Tracing lol!");
    log.info("Here's info!");
    log.warn("Wow! Isn't it a warning???");
    log.fatal("HOLY CRAP! This is fatal!");

    log.withTime(false);
    log.withThreadName(true);

    log.debug("User got data!");
    log.trace("Tracing lol!");
    log.info("Here's info!");
    log.warn("Wow! Isn't it a warning???");
    log.fatal("HOLY CRAP! This is fatal!");

    log.withTime(false);
    log.withThreadName(false);

    log.debug("User got data!");
    log.trace("Tracing lol!");
    log.info("Here's info!");
    log.warn("Wow! Isn't it a warning???");
    log.fatal("HOLY CRAP! This is fatal!");
}
