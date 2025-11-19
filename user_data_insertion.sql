-- Tạo dữ liệu mẫu cho bảng users
INSERT INTO users (email, password, full_name, phone, role, auth_provider, email_verified, created_at, updated_at) 
VALUES
  ('admin@gmail.com', '$2a$10$XPTYHRQfUrFKCYnH4uDgzOadPwsHJp5OcWCy.lDWGOWDxVKlmSvK6', 'Quản Trị Viên', '0901234567', 'ADMIN', 'EMAIL', TRUE, NOW(), NOW()),
  
  ('user1@gmail.com', '$2a$10$XPTYHRQfUrFKCYnH4uDgzOadPwsHJp5OcWCy.lDWGOWDxVKlmSvK6', 'Nguyễn Văn An', '0912345678', 'USER', 'EMAIL', TRUE, NOW(), NOW()),
  
  ('user2@gmail.com', '$2a$10$XPTYHRQfUrFKCYnH4uDgzOadPwsHJp5OcWCy.lDWGOWDxVKlmSvK6', 'Trần Thị Bình', '0923456789', 'USER', 'EMAIL', TRUE, NOW(), NOW()),
  
  ('user3@gmail.com', '$2a$10$XPTYHRQfUrFKCYnH4uDgzOadPwsHJp5OcWCy.lDWGOWDxVKlmSvK6', 'Lê Hoàng Cường', '0934567890', 'USER', 'EMAIL', FALSE, NOW(), NOW()),
  
  ('googleuser@gmail.com', NULL, 'Phạm Minh Đức', '0945678901', 'USER', 'GOOGLE', TRUE, NOW(), NOW()),
  
  ('facebookuser@gmail.com', NULL, 'Võ Thị Em', '0956789012', 'USER', 'FACEBOOK', TRUE, NOW(), NOW()),
  
  ('testuser@gmail.com', '$2a$10$XPTYHRQfUrFKCYnH4uDgzOadPwsHJp5OcWCy.lDWGOWDxVKlmSvK6', 'Hoàng Văn Phúc', '0967890123', 'USER', 'EMAIL', TRUE, NOW(), NOW());
