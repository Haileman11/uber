import 'package:common/dio_client.dart';
import 'package:dio/dio.dart';

class ProfileService {
  /// Persists the user's preferred ThemeMode to local or remote storage.
  late DioClient _dioClient;

  ProfileService(this._dioClient);
  static const getUserProfileUrl = "Request/get-user-profile";
  Future<Map?> getUserProfile() async {
    Response response;
    try {
      response = await _dioClient.dio.get(getUserProfileUrl,
          options: Options(headers: {'requiresToken': true}));
      return response.data;
    } on DioError catch (e) {
      print(e);
      if (e.response!.statusCode == 401) {
        return null;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
