const std = @import("std");
const ctime = @cImport({
    @cInclude("time.h");
});

var global_logger: Logger = Logger{
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

    inline fn log(
        self: *Self,
        comptime src: std.builtin.SourceLocation,
        comptime level: LogLevel,
        comptime message: []const u8,
        args: anytype
    ) void
    {
        if (self.log_level == null) return;

        if (@intFromEnum(level) >= @intFromEnum(self.log_level.?)) {

            if (self.timestamp and !self.threadname) {
                logWithTime(src, message, level, args);
            }
            else if(self.timestamp and self.threadname) {
                logWithThreadAndTime(src, message, level, args);
            }
            else if(!self.timestamp and self.threadname) {
                logWithThread(src, message, level, args);
            }
            else {
                logSimple(src, message, level, args);
            }

        }
    }


    inline fn logSimple(
        comptime src: std.builtin.SourceLocation,
        comptime message: []const u8,
        comptime level: LogLevel,
        args: anytype
    ) void
    {
        std.debug.print("{s}[{s}]\t{s}:{d} {s} " ++ message ++ "\n", .{
            levelIntoColor(level),
            levelIntoString(level),
            src.file,
            src.line,
            resetColor()
        } ++ args);
    }


    inline fn logWithThread(
        comptime src: std.builtin.SourceLocation,
        comptime message: []const u8,
        comptime level: LogLevel,
        args: anytype
    ) void
    {
        const threadname = std.Thread.getCurrentId();
        std.debug.print("{s}[{s}]\t{s}:{d} TID: {d}{s} " ++ message ++ "\n", .{
            levelIntoColor(level),
            levelIntoString(level),
            src.file,
            src.line,
            threadname,
            resetColor(),
        } ++ args);
    }


    inline fn logWithThreadAndTime(
        comptime src: std.builtin.SourceLocation,
        comptime message: []const u8,
        comptime level: LogLevel,
        args: anytype
    ) void
    {
        var now: ctime.time_t = undefined;
        _ = ctime.time(&now);
        const timeinfo = ctime.localtime(&now);
        const asctime = ctime.asctime(timeinfo);
        const slice = cStringToSlice(asctime);
        const fasctime = removeNewline(slice);
        const threadname = std.Thread.getCurrentId();
        std.debug.print("{s}[{s}]\t{s}:{d} TID: {d}\t{s}{s} " ++ message ++ "\n", .{
            levelIntoColor(level),
            levelIntoString(level),
            src.file,
            src.line,
            threadname,
            fasctime,
            resetColor(),
        } ++ args);
    }


    inline fn logWithTime(
        comptime src: std.builtin.SourceLocation,
        comptime message: []const u8,
        comptime level: LogLevel,
        args: anytype
    ) void
    {
        var now: ctime.time_t = undefined;
        _ = ctime.time(&now);
        const timeinfo = ctime.localtime(&now);
        const asctime = ctime.asctime(timeinfo);
        const slice = cStringToSlice(asctime);
        const fasctime = removeNewline(slice);
        std.debug.print("{s}[{s}]\t{s}:{d} {s}{s} " ++ message ++ "\n", .{
            levelIntoColor(level),
            levelIntoString(level),
            src.file,
            src.line,
            fasctime,
            resetColor(),
        } ++ args);
    }

    inline fn levelIntoString(comptime level: LogLevel) []const u8 {
        return switch (level) {
            .trace => "TRACE",
            .debug => "DEBUG",
            .info => "INFO",
            .warn => "WARN",
            .fatal => "FATAL",
        };
    }

    inline fn levelIntoColor(comptime level: LogLevel) []const u8 {
        return switch (level) {
            .trace => "\x1b[34m", // Blue
            .debug => "\x1b[36m", // Cyan
            .info => "\x1b[35m",  // Green
            .warn => "\x1b[33m",  // Yellow
            .fatal => "\x1b[31m", // Red
        };
    }

    inline fn resetColor() []const u8 {
        return "\x1b[0m";
    }

    inline fn cStringToSlice(c_string: [*c]u8) []u8 {
        var len: usize = 0;
        while (c_string[len] != 0) {
            len += 1;
        }
        return c_string[0..len];
    }

    inline fn removeNewline(input: []u8) []u8 {
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

pub inline fn withThreadName(comptime threadname: bool) void {
    global_logger.threadname = threadname;
}

pub inline fn withTime(comptime timestamp: bool) void {
    global_logger.timestamp = timestamp;
}

pub inline fn setLogLevel(comptime level: ?LogLevel) void {
    global_logger.log_level = level;
}

pub inline fn trace(comptime src: std.builtin.SourceLocation, comptime message: []const u8, args: anytype) void {
    global_logger.log(src, LogLevel.trace, message, args);
}

pub inline fn debug(comptime src: std.builtin.SourceLocation, comptime message: []const u8, args: anytype) void {
    global_logger.log(src, LogLevel.debug, message, args);
}

pub inline fn info(comptime src: std.builtin.SourceLocation, comptime message: []const u8, args: anytype) void {
    global_logger.log(src, LogLevel.info, message, args);
}

pub inline fn warn(comptime src: std.builtin.SourceLocation, comptime message: []const u8, args: anytype) void {
    global_logger.log(src, LogLevel.warn, message, args);
}

pub inline fn fatal(comptime src: std.builtin.SourceLocation, comptime message: []const u8, args: anytype) void {
    global_logger.log(src, LogLevel.fatal, message, args);
}
