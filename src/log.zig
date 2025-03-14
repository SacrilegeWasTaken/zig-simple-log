const std = @import("std");
const ctime = @cImport({
    @cInclude("time.h");
});

pub var global_logger: Logger = Logger{
    .log_level = null,
    .timestamp = false,
    .threadname = false,
};


pub const LogLevel = enum {
    trace,
    debug,
    info,
    warn,
    fatal,
};

const Logger = struct {
    log_level: ?LogLevel,
    timestamp: bool,
    threadname: bool,

    const Self = @This();

    fn log(self: *Self, comptime level: LogLevel, comptime message: []const u8) void {
        if (self.log_level == null) return;

        if (@intFromEnum(level) >= @intFromEnum(self.log_level.?)) {

            if (self.timestamp) {
                var now: ctime.time_t = undefined;
                _ = ctime.time(&now);
                const timeinfo = ctime.localtime(&now);
                const asctime = ctime.asctime(timeinfo);
                const slice = cStringToSlice(asctime);
                const fasctime = removeNewline(slice);
                std.debug.print("{s}[{s}]\t{s}  {s} {s}\n", .{
                    levelIntoColor(level),
                    levelIntoString(level),
                    fasctime,
                    resetColor(),
                    message
                });
                return;
            }
            std.debug.print("{s}[{s}]{s}\t {s}\n", .{
                levelIntoColor(level),
                levelIntoString(level),
                resetColor(),
                message
            });
        }
    }

    fn levelIntoString(comptime level: LogLevel) []const u8 {
        return switch (level) {
            .trace => "TRACE",
            .debug => "DEBUG",
            .info => "INFO",
            .warn => "WARN",
            .fatal => "FATAL",
        };
    }

    fn levelIntoColor(comptime level: LogLevel) []const u8 {
        return switch (level) {
            .trace => "\x1b[34m", // Blue
            .debug => "\x1b[36m", // Cyan
            .info => "\x1b[32m",  // Green
            .warn => "\x1b[33m",  // Yellow
            .fatal => "\x1b[31m", // Red
        };
    }

    fn resetColor() []const u8 {
        return "\x1b[0m";
    }

    fn cStringToSlice(c_string: [*c]u8) []u8 {
        var len: usize = 0;
        while (c_string[len] != 0) {
            len += 1;
        }
        return c_string[0..len];
    }

    fn removeNewline(input: []u8) []u8 {
        var j: usize = 0;
        for (input) |c| {
            if (c != '\n' and c != '\r') {
                input[j] = c;
                j += 1;
            }
        }
        return input[0..j];
    }

};

pub fn witnThreadName(comptime threadname: bool) void {
    global_logger.threadname = threadname;
}

pub fn withTime(comptime timestamp: bool) void {
    global_logger.timestamp = timestamp;
}

pub fn setLogLevel(comptime level: ?LogLevel) void {
    global_logger.log_level = level;
}

pub fn trace(comptime message: []const u8) void {
    global_logger.log(LogLevel.trace, message);
}

pub fn debug(comptime message: []const u8) void {
    global_logger.log(LogLevel.debug, message);
}

pub fn info(comptime message: []const u8) void {
    global_logger.log(LogLevel.info, message);
}

pub fn warn(comptime message: []const u8) void {
    global_logger.log(LogLevel.warn, message);
}

pub fn fatal(comptime message: []const u8) void {
    global_logger.log(LogLevel.fatal, message);
}
