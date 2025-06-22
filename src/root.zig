const std = @import("std");
const c = @cImport({
    @cInclude("time.h");
    @cInclude("pthread/pthread.h");
});

var global_logger: Logger = Logger{
    .log_level = null,
    .timestamp = false,
    .threadname = false,
    .nii = false,
};

pub inline fn useThreadName(comptime use: bool) void {
    global_logger.nii = use;
}

pub inline fn withThreadID(comptime threadname: bool) void {
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
    nii: bool,

    const Self = @This();

    inline fn log(self: *Self, comptime src: std.builtin.SourceLocation, comptime level: LogLevel, comptime message: []const u8, args: anytype) void {
        if (self.log_level == null) return;

        if (@intFromEnum(level) >= @intFromEnum(self.log_level.?)) {
            if (self.timestamp and !self.threadname) {
                logWithTime(src, message, level, args);
            } else if (self.timestamp and self.threadname) {
                self.logWithThreadAndTime(src, message, level, args);
            } else if (!self.timestamp and self.threadname) {
                self.logWithThread(src, message, level, args);
            } else {
                logSimple(src, message, level, args);
            }
        }
    }

    inline fn logSimple(comptime src: std.builtin.SourceLocation, comptime message: []const u8, comptime level: LogLevel, args: anytype) void {
        std.debug.print("{s}[{s}]\t{s}:{d} {s} " ++ message ++ "\n", .{ levelIntoColor(level), levelIntoString(level), src.file, src.line, resetColor() } ++ args);
    }

    inline fn logWithThread(self: *Self, comptime src: std.builtin.SourceLocation, comptime message: []const u8, comptime level: LogLevel, args: anytype) void {
        if (self.nii) {
            var buffer: [128]u8 = undefined;
            @memset(&buffer, 0);
            const pthread_t = c.pthread_self();
            _ = c.pthread_getname_np(pthread_t, &buffer, @sizeOf([128]u8));

            std.debug.print("{s}[{s}]\t{s}:{d} TID: {s} {s} " ++ message ++ "\n", .{
                levelIntoColor(level),
                levelIntoString(level),
                src.file,
                src.line,
                buffer[0..buffer.len],
                resetColor(),
            } ++ args);

            return;
        }

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

    inline fn logWithThreadAndTime(self: *Self, comptime src: std.builtin.SourceLocation, comptime message: []const u8, comptime level: LogLevel, args: anytype) void {
        var now: c.time_t = undefined;
        _ = c.time(&now);
        const timeinfo = c.localtime(&now);
        const asctime = c.asctime(timeinfo);
        const slice = cStringToSlice(asctime);
        const fasctime = removeNewline(slice);

        if (self.nii) {
            var buffer: [128]u8 = undefined;
            @memset(&buffer, 0);

            const pthread_t = c.pthread_self();
            _ = c.pthread_getname_np(pthread_t, &buffer, @sizeOf([128]u8));

            std.debug.print("{s}[{s}]\t{s}:{d} TID: {s}  {s}{s} " ++ message ++ "\n", .{
                levelIntoColor(level),
                levelIntoString(level),
                src.file,
                src.line,
                buffer[0..buffer.len],
                fasctime,
                resetColor(),
            } ++ args);

            return;
        }

        const threadid = std.Thread.getCurrentId();

        std.debug.print("{s}[{s}]\t{s}:{d} TID: {d} {s}{s} " ++ message ++ "\n", .{
            levelIntoColor(level),
            levelIntoString(level),
            src.file,
            src.line,
            threadid,
            fasctime,
            resetColor(),
        } ++ args);
    }

    inline fn logWithTime(comptime src: std.builtin.SourceLocation, comptime message: []const u8, comptime level: LogLevel, args: anytype) void {
        var now: c.time_t = undefined;
        _ = c.time(&now);
        const timeinfo = c.localtime(&now);
        const asctime = c.asctime(timeinfo);
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
            .info => "\x1b[35m", // Green
            .warn => "\x1b[33m", // Yellow
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
        for (input) |cc| {
            if (cc != '\n' and cc != '\r') {
                input[j] = cc;
                j += 1;
            }
        }
        return input[0..j];
    }
};
