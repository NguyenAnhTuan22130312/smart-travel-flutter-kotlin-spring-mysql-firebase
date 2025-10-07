package com.example.smart_travel_BE.repository;


import com.example.smart_travel_BE.entity.EmailVerificationToken;
import com.example.smart_travel_BE.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface EmailVerificationTokenRepository extends JpaRepository<EmailVerificationToken, Long> {

    Optional<EmailVerificationToken> findByToken(String token);

    Optional<EmailVerificationToken> findByUser(User user);

    void deleteByUser(User user);
}