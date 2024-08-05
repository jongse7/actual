import 'package:actual/common/secure_storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../const/data.dart';

final dioProvider = Provider((ref){
  final dio = Dio();

  final storage = ref.watch(secureStorageProvider);

  dio.interceptors.add(
    CustomInterceptor(
      storage: storage,
    ),
  );
  return dio;
});

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;

  CustomInterceptor({
    required this.storage,
  });

  // 1) 요청을 보낼때
  // 요청이 보내질 때마다
  // 만약 요청의 Header에 accessToken : true라는 값이 있다면
  // 실제 토큰을 가져와서 storage에서 authorization : bearer $token으로
  // 헤더를 변경한다.
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print('[REQ] [${options.method} ${options.uri}');

    // accessToken 삽입
    if (options.headers['accessToken'] == 'true') {
      options.headers.remove('accessToken');
      final token = await storage.read(key: ACCESS_TOKEN_KEY);

      options.headers.addAll({
        'authorization': 'Bearer $token',
      });
    }

    // refreshToken 삽입
    if (options.headers['refreshToken'] == 'true') {
      options.headers.remove('refreshToken');
      final token = await storage.read(key: REFRESH_TOKEN_KEY);

      options.headers.addAll({
        'authorization': 'Bearer $token',
      });
    }

    return super.onRequest(options, handler);
  }

  // 2) 응답을 받을때
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('[REQ] [${response.requestOptions.method} ${response.requestOptions.uri}');
    super.onResponse(response, handler);
  }

  // 3) 에러가 났을때
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401에러가 났을때 (status code)
    // 토큰을 재발급 받는 시도를 하고 토큰이 재발급되면
    // 다시 새로운 토큰으로 요청을 한다.
    print('[ERR] [${err.requestOptions.method} ${err.requestOptions.uri}');

    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    // refreshToken이 없을 때 에러 던지기
    if (refreshToken == null) {
      handler.reject(err); // 에러 돌려주기
      return;
    }

    // 401 오류일 때
    final isStatus401 = err.response?.statusCode == 401;
    // 토큰을 새로 발급 받는 요청인지?
    final isPathRefresh = err.requestOptions.path == '/auth/token';

    // 401 오류이고 토큰을 새로 발급 받는 요청이 아닐 떄
    if (isStatus401 && !isPathRefresh) {
      try {
        final dio = Dio();

        final resp = await dio.post(
          'http://$ip/auth/token',
          options: Options(
            headers: {
              'authoriztion': 'Bearer $refreshToken',
            },
          ),
        );

        final accessToken = resp.data['accessToken'];

        final options = err.requestOptions;

        // 토큰 변경하기
        options.headers.addAll({
          'authorization' : 'Bearer $accessToken',
        });

        await storage.write(key : ACCESS_TOKEN_KEY, value: accessToken);

        // 요청 재전송
        final response = await dio.fetch(options);

        return handler.resolve(response);
      } catch (e) { // on DioError catch (e) 새로운 Dio 패키지에선 아마 다른 걸로 대체된듯...
        return handler.reject(err);
      }
    }
  }
}
