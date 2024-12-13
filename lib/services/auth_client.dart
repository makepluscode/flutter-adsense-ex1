import 'package:http/http.dart' as http;

class AuthClient extends http.BaseClient {
  final String accessToken;
  final http.Client _inner;

  AuthClient(this.accessToken, this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $accessToken';
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
