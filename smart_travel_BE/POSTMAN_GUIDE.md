# Hướng Dẫn Test API Quản Lý User với Postman

## 📋 Tổng Quan

Collection này chứa **15+ test cases** để test đầy đủ các chức năng quản lý tài khoản người dùng.

## 🚀 Quick Start

### Bước 1: Import Collection vào Postman
1. Mở Postman
2. Click **Import** (góc trên bên trái)
3. Chọn file `User_Management_APIs.postman_collection.json`
4. Click **Import**

### Bước 2: Cấu hình Biến

Sau khi import, mở Collection Settings và set các biến:

| Biến | Giá Trị Mặc Định | Mô Tả |
|------|------------------|--------|
| `baseUrl` | `http://localhost:8080` | URL của backend server |
| `adminUserId` | `1` | ID của admin user (kiểm tra trong database) |
| `testUserId` | `2` | ID của user để test các chức năng |

**Lưu ý:** Để lấy `adminUserId` và `testUserId` thực tế, query database:
```sql
SELECT id, email, role FROM users WHERE role = 'ADMIN' LIMIT 1;
SELECT id, email, role FROM users WHERE role = 'USER' LIMIT 1;
```

### Bước 3: Chạy Test

#### Cách 1: Test Từng Request (Recommended cho lần đầu)
1. Mở folder **"1. Get All Users (Pagination & Search)"**
2. Chọn request **"Get All Users - Page 1 (Default)"**
3. Click **Send**
4. Kiểm tra response trong tab **Test Results**

#### Cách 2: Run All Tests (Collection Runner)
1. Click chuột phải vào collection **"User Management APIs - Smart Travel"**
2. Chọn **"Run collection"**
3. Click **"Run User Management APIs"**
4. Xem kết quả tất cả tests

## 📁 Cấu Trúc Collection

```
User Management APIs
├── 1. Get All Users (Pagination & Search)
│   ├── Get All Users - Page 1 (Default)
│   ├── Get All Users - Search by Name
│   ├── Get All Users - Search by Email
│   └── Get All Users - Page 2
│
├── 2. Get User Detail
│   ├── Get User Detail - Valid ID
│   └── Get User Detail - Invalid ID
│
├── 3. Update User
│   ├── Update User - Full Name
│   ├── Update User - Phone
│   ├── Update User - Role to ADMIN
│   ├── Update User - All Fields
│   └── Update User - Invalid Phone Format
│
├── 4. Lock User Account
│   ├── Lock User - Success
│   ├── Lock User - Already Locked
│   └── Lock User - Invalid ID
│
└── 5. Unlock User Account
    ├── Unlock User - Success
    └── Unlock User - Already Unlocked
```

## 🔍 Các API Endpoints

### 1. GET /api/v1/admin/users
Lấy danh sách users với phân trang và tìm kiếm.

**Query Parameters:**
- `page` (optional): Số trang, bắt đầu từ 0
- `size` (optional): Số items mỗi trang (1-100)
- `searchKeyword` (optional): Tìm theo tên, email, hoặc SĐT
- `sortBy` (optional): Field để sắp xếp
- `sortDirection` (optional): ASC hoặc DESC

### 2. GET /api/v1/admin/users/{id}
Xem thông tin chi tiết của một user.

### 3. PUT /api/v1/admin/users/{id}
Cập nhật thông tin user (fullName, phone, role).

### 4. POST /api/v1/admin/users/{id}/lock
Khóa tài khoản user (set isActive = false).

### 5. POST /api/v1/admin/users/{id}/unlock
Mở khóa tài khoản user (set isActive = true).

## ✅ Test Scenarios Quan Trọng

### Scenario 1: Pagination
```
1. Gọi "Get All Users - Page 1" → Verify có data
2. Gọi "Get All Users - Page 2" → Verify page number = 1
3. Check totalPages, hasNext, hasPrevious
```

### Scenario 2: Search
```
1. Gọi "Search by Name" với keyword = "admin"
2. Verify kết quả chứa keyword trong fullName
3. Gọi "Search by Email" với keyword = "gmail"
4. Verify kết quả chứa "gmail" trong email
```

### Scenario 3: Update User
```
1. Gọi "Get User Detail" → Lưu lại giá trị hiện tại
2. Gọi "Update User - Full Name" → Verify tên đã đổi
3. Gọi "Get User Detail" lại → Confirm thay đổi
```

### Scenario 4: Lock/Unlock
```
1. Gọi "Lock User - Success" → Verify msg thành công
2. Gọi "Get User Detail" → Check isActive = false
3. Gọi "Lock User - Already Locked" → Verify error message
4. Gọi "Unlock User - Success" → Verify msg thành công
5. Gọi "Get User Detail" → Check isActive = true
```

## 🛠️ Troubleshooting

### Lỗi: 401 Unauthorized
**Nguyên nhân:** Thiếu hoặc sai header `X-User-Id`  
**Giải pháp:** Kiểm tra biến `adminUserId` đã được set đúng ID của admin

### Lỗi: 404 User Not Found
**Nguyên nhân:** `testUserId` không tồn tại trong database  
**Giải pháp:** 
```sql
SELECT id FROM users LIMIT 1;
```
Update biến `testUserId` với ID thực tế

### Lỗi: 400 Phone Existed
**Nguyên nhân:** Số điện thoại đã được user khác sử dụng  
**Giải pháp:** Đổi số điện thoại khác trong request body

### Lỗi: Connection Refused
**Nguyên nhân:** Backend server chưa chạy  
**Giải pháp:**
```bash
cd smart_travel_BE
./gradlew bootRun
```

## 📊 Expected Results

Sau khi run tất cả tests, bạn sẽ thấy:
- ✅ **15+ tests passed** (màu xanh)
- ⏱️ Average response time < 500ms
- 📈 Success rate: 100%

## 🎯 Tips

1. **Luôn test theo thứ tự:** Get → Update → Lock → Unlock
2. **Kiểm tra database sau mỗi thao tác** để verify dữ liệu thay đổi
3. **Sử dụng Test Results tab** để xem chi tiết assertions
4. **Export results** bằng cách click "Export Results" sau khi run collection

## 📚 Tham Khảo Thêm

- [Walkthrough.md](file:///C:/Users/Anhtu/.gemini/antigravity/brain/fd7fbcb8-eb7c-4d5c-8f45-cd2eec945d9c/walkthrough.md) - Chi tiết về implementation
- [Implementation Plan](file:///C:/Users/Anhtu/.gemini/antigravity/brain/fd7fbcb8-eb7c-4d5c-8f45-cd2eec945d9c/implementation_plan.md) - Kế hoạch ban đầu

## 💡 Lưu Ý Quan Trọng

> **⚠️ Không lock tài khoản admin đang sử dụng!**  
> Nếu lock chính tài khoản admin của bạn, bạn sẽ không thể truy cập các API này nữa.

> **💾 Backup data trước khi test**  
> Một số tests sẽ modify database (update, lock/unlock). Nên backup trước khi test.

---

**Happy Testing! 🚀**
