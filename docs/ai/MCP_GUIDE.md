# Hướng dẫn sử dụng MCP Servers

Tài liệu này hướng dẫn chi tiết cách sử dụng từng MCP server trong dự án Flutter "AI LMS".

## Mục lục

1. [Supabase MCP Server](#supabase-mcp-server)
2. [Fetch MCP Server](#fetch-mcp-server)
3. [Context7 MCP Server](#context7-mcp-server)
4. [GitHub MCP Server](#github-mcp-server)
5. [Filesystem MCP Server](#filesystem-mcp-server)
6. [Memory MCP Server](#memory-mcp-server)
7. [Dart MCP Server](#dart-mcp-server)
8. [Best Practices](#best-practices)
9. [Use Cases](#use-cases)

## Supabase MCP Server

### Mục đích
Quản lý database Supabase, kiểm tra schema, query dữ liệu, apply migrations, và quản lý Edge Functions.

### Các tính năng chính

#### 1. List Tables
**Khi nào sử dụng**: Khi cần kiểm tra cấu trúc database hoặc xem các tables có sẵn.

**Ví dụ sử dụng**:
```
Sử dụng Supabase MCP để list tất cả các tables trong database
```

**Kết quả**: Danh sách tất cả tables trong schema `public` và các schemas khác.

#### 2. Execute SQL Query
**Khi nào sử dụng**: 
- Kiểm tra dữ liệu trong database
- Xem cấu trúc bảng chi tiết
- Test queries trước khi implement trong code

**Ví dụ sử dụng**:
```
Sử dụng Supabase MCP để execute query: SELECT * FROM profiles LIMIT 5
```

**Lưu ý**: 
- Chỉ sử dụng SELECT queries để xem dữ liệu
- Không sử dụng để thay đổi dữ liệu trực tiếp (dùng migrations thay thế)

#### 3. List Extensions
**Khi nào sử dụng**: Kiểm tra các PostgreSQL extensions đã được cài đặt.

**Ví dụ sử dụng**:
```
Sử dụng Supabase MCP để list các extensions trong database
```

#### 4. List Migrations
**Khi nào sử dụng**: Xem lịch sử migrations đã được apply.

**Ví dụ sử dụng**:
```
Sử dụng Supabase MCP để list tất cả migrations
```

#### 5. Apply Migration
**Khi nào sử dụng**: Khi cần tạo hoặc thay đổi schema database.

**Ví dụ sử dụng**:
```
Sử dụng Supabase MCP để apply migration với tên "add_students_table" và SQL: CREATE TABLE students (...)
```

**Best Practice**: 
- Luôn kiểm tra migration SQL trước khi apply
- Sử dụng tên migration rõ ràng và mô tả đúng thay đổi

#### 6. Get Logs
**Khi nào sử dụng**: Debug issues với database hoặc API.

**Ví dụ sử dụng**:
```
Sử dụng Supabase MCP để get logs từ service "api" trong 24h qua
```

**Các services có sẵn**: `api`, `postgres`, `auth`, `storage`, `realtime`, `edge-function`

#### 7. Get Advisors
**Khi nào sử dụng**: Kiểm tra security và performance issues sau khi thay đổi schema.

**Ví dụ sử dụng**:
```
Sử dụng Supabase MCP để get security advisors
Sử dụng Supabase MCP để get performance advisors
```

#### 8. Generate TypeScript Types
**Khi nào sử dụng**: Generate types cho TypeScript/JavaScript clients (không dùng cho Flutter).

**Ví dụ sử dụng**:
```
Sử dụng Supabase MCP để generate TypeScript types
```

### Use Cases

1. **Trước khi tạo Repository**:
   ```
   1. List tables để xem cấu trúc database
   2. Execute SQL để xem chi tiết cấu trúc bảng
   3. Sau đó mới tạo entity và repository phù hợp
   ```

2. **Kiểm tra dữ liệu**:
   ```
   Execute SQL query để xem dữ liệu thực tế trong database
   ```

3. **Apply Migration**:
   ```
   Apply migration để tạo bảng mới hoặc thay đổi schema
   ```

## Fetch MCP Server

### Mục đích
Fetch documentation, examples, và web content để hỗ trợ development.

### Các tính năng chính

#### Fetch URL Content
**Khi nào sử dụng**:
- Tìm documentation của thư viện mới
- Fetch examples từ web
- Lấy API documentation

**Ví dụ sử dụng**:
```
Sử dụng Fetch MCP để fetch nội dung từ https://pub.dev/packages/provider
```

**Best Practice**: 
- Sử dụng khi thêm thư viện mới vào `pubspec.yaml`
- Fetch documentation trước khi implement để đảm bảo sử dụng đúng cách

### Use Cases

1. **Khi thêm thư viện mới**:
   ```
   1. Thêm package vào pubspec.yaml
   2. Sử dụng Fetch MCP để fetch documentation từ pub.dev
   3. Tìm examples và best practices
   4. Implement theo documentation
   ```

2. **Tìm best practices**:
   ```
   Fetch articles hoặc documentation về Flutter best practices
   ```

## Context7 MCP Server

### Mục đích
Quản lý context và tìm kiếm trong codebase.

### Các tính năng chính

#### Search Codebase
**Khi nào sử dụng**:
- Tìm các patterns trong codebase
- Tìm các file liên quan đến một feature
- Hiểu context của một phần code

**Ví dụ sử dụng**:
```
Sử dụng Context7 MCP để tìm các file liên quan đến authentication
```

### Use Cases

1. **Tìm patterns đã sử dụng**:
   ```
   Tìm cách các features tương tự được implement để đảm bảo consistency
   ```

2. **Hiểu codebase**:
   ```
   Tìm các file liên quan để hiểu đầy đủ context của một feature
   ```

## GitHub MCP Server

### Mục đích
Quản lý Git operations như tạo commits, xem branches, tạo PRs.

### Các tính năng chính

#### List Branches
**Khi nào sử dụng**: Xem các branches hiện có trong repository.

**Ví dụ sử dụng**:
```
Sử dụng GitHub MCP để list các branches
```

#### Create Commit
**Khi nào sử dụng**: Tạo commit với message rõ ràng (chỉ khi được yêu cầu).

**Ví dụ sử dụng**:
```
Sử dụng GitHub MCP để tạo commit với message "[feat] Add assignment builder screen"
```

**Best Practice**: 
- Không tự động tạo commits trừ khi được yêu cầu
- Luôn tạo commit message rõ ràng và mô tả đầy đủ
- Format: `[type] description`

#### Create Pull Request
**Khi nào sử dụng**: Tạo PR khi được yêu cầu.

**Ví dụ sử dụng**:
```
Sử dụng GitHub MCP để tạo pull request từ branch "feature/assignment-builder" vào "main"
```

### Use Cases

1. **Quản lý Git**:
   ```
   Khi người dùng yêu cầu tạo commit hoặc quản lý Git operations
   ```

2. **Xem branches**:
   ```
   Xem các branches hiện có để hiểu workflow
   ```

## Filesystem MCP Server

### Mục đích
Đọc/ghi files và navigate codebase.

### Các tính năng chính

#### Read File
**Khi nào sử dụng**: 
- Đọc nhiều files cùng lúc để hiểu context
- Đọc configuration files
- Đọc documentation

**Ví dụ sử dụng**:
```
Sử dụng Filesystem MCP để đọc file pubspec.yaml
Sử dụng Filesystem MCP để đọc file lib/main.dart
```

#### Write File
**Khi nào sử dụng**: Ghi file khi cần (thường không cần vì có tools khác).

**Ví dụ sử dụng**:
```
Sử dụng Filesystem MCP để ghi file (ít khi sử dụng)
```

#### List Directory
**Khi nào sử dụng**: Xem cấu trúc thư mục.

**Ví dụ sử dụng**:
```
Sử dụng Filesystem MCP để list các files trong thư mục lib/
```

### Use Cases

1. **Đọc nhiều files cùng lúc**:
   ```
   Đọc nhiều files liên quan để hiểu đầy đủ context trước khi implement
   ```

2. **Navigate codebase**:
   ```
   Tìm và đọc các files trong codebase để hiểu cấu trúc
   ```

## Memory MCP Server

### Mục đích
Lưu trữ và truy xuất context quan trọng giữa các sessions.

### Các tính năng chính

#### Store Memory
**Khi nào sử dụng**: 
- Lưu các quyết định kiến trúc quan trọng
- Lưu các patterns đã được thống nhất
- Lưu context quan trọng giữa các sessions

**Ví dụ sử dụng**:
```
Sử dụng Memory MCP để lưu: "Dự án sử dụng MVVM pattern với Provider cho state management"
```

#### Retrieve Memory
**Khi nào sử dụng**: Truy xuất context đã lưu từ các sessions trước.

**Ví dụ sử dụng**:
```
Sử dụng Memory MCP để retrieve memory về architecture patterns
```

### Use Cases

1. **Lưu quyết định kiến trúc**:
   ```
   Lưu các quyết định quan trọng về architecture và patterns để maintain consistency
   ```

2. **Maintain context**:
   ```
   Lưu context quan trọng giữa các sessions để AI agent có thể tiếp tục công việc hiệu quả
   ```

## Dart MCP Server

### Mục đích
Phân tích code Dart/Flutter, format code, kiểm tra linter errors, và các operations liên quan đến Dart tooling.

### Các tính năng chính

#### Format Code
**Khi nào sử dụng**: 
- Khi cần format một file hoặc nhiều files Dart
- Khi code chưa được format đúng chuẩn Dart style
- Trước khi commit code

**Ví dụ sử dụng**:
```
Sử dụng Dart MCP để format file lib/presentation/views/home_screen.dart
Sử dụng Dart MCP để format tất cả files trong thư mục lib/presentation/
```

**Best Practice**: 
- Format code sau khi viết xong
- Format code trước khi commit
- Không format code đã được format đúng chuẩn

#### Analyze Linter Errors
**Khi nào sử dụng**: 
- Khi cần kiểm tra linter errors trong một file hoặc thư mục cụ thể
- Khi muốn xem chi tiết warnings/errors trước khi fix
- Khi cần đảm bảo code quality

**Ví dụ sử dụng**:
```
Sử dụng Dart MCP để analyze linter errors trong lib/presentation/
Sử dụng Dart MCP để kiểm tra linter errors trong file lib/data/repositories/user_repository_impl.dart
```

**Best Practice**: 
- Analyze code sau khi viết xong
- Fix tất cả errors trước khi commit
- Không ignore warnings trừ khi có lý do chính đáng

#### Code Quality Check
**Khi nào sử dụng**: 
- Khi cần đánh giá code quality của một phần code
- Khi muốn tìm các vấn đề tiềm ẩn trong code
- Khi refactoring code

**Ví dụ sử dụng**:
```
Sử dụng Dart MCP để kiểm tra code quality của file lib/data/repositories/
Sử dụng Dart MCP để phân tích code quality của feature authentication
```

#### Find Patterns in Dart Code
**Khi nào sử dụng**: 
- Khi cần tìm các patterns cụ thể trong codebase Dart
- Khi muốn phân tích cấu trúc code Dart
- Khi cần tìm tất cả các class/function theo pattern

**Ví dụ sử dụng**:
```
Sử dụng Dart MCP để tìm tất cả các class extends ChangeNotifier
Sử dụng Dart MCP để tìm tất cả các repository implementation
```

### Khi NÀO KHÔNG NÊN sử dụng Dart MCP

1. **Đọc file đơn giản**:
   - KHÔNG sử dụng Dart MCP để đọc file
   - Dùng `read_file` tool thay thế (nhanh hơn và phù hợp hơn)

2. **Tìm kiếm text đơn giản**:
   - KHÔNG sử dụng Dart MCP để tìm kiếm text trong files
   - Dùng `grep` tool thay thế (hiệu quả hơn cho text search)

3. **Semantic search**:
   - KHÔNG sử dụng Dart MCP cho semantic search
   - Dùng `codebase_search` tool thay thế (phù hợp hơn cho tìm kiếm theo ngữ nghĩa)

4. **Operations đơn giản**:
   - KHÔNG sử dụng Dart MCP cho các operations đơn giản có thể dùng tools khác
   - Chỉ sử dụng khi thực sự cần phân tích code Dart hoặc format code

### Use Cases

1. **Format code sau khi viết**:
   ```
   1. Viết code mới hoặc chỉnh sửa code
   2. Sử dụng Dart MCP để format code
   3. Kiểm tra lại code đã được format đúng
   ```

2. **Kiểm tra code quality trước khi commit**:
   ```
   1. Sử dụng Dart MCP để analyze linter errors
   2. Fix tất cả errors và warnings
   3. Format code lại nếu cần
   4. Commit code
   ```

3. **Refactoring code**:
   ```
   1. Sử dụng Dart MCP để kiểm tra code quality của phần code cần refactor
   2. Refactor code
   3. Sử dụng Dart MCP để format và analyze lại
   4. Đảm bảo không có lỗi mới
   ```

## Best Practices

### 1. Sử dụng đúng tool cho đúng mục đích
- **Supabase MCP**: Database operations, schema checks
- **Fetch MCP**: Documentation và web content
- **Context7 MCP**: Codebase search và context management
- **GitHub MCP**: Git operations (chỉ khi được yêu cầu)
- **Filesystem MCP**: File operations khi cần đọc nhiều files
- **Memory MCP**: Lưu trữ context quan trọng
- **Dart MCP**: Format code, analyze linter errors, code quality checks (KHÔNG dùng cho đọc file hoặc text search)

### 2. Luôn kiểm tra trước khi giả định
- Sử dụng Supabase MCP để kiểm tra schema trước khi tạo model
- Sử dụng Filesystem MCP để đọc files trước khi giả định cấu trúc

### 3. Kết hợp các MCP servers
- Có thể sử dụng nhiều MCP servers cùng lúc để có context đầy đủ
- Ví dụ: Sử dụng Supabase MCP để check schema + Filesystem MCP để đọc repository code

### 4. Document findings
- Khi tìm thấy patterns hoặc best practices quan trọng, lưu vào Memory MCP hoặc documentation
- Update memory bank khi có thay đổi quan trọng

### 5. Security
- Không commit tokens vào Git
- Kiểm tra quyền truy cập của MCP servers
- Sử dụng environment variables cho sensitive data

## Use Cases

### Use Case 1: Tạo Repository mới

**Workflow**:
1. Sử dụng Supabase MCP để list tables và kiểm tra schema
2. Sử dụng Supabase MCP để execute SQL query xem chi tiết cấu trúc bảng
3. Sử dụng Filesystem MCP để đọc các repository hiện có để hiểu pattern
4. Tạo entity và repository theo pattern đã có
5. Sử dụng Memory MCP để lưu pattern nếu cần

### Use Case 2: Thêm thư viện mới

**Workflow**:
1. Thêm package vào `pubspec.yaml`
2. Sử dụng Fetch MCP để fetch documentation từ pub.dev
3. Tìm examples và best practices
4. Implement theo documentation
5. Sử dụng Memory MCP để lưu patterns quan trọng

### Use Case 3: Debug database issue

**Workflow**:
1. Sử dụng Supabase MCP để get logs từ service liên quan
2. Sử dụng Supabase MCP để execute SQL query kiểm tra dữ liệu
3. Sử dụng Supabase MCP để get advisors kiểm tra security/performance issues
4. Fix issue và verify

### Use Case 4: Tìm hiểu codebase

**Workflow**:
1. Sử dụng Context7 MCP để tìm các files liên quan
2. Sử dụng Filesystem MCP để đọc các files quan trọng
3. Sử dụng Memory MCP để lưu findings quan trọng

## Troubleshooting

### MCP Server không phản hồi
- Kiểm tra MCP server đã được cấu hình đúng trong `mcp.json`
- Restart Cursor
- Kiểm tra logs trong Developer Tools

### Kết quả không đúng
- Kiểm tra parameters đã đúng
- Kiểm tra quyền truy cập
- Thử lại với parameters khác

### Performance issues
- Không sử dụng MCP servers cho operations đơn giản
- Cache kết quả khi có thể
- Sử dụng đúng tool cho đúng mục đích

## Tài liệu tham khảo

- [CURSOR_SETUP.md](CURSOR_SETUP.md) - Hướng dẫn setup Cursor và MCP
- [AI_INSTRUCTIONS.md](AI_INSTRUCTIONS.md) - Hướng dẫn cho AI agent
- [.clinerules](.clinerules) - Rules và quy tắc làm việc
