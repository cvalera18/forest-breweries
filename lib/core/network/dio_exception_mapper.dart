import 'dart:io';

import 'package:dio/dio.dart';
import 'package:forest_breweries/core/error/app_exception.dart';

extension DioExceptionMapper on DioException {
  AppException toAppException() => switch (type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.connectionError => const NetworkException(),
    DioExceptionType.unknown when error is SocketException =>
      const NetworkException(),
    DioExceptionType.badResponse when response?.statusCode == 404 =>
      const NotFoundException(),
    DioExceptionType.badResponse => ServerException(response?.statusCode),
    DioExceptionType.cancel ||
    DioExceptionType.badCertificate ||
    DioExceptionType.transformTimeout ||
    DioExceptionType.unknown => UnexpectedException(this),
  };
}
