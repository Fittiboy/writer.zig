const std = @import("std");

pub fn main() void {
    var filler = Filler(20).init('-');
    const writer = filler.writer();
    writer.writeAll("Hello there!");
    std.debug.print("{s}\n", .{filler.buf});
}

pub fn Filler(comptime size: usize) type {
    return struct {
        const Self = @This();
        buf: [size]u8 = undefined,

        pub fn init(data: u8) Self {
            return .{ .buf = [_]u8{data} ** size };
        }

        pub fn writeAll(self: *Self, data: []const u8) void {
            std.mem.copyForwards(u8, &self.buf, data);
        }

        pub fn writer(self: *Self) Writer {
            return Writer.init(self);
        }
    };
}

pub const Writer = struct {
    const Self = @This();
    ptr: *anyopaque,
    writeAllFn: *const fn (ptr: *anyopaque, data: []const u8) void,

    pub fn init(ptr: anytype) Self {
        return .{
            .ptr = ptr,
            .writeAllFn = struct {
                const T = @TypeOf(ptr);
                const ptr_info = @typeInfo(T);
                pub fn writeAll(pointer: *anyopaque, data: []const u8) void {
                    const self: T = @ptrCast(@alignCast(pointer));
                    @call(.always_inline, ptr_info.Pointer.child.writeAll, .{ self, data });
                }
            }.writeAll,
        };
    }

    pub fn writeAll(self: Self, data: []const u8) void {
        self.writeAllFn(self.ptr, data);
    }
};
