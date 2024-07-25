const std = @import("std");

pub fn main() void {
    var filler = CenterFiller(20).init('-');
    const writer = filler.writer();

    writer.writeAll("Yo!");
    std.debug.print("{s}\n", .{filler.buf});

    writer.writeAll("Hey!");
    std.debug.print("{s}\n", .{filler.buf});

    writer.writeAll("Hello there!");
    std.debug.print("{s}\n", .{filler.buf});
}

pub fn CenterFiller(comptime size: usize) type {
    return struct {
        const Self = @This();
        buf: [size]u8 = undefined,

        pub fn init(data: u8) Self {
            return .{ .buf = [_]u8{data} ** size };
        }

        pub fn writeAll(context: *const anyopaque, data: []const u8) void {
            const self: *Self = @constCast(@alignCast(@ptrCast(context)));
            std.debug.assert(data.len <= self.buf.len);

            const offset = (self.buf.len - data.len) / 2;
            std.mem.copyForwards(u8, self.buf[offset..], data);
        }

        pub fn writer(self: *Self) Writer {
            return .{ .context = self, .writeAllFn = writeAll };
        }
    };
}

pub const Writer = struct {
    const Self = @This();
    context: *const anyopaque,
    writeAllFn: *const fn (context: *const anyopaque, data: []const u8) void,

    pub fn writeAll(self: Self, data: []const u8) void {
        self.writeAllFn(self.context, data);
    }
};
