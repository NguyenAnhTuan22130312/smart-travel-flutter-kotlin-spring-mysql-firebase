# Debug Email Verification - Hướng dẫn kiểm tra

## 🔍 Các điểm cần kiểm tra

### 1. Kiểm tra Email có được gửi không

**Kiểm tra logs:**

```bash
# Tìm log "Verification email sent to"
# Nếu không thấy → Email không được gửi
```

**Nguyên nhân có thể:**

- Email service không được cấu hình đúng
- Gmail App Password không đúng
- SMTP bị chặn

**Cách test:**

1. Đăng ký user mới
2. Kiểm tra inbox email (cả spam folder)
3. Kiểm tra server logs

---

### 2. Kiểm tra Token có được tạo và lưu không

**Query database:**

```sql
SELECT * FROM email_verification_tokens
WHERE user_id = (SELECT id FROM users WHERE email = 'your-email@example.com')
ORDER BY created_at DESC;
```

**Kiểm tra:**

- Token có được tạo không?
- expiry_date có đúng không? (phải sau 1 giờ từ created_at)
- verified_at có null không? (phải null khi chưa verify)

---

### 3. Kiểm tra User có được cập nhật emailVerified không

**Query database:**

```sql
SELECT id, email, email_verified, created_at, updated_at
FROM users
WHERE email = 'your-email@example.com';
```

**Sau khi click link verify:**

- `email_verified` phải = 1 (true)
- `updated_at` phải được cập nhật

---

### 4. Kiểm tra Link Verify có đúng không

**Link trong email:**

```
http://localhost:8080/api/v1/auth/verify-email?token={token}
```

**Lưu ý:**

- Nếu deploy production, cần thay `localhost:8080` bằng domain thực
- Token phải được URL encode đúng cách

---

### 5. Kiểm tra Logs khi Verify

**Tìm các log:**

- "Email verified successfully for user: {email}"
- "Xác thực thất bại" (nếu có lỗi)
- Exception stack trace

---

## 🐛 Các lỗi thường gặp

### Lỗi 1: Token không tồn tại

**Nguyên nhân:**

- Token bị sai format
- Token đã bị xóa
- Database không sync

**Giải pháp:**

- Kiểm tra token trong database
- Thử resend verification email

---

### Lỗi 2: Token đã hết hạn

**Nguyên nhân:**

- Token quá 1 giờ
- Server time không đúng

**Giải pháp:**

- Gửi lại email verification mới

---

### Lỗi 3: Email đã được verify

**Nguyên nhân:**

- User đã click link verify trước đó

**Giải pháp:**

- Kiểm tra `email_verified` trong database
- Nếu đã verify, không cần verify lại

---

### Lỗi 4: User không được cập nhật

**Nguyên nhân:**

- Transaction không commit
- Entity không được refresh

**Giải pháp:**

- Thêm `@Transactional` annotation
- Refresh entity sau khi save

---

## 🔧 Cách test thủ công

### Bước 1: Đăng ký user

```bash
POST http://localhost:8080/api/v1/auth/register
{
  "fullName": "Test User",
  "email": "test@example.com",
  "phone": "0123456789",
  "password": "password123",
  "confirmPassword": "password123"
}
```

### Bước 2: Kiểm tra database

```sql
-- Kiểm tra user
SELECT * FROM users WHERE email = 'test@example.com';

-- Kiểm tra token
SELECT * FROM email_verification_tokens
WHERE user_id = (SELECT id FROM users WHERE email = 'test@example.com');
```

### Bước 3: Lấy token từ database

```sql
SELECT token FROM email_verification_tokens
WHERE user_id = (SELECT id FROM users WHERE email = 'test@example.com')
ORDER BY created_at DESC LIMIT 1;
```

### Bước 4: Test verify endpoint

```bash
GET http://localhost:8080/api/v1/auth/verify-email?token={token_from_step3}
```

### Bước 5: Kiểm tra lại database

```sql
-- Kiểm tra email_verified đã = 1 chưa
SELECT email_verified FROM users WHERE email = 'test@example.com';

-- Kiểm tra user_profiles đã được tạo chưa
SELECT * FROM user_profiles
WHERE user_id = (SELECT id FROM users WHERE email = 'test@example.com');
```

---

## 📝 Checklist Debug

- [ ] Email có được gửi không? (kiểm tra inbox)
- [ ] Token có được tạo trong database không?
- [ ] Link verify có đúng format không?
- [ ] Click link verify có redirect đúng không?
- [ ] `email_verified` có được set = true không?
- [ ] `user_profiles` có được tạo không?
- [ ] Logs có báo lỗi gì không?

---

## 🔍 Code cần kiểm tra

1. **AuthService.verifyEmail()** - Method verify email
2. **EmailService.sendVerificationEmail()** - Gửi email
3. **EmailVerificationToken.isExpired()** - Kiểm tra hết hạn
4. **EmailVerificationToken.isVerified()** - Kiểm tra đã verify
