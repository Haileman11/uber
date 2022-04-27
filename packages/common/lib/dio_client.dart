/// A Calculator.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

import 'navigator_service.dart';
import 'shared_preferences_service.dart';
import 'ui/show_dialog.dart';
import 'ui/show_snackbar.dart';

class DioClient {
  late Dio dio;
  late NavigationService navigationService;
  late SharedPreferencesService sharedPrefs;
  DioClient(this.navigationService, ProviderRef ref) {
    sharedPrefs = ref.read(sharedPreferencesServiceProvider);
    dio = Dio(
      BaseOptions(
        baseUrl: "http://192.168.1.108:7500/api/",
        // baseUrl: API_ROOT_URL,
        // connectTimeout: 60000,
        // receiveTimeout: 60000,
      ),
    );
    dio
      ..interceptors.add(LoggingInterceptor())
      // ..interceptors.add(LoggedOutInterceptor(navigationService, sharedPrefs))
      ..interceptors.add(AuthInterceptor(sharedPrefs))
      ..interceptors.add(ErrorInterceptor(dio, navigationService, sharedPrefs));
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    print(
      'ERROR[${err.response == null ? err.error.runtimeType : err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    return super.onError(err, handler);
  }
}

class AuthInterceptor extends Interceptor {
  SharedPreferencesService sharedPrefs;

  AuthInterceptor(this.sharedPrefs);
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    String? token = sharedPrefs.getToken();
    if (options.headers.containsKey("requiresToken") &&
        token != null &&
        token != '') {
      options.headers.remove("requiresToken");
      options.headers["Authorization"] = "Bearer " + token;
    }
    super.onRequest(options, handler);
  }
}

// class LoggedOutInterceptor extends Interceptor {
//   SharedPrefs sharedPrefs;
//   NavigationService navigationService;

//   LoggedOutInterceptor(this.navigationService, this.sharedPrefs);

//   @override
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     bool requiresToken = options.headers.containsKey("requiresToken");
//     String token = sharedPrefs.getToken();
//     if (requiresToken && (token == null || token == '')) {
//       showSignInSnackBar(
//         navigationService.navigatorKey.currentContext,
//       );
//       handler.reject(
//         DioError(requestOptions: options),
//       );
//       return;
//     }
//     super.onRequest(options, handler);
//   }
// }

class ErrorInterceptor extends Interceptor {
  NavigationService navigationService;
  Dio dio;
  SharedPreferencesService sharedPrefs;
  ErrorInterceptor(this.dio, this.navigationService, this.sharedPrefs);
  @override
  // void onResponse(Response response, ResponseInterceptorHandler handler) {
  //   if (response.data['message'] != null) {
  //     showSnackBar(
  //         navigationService.navigatorKey.currentState!.overlay!.context,
  //         response.data['message'],
  //         false);
  //   }
  //   super.onResponse(response, handler);
  // }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.error is SocketException) {
      showSnackBar(
          navigationService.navigatorKey.currentState!.overlay!.context,
          "Socket Exception",
          true);
      // Response response;
      // response = await showErrorDialog(
      //     navigationService.navigatorKey.currentState.overlay.context, err,
      //     dio: dio);
      // if (response != null) {
      //   handler.resolve(response);
      // }
      return;
    } else if (err.response == null) {
      showSnackBar(
          navigationService.navigatorKey.currentState!.overlay!.context,
          err.message,
          true);
    } else if (err.type == DioErrorType.response) {
      if (err.response!.statusCode == 401) {
        // sharedPrefs.logOut();

        showSnackBar(
            navigationService.navigatorKey.currentState!.overlay!.context,
            err.response!.data['message'],
            // err.response!.data['error'] ?? err.response!.data['message'],
            true);
      } else {
        if (err.response != null) {
          showSnackBar(
              navigationService.navigatorKey.currentState!.overlay!.context,
              "Not found",
              true);
        }
      }
    } else {
      showSnackBar(
          navigationService.navigatorKey.currentState!.overlay!.context,
          err.error,
          // err.response!.data['message'],
          true);
    }
    handler.reject(err);
    // handler.resolve(Response(requestOptions: err.requestOptions));
  }
}

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref.read(navigationProvider.notifier), ref);
});
