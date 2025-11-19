# Hướng Dẫn Test API với Postman

## 📋 Cấu hình cơ bản

### Base URL

```
http://localhost:8080/api/v1/auth
```

### Headers mặc định

- **Content-Type**: `application/json`
- **Accept**: `application/json`

---

## 🔐 1. Đăng ký tài khoản (Register)

### Endpoint

```
POST /api/v1/auth/register
```

### Request Body

```json
{
  "fullName": "Nguyễn Văn A",
  "email": "test@example.com",
  "phone": "0123456789",
  "password": "password123",
  "confirmPassword": "password123"
}
```

### Response thành công (201)

```json
{
  "msg": "Đăng ký thành công",
  "data": {
    "id": 1,
    "email": "test@example.com",
    "fullName": "Nguyễn Văn A",
    "message": "Đăng kí tài khoản thành công, vui lòng xác thực tài khoản"
  }
}
```

### Response lỗi (400)

```json
{
  "msg": "Email đã tồn tại"
}
```

### Cách test trong Postman:

1. Chọn method: **POST**
2. URL: `http://localhost:8080/api/v1/auth/register`
3. Tab **Headers**: Thêm `Content-Type: application/json`
4. Tab **Body** → chọn **raw** → chọn **JSON**
5. Paste JSON request body ở trên
6. Click **Send**

---

## 🔑 2. Đăng nhập (Login)

### Endpoint

```
POST /api/v1/auth/login
```

### Request Body

```json
{
  "email": "test@example.com",
  "password": "password123"
}
```

### Response thành công (200)

```json
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "role": "USER",
    "fullName": "Nguyễn Văn A"
  }
}
```

### Response lỗi phổ biến

#### 1. Email không tồn tại (404)

```json
{
  "code": 1005,
  "msg": "Email không tồn tại",
  "data": null
}
```

#### 2. Tài khoản chưa được xác thực (401)

```json
{
  "code": 1019,
  "msg": "Tài khoản chưa được xác thực",
  "data": null
}
```

**Nguyên nhân**: Email chưa được verify hoặc tài khoản chưa được kích hoạt

**Cách xử lý**:

- Kiểm tra email và click vào link xác thực
- Hoặc gọi API `/api/v1/auth/resend-verification?email={email}` để gửi lại email xác thực

#### 3. Tài khoản không chính xác (401)

```json
{
  "code": 1006,
  "msg": "Tài khoản không chính xác",
  "data": null
}
```

**Nguyên nhân**: Mật khẩu không đúng

**Cách xử lý**:

- Kiểm tra lại mật khẩu
- Nếu quên mật khẩu, sử dụng API `/api/v1/auth/forgot-password`

### Lưu ý:

- **Lưu token** để dùng cho các API yêu cầu authentication
- Token có thời hạn 1 giờ (3600 giây)
- Refresh token có thời hạn 7 ngày
- **Quan trọng**: Phải xác thực email trước khi đăng nhập (trừ khi đăng nhập bằng Google/Facebook)

---

## 📧 3. Xác thực Email (Verify Email)

### Endpoint

```
GET /api/v1/auth/verify-email?token={token}
```

### Cách test:

1. Sau khi đăng ký, kiểm tra email để lấy token
2. Method: **GET**
3. URL: `http://localhost:8080/api/v1/auth/verify-email?token=abc123...`
4. Click **Send**
5. Sẽ redirect đến `/verify-success.html` nếu thành công

---

## 🔄 4. Gửi lại email xác thực (Resend Verification)

### Endpoint

```
POST /api/v1/auth/resend-verification?email={email}
```

### Cách test:

1. Method: **POST**
2. URL: `http://localhost:8080/api/v1/auth/resend-verification?email=test@example.com`
3. Click **Send**

### Response thành công (201)

```json
{
  "msg": "Gửi lại email xác thực thành công"
}
```

---

## 🔐 5. Đăng nhập bằng Google

### Endpoint

```
POST /api/v1/auth/google-login
```

### Request Body

```json
{
  "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...",
  "email": "user@gmail.com",
  "displayName": "Nguyễn Văn B"
}
```

### Response thành công (200)

```json
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "role": "USER",
    "fullName": "Nguyễn Văn B"
  }
}
```

### Lưu ý:

- `idToken` là token từ Firebase Authentication
- Nếu user chưa tồn tại, hệ thống sẽ tự động tạo user mới và UserProfile

---

## 🔐 6. Đăng nhập bằng Facebook

### Endpoint

```
POST /api/v1/auth/facebook-login
```

### Request Body

```json
{
  "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...",
  "email": "user@facebook.com",
  "displayName": "Nguyễn Văn C"
}
```

### Response: Tương tự Google Login

---

## 🔒 7. Quên mật khẩu (Forgot Password)

### Endpoint

```
POST /api/v1/auth/forgot-password?email={email}
```

### Cách test:

1. Method: **POST**
2. URL: `http://localhost:8080/api/v1/auth/forgot-password?email=test@example.com`
3. Click **Send**

### Response thành công (200)

```json
{
  "msg": "Yêu cầu đã được gửi!"
}
```

---

## 🔄 8. Đặt lại mật khẩu (Reset Password)

### Endpoint

```
POST /api/v1/auth/reset-password
```

### Request Body

```json
{
  "token": "abc123...",
  "password": "newpassword123",
  "passwordConfirm": "newpassword123"
}
```

### Response thành công (200)

```json
{
  "msg": "Đặt lại mật khẩu thành công!. Vui lòng quay lại ứng dụng để đăng nhập"
}
```

---

## 🛠️ Cách sử dụng Token JWT trong Postman

### Cách 1: Thêm vào Headers

1. Sau khi đăng nhập, copy token từ response
2. Vào tab **Headers**
3. Thêm header mới:
   - **Key**: `Authorization`
   - **Value**: `Bearer {token}` (thay {token} bằng token thực tế)

### Cách 2: Sử dụng Variables trong Postman

1. Tạo environment variable:
   - Variable: `token`
   - Value: (để trống, sẽ set sau khi login)
2. Sau khi login, dùng script trong tab **Tests**:

```javascript
var jsonData = pm.response.json();
if (jsonData.data && jsonData.data.token) {
  pm.environment.set("token", jsonData.data.token);
}
```

3. Trong các request khác, dùng: `Bearer {{token}}`

---

## 📝 Collection Postman mẫu

### Tạo Collection:

1. Click **New** → **Collection**
2. Đặt tên: "Smart Travel API"
3. Thêm các request vào collection

### Thứ tự test đề xuất:

1. ✅ Register (đăng ký)
2. ✅ Verify Email (xác thực email)
3. ✅ Login (đăng nhập)
4. ✅ Google Login (nếu cần)
5. ✅ Các API khác (sử dụng token từ login)

---

## ⚠️ Lưu ý quan trọng

1. **Server phải đang chạy**: Đảm bảo Spring Boot app đang chạy trên port 8080
2. **Database**: MySQL phải đang chạy và có database `smart_travel_db`
3. **Email**: Cần cấu hình email service để nhận verification email
4. **Firebase**: Để test Google/Facebook login, cần có Firebase project và idToken hợp lệ
5. **Validation**:
   - Email phải đúng format
   - Password tối thiểu 8 ký tự
   - Phone phải đúng 10 số

---

## 🐛 Xử lý lỗi thường gặp

### 401 Unauthorized

- Token đã hết hạn → Đăng nhập lại
- Token không hợp lệ → Kiểm tra format `Bearer {token}`

### 400 Bad Request

- Kiểm tra request body format JSON
- Kiểm tra các field required
- Kiểm tra validation rules

### 500 Internal Server Error

- Kiểm tra server logs
- Kiểm tra database connection
- Kiểm tra cấu hình application.yaml

---

## 👤 9. Profile APIs - Quản lý thông tin cá nhân

### 9.1. Lấy thông tin profile

#### Endpoint

```
GET /api/v1/users/profile
```

#### Headers

```
Authorization: Bearer {token}
Content-Type: application/json
```

#### Response thành công (200)

```json
{
  "msg": "Lấy thông tin profile thành công",
  "data": {
    "id": 1,
    "email": "test@example.com",
    "fullName": "Nguyễn Văn A",
    "phone": "0123456789",
    "role": "USER",
    "authProvider": "EMAIL",
    "emailVerified": true,
    "createdAt": "2024-01-01T10:00:00",
    "updatedAt": "2024-01-01T10:00:00",
    "avatarUrl": "https://example.com/avatar.jpg",
    "bio": "Giới thiệu về bản thân",
    "gender": "MALE",
    "dateOfBirth": "1990-01-01",
    "address": "123 Đường ABC",
    "city": "Hà Nội",
    "country": "Việt Nam",
    "preferences": "{\"theme\":\"light\"}",
    "languageSettings": "{\"lang\":\"vi\"}",
    "darkModeEnabled": false,
    "profileUpdatedAt": "2024-01-01T10:00:00"
  }
}
```

---

### 9.2. Cập nhật thông tin profile

#### Endpoint

```
PUT /api/v1/users/profile
```

#### Headers

```
Authorization: Bearer {token}
Content-Type: application/json
```

#### Request Body (tất cả các field đều optional)

```json
{
  "fullName": "Nguyễn Văn B",
  "phone": "0987654321",
  "avatarUrl": "https://example.com/new-avatar.jpg",
  "bio": "Cập nhật giới thiệu mới",
  "gender": "FEMALE",
  "dateOfBirth": "1995-05-15",
  "address": "456 Đường XYZ",
  "city": "Hồ Chí Minh",
  "country": "Việt Nam",
  "preferences": "{\"theme\":\"dark\",\"notifications\":true}",
  "languageSettings": "{\"lang\":\"en\"}",
  "darkModeEnabled": true
}
```

#### Response thành công (200)

```json
{
  "msg": "Cập nhật profile thành công",
  "data": {
    // ... thông tin profile đã được cập nhật
  }
}
```

#### Validation Rules:

- `fullName`: 2-100 ký tự
- `phone`: Đúng 10 số, không trùng với user khác
- `bio`: Tối đa 1000 ký tự
- `gender`: MALE, FEMALE, hoặc OTHER
- `address`: Tối đa 100 ký tự
- `city`: Tối đa 50 ký tự
- `country`: Tối đa 50 ký tự

#### Lưu ý:

- Chỉ cần gửi các field muốn cập nhật, không cần gửi tất cả
- Nếu UserProfile chưa tồn tại, hệ thống sẽ tự động tạo mới
- Phone sẽ được kiểm tra trùng lặp (trừ chính user hiện tại)

---

### 9.3. Đổi mật khẩu

#### Endpoint

```
PUT /api/v1/users/change-password
```

#### Headers

```
Authorization: Bearer {token}
Content-Type: application/json
```

#### Request Body

```json
{
  "currentPassword": "oldPassword123",
  "newPassword": "newPassword456",
  "confirmNewPassword": "newPassword456"
}
```

#### Logic

- Kiểm tra email đã xác thực
- So khớp mật khẩu hiện tại
- Kiểm tra mật khẩu mới và xác nhận
- Không cho phép trùng mật khẩu cũ
- Lưu mật khẩu mới (đã mã hóa)

#### Response thành công (200)

```json
{
  "msg": "Đổi mật khẩu thành công"
}
```

#### Response lỗi phổ biến

- Sai mật khẩu hiện tại → `UNAUTHENTICATED`
- Mật khẩu mới và xác nhận không khớp → `INVALID_PASSWORD`
- Email chưa xác thực → `ACCOUNT_NOT_CONFIRM`

---

### 9.4. Lấy cài đặt (ngôn ngữ, dark mode, notifications)

#### Endpoint

```
GET /api/v1/users/settings
```

#### Headers

```
Authorization: Bearer {token}
Content-Type: application/json
```

#### Response thành công (200)

```json
{
  "msg": "Lấy thông tin cài đặt thành công",
  "data": {
    "languageSettings": "{\"lang\":\"vi\"}",
    "darkModeEnabled": true,
    "notificationSettings": "{\"email\":true,\"push\":false}"
  }
}
```

#### Lưu ý

- Email phải được xác thực trước khi gọi API
- Nếu user chưa từng lưu cài đặt, hệ thống sẽ trả về giá trị mặc định (`darkModeEnabled = false`, các trường còn lại `null`)

---

### 9.5. Cập nhật cài đặt

#### Endpoint

```
PUT /api/v1/users/settings
```

#### Headers

```
Authorization: Bearer {token}
Content-Type: application/json
```

#### Request Body (tất cả field optional)

```json
{
  "languageSettings": "{\"lang\":\"en\"}",
  "darkModeEnabled": false,
  "notificationSettings": "{\"email\":true,\"push\":true,\"sms\":false}"
}
```

#### Response thành công (200)

```json
{
  "msg": "Cập nhật cài đặt thành công",
  "data": {
    "languageSettings": "{\"lang\":\"en\"}",
    "darkModeEnabled": false,
    "notificationSettings": "{\"email\":true,\"push\":true,\"sms\":false}"
  }
}
```

#### Response lỗi phổ biến

- Email chưa xác thực → `ACCOUNT_NOT_CONFIRM`
- Token không hợp lệ/hết hạn → `UNAUTHENTICATED`

---

### 9.6. Lấy cấp bậc / thành tích

#### Endpoint

```
GET /api/v1/users/level
```

#### Response thành công (200)

```json
{
  "msg": "Lấy cấp bậc thành công",
  "data": {
    "currentLevel": "Adventurer",
    "currentBadge": "Top Reviewer",
    "experiencePoints": 2450,
    "nextLevelAt": 3000,
    "progressPercentage": 72.5,
    "achievements": "{\"totalTrips\":12,\"reviews\":25}"
  }
}
```

#### Ghi chú

- `progressPercentage` thể hiện phần trăm tiến tới level tiếp theo
- Khi đạt level cuối (`Legend`), `nextLevelAt` = `null`

---

### 9.7. Cập nhật cấp bậc / thành tích

#### Endpoint

```
PUT /api/v1/users/level
```

#### Request Body

```json
{
  "experiencePoints": 3200,
  "currentBadge": "Trailblazer",
  "achievements": "{\"totalTrips\":15,\"reviews\":40}"
}
```

#### Response thành công (200)

```json
{
  "msg": "Cập nhật cấp bậc thành công",
  "data": {
    "currentLevel": "Trailblazer",
    "currentBadge": "Trailblazer",
    "experiencePoints": 3200,
    "nextLevelAt": 7000,
    "progressPercentage": 10.0,
    "achievements": "{\"totalTrips\":15,\"reviews\":40}"
  }
}
```

#### Lưu ý

- API yêu cầu token và email đã xác thực
- `experiencePoints` là giá trị tuyệt đối (tổng XP mới)
- `achievements` nên ở định dạng JSON string để FE parse

---

## 📚 Các endpoint khác trong project

Ngoài AuthController và UserController, project còn có các controller khác:

- `/api/v1/hotels` - Quản lý khách sạn
- `/api/v1/destinations` - Quản lý điểm đến
- `/api/v1/bookings` - Quản lý đặt phòng
- `/api/v1/provinces` - Quản lý tỉnh thành
- `/api/v1/payments` - Quản lý thanh toán

Tất cả đều sử dụng JWT token trong header `Authorization: Bearer {token}`
