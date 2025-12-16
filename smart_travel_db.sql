/*
 Navicat Premium Dump SQL

 Source Server         : Mysql
 Source Server Type    : MySQL
 Source Server Version : 80041 (8.0.41)
 Source Host           : localhost:3306
 Source Schema         : smart_travel_db

 Target Server Type    : MySQL
 Target Server Version : 80041 (8.0.41)
 File Encoding         : 65001

 Date: 19/11/2025 14:00:57
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for bookings
-- ----------------------------
DROP TABLE IF EXISTS `bookings`;
CREATE TABLE `bookings`
(
    `id`                  bigint                                                       NOT NULL AUTO_INCREMENT,
    `booking_type`        varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `cancellation_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci        NULL,
    `coupon_code`         varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
    `created_at`          datetime(6)                                                  NOT NULL,
    `discount_amount`     decimal(12, 2)                                               NULL DEFAULT NULL,
    `end_date`            date                                                         NOT NULL,
    `final_price`         decimal(12, 2)                                               NOT NULL,
    `hotel_id`            bigint                                                       NULL DEFAULT NULL,
    `number_of_people`    int                                                          NOT NULL,
    `number_of_rooms`     int                                                          NOT NULL,
    `special_requests`    text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci        NULL,
    `start_date`          date                                                         NOT NULL,
    `status`              varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `total_price`         decimal(12, 2)                                               NOT NULL,
    `tour_id`             bigint                                                       NULL DEFAULT NULL,
    `updated_at`          datetime(6)                                                  NOT NULL,
    `user_id`             bigint                                                       NOT NULL,
    `room_type_id`        bigint                                                       NULL DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `idx_user_id` (`user_id` ASC) USING BTREE,
    INDEX `idx_status` (`status` ASC) USING BTREE,
    INDEX `idx_created_at` (`created_at` DESC) USING BTREE,
    INDEX `FKgxj821at0er9dtw7wtyc05ni1` (`room_type_id` ASC) USING BTREE,
    CONSTRAINT `FKeyog2oic85xg7hsu2je2lx3s6` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT `FKgxj821at0er9dtw7wtyc05ni1` FOREIGN KEY (`room_type_id`) REFERENCES `room_types` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB
  AUTO_INCREMENT = 2
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bookings
-- ----------------------------
INSERT INTO `bookings`
VALUES (1, 'DESTINATION', NULL, NULL, '2025-10-26 13:52:15.720293', 0.00, '2025-10-27', 300000.00, NULL, 2, 1, NULL,
        '2025-10-26', 'PENDING', 300000.00, NULL, '2025-10-26 13:52:15.720293', 19, NULL);

-- ----------------------------
-- Table structure for coupons
-- ----------------------------
DROP TABLE IF EXISTS `coupons`;
CREATE TABLE `coupons`
(
    `id`                  bigint                                                       NOT NULL AUTO_INCREMENT,
    `code`                varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `description`         text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci        NULL,
    `discount_type`       varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `discount_value`      decimal(10, 2)                                               NOT NULL,
    `is_active`           bit(1)                                                       NOT NULL,
    `max_discount_amount` decimal(12, 2)                                               NULL DEFAULT NULL,
    `min_order_amount`    decimal(12, 2)                                               NULL DEFAULT NULL,
    `usage_limit`         int                                                          NULL DEFAULT NULL,
    `used_count`          int                                                          NOT NULL,
    `valid_from`          datetime(6)                                                  NOT NULL,
    `valid_to`            datetime(6)                                                  NOT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `UKeplt0kkm9yf2of2lnx6c1oy9b` (`code` ASC) USING BTREE,
    INDEX `idx_code` (`code` ASC) USING BTREE,
    INDEX `idx_valid_from` (`valid_from` ASC) USING BTREE,
    INDEX `idx_valid_to` (`valid_to` ASC) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of coupons
-- ----------------------------

-- ----------------------------
-- Table structure for destination_images
-- ----------------------------
DROP TABLE IF EXISTS `destination_images`;
CREATE TABLE `destination_images`
(
    `id`             bigint                                                        NOT NULL AUTO_INCREMENT,
    `display_order`  int                                                           NOT NULL,
    `image_url`      varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `is_primary`     bit(1)                                                        NOT NULL,
    `uploaded_at`    datetime(6)                                                   NOT NULL,
    `destination_id` bigint                                                        NOT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `FKcc0wuw8papfbghqwbnc6hyax3` (`destination_id` ASC) USING BTREE,
    CONSTRAINT `FKcc0wuw8papfbghqwbnc6hyax3` FOREIGN KEY (`destination_id`) REFERENCES `destinations` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB
  AUTO_INCREMENT = 29
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of destination_images
-- ----------------------------
INSERT INTO `destination_images`
VALUES (2, 1, 'https://res.cloudinary.com/dcwqv4rng/image/upload/v1760535081/fck2ksa2z3w4u2ftoi8u.jpg', b'1',
        '2025-10-11 21:30:00.000000', 2);
INSERT INTO `destination_images`
VALUES (3, 1, 'https://res.cloudinary.com/dcwqv4rng/image/upload/v1760535115/lspymugxdivfldd37nlm.jpg', b'1',
        '2025-10-11 21:35:00.000000', 3);
INSERT INTO `destination_images`
VALUES (4, 1, 'https://res.cloudinary.com/dcwqv4rng/image/upload/v1760535114/n5oue5okhvgussftb52q.jpg', b'1',
        '2025-10-11 21:40:00.000000', 4);
INSERT INTO `destination_images`
VALUES (15, 0, 'https://res.cloudinary.com/dcwqv4rng/image/upload/v1763375564/destinations/zvmvqyxzoqcorqjeqfbv.jpg',
        b'1', '2025-11-17 17:32:46.203884', 1);
INSERT INTO `destination_images`
VALUES (18, 2, 'https://res.cloudinary.com/dcwqv4rng/image/upload/v1763378897/destinations/ham1iqcmztm3kbveknyg.jpg',
        b'1', '2025-11-17 18:28:18.292768', 6);
INSERT INTO `destination_images`
VALUES (19, 3, 'https://res.cloudinary.com/dcwqv4rng/image/upload/v1763378917/destinations/hpbhqogp37kp6mjyx283.jpg',
        b'0', '2025-11-17 18:28:43.996014', 6);
INSERT INTO `destination_images`
VALUES (23, 2, 'https://res.cloudinary.com/dcwqv4rng/image/upload/v1763397684/destinations/jllryrwq0bwk9bgm9g21.jpg',
        b'0', '2025-11-17 23:41:25.230576', 6);
INSERT INTO `destination_images`
VALUES (25, 3, 'https://res.cloudinary.com/dcwqv4rng/image/upload/v1763438770/destinations/a0qqsayyfnfa09qtfusv.jpg',
        b'0', '2025-11-18 11:06:11.623281', 6);
INSERT INTO `destination_images`
VALUES (26, 0, 'https://res.cloudinary.com/dcwqv4rng/image/upload/v1763440898/destinations/yhazdmjgjcesmgkahlzo.jpg',
        b'0', '2025-11-18 11:41:44.855948', 7);
INSERT INTO `destination_images`
VALUES (27, 1, 'https://res.cloudinary.com/dcwqv4rng/image/upload/v1763440901/destinations/faosb6r27sichfy8jyt8.png',
        b'0', '2025-11-18 11:41:44.875275', 7);
INSERT INTO `destination_images`
VALUES (28, 2, 'https://res.cloudinary.com/dcwqv4rng/image/upload/v1763440904/destinations/llgxdb3htwllumeqwve1.jpg',
        b'0', '2025-11-18 11:41:44.879700', 7);

-- ----------------------------
-- Table structure for destinations
-- ----------------------------
DROP TABLE IF EXISTS `destinations`;
CREATE TABLE `destinations`
(
    `id`             bigint                                                        NOT NULL AUTO_INCREMENT,
    `address`        varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
    `average_rating` decimal(3, 2)                                                 NULL DEFAULT NULL,
    `category`       varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
    `created_at`     datetime(6)                                                   NOT NULL,
    `description`    text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci         NULL,
    `entry_fee`      decimal(10, 2)                                                NULL DEFAULT NULL,
    `is_active`      bit(1)                                                        NOT NULL,
    `is_featured`    bit(1)                                                        NOT NULL,
    `latitude`       double                                                        NOT NULL,
    `longitude`      double                                                        NOT NULL,
    `name`           varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `opening_hours`  json                                                          NULL,
    `review_count`   int                                                           NOT NULL,
    `updated_at`     datetime(6)                                                   NOT NULL,
    `view_count`     bigint                                                        NOT NULL,
    `province_id`    bigint                                                        NOT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `idx_province_id` (`province_id` ASC) USING BTREE,
    INDEX `idx_category` (`category` ASC) USING BTREE,
    INDEX `idx_rating` (`average_rating` DESC) USING BTREE,
    INDEX `idx_view_count` (`view_count` DESC) USING BTREE,
    CONSTRAINT `FKhtv3orlij3aoygn4xxrct27gd` FOREIGN KEY (`province_id`) REFERENCES `provinces` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB
  AUTO_INCREMENT = 8
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of destinations
-- ----------------------------
INSERT INTO `destinations`
VALUES (1, 'Phường Bãi Cháy, Thành phố Hạ Long, Quảng Ninh', 4.80, 'BEACH', '2025-10-11 21:22:00.000000',
        '<p>Vịnh Hạ Long là một di sản thiên nhiên thế giới UNESCO, nổi tiếng với hàng ngàn đảo đá vôi, hang động kỳ bí và cảnh quan tuyệt đẹp.</p>',
        150000.00, b'1', b'1', 20.9101, 107.1839, 'Vịnh Hạ Long', '{
    \"friday\": \"08:00-17:00\",
    \"monday\": \"08:00-17:00\",
    \"sunday\": \"08:00-17:00\",
    \"tuesday\": \"08:00-17:00\",
    \"saturday\": \"08:00-17:00\",
    \"thursday\": \"08:00-17:00\",
    \"wednesday\": \"08:00-17:00\"
  }', 1200, '2025-11-17 01:45:31.227064', 50000, 1);
INSERT INTO `destinations`
VALUES (2, 'Xã Hòa Ninh, Huyện Hòa Vang, Đà Nẵng', 4.65, 'MOUNTAIN', '2025-10-11 21:30:00.000000',
        'Bà Nà Hills là khu du lịch nổi tiếng với cáp treo kỷ lục, cầu Vàng độc đáo và khí hậu mát mẻ như châu Âu.',
        750000.00, b'1', b'1', 15.9972, 107.9965, 'Bà Nà Hills', '{
    \"friday\": \"07:00-21:00\",
    \"monday\": \"07:00-21:00\",
    \"sunday\": \"07:00-21:00\",
    \"tuesday\": \"07:00-21:00\",
    \"saturday\": \"07:00-21:00\",
    \"thursday\": \"07:00-21:00\",
    \"wednesday\": \"07:00-21:00\"
  }', 950, '2025-10-11 21:30:00.000000', 32000, 2);
INSERT INTO `destinations`
VALUES (3, 'Phường 1, Thành phố Đà Lạt, Lâm Đồng', 4.70, 'BEACH', '2025-10-11 21:35:00.000000',
        'Hồ Xuân Hương nằm giữa lòng Đà Lạt, được mệnh danh là trái tim của thành phố, với cảnh quan thơ mộng và không khí trong lành.',
        0.00, b'1', b'1', 11.9411, 108.4373, 'Hồ Xuân Hương', '{
    \"friday\": \"00:00-23:59\",
    \"monday\": \"00:00-23:59\",
    \"sunday\": \"00:00-23:59\",
    \"tuesday\": \"00:00-23:59\",
    \"saturday\": \"00:00-23:59\",
    \"thursday\": \"00:00-23:59\",
    \"wednesday\": \"00:00-23:59\"
  }', 600, '2025-10-11 21:35:00.000000', 15000, 3);
INSERT INTO `destinations`
VALUES (4, 'Phường Lê Bình, Quận Cái Răng, Cần Thơ', 4.50, 'CULTURE', '2025-10-11 21:40:00.000000',
        'Chợ nổi Cái Răng là biểu tượng văn hóa sông nước miền Tây, nơi du khách trải nghiệm mua bán trên sông và khám phá đời sống địa phương.',
        0.00, b'1', b'1', 10.0123, 105.7512, 'Chợ Nổi Cái Răng', '{
    \"friday\": \"05:00-12:00\",
    \"monday\": \"05:00-12:00\",
    \"sunday\": \"05:00-12:00\",
    \"tuesday\": \"05:00-12:00\",
    \"saturday\": \"05:00-12:00\",
    \"thursday\": \"05:00-12:00\",
    \"wednesday\": \"05:00-12:00\"
  }', 800, '2025-10-11 21:40:00.000000', 20000, 4);
INSERT INTO `destinations`
VALUES (6, 'Quận Hoàn Kiếm, Hà Nội', 0.00, 'CULTURE', '2025-11-16 16:22:37.982196',
        '<p>Hồ Ho Kiếm (còn gọi là Hồ Gươm) là trái tim của Hà Nội, nằm giữa trung tâm thủ đô. Nơi đây có Tháp Rùa, Đền Ngọc Sơn, Cầu Thê Húc và gắn liền với truyền thuyết vua Lê Lợi trả gươm thần. Là điểm đến không thể bỏ qua khi đến Hà Nội.</p>',
        0.00, b'0', b'1', 21.0285, 105.8521, 'Hồ Hoàn Kiếm', '{
    \"friday\": \"7:00 - 17:00\",
    \"monday\": \"\",
    \"sunday\": \"\",
    \"tuesday\": \"8:00 - 17:00\",
    \"saturday\": \"\",
    \"thursday\": \"\",
    \"wednesday\": \"\"
  }', 0, '2025-11-18 11:06:16.413747', 0, 7);
INSERT INTO `destinations`
VALUES (7, '58 Quốc Tử Giám, Đống Đa, Hà Nội', 0.00, 'CULTURE', '2025-11-18 11:41:36.228041',
        '<p>Văn Miếu – Quốc Tử Giám là quần thể di tích lịch sử và văn hóa quốc gia đặc biệt của Việt Nam, được xem là trường đại học đầu tiên của nước ta. Nơi đây nổi tiếng với kiến trúc cổ kính, bia Tiến sĩ và là điểm tham quan hấp dẫn bậc nhất tại Hà Nội.</p>',
        0.00, b'1', b'1', 21.028119, 105.83564, 'Văn Miếu – Quốc Tử Giám', '{
    \"friday\": \"7:00 - 21:00\",
    \"monday\": \"7:00 - 21:00\",
    \"sunday\": \"7:00 - 21:00\",
    \"tuesday\": \"7:00 - 21:00\",
    \"saturday\": \"7:00 - 21:00\",
    \"thursday\": \"7:00 - 21:00\",
    \"wednesday\": \"7:00 - 21:00\"
  }', 0, '2025-11-18 11:41:36.228041', 0, 7);

-- ----------------------------
-- Table structure for email_verification_tokens
-- ----------------------------
DROP TABLE IF EXISTS `email_verification_tokens`;
CREATE TABLE `email_verification_tokens`
(
    `id`          bigint                                                        NOT NULL AUTO_INCREMENT,
    `created_at`  datetime(6)                                                   NOT NULL,
    `expiry_date` datetime(6)                                                   NOT NULL,
    `token`       varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `verified_at` datetime(6)                                                   NULL DEFAULT NULL,
    `user_id`     bigint                                                        NOT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `UKewmvysc7e9y6uy7og2c21axa9` (`token` ASC) USING BTREE,
    UNIQUE INDEX `UKs3mje1c85ftmp2uld6dt1bffs` (`user_id` ASC) USING BTREE,
    CONSTRAINT `FKi1c4mmamlb8keqt74k4lrtwhc` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB
  AUTO_INCREMENT = 45
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of email_verification_tokens
-- ----------------------------
INSERT INTO `email_verification_tokens`
VALUES (1, '2025-10-06 11:29:13.910106', '2025-10-06 12:29:13.908988', '30348ce9-c2b0-465f-9629-fd0abf0a1d23', NULL, 2);
INSERT INTO `email_verification_tokens`
VALUES (2, '2025-10-06 11:44:24.817505', '2025-10-06 12:44:24.816506', '47349cc9-74b9-47f4-a5bb-66cace54b62a', NULL, 3);
INSERT INTO `email_verification_tokens`
VALUES (5, '2025-10-06 12:00:44.188882', '2025-10-06 13:00:44.182392', 'e5415279-fee1-460d-8846-9c83950d34a0', NULL, 7);
INSERT INTO `email_verification_tokens`
VALUES (9, '2025-10-06 13:21:39.041526', '2025-10-06 14:21:39.040453', '0441f657-ef81-469f-af4c-a15a6d35f8ee',
        '2025-10-06 13:22:06.702685', 11);
INSERT INTO `email_verification_tokens`
VALUES (14, '2025-10-06 13:40:23.392103', '2025-10-06 14:40:23.391213', '259d5780-6e2c-433c-adfe-0cfdd5ee67d7',
        '2025-10-06 13:40:59.521613', 8);
INSERT INTO `email_verification_tokens`
VALUES (15, '2025-10-06 20:46:11.979210', '2025-10-06 21:46:11.976805', 'a669781c-59cd-46ea-865b-4465afa6df34', NULL,
        12);
INSERT INTO `email_verification_tokens`
VALUES (16, '2025-10-07 21:27:32.618042', '2025-10-07 22:27:32.615830', 'dc188b28-3a72-44f8-8b4a-a40f30b32920', NULL,
        13);
INSERT INTO `email_verification_tokens`
VALUES (39, '2025-10-10 21:23:36.412689', '2025-10-10 22:23:36.395274', 'd4509120-1b86-44f0-a0d2-2e0871aef668', NULL,
        14);
INSERT INTO `email_verification_tokens`
VALUES (40, '2025-10-10 21:30:42.363571', '2025-10-10 22:30:42.336952', '96a94e02-8e37-4197-81f6-06979f4c134d',
        '2025-10-10 21:31:14.295146', 10);
INSERT INTO `email_verification_tokens`
VALUES (41, '2025-10-12 14:56:13.642866', '2025-10-12 15:56:13.639824', 'afb048fb-884d-4f8b-a118-92044dad4b22', NULL,
        15);
INSERT INTO `email_verification_tokens`
VALUES (42, '2025-10-15 15:20:01.556830', '2025-10-15 16:20:01.554354', '1736095f-4a8a-41e8-9a93-d0686b2f0f83', NULL,
        16);
INSERT INTO `email_verification_tokens`
VALUES (43, '2025-10-15 15:21:20.628708', '2025-10-15 16:21:20.628030', '7972b6c0-81e2-4fc1-b037-679dd1560198',
        '2025-10-15 15:22:39.187321', 17);
INSERT INTO `email_verification_tokens`
VALUES (44, '2025-11-17 01:27:43.906246', '2025-11-17 02:27:43.905540', '521d62aa-6b90-4ad9-b6b8-ae36ba74e5e9', NULL,
        20);

-- ----------------------------
-- Table structure for hotel_images
-- ----------------------------
DROP TABLE IF EXISTS `hotel_images`;
CREATE TABLE `hotel_images`
(
    `id`            bigint                                                        NOT NULL AUTO_INCREMENT,
    `display_order` int                                                           NOT NULL,
    `image_url`     varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `is_primary`    bit(1)                                                        NOT NULL,
    `uploaded_at`   datetime(6)                                                   NOT NULL,
    `hotel_id`      bigint                                                        NOT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `FKrj3n45f8oqy1yr996g14j757i` (`hotel_id` ASC) USING BTREE,
    CONSTRAINT `FKrj3n45f8oqy1yr996g14j757i` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB
  AUTO_INCREMENT = 10
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hotel_images
-- ----------------------------
INSERT INTO `hotel_images`
VALUES (6, 1, 'https://example.com/hotel-bana1-1.jpg', b'1', '2025-10-11 22:00:00.000000', 1);
INSERT INTO `hotel_images`
VALUES (7, 0, 'https://example.com/hotel-bana1-2.jpg', b'0', '2025-10-11 22:00:00.000000', 1);
INSERT INTO `hotel_images`
VALUES (8, 1, 'https://example.com/hotel-bana2-1.jpg', b'1', '2025-10-11 22:01:00.000000', 2);
INSERT INTO `hotel_images`
VALUES (9, 0, 'https://example.com/hotel-bana2-2.jpg', b'0', '2025-10-11 22:01:00.000000', 2);

-- ----------------------------
-- Table structure for hotels
-- ----------------------------
DROP TABLE IF EXISTS `hotels`;
CREATE TABLE `hotels`
(
    `id`              bigint                                                        NOT NULL AUTO_INCREMENT,
    `address`         varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `amenities`       json                                                          NULL,
    `available_rooms` int                                                           NOT NULL,
    `average_rating`  decimal(3, 2)                                                 NULL DEFAULT NULL,
    `created_at`      datetime(6)                                                   NOT NULL,
    `description`     text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci         NULL,
    `email`           varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
    `is_active`       bit(1)                                                        NOT NULL,
    `latitude`        double                                                        NOT NULL,
    `longitude`       double                                                        NOT NULL,
    `name`            varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `phone`           varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci  NULL DEFAULT NULL,
    `price_per_night` decimal(10, 2)                                                NOT NULL,
    `review_count`    int                                                           NOT NULL,
    `star_rating`     int                                                           NOT NULL,
    `total_rooms`     int                                                           NOT NULL,
    `updated_at`      datetime(6)                                                   NOT NULL,
    `destination_id`  bigint                                                        NOT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `idx_destination_id` (`destination_id` ASC) USING BTREE,
    INDEX `idx_star_rating` (`star_rating` DESC) USING BTREE,
    CONSTRAINT `FKpocxu2e8i0q1m0f6wq280cfwl` FOREIGN KEY (`destination_id`) REFERENCES `destinations` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB
  AUTO_INCREMENT = 3
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hotels
-- ----------------------------
INSERT INTO `hotels`
VALUES (1, 'Khu du lịch Bà Nà Hills, Hòa Ninh, Hòa Vang, Đà Nẵng', '[
  \"Wifi miễn phí\",
  \"Bể bơi\",
  \"Nhà hàng\",
  \"Xe đưa đón\",
  \"Spa\"
]', 45, 4.70, '2025-10-11 21:45:00.000000',
        'Khách sạn sang trọng mang phong cách Pháp cổ điển, nằm ngay trong khu du lịch Bà Nà Hills, với tầm nhìn tuyệt đẹp trên núi.',
        'info@mercurebana.com', b'1', 15.9981, 107.9967, 'Mercure Ba Na Hills French Village', '+84 236 3799 888',
        2800000.00, 524, 5, 200, '2025-10-11 21:45:00.000000', 2);
INSERT INTO `hotels`
VALUES (2, 'Bà Nà Hills, Hòa Ninh, Hòa Vang, Đà Nẵng', '[
  \"Wifi miễn phí\",
  \"Nhà hàng\",
  \"Phòng Gym\",
  \"Bar\"
]', 25, 4.50, '2025-10-11 21:46:00.000000',
        'Khách sạn cổ điển, nằm gần hầm rượu Debay và khu vực Cầu Vàng, phù hợp cho du khách thích sự yên tĩnh và phong cách châu Âu.',
        'contact@debaybana.vn', b'1', 15.9969, 107.9959, 'Debay Hotel Ba Na Hills', '+84 236 3799 555', 1900000.00, 310,
        4, 100, '2025-10-11 21:46:00.000000', 2);

-- ----------------------------
-- Table structure for invoices
-- ----------------------------
DROP TABLE IF EXISTS `invoices`;
CREATE TABLE `invoices`
(
    `id`             bigint                                                       NOT NULL AUTO_INCREMENT,
    `created_at`     datetime(6)                                                  NOT NULL,
    `invoice_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `issue_date`     date                                                         NOT NULL,
    `item_details`   json                                                         NOT NULL,
    `tax_amount`     decimal(12, 2)                                               NULL DEFAULT NULL,
    `total_amount`   decimal(12, 2)                                               NOT NULL,
    `booking_id`     bigint                                                       NOT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `UKl1x55mfsay7co0r3m9ynvipd5` (`invoice_number` ASC) USING BTREE,
    UNIQUE INDEX `UKqn380ix1ge287r0rd8th12bwi` (`booking_id` ASC) USING BTREE,
    INDEX `idx_booking_id` (`booking_id` ASC) USING BTREE,
    INDEX `idx_invoice_number` (`invoice_number` ASC) USING BTREE,
    CONSTRAINT `FKb9bhb7xre5v64qvjeholh3qj0` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of invoices
-- ----------------------------

-- ----------------------------
-- Table structure for payments
-- ----------------------------
DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments`
(
    `id`               bigint                                                        NOT NULL AUTO_INCREMENT,
    `amount`           decimal(12, 2)                                                NOT NULL,
    `created_at`       datetime(6)                                                   NOT NULL,
    `gateway_response` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci         NULL,
    `note`             text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci         NULL,
    `paid_at`          datetime(6)                                                   NULL DEFAULT NULL,
    `payment_method`   varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci  NOT NULL,
    `status`           varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci  NOT NULL,
    `transaction_id`   varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
    `updated_at`       datetime(6)                                                   NOT NULL,
    `booking_id`       bigint                                                        NOT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `UKnuscjm6x127hkb15kcb8n56wo` (`booking_id` ASC) USING BTREE,
    UNIQUE INDEX `UKlryndveuwa4k5qthti0pkmtlx` (`transaction_id` ASC) USING BTREE,
    INDEX `idx_booking_id` (`booking_id` ASC) USING BTREE,
    INDEX `idx_transaction_id` (`transaction_id` ASC) USING BTREE,
    CONSTRAINT `FKc52o2b1jkxttngufqp3t7jr3h` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of payments
-- ----------------------------

-- ----------------------------
-- Table structure for provinces
-- ----------------------------
DROP TABLE IF EXISTS `provinces`;
CREATE TABLE `provinces`
(
    `id`          bigint                                                        NOT NULL AUTO_INCREMENT,
    `code`        varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci  NOT NULL,
    `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci         NULL,
    `image_url`   varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
    `is_popular`  bit(1)                                                        NOT NULL,
    `name`        varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `region`      varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci  NULL DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `UKdalikev902uvkpwn632apqe1k` (`code` ASC) USING BTREE,
    UNIQUE INDEX `UKl256wnwfdobq071mcq7rckr9y` (`name` ASC) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 8
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of provinces
-- ----------------------------
INSERT INTO `provinces`
VALUES (1, 'QN',
        '<p>Quảng Ninh là một tỉnh ven biển thuộc vùng Đông Bắc Bộ, nổi tiếng với Vịnh Hạ Long - di sản thiên nhiên thế giới UNESCO.</p>',
        'https://res.cloudinary.com/dcwqv4rng/image/upload/v1760192777/hrj0ytbvfe4dlaqdatjv.jpg', b'1', 'Quảng Ninh',
        'NORTH');
INSERT INTO `provinces`
VALUES (2, 'DN',
        'Đà Nẵng là thành phố biển nổi tiếng với bãi biển Mỹ Khê, cầu Rồng và Bà Nà Hills, trung tâm du lịch của miền Trung Việt Nam.',
        'https://res.cloudinary.com/dcwqv4rng/image/upload/v1760535538/tdjci9thdvu6wkpaznw5.jpg', b'1', 'Đà Nẵng',
        'CENTRAL');
INSERT INTO `provinces`
VALUES (3, 'LD',
        'Lâm Đồng là vùng cao nguyên mát mẻ, nổi tiếng với Đà Lạt - thành phố ngàn hoa, hồ Xuân Hương và các thác nước hùng vĩ.',
        'https://res.cloudinary.com/dcwqv4rng/image/upload/v1760535639/otgxinezauzwh1gxainm.jpg', b'1', 'Lâm Đồng',
        'CENTRAL_HIGHLANDS');
INSERT INTO `provinces`
VALUES (4, 'CT',
        'Cần Thơ là trung tâm của Đồng bằng sông Cửu Long, nổi tiếng với chợ nổi Cái Răng và văn hóa sông nước đặc trưng.',
        'https://res.cloudinary.com/dcwqv4rng/image/upload/v1760535642/kmvuf0s00ognaqzegetn.jpg', b'1', 'Cần Thơ',
        'SOUTH');
INSERT INTO `provinces`
VALUES (7, 'HN',
        '<p><span style=\"background-color: rgb(250, 251, 255); color: rgb(71, 71, 71);\">Hà Nội, thủ đô của Việt Nam, nổi tiếng với kiến trúc trăm tuổi và nền văn hóa phong phú với sự ảnh hưởng của khu vực Đông Nam Á, Trung Quốc và Pháp. Trung tâm thành phố là Khu phố cổ nhộn nhịp, nơi các con phố hẹp được mang tên \"hàng\". Có rất nhiều ngôi đền nhỏ, bao gồm Bạch Mã, tôn vinh một con ngựa huyền thoại, cùng với chợ Đồng Xuân, bán hàng gia dụng và thức ăn đường phố.</span></p>',
        'https://res.cloudinary.com/dcwqv4rng/image/upload/v1763271814/provinces/k3xu5wc2fd5ghvwqrwu7.jpg', b'1',
        'Hà Nội', 'Miền Bắc');

-- ----------------------------
-- Table structure for refresh_tokens
-- ----------------------------
DROP TABLE IF EXISTS `refresh_tokens`;
CREATE TABLE `refresh_tokens`
(
    `id`          bigint                                                        NOT NULL AUTO_INCREMENT,
    `expiry_date` datetime(6)                                                   NOT NULL,
    `revoked`     bit(1)                                                        NOT NULL,
    `token`       varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `user_id`     bigint                                                        NOT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `UKghpmfn23vmxfu3spu3lfg4r2d` (`token` ASC) USING BTREE,
    INDEX `FK1lih5y2npsf8u5o3vhdb9y0os` (`user_id` ASC) USING BTREE,
    CONSTRAINT `FK1lih5y2npsf8u5o3vhdb9y0os` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB
  AUTO_INCREMENT = 182
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of refresh_tokens
-- ----------------------------
INSERT INTO `refresh_tokens`
VALUES (1, '2025-10-13 15:39:24.486273', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc1OTczOTk2NCwiZXhwIjoxNzYwMzQ0NzY0fQ.9ZNx3zDk-35pGdXfSKmFESu5Z6O_m9UApWRDThCSI1Y',
        10);
INSERT INTO `refresh_tokens`
VALUES (2, '2025-10-13 18:53:56.913247', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc1OTc1MTYzNiwiZXhwIjoxNzYwMzU2NDM2fQ.fabG0rPUvtbKmCdfColA2AKuyXwXcZHKxqtaGkpRUqY',
        10);
INSERT INTO `refresh_tokens`
VALUES (3, '2025-10-13 19:43:04.641193', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc1OTc1NDU4NCwiZXhwIjoxNzYwMzU5Mzg0fQ.6118wQsp2KNKLc9VCFJoCnd8rsetRN9LC_GRlWzZZl4',
        10);
INSERT INTO `refresh_tokens`
VALUES (4, '2025-10-13 19:43:12.408374', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc1OTc1NDU5MiwiZXhwIjoxNzYwMzU5MzkyfQ.QJs1h2RrLuIvNE-1WqnAQ8x0DQBayslXCtyqQHjiENM',
        10);
INSERT INTO `refresh_tokens`
VALUES (5, '2025-10-13 19:43:45.582577', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc1OTc1NDYyNSwiZXhwIjoxNzYwMzU5NDI1fQ.U5VQcbd9ACixKX8pLi4e8yIlGFDtMUZissSCQ9EXGck',
        10);
INSERT INTO `refresh_tokens`
VALUES (6, '2025-10-13 19:46:38.364460', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc1OTc1NDc5OCwiZXhwIjoxNzYwMzU5NTk4fQ.ISoXcETcusOHYE8c5FbiPXm_xcZ8lOcbvSjFFyYm33k',
        10);
INSERT INTO `refresh_tokens`
VALUES (7, '2025-10-13 19:48:03.047757', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc1OTc1NDg4MywiZXhwIjoxNzYwMzU5NjgzfQ.KSvV3G8nJeb6LYCElVRRylVtiYWANCBMjtk_DTeFTws',
        10);
INSERT INTO `refresh_tokens`
VALUES (8, '2025-10-13 19:49:32.461553', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc1OTc1NDk3MiwiZXhwIjoxNzYwMzU5NzcyfQ.dHrmOav-0p7fqdXzC_MUHJMyTIRc2t-FWZ8_kT95GY8',
        10);
INSERT INTO `refresh_tokens`
VALUES (9, '2025-10-13 20:44:44.749216', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc1OTc1ODI4NCwiZXhwIjoxNzYwMzYzMDg0fQ.w53u0DwjgjTyY-NypaaRx44qWrXfbjUuRB60Hl__Ysw',
        10);
INSERT INTO `refresh_tokens`
VALUES (10, '2025-10-13 20:44:47.165980', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc1OTc1ODI4NywiZXhwIjoxNzYwMzYzMDg3fQ.873tdVcKJ9Hwxi15hhTBNkNtPpN-08vYqlBhV_2A3A4',
        10);
INSERT INTO `refresh_tokens`
VALUES (11, '2025-10-13 20:51:27.760230', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc1OTc1ODY4NywiZXhwIjoxNzYwMzYzNDg3fQ.1rE5pn3ztOhjTuYb7TzZ1F1aLJ5e_KrOePNdeqlOG-A',
        10);
INSERT INTO `refresh_tokens`
VALUES (12, '2025-10-13 20:58:55.319357', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc1OTc1OTEzNSwiZXhwIjoxNzYwMzYzOTM1fQ.NgU_qjCZeW4ZQ3kNrmK01LjSY5sifepDJPMMPKVmhgQ',
        10);
INSERT INTO `refresh_tokens`
VALUES (15, '2025-10-13 20:59:29.610980', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc1OTc1OTE2OSwiZXhwIjoxNzYwMzYzOTY5fQ.SvmRwKU4ZPWhXVcEH3lD6MRHmdXZu5VSvrORiMsiyxg',
        10);
INSERT INTO `refresh_tokens`
VALUES (16, '2025-10-14 21:27:50.020703', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc1OTg0NzI3MCwiZXhwIjoxNzYwNDUyMDcwfQ.Lgsb-PMew7bRbXEMkPOWed8N0FX7snBKnky3lLuPBH8',
        10);
INSERT INTO `refresh_tokens`
VALUES (17, '2025-10-14 21:27:55.520144', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc1OTg0NzI3NSwiZXhwIjoxNzYwNDUyMDc1fQ.2XJKkEF964jHHpdQ8ALjP13HDIJCvE4MWqzUEU7VCEg',
        10);
INSERT INTO `refresh_tokens`
VALUES (18, '2025-10-14 21:28:54.810502', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc1OTg0NzMzNCwiZXhwIjoxNzYwNDUyMTM0fQ.YjzMPChSzqZnc4IHpzx8kdYMwvhxq-gYXcjemTyi1-U',
        10);
INSERT INTO `refresh_tokens`
VALUES (19, '2025-10-14 21:32:14.302789', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc1OTg0NzUzNCwiZXhwIjoxNzYwNDUyMzM0fQ.el6xOouDIPAcICjZbNI0ZGTQIJTrE8pwk1xAl6Ofeoo',
        10);
INSERT INTO `refresh_tokens`
VALUES (20, '2025-10-15 16:28:18.152927', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc1OTkxNTY5OCwiZXhwIjoxNzYwNTIwNDk4fQ.yicOPjlJfvXwoc58UsFDibCcWCXaAcge_MNQFf207CE',
        10);
INSERT INTO `refresh_tokens`
VALUES (21, '2025-10-17 21:31:49.289989', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MDEwNjcwOSwiZXhwIjoxNzYwNzExNTA5fQ.aUMRVZBPNFuXyF-z3ZLnGSaOMfFvClfvr9gKykYxXng',
        10);
INSERT INTO `refresh_tokens`
VALUES (22, '2025-10-22 15:08:19.135801', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYwNTE1Njk5LCJleHAiOjE3NjExMjA0OTl9.RLAPCshQ7qWUrCZZY3Dt6UAVCRd0tEuX6bFuMTUlKH0',
        1);
INSERT INTO `refresh_tokens`
VALUES (23, '2025-10-22 15:08:32.838652', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYwNTE1NzEyLCJleHAiOjE3NjExMjA1MTJ9.uD1vy87qiNSULTWgu3JvqY3F6Mi8OVUS6dGIyhVXZvQ',
        1);
INSERT INTO `refresh_tokens`
VALUES (24, '2025-10-22 15:09:22.948061', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYwNTE1NzYyLCJleHAiOjE3NjExMjA1NjJ9.u9Sj-8T_yqDHlygWkAOraHgcwV-PdOZdwYeAPVLj2TI',
        1);
INSERT INTO `refresh_tokens`
VALUES (25, '2025-10-22 15:09:36.958364', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYwNTE1Nzc2LCJleHAiOjE3NjExMjA1NzZ9.HjNhXucWbDMLi0-bMaJ18ErUPXwRC8kYH4vR83jbqjQ',
        1);
INSERT INTO `refresh_tokens`
VALUES (26, '2025-10-22 15:13:56.712643', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MDUxNjAzNiwiZXhwIjoxNzYxMTIwODM2fQ.hUkVhDDKelJaStuW92OW9bJuBuzwlnfzJjZbTTN1Ejo',
        10);
INSERT INTO `refresh_tokens`
VALUES (27, '2025-10-22 15:17:35.882834', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MDUxNjI1NSwiZXhwIjoxNzYxMTIxMDU1fQ.jIxoLKtkryQG3GWgk2h4QQykMb7KksaeoHPgpx6E2gQ',
        10);
INSERT INTO `refresh_tokens`
VALUES (28, '2025-10-22 15:23:46.244890', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxNyIsImlhdCI6MTc2MDUxNjYyNiwiZXhwIjoxNzYxMTIxNDI2fQ.H6Rzh6at3e28T1PYuJ8lv_CpYCj-XImjKv5ikO77_NM',
        17);
INSERT INTO `refresh_tokens`
VALUES (29, '2025-10-22 19:27:19.363329', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MDUzMTIzOSwiZXhwIjoxNzYxMTM2MDM5fQ.RCR4bP1ryFvf22BEMYSy0uvOjKAy43CG9rGew_V7HXQ',
        10);
INSERT INTO `refresh_tokens`
VALUES (30, '2025-10-22 19:30:11.224391', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MDUzMTQxMSwiZXhwIjoxNzYxMTM2MjExfQ.xZuVnLLh6lZ2qrqU4bPX3VGYYiaMv_ogHZtvemMfUW0',
        10);
INSERT INTO `refresh_tokens`
VALUES (31, '2025-10-22 20:12:33.881949', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MDUzMzk1MywiZXhwIjoxNzYxMTM4NzUzfQ.ih6bRsTA_wdOeGVwyTqkmsAynegZWccigHcjeNy7-Ug',
        10);
INSERT INTO `refresh_tokens`
VALUES (32, '2025-10-22 20:49:40.744222', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MDUzNjE4MCwiZXhwIjoxNzYxMTQwOTgwfQ.IuyTOTy6C_GWkwmoIIAiemLv7g-aCPe2iIAZxOdi-Js',
        10);
INSERT INTO `refresh_tokens`
VALUES (33, '2025-10-22 20:51:10.653838', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MDUzNjI3MCwiZXhwIjoxNzYxMTQxMDcwfQ.SxJ61Try2t6L1MWlb8xrps85KDc-sty6usjauotmg8Q',
        10);
INSERT INTO `refresh_tokens`
VALUES (34, '2025-10-22 21:06:35.460586', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MDUzNzE5NSwiZXhwIjoxNzYxMTQxOTk1fQ.WneqT-CwsDBlGzLlDELe0CAqDupNYocfLzu8NgcAWvE',
        10);
INSERT INTO `refresh_tokens`
VALUES (35, '2025-10-22 21:11:33.336289', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MDUzNzQ5MywiZXhwIjoxNzYxMTQyMjkzfQ.oUDuD3Fv0nmim3slscA5DqoHTQLJbzOKh2OKz6thFJg',
        10);
INSERT INTO `refresh_tokens`
VALUES (36, '2025-10-27 10:22:35.777735', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MDkzMDU1NSwiZXhwIjoxNzYxNTM1MzU1fQ.gyPvfcSS5CoJ31yDrGpsGpzpTbFPy6CmdEEswY1Bk1U',
        10);
INSERT INTO `refresh_tokens`
VALUES (37, '2025-10-27 15:05:40.121754', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MDk0NzU0MCwiZXhwIjoxNzYxNTUyMzQwfQ.b5dO7LrJlQJtYmXGo5cMYbf5BdX34nDhc16x24dwOOQ',
        10);
INSERT INTO `refresh_tokens`
VALUES (38, '2025-10-27 15:08:17.587553', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MDk0NzY5NywiZXhwIjoxNzYxNTUyNDk3fQ.flHL9PD-yD5G4WS3L4RVfKWfsNX-cGjdWQKfRNgkRvU',
        10);
INSERT INTO `refresh_tokens`
VALUES (39, '2025-10-27 15:24:40.317722', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MDk0ODY4MCwiZXhwIjoxNzYxNTUzNDgwfQ.qMUw2woQstf0R3LyMxUKMAN4cBDpRzHDop8Jsh4Sty8',
        10);
INSERT INTO `refresh_tokens`
VALUES (40, '2025-10-27 16:11:17.318296', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MDk1MTQ3NywiZXhwIjoxNzYxNTU2Mjc3fQ.xLOlLnjq3NOYM-I3ndn2mz-9CxLXRalvDV0Gr9opmG8',
        10);
INSERT INTO `refresh_tokens`
VALUES (41, '2025-10-27 16:26:53.184920', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MDk1MjQxMywiZXhwIjoxNzYxNTU3MjEzfQ.OKKCq2cziQYin9Zruqo1hN5mXEATKUA2Lp8RJAcBjDg',
        10);
INSERT INTO `refresh_tokens`
VALUES (42, '2025-10-31 18:58:44.063446', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MTMwNzEyNCwiZXhwIjoxNzYxOTExOTI0fQ.XFpoYS75FPmGngZthT-fthpmLm1eoia4FWnzGV5TxqE',
        10);
INSERT INTO `refresh_tokens`
VALUES (43, '2025-11-01 21:45:57.394310', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTQwMzU1NywiZXhwIjoxNzYyMDA4MzU3fQ.9897oJ4I_EAeLDCWEWVImZiXfhsCwYVNdtbJ0QnHNqw',
        18);
INSERT INTO `refresh_tokens`
VALUES (44, '2025-11-01 21:47:08.770526', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTQwMzYyOCwiZXhwIjoxNzYyMDA4NDI4fQ.kchzhenhzFmyzvHjZyBM__I4PJMNzPZb3y8nKk1YaY8',
        18);
INSERT INTO `refresh_tokens`
VALUES (45, '2025-11-01 22:13:16.089824', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTQwNTE5NiwiZXhwIjoxNzYyMDA5OTk2fQ.lSQqU2Q36BE5CZaDMiUEnXb4DKnmTUqRmQ_B4xcHfVA',
        18);
INSERT INTO `refresh_tokens`
VALUES (46, '2025-11-01 22:15:22.622016', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTQwNTMyMiwiZXhwIjoxNzYyMDEwMTIyfQ.gqFkqrGUwXkec-kSgq7nslvqp04lhCud1HjWXAK7ltc',
        18);
INSERT INTO `refresh_tokens`
VALUES (47, '2025-11-02 00:05:13.834616', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTQxMTkxMywiZXhwIjoxNzYyMDE2NzEzfQ.xS5mKwyIxjxB7sCxmlXR9iqxXOJRjZvOmXWC-hp4p40',
        18);
INSERT INTO `refresh_tokens`
VALUES (48, '2025-11-02 14:05:41.443040', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTQ2MjM0MSwiZXhwIjoxNzYyMDY3MTQxfQ.QNOtisiSy0WD3FeGlclpTokaAjHvN5SI6K892aUu5CM',
        18);
INSERT INTO `refresh_tokens`
VALUES (49, '2025-11-02 16:08:53.294680', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTQ2OTczMywiZXhwIjoxNzYyMDc0NTMzfQ.-n1MVXUDB6CHvUwBW3Wa4XYqDBSz1hNSFJ43gFVzmvE',
        18);
INSERT INTO `refresh_tokens`
VALUES (50, '2025-11-02 16:14:44.372078', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTQ3MDA4NCwiZXhwIjoxNzYyMDc0ODg0fQ.54DCgOWq3D3DuxITl5BKzb49xdHqHJCoqsL1zWdFZ8E',
        18);
INSERT INTO `refresh_tokens`
VALUES (51, '2025-11-02 16:16:09.039003', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTQ3MDE2OSwiZXhwIjoxNzYyMDc0OTY5fQ.0vJ6MMxWYYUCNAtSOUjgcOHVbtlEUEhdF1dYIfX24xE',
        18);
INSERT INTO `refresh_tokens`
VALUES (52, '2025-11-02 16:19:12.355267', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTQ3MDM1MiwiZXhwIjoxNzYyMDc1MTUyfQ.BcaRP2TXJJ-zwQWRcEPWiUyaEV0OOIbF0wCs_VOraoE',
        18);
INSERT INTO `refresh_tokens`
VALUES (53, '2025-11-02 18:12:50.160177', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTQ3NzE3MCwiZXhwIjoxNzYyMDgxOTcwfQ.H8dNU6vyQxunG0WWQJ0eXpAobIhTSr3bAbHQH5ldjqA',
        18);
INSERT INTO `refresh_tokens`
VALUES (54, '2025-11-02 18:26:58.522405', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTQ3ODAxOCwiZXhwIjoxNzYyMDgyODE4fQ.plm3KVkdJkU6jFirLpTw6WT2cqMnnMPpX09g0nKytfw',
        18);
INSERT INTO `refresh_tokens`
VALUES (55, '2025-11-02 19:48:08.280529', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTQ4Mjg4OCwiZXhwIjoxNzYyMDg3Njg4fQ.yUMbtGw7yDL7eHemg5Xuq7HFoYH7NT8aG1jcojOtbCs',
        18);
INSERT INTO `refresh_tokens`
VALUES (56, '2025-11-02 20:05:03.172202', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTQ4MzkwMywiZXhwIjoxNzYyMDg4NzAzfQ.Ftz8xEb4BwtXRw9b6kOFbFDh2HO1NdwyoGsY3gMSyUQ',
        18);
INSERT INTO `refresh_tokens`
VALUES (57, '2025-11-02 20:19:17.793753', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTQ4NDc1NywiZXhwIjoxNzYyMDg5NTU3fQ.VE5_9gH04kuV3F0Oi8YIlxYPNaiTQWMaSe0PnusaQkY',
        18);
INSERT INTO `refresh_tokens`
VALUES (58, '2025-11-02 20:33:49.244717', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTQ4NTYyOSwiZXhwIjoxNzYyMDkwNDI5fQ.bPrKwTARTB9RFfzpEZ6_QnDr3P-QEgJyeX6jWVMOrAI',
        18);
INSERT INTO `refresh_tokens`
VALUES (59, '2025-11-02 20:35:12.694644', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTQ4NTcxMiwiZXhwIjoxNzYyMDkwNTEyfQ.uRH0BUFeKBtgHuXelRsqck0MLcz9U0tyO2dwDnGBMr8',
        18);
INSERT INTO `refresh_tokens`
VALUES (60, '2025-11-02 20:37:38.067200', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTQ4NTg1OCwiZXhwIjoxNzYyMDkwNjU4fQ.cvhITG77ukshnAp4XdPKSd7k29_WLwYjlUmvcsteDkA',
        18);
INSERT INTO `refresh_tokens`
VALUES (61, '2025-11-03 13:55:35.817891', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTU0ODEzNSwiZXhwIjoxNzYyMTUyOTM1fQ.5WP149nPeL8Mb4o5_1uPahqtfzhQ96Np2PZ9O1gxb-w',
        18);
INSERT INTO `refresh_tokens`
VALUES (62, '2025-11-04 11:27:23.424026', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTYyNTY0MywiZXhwIjoxNzYyMjMwNDQzfQ.Gv3VKX1jGf7Kek2PX9is6EkuVRc80LS4IslHf9XT0cg',
        18);
INSERT INTO `refresh_tokens`
VALUES (63, '2025-11-04 17:38:46.944545', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTY0NzkyNiwiZXhwIjoxNzYyMjUyNzI2fQ.XnkS0SCjbh1Zr8YJbKmdSfqia1Ik02a9GpdwjmoM9ZQ',
        18);
INSERT INTO `refresh_tokens`
VALUES (64, '2025-11-04 17:41:07.336024', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTY0ODA2NywiZXhwIjoxNzYyMjUyODY3fQ.tWD2AVgp7Xda7qDoMGSxaQkDxtuobeMwSnMkZoJgw9U',
        18);
INSERT INTO `refresh_tokens`
VALUES (65, '2025-11-04 17:45:08.261430', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTY0ODMwOCwiZXhwIjoxNzYyMjUzMTA4fQ.0OUaKeCo9j8evUWtztHjynjtwMWMnwo72Nr9enev-Pc',
        18);
INSERT INTO `refresh_tokens`
VALUES (66, '2025-11-04 17:49:45.670738', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTY0ODU4NSwiZXhwIjoxNzYyMjUzMzg1fQ.pqVWMKTHcYXcU_XUY8P7_rLN3l1za8SWuVA3ZSTh1_g',
        18);
INSERT INTO `refresh_tokens`
VALUES (67, '2025-11-04 17:51:37.646627', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTY0ODY5NywiZXhwIjoxNzYyMjUzNDk3fQ.kfVnUfok9q3AWEighkpY___QqvzK-gMFUlxY6uWFnsA',
        18);
INSERT INTO `refresh_tokens`
VALUES (68, '2025-11-04 17:54:19.796304', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTY0ODg1OSwiZXhwIjoxNzYyMjUzNjU5fQ.nqX3s5AUR_UAmgtQTAobJ6etiD8pYNTjvBZowA33Bvc',
        18);
INSERT INTO `refresh_tokens`
VALUES (69, '2025-11-04 18:27:44.145483', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTY1MDg2NCwiZXhwIjoxNzYyMjU1NjY0fQ.zplV2vOlTPVUikuUwCC8ochwFQ__ZcVTYwXLNxErj9E',
        18);
INSERT INTO `refresh_tokens`
VALUES (70, '2025-11-04 19:17:43.220190', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTY1Mzg2MywiZXhwIjoxNzYyMjU4NjYzfQ.0llBzLXhGwgU900jddR3QbhsbjfXgye3shH0bxOITOc',
        18);
INSERT INTO `refresh_tokens`
VALUES (71, '2025-11-04 19:28:52.572012', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTY1NDUzMiwiZXhwIjoxNzYyMjU5MzMyfQ.asNsi2cYViPNjoKYMmXWoYgKI73zzY78cH-UMI7Ixc8',
        18);
INSERT INTO `refresh_tokens`
VALUES (72, '2025-11-04 19:37:47.697237', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTY1NTA2NywiZXhwIjoxNzYyMjU5ODY3fQ.UeG6VGYFJrtCd8hVSBeFTjPNZpZbHb4oZo00s2dAVlU',
        18);
INSERT INTO `refresh_tokens`
VALUES (73, '2025-11-04 19:38:41.326796', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTY1NTEyMSwiZXhwIjoxNzYyMjU5OTIxfQ.vsk5i4LT3LzqIALINE-puRIvpVrLktFVO7Kdv2-KHPw',
        18);
INSERT INTO `refresh_tokens`
VALUES (74, '2025-11-04 20:27:19.193804', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTY1ODAzOSwiZXhwIjoxNzYyMjYyODM5fQ.5LvN_uYOekWWZTEKCN6nNNbYdj6CYVqThWgn2hQDFV4',
        18);
INSERT INTO `refresh_tokens`
VALUES (75, '2025-11-04 20:37:26.611854', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTY1ODY0NiwiZXhwIjoxNzYyMjYzNDQ2fQ.cY54YpKqYOE1t7YGbPGUSSqa0dAtZBLoh6UR7QA9Y5k',
        18);
INSERT INTO `refresh_tokens`
VALUES (76, '2025-11-04 21:14:37.794625', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTY2MDg3NywiZXhwIjoxNzYyMjY1Njc3fQ.gqMiIFvjW23RmRcJqeQ1OPbO_zeOHZh9ltQHan1VmB8',
        18);
INSERT INTO `refresh_tokens`
VALUES (77, '2025-11-05 14:20:06.199328', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTcyMjQwNiwiZXhwIjoxNzYyMzI3MjA2fQ.XWLiR_ZqAg3I1pBxS6IBKLha8di7LJFNuOii0QXknt8',
        18);
INSERT INTO `refresh_tokens`
VALUES (78, '2025-11-05 14:38:36.613223', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTcyMzUxNiwiZXhwIjoxNzYyMzI4MzE2fQ.WHhhl0RcIs_2Se40yvQO_3P0n12M50FSqq4Be2h3lR0',
        18);
INSERT INTO `refresh_tokens`
VALUES (79, '2025-11-05 14:58:33.209289', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTcyNDcxMywiZXhwIjoxNzYyMzI5NTEzfQ.zhDK1HlWJEqUpLgpmeJUARw4HsqOHVhyIDE7hy-3yWE',
        18);
INSERT INTO `refresh_tokens`
VALUES (80, '2025-11-05 15:05:41.327884', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTcyNTE0MSwiZXhwIjoxNzYyMzI5OTQxfQ.wJocHJ74eHTtIJutqrbIwT7W-ce16UHUsa4H1WrJSIg',
        18);
INSERT INTO `refresh_tokens`
VALUES (81, '2025-11-05 15:27:34.312851', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTcyNjQ1NCwiZXhwIjoxNzYyMzMxMjU0fQ.3D4eIxI6Z-1q8oiCGyXaY7cTQ-YvBCCaINmiD5O7Zao',
        18);
INSERT INTO `refresh_tokens`
VALUES (82, '2025-11-05 15:31:32.805966', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTcyNjY5MiwiZXhwIjoxNzYyMzMxNDkyfQ.zipfw7gtHczRDctyzaPFX6cWsMwcFO8FyH7x6qjRnDI',
        18);
INSERT INTO `refresh_tokens`
VALUES (83, '2025-11-05 16:04:55.834171', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTcyODY5NSwiZXhwIjoxNzYyMzMzNDk1fQ.GvaIpOWOMW-q1WzZLLHvP3cn8Izu4SfOq73zb70d9mk',
        18);
INSERT INTO `refresh_tokens`
VALUES (84, '2025-11-05 16:17:14.233192', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTcyOTQzNCwiZXhwIjoxNzYyMzM0MjM0fQ.H44-05P28fuNGIvi9dFLzUW-DaYTMSY7labhZlvMyHY',
        18);
INSERT INTO `refresh_tokens`
VALUES (85, '2025-11-05 16:20:15.141015', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTcyOTYxNSwiZXhwIjoxNzYyMzM0NDE1fQ.EItXzOAn3bZ86p6gAHeW0AGlN9G_xeBgwnsr9XqZebg',
        18);
INSERT INTO `refresh_tokens`
VALUES (86, '2025-11-05 19:00:04.148658', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTczOTIwNCwiZXhwIjoxNzYyMzQ0MDA0fQ.QTKln3rZ21WtEYOIrYIofS4VjkW2ZZ9g59nwxQQ6Zn8',
        18);
INSERT INTO `refresh_tokens`
VALUES (87, '2025-11-05 19:46:24.086933', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTc0MTk4NCwiZXhwIjoxNzYyMzQ2Nzg0fQ.YLYCNnyAKF-pXaB4fuZxDMKBl6k5ybI6rhX8pQe4V3g',
        18);
INSERT INTO `refresh_tokens`
VALUES (88, '2025-11-05 19:50:25.104825', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTc0MjIyNSwiZXhwIjoxNzYyMzQ3MDI1fQ.JCZf95nK3pjeKfJFfrwlM4zAE6dqNIfGMCMj5lgx8Ho',
        18);
INSERT INTO `refresh_tokens`
VALUES (89, '2025-11-05 20:21:11.607981', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTc0NDA3MSwiZXhwIjoxNzYyMzQ4ODcxfQ.TcU6gT0SJ_KE17-q5_De0hBBkTKyS-UUjZwUUgfvvbE',
        18);
INSERT INTO `refresh_tokens`
VALUES (90, '2025-11-05 20:23:31.805064', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MTc0NDIxMSwiZXhwIjoxNzYyMzQ5MDExfQ.Ft6BtquHhD_Pxf1zmyiUsSkQ0kbMGprDGC5p8lebRbg',
        18);
INSERT INTO `refresh_tokens`
VALUES (91, '2025-11-16 12:56:18.572021', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MjY2Nzc3OCwiZXhwIjoxNzYzMjcyNTc4fQ.r8MEicf3p213QVofGg5QpirWlDDX1-EKVakukK-5I3I',
        18);
INSERT INTO `refresh_tokens`
VALUES (92, '2025-11-16 16:25:46.430277', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MjY4MDM0NiwiZXhwIjoxNzYzMjg1MTQ2fQ.3aMQQPdeN2d5F0lJjc_pCmXLWFIxcvKqg5H68sNWJcA',
        18);
INSERT INTO `refresh_tokens`
VALUES (93, '2025-11-16 16:31:16.862679', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MjY4MDY3NiwiZXhwIjoxNzYzMjg1NDc2fQ.-b_q_Asfv0UM_cOytBZ67FFEiH8G7kngY4LSRRzJMzk',
        18);
INSERT INTO `refresh_tokens`
VALUES (94, '2025-11-16 19:11:58.779307', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MjY5MDMxOCwiZXhwIjoxNzYzMjk1MTE4fQ.WYd1VNxe6PoEXY7RFTzxACGJCDhjV0np-2lTpnOSAX8',
        18);
INSERT INTO `refresh_tokens`
VALUES (95, '2025-11-16 19:17:14.786861', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MjY5MDYzNCwiZXhwIjoxNzYzMjk1NDM0fQ.zrJ_iUpyBXNUODlyasGIB7ZDjEfX6cquyYNUSvIx9X8',
        18);
INSERT INTO `refresh_tokens`
VALUES (96, '2025-11-16 19:54:12.581180', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MjY5Mjg1MiwiZXhwIjoxNzYzMjk3NjUyfQ.ld6oZSHyUMHNKAN9iJpmOVRVhob4DecYtD4nZ1RynIo',
        18);
INSERT INTO `refresh_tokens`
VALUES (97, '2025-11-19 11:49:01.038895', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MjkyMjk0MSwiZXhwIjoxNzYzNTI3NzQxfQ.WEbCVN7BgyiwqhijKY8pEHBZUWlpYdPIwb3XmK6ZGEE',
        10);
INSERT INTO `refresh_tokens`
VALUES (98, '2025-11-19 12:02:40.232615', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMCIsImlhdCI6MTc2MjkyMzc2MCwiZXhwIjoxNzYzNTI4NTYwfQ.kh4mDeP4gNa8TGGXYMHFg368nmk2m-WT-UOGdBL9C6s',
        10);
INSERT INTO `refresh_tokens`
VALUES (99, '2025-11-19 12:03:51.418404', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTIzODMxLCJleHAiOjE3NjM1Mjg2MzF9.bcVZSHatEC55Ir-cw4LJMw1Q1F6mxGe1NbgVjguZY2o',
        1);
INSERT INTO `refresh_tokens`
VALUES (100, '2025-11-19 12:35:43.875929', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTI1NzQzLCJleHAiOjE3NjM1MzA1NDN9.25vcJczrjwrVZuLjiR9vmhvvrM2MMEvkIV68qiU9bNE',
        1);
INSERT INTO `refresh_tokens`
VALUES (101, '2025-11-19 14:53:46.423642', b'1',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTM0MDI2LCJleHAiOjE3NjM1Mzg4MjZ9.nDrRVYZEsqtIQmGK_bQvY57E3KQZl2KV85NJnqTiWpc',
        1);
INSERT INTO `refresh_tokens`
VALUES (102, '2025-11-19 15:35:03.012662', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTM2NTAzLCJleHAiOjE3NjM1NDEzMDN9.8B7sRVV5Dvs4i7mmMWT8hCXI9HDjpKuIoE0kg8bD0Rw',
        1);
INSERT INTO `refresh_tokens`
VALUES (103, '2025-11-19 15:35:08.162735', b'1',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTM2NTA4LCJleHAiOjE3NjM1NDEzMDh9.MlT-hcgwpCWAS4-V7A5gKu1SXSADhWdaqy7k70kExMs',
        1);
INSERT INTO `refresh_tokens`
VALUES (104, '2025-11-19 16:32:48.341400', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTM5OTY4LCJleHAiOjE3NjM1NDQ3Njh9.pNKjG2kyN7a3xhcSq5g5uXUwNFpS-0CwjyZM2-Z3IMs',
        1);
INSERT INTO `refresh_tokens`
VALUES (105, '2025-11-19 16:34:25.491469', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQwMDY1LCJleHAiOjE3NjM1NDQ4NjV9.joOoG4iDQkfI0DDFBFE4AMd30FQ-f4XruN6KBjNsPes',
        1);
INSERT INTO `refresh_tokens`
VALUES (106, '2025-11-19 16:34:54.748905', b'1',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQwMDk0LCJleHAiOjE3NjM1NDQ4OTR9.BUhsSvEH9ukRWQqOOV7brIM7g9TpOWw5XvYxIIowfiQ',
        1);
INSERT INTO `refresh_tokens`
VALUES (107, '2025-11-19 17:12:01.084540', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyMzIxLCJleHAiOjE3NjM1NDcxMjF9.UIKpXXjFwMj4nKhMXNPIvnuIXOU_xGHoGPnJ6SgqVi0',
        1);
INSERT INTO `refresh_tokens`
VALUES (108, '2025-11-19 17:12:09.741525', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyMzI5LCJleHAiOjE3NjM1NDcxMjl9.JZ5sLm8CdI1l5Hq6ZqnV0qQFaMWETdM1JgbO7f4rwnc',
        1);
INSERT INTO `refresh_tokens`
VALUES (109, '2025-11-19 17:13:22.896675', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyNDAyLCJleHAiOjE3NjM1NDcyMDJ9.xn86SAC69x02asDd-wmld2DPG0ekOSTL-KA122yi7F0',
        1);
INSERT INTO `refresh_tokens`
VALUES (110, '2025-11-19 17:14:34.651637', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyNDc0LCJleHAiOjE3NjM1NDcyNzR9.TCZubxufUs9eOc6PSfhNWXiKOkkQGZWsVITBcsovyXY',
        1);
INSERT INTO `refresh_tokens`
VALUES (111, '2025-11-19 17:14:56.241498', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyNDk2LCJleHAiOjE3NjM1NDcyOTZ9.mcRV9voBOtQA_ye8wat8G8rp7I6-XztXflk0C2BbRdM',
        1);
INSERT INTO `refresh_tokens`
VALUES (112, '2025-11-19 17:15:19.651980', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyNTE5LCJleHAiOjE3NjM1NDczMTl9.xQ9-BwR0zRPJT7W0-S_aZ5fPcpZX7EZSxKbkbpOcsLc',
        1);
INSERT INTO `refresh_tokens`
VALUES (113, '2025-11-19 17:15:38.931128', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyNTM4LCJleHAiOjE3NjM1NDczMzh9.ZBNQNwZ3vjguSvvT1AFwwi9JeVhSkHzNz5JZSBqH2Ic',
        1);
INSERT INTO `refresh_tokens`
VALUES (114, '2025-11-19 17:19:42.713071', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyNzgyLCJleHAiOjE3NjM1NDc1ODJ9.nGRVFY8rgLOchaBMZRracuAE1UCVZVhoiqSIkx2cBaA',
        1);
INSERT INTO `refresh_tokens`
VALUES (115, '2025-11-19 17:19:47.604358', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyNzg3LCJleHAiOjE3NjM1NDc1ODd9.Kh5JhBy8oCzsxC5oxYT-A5kMsofEEfLHswwiNvRfP_c',
        1);
INSERT INTO `refresh_tokens`
VALUES (116, '2025-11-19 17:19:48.255748', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyNzg4LCJleHAiOjE3NjM1NDc1ODh9.PUd50vliOju3CVM6MSK9cR3SDKx1--RGfVYcUhhpH0w',
        1);
INSERT INTO `refresh_tokens`
VALUES (117, '2025-11-19 17:19:49.345772', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyNzg5LCJleHAiOjE3NjM1NDc1ODl9.roaSSY7UMQL_rMxw_iL66_BUsbF0Y6uNAb6Y94HNGWQ',
        1);
INSERT INTO `refresh_tokens`
VALUES (118, '2025-11-19 17:19:50.085344', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyNzkwLCJleHAiOjE3NjM1NDc1OTB9.aYwdMqcPFYE7Y8IvcqFDSM4HCYK8kBizfRiwDTfLEG0',
        1);
INSERT INTO `refresh_tokens`
VALUES (119, '2025-11-19 17:19:56.540260', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyNzk2LCJleHAiOjE3NjM1NDc1OTZ9.VF6Ih4vTxuP9txHEXcBWMxdourrZXyNk9NZgEgSbpoM',
        1);
INSERT INTO `refresh_tokens`
VALUES (120, '2025-11-19 17:19:57.129024', b'1',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyNzk3LCJleHAiOjE3NjM1NDc1OTd9.lNdXOpc6w14_2KFkmbk6TZrDOysEwKngenrKgSio7rc',
        1);
INSERT INTO `refresh_tokens`
VALUES (121, '2025-11-19 17:20:32.827582', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyODMyLCJleHAiOjE3NjM1NDc2MzJ9.uCVqOZwp7on-q9LRRvmVs95NJjBw2nXzOx2pzim-0i8',
        1);
INSERT INTO `refresh_tokens`
VALUES (122, '2025-11-19 17:20:34.257802', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyODM0LCJleHAiOjE3NjM1NDc2MzR9.woS-JY7QW0hSj8YNSB0ADK4cJpqF1jQfeqB_OlHgDsI',
        1);
INSERT INTO `refresh_tokens`
VALUES (125, '2025-11-19 17:20:36.393812', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyODM2LCJleHAiOjE3NjM1NDc2MzZ9.iUbTSmxamVyD0ykeD-bAI__QLk4y3m1AaL-IrkQEYCY',
        1);
INSERT INTO `refresh_tokens`
VALUES (126, '2025-11-19 17:20:37.225087', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyODM3LCJleHAiOjE3NjM1NDc2Mzd9.iPSDnTwc_DlaqX4IP21x75One9SkOG4a_INGN68PkHg',
        1);
INSERT INTO `refresh_tokens`
VALUES (129, '2025-11-19 17:20:39.629712', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyODM5LCJleHAiOjE3NjM1NDc2Mzl9.TZnqPtps0gpJvNQp4ZDtRd9QKhFe8sZTc7GRSuCjc5Y',
        1);
INSERT INTO `refresh_tokens`
VALUES (130, '2025-11-19 17:20:40.388488', b'1',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyODQwLCJleHAiOjE3NjM1NDc2NDB9.7g1RD7Ots31ZD4sKTXMTgOfXkabdLL9OE-4L9XfsELA',
        1);
INSERT INTO `refresh_tokens`
VALUES (131, '2025-11-19 17:22:04.113001', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyOTI0LCJleHAiOjE3NjM1NDc3MjR9.HBJjyAQEN_w5dZLf2rXp5Lj7eAfX2w_Yv1iHfyMkRdE',
        1);
INSERT INTO `refresh_tokens`
VALUES (132, '2025-11-19 17:22:07.278303', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyOTI3LCJleHAiOjE3NjM1NDc3Mjd9.ttVcvyQayDzHoqAdYll_zWIxATDj2mGGCM_dKike-jM',
        1);
INSERT INTO `refresh_tokens`
VALUES (133, '2025-11-19 17:22:28.328970', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyOTQ4LCJleHAiOjE3NjM1NDc3NDh9.ljoPU4UyTSQ6TAIZW8hmVJ5qaxDirgBY7DFAaIreY6Q',
        1);
INSERT INTO `refresh_tokens`
VALUES (134, '2025-11-19 17:22:29.080019', b'1',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyOTQ5LCJleHAiOjE3NjM1NDc3NDl9.-nGuAG3pzT6ovXdJplN6bzHZ5-DkLrOIqUHJKPA09CY',
        1);
INSERT INTO `refresh_tokens`
VALUES (137, '2025-11-19 17:22:56.600610', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQyOTc2LCJleHAiOjE3NjM1NDc3NzZ9.e1HAQcooq8jQrSCodTr0mWXy1zwH5TBMDGhinM48uE0',
        1);
INSERT INTO `refresh_tokens`
VALUES (138, '2025-11-19 17:23:36.297861', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQzMDE2LCJleHAiOjE3NjM1NDc4MTZ9.xkhjzWUkUnxXcvxnSfmLDNHbWW-yQ_gqK9HW8PWezdg',
        1);
INSERT INTO `refresh_tokens`
VALUES (139, '2025-11-19 17:23:37.314623', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQzMDE3LCJleHAiOjE3NjM1NDc4MTd9.PYoRohrB0aP8IiqUaguEPOpD0KA8JoEoeCC4UDecXDk',
        1);
INSERT INTO `refresh_tokens`
VALUES (142, '2025-11-19 17:25:07.756754', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQzMTA3LCJleHAiOjE3NjM1NDc5MDd9.9vAxdIZ36wUvY_hCaZe6R6bf43OOVy7ZatCPJdDaZGg',
        1);
INSERT INTO `refresh_tokens`
VALUES (143, '2025-11-19 17:25:08.867117', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQzMTA4LCJleHAiOjE3NjM1NDc5MDh9.-PM22-5LcWHcnUzkzQvoG_4zlZdu3ip8cP--U4TCNr4',
        1);
INSERT INTO `refresh_tokens`
VALUES (144, '2025-11-19 17:25:09.472960', b'1',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQzMTA5LCJleHAiOjE3NjM1NDc5MDl9.CQ2Gsvn0xtIN_19KpyuemSAfMKnsqUch6nO05QyOs2s',
        1);
INSERT INTO `refresh_tokens`
VALUES (145, '2025-11-19 17:26:48.832298', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQzMjA4LCJleHAiOjE3NjM1NDgwMDh9.lOdpniAYoOspDC9VXi2GXbjhRtsUhFyzL8Jd8AeTTk4',
        1);
INSERT INTO `refresh_tokens`
VALUES (146, '2025-11-19 17:26:53.574380', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQzMjEzLCJleHAiOjE3NjM1NDgwMTN9.qTxGmd4aQWBMy1X0ndxgnQPT4Q1NQ4w-Ab2xZndQ1qM',
        1);
INSERT INTO `refresh_tokens`
VALUES (147, '2025-11-19 17:32:11.199754', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQzNTMxLCJleHAiOjE3NjM1NDgzMzF9.1K0pa2unvJbGWCcKrrR1xC4UJ3PuTQzpfHTUSE216o8',
        1);
INSERT INTO `refresh_tokens`
VALUES (148, '2025-11-19 17:32:55.159491', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQzNTc1LCJleHAiOjE3NjM1NDgzNzV9.FksHrqHy2uWvCZNaAC9i4ei-GICqy7iTlj8MAfhtnwI',
        1);
INSERT INTO `refresh_tokens`
VALUES (149, '2025-11-19 17:33:04.650299', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQzNTg0LCJleHAiOjE3NjM1NDgzODR9.uogHwJ6km3QI8Hz9ziGwjXPP3Mbpx1Jhfn7RxhVAwcg',
        1);
INSERT INTO `refresh_tokens`
VALUES (150, '2025-11-19 17:33:16.790977', b'1',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQzNTk2LCJleHAiOjE3NjM1NDgzOTZ9.H1D9YgoCIQZFHPKhnwTZa8ZbhhYZPYOLnXYXVrnoIW4',
        1);
INSERT INTO `refresh_tokens`
VALUES (151, '2025-11-19 17:42:27.870636', b'1',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQ0MTQ3LCJleHAiOjE3NjM1NDg5NDd9.COgMa2Zm4MvBTOfTfv_dRGqF4NgTx3BPyZRiM1lmTLM',
        1);
INSERT INTO `refresh_tokens`
VALUES (152, '2025-11-19 18:08:12.247442', b'1',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQ1NjkyLCJleHAiOjE3NjM1NTA0OTJ9.MdQpsd6vfn1dAmIHLo4aN3iGpbUKJfm-WVvYpDsbos8',
        1);
INSERT INTO `refresh_tokens`
VALUES (153, '2025-11-19 18:24:27.601272', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQ2NjY3LCJleHAiOjE3NjM1NTE0Njd9.Ej_ttvgYWXU-HhCV0qmBknMBv2Ci54EvnQxmN8dO2mk',
        1);
INSERT INTO `refresh_tokens`
VALUES (154, '2025-11-19 18:29:51.013696', b'1',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQ2OTkxLCJleHAiOjE3NjM1NTE3OTF9.f4QLGJRhYWxhLUrrejG2W1mY8PV9wxgFE6baST6jd4Y',
        1);
INSERT INTO `refresh_tokens`
VALUES (155, '2025-11-19 18:30:11.610390', b'1',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQ3MDExLCJleHAiOjE3NjM1NTE4MTF9.gJstrDdqMyKILHPP9uVjwcSd-rCKMwQIDCzC6LgAQug',
        1);
INSERT INTO `refresh_tokens`
VALUES (156, '2025-11-19 18:31:24.812137', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYyOTQ3MDg0LCJleHAiOjE3NjM1NTE4ODR9.GwXfRadaxTBOzFQskgRmg5_E4YPx-qQlPSmGpYLBQBk',
        1);
INSERT INTO `refresh_tokens`
VALUES (157, '2025-11-23 12:10:43.665183', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYzMjY5ODQzLCJleHAiOjE3NjM4NzQ2NDN9.z_EOkc69GxtjWq8fx4mQ_cwu7SrHa01zbdi6wVoh-8M',
        1);
INSERT INTO `refresh_tokens`
VALUES (158, '2025-11-23 16:00:06.244985', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYzMjgzNjA2LCJleHAiOjE3NjM4ODg0MDZ9.Ljrc-azbRsxO-CN2R0t8_2ZKZMBK7Pa6qSgXQiZYtJI',
        1);
INSERT INTO `refresh_tokens`
VALUES (159, '2025-11-23 16:58:40.375693', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYzMjg3MTIwLCJleHAiOjE3NjM4OTE5MjB9.9rgMk8gQtfglnCjrfx3CXNP_0v4hzqEmTAfd7xXgy48',
        1);
INSERT INTO `refresh_tokens`
VALUES (160, '2025-11-23 21:38:35.999518', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYzMzAzOTE1LCJleHAiOjE3NjM5MDg3MTV9.jJtWesC6hKv4k8PQpI-TlHrsyxSatDoYSmxRl2Evqxo',
        1);
INSERT INTO `refresh_tokens`
VALUES (161, '2025-11-24 18:12:42.492612', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYzMzc3OTYyLCJleHAiOjE3NjM5ODI3NjJ9.Tuqf5tG9sPZWJuIKHL6xsrk3jDImCetRE6LStzavfuE',
        1);
INSERT INTO `refresh_tokens`
VALUES (162, '2025-11-25 11:12:54.604332', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYzNDM5MTc0LCJleHAiOjE3NjQwNDM5NzR9.twTGkKlwwv4HCw8Y277pn4bxmwh7AJddfSEEjp3utBw',
        1);
INSERT INTO `refresh_tokens`
VALUES (163, '2025-11-25 11:15:20.243266', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYzNDM5MzIwLCJleHAiOjE3NjQwNDQxMjB9.a3f06EQxQf3wJnSHM7fzpsmMP2vN3V73XshIhZkYsPw',
        1);
INSERT INTO `refresh_tokens`
VALUES (164, '2025-11-25 11:16:44.994978', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYzNDM5NDA0LCJleHAiOjE3NjQwNDQyMDR9.ufe0PAWCxrRMTqqne7niIBgm4B7D_5frL2aZjVJIRqc',
        1);
INSERT INTO `refresh_tokens`
VALUES (165, '2025-11-25 11:24:07.381298', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYzNDM5ODQ3LCJleHAiOjE3NjQwNDQ2NDd9.ukw2n2og55l4vieBjPTU6vzEHrwZr2MeRIOyGUrN-ZI',
        1);
INSERT INTO `refresh_tokens`
VALUES (166, '2025-11-25 11:24:56.120774', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYzNDM5ODk2LCJleHAiOjE3NjQwNDQ2OTZ9.ZSLu9mSZ0Xg9jVpGpxjUUl1rIIRCe3TU57adlOw_rVI',
        1);
INSERT INTO `refresh_tokens`
VALUES (167, '2025-11-25 11:26:30.903782', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYzNDM5OTkwLCJleHAiOjE3NjQwNDQ3OTB9.oZRTBy5gQEH4-ynLidS_tbg2xjpig2MvwMwCj2KGSc8',
        1);
INSERT INTO `refresh_tokens`
VALUES (168, '2025-11-25 11:31:44.594263', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYzNDQwMzA0LCJleHAiOjE3NjQwNDUxMDR9.zLAaBLlq91aMahYloEcj66vxlWvpEd-3YhAzyBB2u5g',
        1);
INSERT INTO `refresh_tokens`
VALUES (169, '2025-11-25 11:32:33.512487', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYzNDQwMzUzLCJleHAiOjE3NjQwNDUxNTN9.p8u7xDuNzw9ECQOrAFWiX7BUxCLeskVBqWHrkvZOb3k',
        1);
INSERT INTO `refresh_tokens`
VALUES (170, '2025-11-25 11:33:08.258584', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYzNDQwMzg4LCJleHAiOjE3NjQwNDUxODh9.gD2dKgA-ENq-vJNxH7IsMgBIPCl-CfqvgoQgKj-qwok',
        1);
INSERT INTO `refresh_tokens`
VALUES (171, '2025-11-25 11:34:46.028024', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzYzNDQwNDg2LCJleHAiOjE3NjQwNDUyODZ9.9UEm92hB1GZ2d5IHetMMMNR7y3FB-QAd1EtJomgd3Do',
        1);
INSERT INTO `refresh_tokens`
VALUES (172, '2025-11-25 12:46:58.695024', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MzQ0NDgxOCwiZXhwIjoxNzY0MDQ5NjE4fQ.qLMHLg3leTZyKWe4_CtdLfbx269wG6gsM4uvuuAEo6g',
        18);
INSERT INTO `refresh_tokens`
VALUES (173, '2025-11-25 13:42:29.855471', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MzQ0ODE0OSwiZXhwIjoxNzY0MDUyOTQ5fQ.VfJt5BJljCUtw6ro395gsTyRpC8_ktWCK1HtKwUtFqE',
        18);
INSERT INTO `refresh_tokens`
VALUES (174, '2025-11-25 13:45:15.277168', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MzQ0ODMxNSwiZXhwIjoxNzY0MDUzMTE1fQ.ZFMWyGBTQf3wiThyQ3TLLntAkMIE3YGpXu-Ol5OGtc8',
        18);
INSERT INTO `refresh_tokens`
VALUES (175, '2025-11-25 13:48:31.470405', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MzQ0ODUxMSwiZXhwIjoxNzY0MDUzMzExfQ.O54Y7ilDO1kpfJ0ZqGlKalzRtBVgrnMLFZPEE5tOa48',
        18);
INSERT INTO `refresh_tokens`
VALUES (176, '2025-11-25 14:48:43.375023', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MzQ1MjEyMywiZXhwIjoxNzY0MDU2OTIzfQ.V0ly9-hsy9U7jEItj6C_QvkVZX3uVD3DTh8ebV9bBv0',
        18);
INSERT INTO `refresh_tokens`
VALUES (177, '2025-11-25 14:53:19.938972', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MzQ1MjM5OSwiZXhwIjoxNzY0MDU3MTk5fQ.iwAGssD5ep2rqtiZA3eQ9OJvfcxZ6kiMX-CyApDteis',
        18);
INSERT INTO `refresh_tokens`
VALUES (178, '2025-11-25 14:57:51.138726', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MzQ1MjY3MSwiZXhwIjoxNzY0MDU3NDcxfQ.ZVrT5S1AEF15ss0-LwyShns5BYcPUYC2jBX5Ce41ZNo',
        18);
INSERT INTO `refresh_tokens`
VALUES (179, '2025-11-25 15:10:59.028088', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MzQ1MzQ1OSwiZXhwIjoxNzY0MDU4MjU5fQ.jIdX8ijLwZbzOqF0RWips7eCn4nz9YnqmaqyA3-4IuA',
        18);
INSERT INTO `refresh_tokens`
VALUES (180, '2025-11-25 15:16:57.821551', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MzQ1MzgxNywiZXhwIjoxNzY0MDU4NjE3fQ.X11GjhdoWFfkHmxljN7CBRAtt8Q1yPmHM9OKOyVARsY',
        18);
INSERT INTO `refresh_tokens`
VALUES (181, '2025-11-25 16:53:28.906566', b'0',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxOCIsImlhdCI6MTc2MzQ1OTYwOCwiZXhwIjoxNzY0MDY0NDA4fQ.vAtQEP9B3pPoVF6SZSom0uXqDktmPlUuvKGlGZPfnlo',
        18);

-- ----------------------------
-- Table structure for review_images
-- ----------------------------
DROP TABLE IF EXISTS `review_images`;
CREATE TABLE `review_images`
(
    `id`          bigint                                                        NOT NULL AUTO_INCREMENT,
    `image_url`   varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `uploaded_at` datetime(6)                                                   NOT NULL,
    `review_id`   bigint                                                        NOT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `FK3aayo5bjciyemf3bvvt987hkr` (`review_id` ASC) USING BTREE,
    CONSTRAINT `FK3aayo5bjciyemf3bvvt987hkr` FOREIGN KEY (`review_id`) REFERENCES `reviews` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB
  AUTO_INCREMENT = 4
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of review_images
-- ----------------------------
INSERT INTO `review_images`
VALUES (1, 'https://example.com/review-bana-tour1.jpg', '2025-10-11 22:20:00.000000', 1);
INSERT INTO `review_images`
VALUES (2, 'https://example.com/review-bana-hotel1.jpg', '2025-10-11 22:21:00.000000', 2);
INSERT INTO `review_images`
VALUES (3, 'https://example.com/review-bana-tour2.jpg', '2025-10-11 22:22:00.000000', 3);

-- ----------------------------
-- Table structure for reviews
-- ----------------------------
DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews`
(
    `id`             bigint                                                NOT NULL AUTO_INCREMENT,
    `comment`        text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
    `created_at`     datetime(6)                                           NOT NULL,
    `hotel_id`       bigint                                                NULL DEFAULT NULL,
    `is_approved`    bit(1)                                                NOT NULL,
    `likes_count`    int                                                   NOT NULL,
    `rating`         int                                                   NOT NULL,
    `tour_id`        bigint                                                NULL DEFAULT NULL,
    `updated_at`     datetime(6)                                           NOT NULL,
    `destination_id` bigint                                                NULL DEFAULT NULL,
    `user_id`        bigint                                                NOT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `idx_user_id` (`user_id` ASC) USING BTREE,
    INDEX `idx_destination_id` (`destination_id` ASC) USING BTREE,
    INDEX `idx_created_at` (`created_at` DESC) USING BTREE,
    CONSTRAINT `FKcgy7qjc1r99dp117y9en6lxye` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT `FKo07xgps8spbcjhqpj559t835x` FOREIGN KEY (`destination_id`) REFERENCES `destinations` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB
  AUTO_INCREMENT = 4
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of reviews
-- ----------------------------
INSERT INTO `reviews`
VALUES (1, 'Tour tuyệt vời! Cầu Vàng và khí hậu trên đỉnh núi rất đáng nhớ.', '2025-10-11 22:10:00.000000', NULL, b'1',
        12, 5, 1, '2025-10-11 22:10:00.000000', 2, 1);
INSERT INTO `reviews`
VALUES (2, 'Khách sạn sạch đẹp, nhân viên thân thiện. Ăn sáng ngon và phong cảnh đẹp.', '2025-10-11 22:12:00.000000', 1,
        b'1', 8, 4, NULL, '2025-10-11 22:12:00.000000', 2, 2);
INSERT INTO `reviews`
VALUES (3, 'Tour kết hợp Bà Nà Hills và Hội An rất hợp lý, giá tốt, dịch vụ chu đáo.', '2025-10-11 22:15:00.000000',
        NULL, b'1', 5, 5, 2, '2025-10-11 22:15:00.000000', 2, 3);

-- ----------------------------
-- Table structure for room_types
-- ----------------------------
DROP TABLE IF EXISTS `room_types`;
CREATE TABLE `room_types`
(
    `id`          bigint                                                        NOT NULL AUTO_INCREMENT,
    `amenities`   text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci         NULL,
    `capacity`    int                                                           NULL DEFAULT NULL,
    `created_at`  datetime(6)                                                   NOT NULL,
    `name`        varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `price`       decimal(10, 2)                                                NOT NULL,
    `total_rooms` int                                                           NULL DEFAULT NULL,
    `updated_at`  datetime(6)                                                   NOT NULL,
    `hotel_id`    bigint                                                        NULL DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `idx_hotel_id` (`hotel_id` ASC) USING BTREE,
    INDEX `idx_price` (`price` ASC) USING BTREE,
    CONSTRAINT `FK42cc0t2sr43om89u1loqh7arj` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of room_types
-- ----------------------------

-- ----------------------------
-- Table structure for tour_images
-- ----------------------------
DROP TABLE IF EXISTS `tour_images`;
CREATE TABLE `tour_images`
(
    `id`            bigint                                                        NOT NULL AUTO_INCREMENT,
    `display_order` int                                                           NOT NULL,
    `image_url`     varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `is_primary`    bit(1)                                                        NOT NULL,
    `uploaded_at`   datetime(6)                                                   NOT NULL,
    `tour_id`       bigint                                                        NOT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `FKth1m2rd6q6ltp8kii2msvfi5d` (`tour_id` ASC) USING BTREE,
    CONSTRAINT `FKth1m2rd6q6ltp8kii2msvfi5d` FOREIGN KEY (`tour_id`) REFERENCES `tours` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB
  AUTO_INCREMENT = 7
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of tour_images
-- ----------------------------
INSERT INTO `tour_images`
VALUES (1, 1, 'https://res.cloudinary.com/demo/image/upload/v1720535538/tour_banahills_main.jpg', b'1',
        '2025-10-29 11:41:02.000000', 1);
INSERT INTO `tour_images`
VALUES (2, 2, 'https://res.cloudinary.com/demo/image/upload/v1720535539/tour_banahills_view.jpg', b'0',
        '2025-10-29 11:41:02.000000', 1);
INSERT INTO `tour_images`
VALUES (3, 3, 'https://res.cloudinary.com/demo/image/upload/v1720535540/tour_banahills_bridge.jpg', b'0',
        '2025-10-29 11:41:02.000000', 1);
INSERT INTO `tour_images`
VALUES (4, 1, 'https://res.cloudinary.com/demo/image/upload/v1720535541/tour_hoian_main.jpg', b'1',
        '2025-10-29 11:41:02.000000', 2);
INSERT INTO `tour_images`
VALUES (5, 2, 'https://res.cloudinary.com/demo/image/upload/v1720535542/tour_hoian_lanterns.jpg', b'0',
        '2025-10-29 11:41:02.000000', 2);
INSERT INTO `tour_images`
VALUES (6, 3, 'https://res.cloudinary.com/demo/image/upload/v1720535543/tour_hoian_street.jpg', b'0',
        '2025-10-29 11:41:02.000000', 2);

-- ----------------------------
-- Table structure for tour_schedules
-- ----------------------------
DROP TABLE IF EXISTS `tour_schedules`;
CREATE TABLE `tour_schedules`
(
    `id`            bigint                                                        NOT NULL AUTO_INCREMENT,
    `accommodation` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
    `activities`    text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci         NOT NULL,
    `day_number`    int                                                           NOT NULL,
    `meals`         json                                                          NULL,
    `title`         varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `tour_id`       bigint                                                        NOT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `FKa7bvkxeyqhbppi24qimguq9un` (`tour_id` ASC) USING BTREE,
    CONSTRAINT `FKa7bvkxeyqhbppi24qimguq9un` FOREIGN KEY (`tour_id`) REFERENCES `tours` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB
  AUTO_INCREMENT = 3
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of tour_schedules
-- ----------------------------
INSERT INTO `tour_schedules`
VALUES (1, 'Khách sạn 3* khu vực Bà Nà',
        '07:30 Đón khách tại trung tâm Đà Nẵng. \r\n    09:00 Lên cáp treo, tham quan Cầu Vàng, khu làng Pháp, hầm rượu Debay. \r\n    12:00 Dùng buffet trưa. \r\n    14:00 Vui chơi tại Fantasy Park. \r\n    17:00 Nghỉ đêm tại khách sạn khu vực Bà Nà.',
        1, '[
    \"Sáng\",
    \"Trưa\",
    \"Tối\"
  ]', 'Ngày 1: Tham quan Bà Nà Hills', 2);
INSERT INTO `tour_schedules`
VALUES (2, NULL,
        '07:30 Ăn sáng và di chuyển đến Hội An. \r\n    09:30 Tham quan phố cổ, chùa Cầu, sông Hoài, chợ Hội An. \r\n    12:00 Ăn trưa tại nhà hàng địa phương. \r\n    14:00 Tự do mua sắm và trở về Đà Nẵng vào buổi chiều.',
        2, '[
    \"Sáng\",
    \"Trưa\"
  ]', 'Ngày 2: Tham quan phố cổ Hội An', 2);

-- ----------------------------
-- Table structure for tours
-- ----------------------------
DROP TABLE IF EXISTS `tours`;
CREATE TABLE `tours`
(
    `id`               bigint                                                        NOT NULL AUTO_INCREMENT,
    `average_rating`   decimal(3, 2)                                                 NULL DEFAULT NULL,
    `booking_count`    int                                                           NOT NULL,
    `created_at`       datetime(6)                                                   NOT NULL,
    `description`      text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci         NULL,
    `duration_days`    int                                                           NOT NULL,
    `duration_nights`  int                                                           NOT NULL,
    `excluded`         json                                                          NULL,
    `included`         json                                                          NULL,
    `is_active`        bit(1)                                                        NOT NULL,
    `max_people`       int                                                           NOT NULL,
    `min_people`       int                                                           NOT NULL,
    `name`             varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `price_per_person` decimal(12, 2)                                                NOT NULL,
    `review_count`     int                                                           NOT NULL,
    `updated_at`       datetime(6)                                                   NOT NULL,
    `destination_id`   bigint                                                        NOT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `idx_destination_id` (`destination_id` ASC) USING BTREE,
    INDEX `idx_price` (`price_per_person` ASC) USING BTREE,
    CONSTRAINT `FKnmqftag73fi1wok8f46cwc0dr` FOREIGN KEY (`destination_id`) REFERENCES `destinations` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB
  AUTO_INCREMENT = 3
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of tours
-- ----------------------------
INSERT INTO `tours`
VALUES (1, 4.80, 1500, '2025-10-11 21:50:00.000000',
        'Trải nghiệm cáp treo, tham quan Cầu Vàng, khu làng Pháp, hầm rượu Debay và Fantasy Park.', 1, 0, '[
    \"Chi phí cá nhân\",
    \"Mua sắm riêng\"
  ]', '[
    \"Vé cáp treo\",
    \"Ăn trưa buffet\",
    \"Hướng dẫn viên\",
    \"Xe đưa đón\"
  ]', b'1', 25, 2, 'Tour Bà Nà Hills 1 Ngày', 850000.00, 320, '2025-10-11 21:50:00.000000', 2);
INSERT INTO `tours`
VALUES (2, 4.70, 890, '2025-10-11 21:52:00.000000',
        'Kết hợp khám phá Bà Nà Hills và phố cổ Hội An, bao gồm khách sạn, vé tham quan và xe đưa đón 2 chiều.', 2, 1,
        '[
          \"Chi phí cá nhân\",
          \"Đồ uống\",
          \"Tip HDV\"
        ]', '[
    \"Khách sạn 3*\",
    \"Vé vào cửa\",
    \"Ăn sáng\",
    \"Xe đưa đón\"
  ]', b'1', 20, 2, 'Tour Bà Nà Hills - Hội An 2N1Đ', 1900000.00, 210, '2025-10-11 21:52:00.000000', 2);

-- ----------------------------
-- Table structure for user_profiles
-- ----------------------------
DROP TABLE IF EXISTS `user_profiles`;
CREATE TABLE `user_profiles`
(
    `id`                    bigint                                                        NOT NULL AUTO_INCREMENT,
    `user_id`               bigint                                                        NOT NULL,
    `avatar_url`            varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
    `bio`                   text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci         NULL,
    `gender`                varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci  NULL DEFAULT NULL,
    `date_of_birth`         date                                                          NULL DEFAULT NULL,
    `address`               varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
    `city`                  varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci  NULL DEFAULT NULL,
    `country`               varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci  NULL DEFAULT NULL,
    `notification_settings` json                                                          NULL,
    `language_settings`     json                                                          NULL,
    `dark_mode_enabled`     bit(1)                                                        NULL DEFAULT b'0',
    `experience_points`     bigint                                                        NULL DEFAULT 0,
    `current_level`         varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci  NULL DEFAULT 'Đồng',
    `updated_at`            datetime(6)                                                   NOT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `UK_user_id` (`user_id` ASC) USING BTREE,
    CONSTRAINT `FK_user_profiles_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_profiles
-- ----------------------------

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`
(
    `id`             bigint                                                        NOT NULL AUTO_INCREMENT,
    `auth_provider`  varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci  NULL DEFAULT NULL,
    `created_at`     datetime(6)                                                   NOT NULL,
    `email`          varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    `email_verified` bit(1)                                                        NOT NULL,
    `firebase_uid`   varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
    `is_active`      bit(1)                                                        NOT NULL,
    `password`       varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
    `phone`          varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci  NULL DEFAULT NULL,
    `role`           varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci  NOT NULL,
    `updated_at`     datetime(6)                                                   NOT NULL,
    `full_name`      varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `UK6dotkott2kjsp8vw4d0m25fb7` (`email` ASC) USING BTREE,
    INDEX `idx_email` (`email` ASC) USING BTREE,
    INDEX `idx_phone` (`phone` ASC) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 21
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users`
VALUES (1, NULL, '2025-10-05 18:32:31.288797', 'tuansdev@gmail.com', b'1', NULL, b'1',
        '$2a$10$KHNkJgtsyrlbMddJoQDIXe4b//av7Nb4sajA6i/5Y8TmZDNHMAxQS', NULL, 'ADMIN', '2025-10-05 18:32:31.288797',
        'tuansdev');
INSERT INTO `users`
VALUES (2, 'EMAIL', '2025-10-06 11:29:13.383187', 'nguyenvana@yopmail.com', b'0', NULL, b'1',
        '$2a$10$jmuAKL1E4dcw/n3gp/2w5Op5i79eRTiqmW/W35K2MvgqfwbxsMDli', '0123456789', 'USER',
        '2025-10-06 11:29:13.383187', 'Nguyen Van A');
INSERT INTO `users`
VALUES (3, 'EMAIL', '2025-10-06 11:44:24.562393', '22130313@st.hcmauf.edu.vn', b'0', NULL, b'1',
        '$2a$10$vl6hn5iAlPsfjwVZm67Age/reBsQAYqHV4jtQ5uf73fI1m3zGac.2', '0386394258', 'USER',
        '2025-10-06 11:44:24.563899', 'vo tuan vn');
INSERT INTO `users`
VALUES (4, 'EMAIL', '2025-10-06 11:50:00.000000', 'user4@yopmail.com', b'1', NULL, b'1',
        '$2a$10$jmuAKL1E4dcw/n3gp/2w5Op5i79eRTiqmW/W35K2MvgqfwbxsMDli', '0123456744', 'USER',
        '2025-10-06 11:50:00.000000', 'User Four');
INSERT INTO `users`
VALUES (5, 'EMAIL', '2025-10-06 11:55:00.000000', 'user5@yopmail.com', b'1', NULL, b'1',
        '$2a$10$jmuAKL1E4dcw/n3gp/2w5Op5i79eRTiqmW/W35K2MvgqfwbxsMDli', '0123456755', 'USER',
        '2025-10-06 11:55:00.000000', 'User Five');
INSERT INTO `users`
VALUES (6, 'EMAIL', '2025-10-06 11:58:00.000000', 'user6@yopmail.com', b'1', NULL, b'1',
        '$2a$10$jmuAKL1E4dcw/n3gp/2w5Op5i79eRTiqmW/W35K2MvgqfwbxsMDli', '0123456766', 'USER',
        '2025-10-06 11:58:00.000000', 'User Six');
INSERT INTO `users`
VALUES (7, 'EMAIL', '2025-10-06 12:00:44.009506', 'tuan1@yopmail.com', b'0', NULL, b'1',
        '$2a$10$pCAahqBBJJN.l.4BAfkEvecJex9VxBAwI8CM.irQS6TrzsAaVZDYK', '0386394251', 'USER',
        '2025-10-06 12:00:44.009506', 'vo tuan vn');
INSERT INTO `users`
VALUES (8, 'EMAIL', '2025-10-06 12:48:39.661556', 'tuan2@yopmail.com', b'1', NULL, b'1',
        '$2a$10$MUW2bBqalx8YF.XkuynTaekGvKinXmopBfPcOrWB6gcFmKguGjMvG', '0123456784', 'USER',
        '2025-10-06 13:41:02.793970', 'Nguyen Van A');
INSERT INTO `users`
VALUES (9, 'EMAIL', '2025-10-06 13:00:00.000000', 'user9@yopmail.com', b'1', NULL, b'1',
        '$2a$10$jmuAKL1E4dcw/n3gp/2w5Op5i79eRTiqmW/W35K2MvgqfwbxsMDli', '0123456799', 'USER',
        '2025-10-06 13:00:00.000000', 'User Nine');
INSERT INTO `users`
VALUES (10, 'EMAIL', '2025-10-06 13:10:37.654418', 'tuan3@yopmail.com', b'1', NULL, b'1',
        '$2a$10$Ot42xwjxH/dO2p34yeq0D.Yl5H5c3.NKkxVaEwx6Ed3SZdK0E98WK', '0123456785', 'USER',
        '2025-10-10 21:31:14.298042', 'Nguyen Van A');
INSERT INTO `users`
VALUES (11, 'EMAIL', '2025-10-06 13:21:38.684921', 'tuan4@yopmail.com', b'1', NULL, b'1',
        '$2a$10$AJdWVkEUQbaPJrX4IUN5me3xUJDX.99FIztQRUxR6WvJoMJaP0B.2', '0123456781', 'USER',
        '2025-10-06 13:22:09.907548', 'nguyen avn b');
INSERT INTO `users`
VALUES (12, 'EMAIL', '2025-10-06 20:46:11.659855', 'tuan6@yopmail.com', b'0', NULL, b'1',
        '$2a$10$b2XB3QBT/5vUvQcwuw3lc.bA89DrIKBAAzfWKZy5VlNqjXbxs9bwe', '0123456782', 'USER',
        '2025-10-10 17:15:50.062457', 'tuan vo');
INSERT INTO `users`
VALUES (13, 'EMAIL', '2025-10-07 21:27:32.119677', 'tuan7@yopmail.com', b'0', NULL, b'1',
        '$2a$10$g4GwGZZzGcrPBNS8.U3DJu4O5iFMrWHKn6ppYVc78R1H0gijoWUQ2', '0123456787', 'USER',
        '2025-10-07 21:27:32.120698', 'quoc tuan');
INSERT INTO `users`
VALUES (14, 'EMAIL', '2025-10-10 21:23:36.017784', 'tuan8@yopmail.com', b'0', NULL, b'1',
        '$2a$10$TJu0zp6DcoSKFarkIVE08eelj.m6HtzLXSVLzgDSgFdLhHNHv4gVi', '0987554506', 'USER',
        '2025-10-10 21:23:36.026398', 'vo vn tuan');
INSERT INTO `users`
VALUES (15, 'EMAIL', '2025-10-12 14:56:13.293602', 'tuan9@yopmail.com', b'0', NULL, b'1',
        '$2a$10$WPf5h3yWx.UbqZup49Jn..oA2ELNOZAr7yQe3aKPRl5VJd6lDuegO', '0987554507', 'USER',
        '2025-10-12 14:56:13.293602', 'tuan vo');
INSERT INTO `users`
VALUES (16, 'EMAIL', '2025-10-15 15:20:01.496112', 'tuanvo042004@gmail.com', b'0', NULL, b'1',
        '$2a$10$Xl7UR8u0fpA8fdzO5Hd8GuNf6puKRA5tUXkKvcqPeXSUVc4yfN4zy', '0987554508', 'USER',
        '2025-10-15 15:20:01.496112', 'tuan vo');
INSERT INTO `users`
VALUES (17, 'EMAIL', '2025-10-15 15:21:20.599884', 'votuan042004@gmail.com', b'1', NULL, b'1',
        '$2a$10$VA.htWk56C/jOnMNwFp1veU1vw4ko2/alKbLPtsTzxoA5h7.e.RBq', '0987554523', 'USER',
        '2025-10-15 15:22:42.941642', 'vo tuan');
INSERT INTO `users`
VALUES (18, 'GOOGLE', '2025-10-25 21:45:56.990795', '22130313@st.hcmuaf.edu.vn', b'1', NULL, b'1', NULL, NULL, 'USER',
        '2025-10-25 21:45:56.992141', 'Tuấn Võ Văn Quốc');
INSERT INTO `users`
VALUES (19, NULL, '2025-10-26 13:52:15.653769', 'testuser@gmail.com', b'1', NULL, b'1',
        '$2a$10$3HEmkHxiMrTleYPsJz5PDuqFZKeXHiycZ.q0iX0xKxSOM5HIu0jfO', NULL, 'USER', '2025-10-26 13:52:15.653769',
        'User Test');
INSERT INTO `users`
VALUES (20, 'EMAIL', '2025-11-17 01:27:43.827070', 'tuan11@yopmail.com', b'0', NULL, b'1',
        '$2a$10$pOeEppfLTpjrY82BLrgJt.Lx.3EjSjKGBrszihfWbNDjG9T4nYSe2', '0123456786', 'USER',
        '2025-11-17 01:27:43.827070', 'Nguyen Van A');

SET FOREIGN_KEY_CHECKS = 1;

ALTER TABLE user_profiles
    AUTO_INCREMENT = 1;


INSERT INTO user_profiles
(id, user_id, avatar_url, bio, gender, date_of_birth, address, city, country,
 notification_settings, language_settings, dark_mode_enabled, experience_points, current_level, updated_at)
    VALUES (1, 1, 'https://i.pravatar.cc/300?img=1', 'Quản trị viên hệ thống', 'MALE', '1985-05-15',
            '123 Đường Lê Lợi', 'Hà Nội', 'Việt Nam',
            '{"email": true, "push": true}', '{"lang": "vi"}', TRUE, 8200, 'Kim cương', NOW()),

           (2, 2, 'https://i.pravatar.cc/300?img=12', 'Yêu thích du lịch khám phá', 'MALE', '1990-08-20',
            '456 Đường Nguyễn Huệ', 'Hồ Chí Minh', 'Việt Nam',
            '{"email": true, "push": true}', '{"lang": "vi"}', FALSE, 450, 'Đồng', NOW()),

           (3, 3, 'https://i.pravatar.cc/300?img=45', 'Đam mê ẩm thực và văn hóa', 'FEMALE', '1995-03-10',
            '789 Đường Trần Hưng Đạo', 'Đà Nẵng', 'Việt Nam',
            '{"email": false, "push": false}', '{"lang": "vi"}', FALSE, 1800, 'Bạc', NOW()),

           (4, 7, 'https://i.pravatar.cc/300?img=15', 'Đam mê photography du lịch', 'MALE', '1993-09-30',
            '147 Đường Võ Văn Tần', 'Vũng Tàu', 'Việt Nam',
            '{"email": false, "push": false}', '{"lang": "vi"}', TRUE, 1500, 'Bạc', NOW()),

           (5, 8, 'https://i.pravatar.cc/300?img=22', 'Người thích khám phá lịch sử', 'MALE', '1989-04-12',
            '23 Lý Quốc Sư', 'Hà Nội', 'Việt Nam',
            '{"email": true, "push": true}', '{"lang": "vi"}', FALSE, 6100, 'Vàng', NOW()),

           (6, 10, 'https://i.pravatar.cc/300?img=50', 'Nhiếp ảnh gia tự do', 'FEMALE', '1998-10-11',
            '87 Nam Kỳ Khởi Nghĩa', 'Hồ Chí Minh', 'Việt Nam',
            '{"email": false, "push": false}', '{"lang": "vi"}', FALSE, 1200, 'Bạc', NOW()),

           (7, 11, 'https://i.pravatar.cc/300?img=14', 'Yêu động vật và thiên nhiên', 'FEMALE', '1996-02-05',
            '201 Hoàng Diệu', 'Thanh Hóa', 'Việt Nam',
            '{"email": true, "push": true}', '{"lang": "vi"}', TRUE, 6800, 'Vàng', NOW()),

           (8, 12, 'https://i.pravatar.cc/300?img=32', 'Nhà thiết kế đồ họa', 'MALE', '1987-07-19',
            '55 Trần Quang Khải', 'Huế', 'Việt Nam',
            '{"email": true, "push": true}', '{"lang": "vi"}', FALSE, 400, 'Đồng', NOW()),

           (9, 13, 'https://i.pravatar.cc/300?img=37', 'Thích đi biển và nghỉ dưỡng', 'FEMALE', '1999-06-21',
            '92 Hà Bổng', 'Đà Nẵng', 'Việt Nam',
            '{"email": false, "push": false}', '{"lang": "vi"}', TRUE, 2300, 'Bạc', NOW()),

           (10, 14, 'https://i.pravatar.cc/300?img=18', 'Nhà văn và blogger du lịch', 'MALE', '1993-11-15',
            '77 Võ Nguyên Giáp', 'Quảng Ninh', 'Việt Nam',
            '{"email": true, "push": true}', '{"lang": "en"}', FALSE, 7200, 'Kim cương', NOW()),

           (11, 15, 'https://i.pravatar.cc/300?img=29', 'Yêu thích văn hóa Á Đông', 'FEMALE', '1990-03-17',
            '38 Pasteur', 'Hồ Chí Minh', 'Việt Nam',
            '{"email": true, "push": true}', '{"lang": "vi"}', TRUE, 5100, 'Vàng', NOW()),

           (12, 16, 'https://i.pravatar.cc/300?img=40', 'Đam mê xe máy và phượt dài ngày', 'MALE', '1986-09-28',
            '101 Hoàng Hoa Thám', 'Hà Nội', 'Việt Nam',
            '{"email": false, "push": false}', '{"lang": "vi"}', FALSE, 800, 'Đồng', NOW()),

           (13, 17, 'https://i.pravatar.cc/300?img=38', 'Thích du lịch nghỉ dưỡng cao cấp', 'FEMALE', '1995-05-03',
            '62 Bạch Đằng', 'Hội An', 'Việt Nam',
            '{"email": true, "push": true}', '{"lang": "vi"}', TRUE, 3600, 'Vàng', NOW()),

           (14, 18, 'https://i.pravatar.cc/300?img=13', 'Streamer du lịch', 'MALE', '1999-12-11',
            '140 Nguyễn Văn Cừ', 'Hải Phòng', 'Việt Nam',
            '{"email": true, "push": true}', '{"lang": "en"}', FALSE, 9000, 'Kim cương', NOW()),

           (15, 19, 'https://i.pravatar.cc/300?img=25', 'Thích khám phá các tỉnh miền núi', 'MALE', '1988-08-08',
            '301 Trường Chinh', 'Lạng Sơn', 'Việt Nam',
            '{"email": false, "push": false}', '{"lang": "vi"}', TRUE, 2700, 'Bạc', NOW()),

           (16, 20, 'https://i.pravatar.cc/300?img=9', 'Digital marketer thích du lịch', 'FEMALE', '1997-01-20',
            '509 Nguyễn Kiệm', 'Hồ Chí Minh', 'Việt Nam',
            '{"email": true, "push": true}', '{"lang": "en"}', FALSE, 100, 'Đồng', NOW()),

           (17, 4, 'https://i.pravatar.cc/300?img=60', 'Thích khám phá ẩm thực', 'MALE', '1992-01-01',
            '123 Đường ABC', 'Hà Nội', 'Việt Nam',
            '{"email": true, "push": true}', '{"lang": "vi"}', FALSE, 1000, 'Bạc', NOW()),

           (18, 5, 'https://i.pravatar.cc/300?img=61', 'Yêu thiên nhiên', 'FEMALE', '1993-02-02',
            '456 Đường XYZ', 'Đà Nẵng', 'Việt Nam',
            '{"email": true, "push": true}', '{"lang": "vi"}', TRUE, 2000, 'Vàng', NOW()),

           (19, 6, 'https://i.pravatar.cc/300?img=62', 'Đam mê leo núi', 'MALE', '1994-03-03',
            '789 Đường DEF', 'Hồ Chí Minh', 'Việt Nam',
            '{"email": false, "push": false}', '{"lang": "en"}', FALSE, 500, 'Đồng', NOW()),

           (20, 9, 'https://i.pravatar.cc/300?img=63', 'Thích chụp ảnh', 'FEMALE', '1995-04-04',
            '101 Đường GHI', 'Cần Thơ', 'Việt Nam',
            '{"email": true, "push": true}', '{"lang": "vi"}', TRUE, 3000, 'Kim cương', NOW())
        AS new_data
ON DUPLICATE KEY UPDATE user_id           = new_data.user_id,
                        avatar_url        = new_data.avatar_url,
                        bio               = new_data.bio,
                        gender            = new_data.gender,
                        date_of_birth     = new_data.date_of_birth,
                        address           = new_data.address,
                        city              = new_data.city,
                        country           = new_data.country,
                        notification_settings = new_data.notification_settings,
                        language_settings = new_data.language_settings,
                        dark_mode_enabled = new_data.dark_mode_enabled,
                        experience_points = new_data.experience_points,
                        current_level     = new_data.current_level,
                        updated_at        = new_data.updated_at;
