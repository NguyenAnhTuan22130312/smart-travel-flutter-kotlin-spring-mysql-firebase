package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.user.request.EmailRequest;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class EmailService {

    JavaMailSender mailSender;

    public void sendVerificationEmail(EmailRequest request) {
        try {
            // 1. Gửi email xác thực cho người dùng
            String subjectUser = "Xác thực địa chỉ email của bạn";
            String verificationUrl = "http://localhost:8080/api/v1/auth/verify-email?token=" + request.getToken();
            String messageUser = "<html><body>" +
                    "Xin chào <b>" + request.getEmail() + "</b>,<br><br>" +
                    "Vui lòng nhấp vào liên kết sau để xác thực email của bạn:<br><br>" +
                    "<a style='padding: 10px; background: pink; color: black; text-decoration: none; border-radius: 5px;' href='" + verificationUrl + "'>" +
                    "Xác minh email</a><br><br>" +
                    "Liên kết này sẽ hết hạn sau <b>1 giờ</b>.<br><br>" +
                    "Trân trọng,<br>Smart Travel" +
                    "</body></html>";

            MimeMessage userMail = mailSender.createMimeMessage();
            MimeMessageHelper userHelper = new MimeMessageHelper(userMail, true, "UTF-8");
            userHelper.setTo(request.getTo());
            userHelper.setSubject(subjectUser);
            userHelper.setText(messageUser, true);
            mailSender.send(userMail);
        } catch (MessagingException e) {
            log.error("Failed to send verification email to: {}", request.getTo(), e);
            throw new RuntimeException("Không thể gửi email xác thực", e);
        }
    }

    public void sendWelcomeEmail(String email, String fullName) {
        try {
            // 1. Gửi email xác thực cho người dùng
            String subjectUser = "Xác thực tài khoản thành công";
            String messageUser = "<html><body>" +
                    "Xin chào <b>" + fullName + "</b>,<br><br>" +
                    "Tài khoản của bạn đã được xác thực thành công:<br><br>" +
                    "<h3 style='color: green;'>Cảm ơn bạn đã đăng ký hệ thống của chúng tôi</h3>"+
                    "Trân trọng,<br>Smart Travel" +
                    "</body></html>";

            MimeMessage userMail = mailSender.createMimeMessage();
            MimeMessageHelper userHelper = new MimeMessageHelper(userMail, true, "UTF-8");
            userHelper.setTo(email);
            userHelper.setSubject(subjectUser);
            userHelper.setText(messageUser, true);
            mailSender.send(userMail);
        } catch (MessagingException e) {
            log.error("Failed to send verification email to: {}", email, e);
            throw new RuntimeException("Không thể gửi email xác thực", e);
        }
    }
}