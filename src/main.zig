const std = @import("std");
const vk = @import("vulkan");

var lib_vulkan: ?std.DynLib = null;

pub fn libVulkanBaseLoader(_: vk.Instance, name_ptr: [*:0]const u8) vk.PfnVoidFunction {
    const name = std.mem.span(name_ptr);
    return lib_vulkan.?.lookup(vk.PfnVoidFunction, name) orelse null;
}

const Context = struct {
    vkb: vk.BaseWrapper,
    instance: vk.Instance,

    pub fn init(app_name: [*:0]const u8) !Context {
        var self: Context = undefined;

        const app_info = vk.ApplicationInfo{
            .p_application_name = app_name,
            .application_version = 0,
            .engine_version = @bitCast(vk.makeApiVersion(0, 0, 1, 0)),
            .api_version = @bitCast(vk.API_VERSION_1_2),
        };

        const instance_info = vk.InstanceCreateInfo{
            .p_application_info = &app_info,
        };

        const vkb = vk.BaseWrapper.load(libVulkanBaseLoader);

        std.debug.print("Loading with vkb:\n\n{?}\n\n", .{vkb});

        self.instance = try vkb.createInstance(&instance_info, null);

        std.debug.print("Loaded instance:\n\n{?}\n\n", .{self.instance});

        return self;
    }
};

pub fn main() !void {
    const app_name = "zbox";

    lib_vulkan = try std.DynLib.open("libvulkan.so.1");

    const context = try Context.init(app_name);

    std.debug.print("Created Context: {?}\n", .{context});
}
