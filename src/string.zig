const std = @import("std");

pub fn FixedString(comptime buffer_size: usize) type {
    return struct {
        const Self = @This();

        buffer: [buffer_size]u8,
        length: usize,

        pub fn init() Self {
            return Self {
                .buffer = undefined,
                .length = 0,
            };
        }

        pub fn append(self: *Self, str: []const u8) void {
            const available = self.buffer.len - self.length;
            const copylen = std.math.Min(available, str.len);
            std.mem.copyForwards(u8, self.buffer[self.length..self.length + copylen], str);
            self.length += copylen;
        }

        pub fn slice(self: *const Self) []const u8 {
            return self.buffer[0..self.length];
        }
    };
}
