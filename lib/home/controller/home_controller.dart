class NetworkResponse {
  final int statusCode;
  final dynamic responseData;
  final String? errorMessage;
  final bool isSuccess;

  NetworkResponse({
    required this.statusCode,
    this.responseData,
    this.errorMessage,
    required this.isSuccess,
  });
}