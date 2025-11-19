package com.example.smart_travel_BE.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;

@Getter

public enum ErrorCode {

    //VALID AUTH
    ACCOUNT_NOT_FOUND(1029, "Người dùng không tồn tại", HttpStatus.NOT_FOUND),
    ACCOUNT_NOT_CONFIRM(1019, "Tài khoản chưa được xác thực", HttpStatus.UNAUTHORIZED),
    ERROR_LOGOUT(1017, "Có lỗi khi đăng xuất", HttpStatus.INTERNAL_SERVER_ERROR),
    REFRESH_TOKEN_NOT_FOUND(1016, "Token không tồn tại", HttpStatus.NOT_FOUND),
    TOKEN_INVALID(1015, "Token không hợp lệ", HttpStatus.UNAUTHORIZED),
    REFRESH_TOKEN_EXPIRED(1014, "Token hết hạn", HttpStatus.UNAUTHORIZED),
    INVALID_REFRESH_TOKEN(1013, "Token không hợp lệ", HttpStatus.UNAUTHORIZED),
    SEND_EMAIL_FAILED(1012, "Gửi mail thất bại", HttpStatus.BAD_REQUEST),
    EMAIL_INVALID(1008, "Email không hợp lệ, vui lòng sử dụng email sinh viên", HttpStatus.BAD_REQUEST),
    PASS_INVALID(1010, "Mật khẩu  phải có ít nhất 8 kí tự", HttpStatus.BAD_REQUEST),
    TOKEN_EXPIRED(1011, "Token đã bị hết hạn vui lòng đăng kí lại", HttpStatus.UNAUTHORIZED),
    UNCATEGORIZED_EXCEPTION(9999, "Uncategorized error", HttpStatus.INTERNAL_SERVER_ERROR),
    INVALID_KEY(1001, "Có lỗi xảy ra", HttpStatus.BAD_REQUEST),
    EMAIL_EXISTED(1002, "Email đã tồn tại", HttpStatus.BAD_REQUEST),
    EMAIL_ISVERIFIED(1003, "Email đã được xác thực trước đó",HttpStatus.BAD_REQUEST),
    TOKEN_ISEXPIRED(1040, "Token đã hết hạn. Vui lòng yêu cầu gửi lại email xác thực", HttpStatus.BAD_REQUEST),
    INVALID_PASSWORD(1004, "Mật khẩu xác nhận không khớp", HttpStatus.BAD_REQUEST),
    EMAIL_NOT_EXISTED(1005, "Email không tồn tại", HttpStatus.NOT_FOUND),
    UNAUTHENTICATED(1006, "Tài khoản không chính xác", HttpStatus.UNAUTHORIZED),
    UNAUTHORIZED(1007, "Unauthorized", HttpStatus.UNAUTHORIZED),

    // CHECKING URL PAYMENT
    BOOKING_NOT_FOUND(1010, "Không tìm thấy đơn đặt chỗ", HttpStatus.NOT_FOUND),
    PAYMENT_AMOUNT_MISMATCH(1011, "Số tiền thanh toán không khớp", HttpStatus.BAD_REQUEST),
    PAYMENT_METHOD_NOT_SUPPORTED(1012, "Phương thức thanh toán không được hỗ trợ", HttpStatus.BAD_REQUEST),
    PAYMENT_NOT_FOUND(1013, "Không tìm thấy giao dịch thanh toán", HttpStatus.NOT_FOUND),

    //VALID USER
    NOT_BLANK_FULL_NAME(1020, "Họ tên không được để trống", HttpStatus.BAD_REQUEST),
    SIZE_NAME(1030, "Họ tên phải từ 2-100 ký tự",HttpStatus.BAD_REQUEST),
    EMAIL_NOT_NULL(1031, "Email không được để trống", HttpStatus.BAD_REQUEST),
    NOT_BLANK_PHONE(1021, "Số điện thoại không được để trống", HttpStatus.BAD_REQUEST),
    NOT_BLANK_ADDRESS(1022, "Địa chỉ không được để trống", HttpStatus.BAD_REQUEST),
    PHONE_ERROR(1023, "Số điện thoại phải có 10 chữ số", HttpStatus.NOT_FOUND),
    PHONE_EXISTED(1023, "Số điện thoại đã được đăng kí", HttpStatus.BAD_REQUEST),
    PASS_NOT_NULL(1032, "Mật khẩu không được để trống", HttpStatus.BAD_REQUEST),
    PASS_CONFIRM_NOT_NULL(1033, "Xác nhận mật khẩu không được để trống", HttpStatus.BAD_REQUEST),
    DOB_ERROR(1024, "Ngày sinh phải trước quá khứ", HttpStatus.NOT_FOUND),
    GENDER_ERROR(1025, "Giới tính phải là Nam, Nữ hoặc Khác",HttpStatus.BAD_REQUEST),
    ADDRESS_ERROR(1026, "Địa chỉ tối đa 255 ký tự", HttpStatus.BAD_REQUEST),
    INVALID_FILE_TYPE(1027, "File không đúng định dạng", HttpStatus.BAD_REQUEST),
    FILE_UPLOAD_FAILED(1028, "Upload file thất bại", HttpStatus.INTERNAL_SERVER_ERROR),

    // Thêm các mã lỗi mới cho MoMo
    MOMO_CREATE_PAYMENT_FAILED(9001, "Tạo yêu cầu thanh toán MoMo thất bại",HttpStatus.BAD_REQUEST),
    MOMO_API_CALL_FAILED(9002,  "Lỗi kết nối hoặc gọi API MoMo",HttpStatus.INTERNAL_SERVER_ERROR),

    //VALIDATION cho cập nhật thông tin doanh nghiệp
    NOT_BLANK_COMPANY_NAME(1050, "Tên công ty không được để trống", HttpStatus.BAD_REQUEST),
    NOT_BLANK_DESCRIPTION(1051, "Mô tả không được để trống", HttpStatus.BAD_REQUEST),
    NOT_BLANK_COMPANY_ADDRESS(1052, "Địa chỉ công ty không được để trống", HttpStatus.BAD_REQUEST),
    NOT_BLANK_WEBSITE(1053, "Website không được để trống", HttpStatus.BAD_REQUEST),
    INVALID_WEBSITE_FORMAT(1054, "Website không đúng định dạng URL", HttpStatus.BAD_REQUEST),

    FILE_NOT_FOUND(1055, "File không tồn tại", HttpStatus.NOT_FOUND),

    //PROVINCE
    PROVINCE_NOT_EXISTED(1060, "Tỉnh thành không tồn tại", HttpStatus.NOT_FOUND),

    //DESTINATION
    DESTINATION_NOT_EXISTED(1070, "Địa điểm không tồn tại", HttpStatus.NOT_FOUND),
    ;


    ErrorCode(int code, String message, HttpStatusCode statusCode) {
        this.code = code;
        this.message = message;
        this.statusCode = statusCode;
    }
    private int code;
    private String message;
    private HttpStatusCode statusCode;
}
