const std = @import("std");
const os = std.os;
const print = std.debug.print;

pub fn main() !void {
    const address_family = os.AF.INET;
    const sock_type = os.SOCK.STREAM;
    const protocol = os.IPPROTO.HOPOPTS;

    const socket = try os.socket(address_family, sock_type, protocol);
    defer os.close(socket);

    // disable wait time after terminating the program so that it can be re-run immediately
    try os.setsockopt(socket, os.SOL.SOCKET, os.SO.REUSEADDR, "true");

    const port = 8080;
    const ip = "0.0.0.0";
    const address = try std.net.Address.parseIp(ip, port);

    try os.bind(
        socket,
        &address.any,
        address.getOsSockLen(),
    );

    try os.listen(socket, 10);

    print("listening on {s}:{} ...", .{ ip, port });

    const client = try os.accept(socket, null, null, 0);
    defer os.close(client);

    var req_buf: [512]u8 = .{0} ** 512;
    const msg_len = try os.recv(client, &req_buf, 0);
    _ = msg_len;
    print("REQUEST:\n{s}\n", .{req_buf});

    // GET /file.html .....

    const filename = getFilepathFromRequest(&req_buf);
    print("filename: \'{s}\'\n", .{filename});

    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    const empty_iovec = [0]os.iovec_const{};
    const sent_bytes = try os.sendfile(
        client,
        file.handle,
        0,
        0,
        &empty_iovec,
        &empty_iovec,
        0,
    );
    _ = sent_bytes;
    print("exiting...\n", .{});
}

fn getFilepathFromRequest(request: []const u8) []const u8 {
    var req_tokens = std.mem.tokenizeAny(u8, request, &[_]u8{ ' ', '\n', 0 });

    var idx: usize = 0;
    while (req_tokens.next()) |token| : (idx += 1) {
        switch (idx) {
            // return file path without beginning slash
            1 => return token[1..],
            else => continue,
        }
    }
    unreachable;
}
