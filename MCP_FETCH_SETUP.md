# MCP Fetch Server Setup Guide

## Cài đặt

1. **Cài đặt package MCP Python:**
   ```bash
   pip install mcp
   ```

2. **Kiểm tra server có chạy được không:**
   ```bash
   python -m mcp_server_fetch
   ```
   
   Nếu không có lỗi, server đã sẵn sàng!

## Cấu hình trong Cursor

File `mcp.json` đã được cấu hình sẵn:
```json
"fetch": {
  "command": "python",
  "args": ["-m", "mcp_server_fetch"]
}
```

## Test Resources

Server này expose 3 test resources:

1. **`fetch://hello`** - Text greeting (text/plain)
2. **`fetch://test-data`** - JSON data (application/json)  
3. **`fetch://info`** - Server info (text/markdown)

## Cách test

Sau khi restart Cursor để load server mới:

1. Gọi `list_mcp_resources` với `server: "fetch"` để xem danh sách
2. Gọi `fetch_mcp_resource` với:
   - `server: "fetch"`
   - `uri: "fetch://hello"` (hoặc các URI khác)

## Troubleshooting

- **Lỗi "ModuleNotFoundError"**: Đảm bảo đã cài `pip install mcp`
- **Server không kết nối**: Restart Cursor và kiểm tra log trong Cursor Settings → MCP Servers
- **Không thấy resources**: Đảm bảo server đã khởi động thành công (check logs)
