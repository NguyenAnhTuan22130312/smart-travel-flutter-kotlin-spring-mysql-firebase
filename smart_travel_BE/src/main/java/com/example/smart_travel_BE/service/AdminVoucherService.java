package com.example.smart_travel_BE.service;

import com.example.smart_travel_BE.dto.voucher.VoucherRequest;
import com.example.smart_travel_BE.entity.Voucher;
import com.example.smart_travel_BE.repository.VoucherRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
 
@Service
@RequiredArgsConstructor
public class AdminVoucherService {

    private final VoucherRepository voucherRepository;

    public List<Voucher> getAllVouchers() {
        return voucherRepository.findAll();
    }

    public Voucher getVoucherById(Long id) {
        return voucherRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy Voucher với ID: " + id));
    }

    @Transactional
    public Voucher createVoucher(VoucherRequest request) {
        if (voucherRepository.existsByCode(request.getCode())) {
            throw new RuntimeException("Mã Voucher '" + request.getCode() + "' đã tồn tại!");
        }

        Voucher voucher = new Voucher();
        voucher.setCode(request.getCode().toUpperCase());
        voucher.setDiscountAmount(request.getDiscountAmount());
        voucher.setExpiryDate(request.getExpiryDate());
        voucher.setIsActive(request.getIsActive());
        voucher.setUsageLimit(request.getUsageLimit());
        voucher.setPointsRequired(request.getPointsRequired()); // Lưu điểm cần đổi
        voucher.setDescription(request.getDescription());
        voucher.setImageUrl(request.getImageUrl());

        return voucherRepository.save(voucher);
    }

    @Transactional
    public Voucher updateVoucher(Long id, VoucherRequest request) {
        Voucher voucher = getVoucherById(id);

        if (!voucher.getCode().equalsIgnoreCase(request.getCode())
                && voucherRepository.existsByCode(request.getCode())) {
            throw new RuntimeException("Mã Voucher '" + request.getCode() + "' đã được sử dụng bởi voucher khác!");
        }

        voucher.setCode(request.getCode().toUpperCase());
        voucher.setDiscountAmount(request.getDiscountAmount());
        voucher.setExpiryDate(request.getExpiryDate());
        voucher.setIsActive(request.getIsActive());
        voucher.setUsageLimit(request.getUsageLimit());
        voucher.setPointsRequired(request.getPointsRequired()); // Lưu điểm cần đổi
        voucher.setDescription(request.getDescription());
        voucher.setImageUrl(request.getImageUrl());

        return voucherRepository.save(voucher);
    }

    @Transactional
    public void deleteVoucher(Long id) {
        // 1. Tìm voucher
        Voucher voucher = voucherRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy Voucher để xóa"));

        // 2. Kiểm tra xem có nên xóa cứng không (nếu muốn)
        // Nếu muốn giữ lịch sử, ta chỉ cần tắt kích hoạt:
        voucher.setIsActive(false);

        // Hoặc nếu bạn có trường 'deleted', hãy set nó là true
        // voucher.setDeleted(true);

        // 3. Lưu lại thay đổi
        voucherRepository.save(voucher);

        // KHÔNG GỌI voucherRepository.deleteById(id); NỮA
    }
}