class ApiResponseModel<T>{
  final int code;
  final String msg;
  final T? data;

  ApiResponseModel({required this.code, required this.msg, this.data});

  factory ApiResponseModel.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic)? fromJsonT,
      ) {
    return ApiResponseModel<T>(
      code: json['code'] as int,
      msg: json['msg']?.toString() ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          :null,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T)? toJsonT) {
    return {
      'code': code,
      'msg': msg,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : null,
    };
  }
}