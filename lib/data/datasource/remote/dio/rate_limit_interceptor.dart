import 'package:dio/dio.dart';

/// Retries GET requests after HTTP 429 with optional [Retry-After] delay.
class RateLimitInterceptor extends Interceptor {
  RateLimitInterceptor(this._dio);

  final Dio _dio;

  static const String _retryExtraKey = 'rate_limit_retry_count';

  int _retryAfterSeconds(Response<dynamic>? response) {
    final header = response?.headers.value('retry-after');
    if (header == null || header.isEmpty) return 0;
    final asInt = int.tryParse(header);
    if (asInt != null) return asInt.clamp(1, 60);
    final asDate = DateTime.tryParse(header);
    if (asDate != null) {
      final sec = asDate.difference(DateTime.now()).inSeconds;
      return sec.clamp(1, 60);
    }
    return 0;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode != 429) {
      handler.next(err);
      return;
    }
    final ro = err.requestOptions;
    if (ro.method.toUpperCase() != 'GET') {
      handler.next(err);
      return;
    }
    final count = (ro.extra[_retryExtraKey] as int?) ?? 0;
    if (count >= 2) {
      handler.next(err);
      return;
    }
    _retryAfterDelay(err, handler, count);
  }

  Future<void> _retryAfterDelay(
    DioException err,
    ErrorInterceptorHandler handler,
    int count,
  ) async {
    final ro = err.requestOptions;
    final fromHeader = _retryAfterSeconds(err.response);
    final fallback = (1 << count).clamp(1, 8);
    final seconds = fromHeader > 0 ? fromHeader : fallback;
    await Future<void>.delayed(Duration(seconds: seconds));
    ro.extra[_retryExtraKey] = count + 1;
    try {
      final response = await _dio.fetch(ro);
      handler.resolve(response);
    } catch (e) {
      if (e is DioException) {
        handler.next(e);
      } else {
        handler.next(err);
      }
    }
  }
}
