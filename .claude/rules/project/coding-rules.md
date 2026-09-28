---
name: coding-rules
description: File header comments, business-logic step-docstrings, protected files, code hygiene — áp khi tạo/sửa source code
paths:
  - "**/*.py"
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.go"
  - "**/*.sh"
  - "**/*.sql"
  - "**/*.dart"
  - "**/*.java"
  - "**/*.kt"
status: active
updated: 2026-09-26
---

# Coding Rules — nguồn: `.claude/config/coding-rules.md`

> File đầy đủ (ví dụ chi tiết mọi ngôn ngữ) ở [.claude/config/coding-rules.md](../../config/coding-rules.md). File này là bản rule LAZY để native loader tự nạp khi chạm source code — nội dung tóm tắt, không lược bớt quy tắc.

## 1. Protected files — never edit

`.env*` (trừ `.env.example/.sample/.template`), `*.pem`, `*.key`, `secrets.json`, `service-account.json`, config prod (`firebase.json`, `vercel.json`, `netlify.toml`), `.git/config`, IDE workspace files. Cần giá trị `.env*` thật → dừng, báo user, không đoán.

## 2. File header comment

Mọi file **tạo mới** hoặc **sửa đáng kể** phải có header (đúng syntax ngôn ngữ) ở đầu file, trước import: `File/@file`, `Description/@description`, `Created at/by`, `Updated at/by`. Xem template từng ngôn ngữ trong file gốc.

## 3. Business-logic function comments

Hàm/method chứa **business logic** (không phải glue code thuần) → docstring liệt kê từng bước (`Process: 1. ... 2. ...`) + comment số thứ tự khớp trong body (`// 1. ...`). Hàm <3 bước và rõ nghĩa từ tên → 1 dòng mô tả, bỏ numbered list.

## 4. Inline comments

Chỉ comment WHY, không comment WHAT. Dùng token comment native ngôn ngữ. Không block-comment trong thân hàm trừ numbered step markers (mục 3). **Comment/docstring trong code luôn viết tiếng Anh** (khác với chat trả lời user — mặc định tiếng Việt theo [[general]]).

## 5. General hygiene

Không dead code (xoá block comment-out trước khi done). Không TODO vô căn cứ (ghi vào `notes=` status thay vì code). Match style file lân cận. Chạy test/lint trước khi báo done.
