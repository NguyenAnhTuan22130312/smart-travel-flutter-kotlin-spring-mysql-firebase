package com.example.smart_travel_BE.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;

@Getter

public enum ErrorCode {

    //VALID AUTH

    IS_VERIFY_EMAIL(1018, "Tài khoản chưa được xác thực", HttpStatus.UNAUTHORIZED),
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
    UNAUTHORIZED(1007, "Không có quyền truy cập hoặc phiên đăng nhập đã hết hạn", HttpStatus.UNAUTHORIZED),
    INVOICE_NOT_FOUND(1040, "Không tìm thấy hóa đơn", HttpStatus.NOT_FOUND),
    REFUND_NOT_ALLOWED(1041, "Không thể yêu cầu hoàn tiền với trạng thái hiện tại", HttpStatus.BAD_REQUEST),
    REFUND_ALREADY_REQUESTED(1042, "Yêu cầu hoàn tiền đã được gửi trước đó", HttpStatus.BAD_REQUEST),


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
    USER_NOT_EXISTED(1034, "Người dùng không tồn tại", HttpStatus.NOT_FOUND),
    USER_ALREADY_LOCKED(1035, "Tài khoản đã bị khóa", HttpStatus.BAD_REQUEST),
    USER_ALREADY_UNLOCKED(1036, "Tài khoản đã được mở khóa", HttpStatus.BAD_REQUEST),

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
    NOT_BLANK_PROVINCE_NAME(1061, "Tên tỉnh không được để trống", HttpStatus.BAD_REQUEST),
    SIZE_PROVINCE_NAME(1062, "Tên tỉnh phải từ 2 đến 100 ký tự", HttpStatus.BAD_REQUEST),
    NOT_BLANK_PROVINCE_CODE(1063, "Mã tỉnh không được để trống", HttpStatus.BAD_REQUEST),
    SIZE_PROVINCE_CODE(1064, "Mã tỉnh phải từ 2 đến 10 ký tự", HttpStatus.BAD_REQUEST),
    NOT_BLANK_REGION(1065, "Vùng không được để trống", HttpStatus.BAD_REQUEST),
    SIZE_DESCRIPTION(1066, "Mô tả tối đa 255 ký tự", HttpStatus.BAD_REQUEST),
    NOT_NULL_IS_POPULAR(1067, "Trường isPopular không được null", HttpStatus.BAD_REQUEST),
    IMAGE_UPLOAD_FAILED(1068, "Upload hình ảnh thất bại", HttpStatus.BAD_REQUEST),
    PROVINCE_CODE_EXISTED(1069, "Tỉnh đã tồn tại", HttpStatus.BAD_REQUEST),


    //DESTINATION
    DESTINATION_NOT_EXISTED(1070, "Địa điểm không tồn tại", HttpStatus.NOT_FOUND),
    DESTINATION_NAME_BLANK(1101, "Tên địa điểm không được để trống", HttpStatus.BAD_REQUEST),
    DESTINATION_NAME_SIZE(1102, "Tên địa điểm phải từ 2 đến 200 ký tự", HttpStatus.BAD_REQUEST),
    PROVINCE_ID_REQUIRED(1103, "ID tỉnh/thành là bắt buộc", HttpStatus.BAD_REQUEST),
    LATITUDE_REQUIRED(1104, "Vĩ độ là bắt buộc", HttpStatus.BAD_REQUEST),
    LONGITUDE_REQUIRED(1105, "Kinh độ là bắt buộc", HttpStatus.BAD_REQUEST),
    LATITUDE_INVALID(1106, "Vĩ độ phải từ -90 đến 90", HttpStatus.BAD_REQUEST),
    LONGITUDE_INVALID(1107, "Kinh độ phải từ -180 đến 180", HttpStatus.BAD_REQUEST),
    CATEGORY_SIZE(1108, "Danh mục phải từ 2 đến 100 ký tự", HttpStatus.BAD_REQUEST),
    ENTRY_FEE_NEGATIVE(1109, "Phí vào cửa không được âm", HttpStatus.BAD_REQUEST),
    IMAGE_URL_INVALID(1110, "URL ảnh không hợp lệ", HttpStatus.BAD_REQUEST),
    DESTINATION_ALREADY_EXISTS(1002, "Địa điểm đã tồn tại trong tỉnh này", HttpStatus.CONFLICT),
    INVALID_JSON_FORMAT(1111, "Định dạng JSON không hợp lệ", HttpStatus.BAD_REQUEST),

    FILE_REQUIRED(1113, "File ảnh là bắt buộc", HttpStatus.BAD_REQUEST),
    FILE_TOO_LARGE(1114, "File quá lớn, tối đa 5MB", HttpStatus.BAD_REQUEST),
    FILE_TYPE_NOT_SUPPORTED(1115, "Chỉ hỗ trợ JPG, PNG, WebP, GIF", HttpStatus.BAD_REQUEST),
    IMAGE_UPLOAD_FAILED_ERROR(1116, "Upload ảnh thất bại", HttpStatus.INTERNAL_SERVER_ERROR),
    IMAGE_NOT_FOUND(1117, "Hình ảnh không tồn tài", HttpStatus.NOT_FOUND),
    AUDIO_ALREADY_EXISTS(1118, "Địa điểm này đã có nội dung thuyết minh, vui lòng sử dụng chức năng chỉnh sửa", HttpStatus.BAD_REQUEST),

    ///BANNER
    BANNER_NAME_BLANK(1080, "Tên banner không được để trống", HttpStatus.BAD_REQUEST),
    IMAGE_URL_BLANK(1081, "Đường dẫn hình ảnh không được để trống", HttpStatus.BAD_REQUEST),
    BANNER_NOT_EXISTED(1082, "Banner không tồn tại", HttpStatus.NOT_FOUND),
    /// INVOICE
    INVALID_TYPE(1018, "Sai type cua hotel, tour, destination", HttpStatus.UNAUTHORIZED),


    // ADMIN PERMISSIONS
    CANNOT_MODIFY_ADMIN_USER(1090, "Không thể sửa thông tin admin khác cùng cấp", HttpStatus.FORBIDDEN),
    CANNOT_CHANGE_ADMIN_ROLE(1091, "Không thể thay đổi role của ADMINTOUR/ADMINHOTEL", HttpStatus.FORBIDDEN),
    NO_WRITE_PERMISSION(1092, "Bạn chỉ có quyền xem, không có quyền chỉnh sửa", HttpStatus.FORBIDDEN),
    CANNOT_MODIFY_HIGHER_ROLE(1093, "Không thể chỉnh sửa tài khoản có role cao hơn hoặc bằng bạn", HttpStatus.FORBIDDEN),
    COOLDOWN_ACTIVE(1009, "Vui lòng đợi 3 phút để tiếp tục nhận EXP tại địa điểm này", HttpStatus.BAD_REQUEST),
    REVIEW_SPAM_DETECTED(1019,"spam it thoi", HttpStatus.BAD_REQUEST),
    DESTINATION_NOT_FOUND(1019,  "khong thay destination" ,HttpStatus.NOT_FOUND ),
    REFUND_NOT_PENDING(1050,"status not in pending" , HttpStatus.BAD_REQUEST ),
    INVALID_BOOKING_TYPE(1051, "Chỉ áp dụng check-in cho đơn đặt phòng khách sạn",HttpStatus.BAD_REQUEST),
    INVALID_STATUS(1052, "Đơn hàng phải ở trạng thái ACTIVE để check-in",HttpStatus.BAD_REQUEST),;

    ErrorCode(int code, String message, HttpStatusCode statusCode) {
        this.code = code;
        this.message = message;
        this.statusCode = statusCode;
    }
    private int code;
    private String message;
    private HttpStatusCode statusCode;
}
