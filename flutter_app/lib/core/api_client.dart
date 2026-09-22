import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000/api',
  );
  final http.Client _client;

  Future<ApiUser> login(String phone, String password) async {
    final body = await _request(
      '/auth/login',
      method: 'POST',
      payload: {'phone': phone, 'password': password},
    );
    return ApiUser.fromJson(body['user'] as Map<String, dynamic>);
  }

  Future<ApiUser> signup({
    required String name,
    required String school,
    required String grade,
    required String phone,
    required String password,
  }) async {
    final body = await _request(
      '/auth/signup',
      method: 'POST',
      payload: {
        'authProvider': 'phone',
        'name': name,
        'school': school,
        'grade': grade,
        'phone': phone,
        'password': password,
      },
    );
    return ApiUser.fromJson(body['user'] as Map<String, dynamic>);
  }

  Future<List<UserResult>> searchUsers(
    String apiKey, {
    String query = '',
    String region = '',
    String school = '',
  }) async {
    final uri = Uri.parse('$baseUrl/auth/users/search').replace(
      queryParameters: {'q': query, 'region': region, 'school': school},
    );
    final body = await _getUri(uri, apiKey);
    return (body['users'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(UserResult.fromJson)
        .toList();
  }

  Future<void> sendFriendRequest(String apiKey, String userId) async =>
      _request(
        '/auth/friends/requests',
        method: 'POST',
        apiKey: apiKey,
        payload: {'userId': userId},
      );

  Future<List<FriendRequest>> friendRequests(String apiKey) async {
    final body = await _request('/auth/friends/requests', apiKey: apiKey);
    return (body['requests'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(FriendRequest.fromJson)
        .toList();
  }

  Future<List<UserResult>> friends(String apiKey) async {
    final body = await _request('/auth/friends', apiKey: apiKey);
    return (body['friends'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(UserResult.fromJson)
        .toList();
  }

  Future<void> respondFriendRequest(
    String apiKey,
    String id,
    bool accept,
  ) async => _request(
    '/auth/friends/requests/$id',
    method: 'PATCH',
    apiKey: apiKey,
    payload: {'status': accept ? 'accepted' : 'rejected'},
  );

  Future<List<Challenge>> listChallenges(String apiKey) async {
    final body = await _request('/challenges/mine', apiKey: apiKey);
    final list = body['challenges'] as List? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(Challenge.fromJson)
        .toList();
  }

  Future<List<Verification>> listVerifications(String apiKey) async {
    final body = await _request('/verifications', apiKey: apiKey);
    return (body['verifications'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Verification.fromJson)
        .toList();
  }

  Future<Map<String, dynamic>> analyzeScreenTime(
    String apiKey,
    List<String> images,
    List<String> appNames,
  ) {
    final date = DateTime.now();
    return _request(
      '/verify/analyze',
      method: 'POST',
      apiKey: apiKey,
      payload: {
        'images': images,
        'trackedAppNames': appNames,
        'todayLabel': '${date.year}년 ${date.month}월 ${date.day}일',
      },
    );
  }

  Future<Map<String, dynamic>> submitVerification(
    String apiKey,
    String date,
    int minutes,
    List<AppLimit> apps,
  ) => _request(
    '/verifications',
    method: 'POST',
    apiKey: apiKey,
    payload: {
      'date': date,
      'usedMinutes': minutes,
      'apps': apps.map((app) => app.toJson()).toList(),
    },
  );

  Future<Challenge> createChallenge(
    String apiKey,
    Map<String, dynamic> payload,
  ) async {
    final body = await _request(
      '/challenges',
      method: 'POST',
      apiKey: apiKey,
      payload: payload,
    );
    return Challenge.fromJson(body['challenge'] as Map<String, dynamic>);
  }

  Future<Challenge> getChallenge(String id) async {
    final body = await _request('/challenges/$id');
    return Challenge.fromJson(body['challenge'] as Map<String, dynamic>);
  }

  Future<Challenge> joinChallenge(
    String apiKey, {
    String? id,
    String? code,
  }) async {
    final payload = <String, dynamic>{};
    if (id != null) {
      payload['challengeId'] = id;
    }
    if (code != null) {
      payload['code'] = code;
    }
    final body = await _request(
      '/challenges/join',
      method: 'POST',
      apiKey: apiKey,
      payload: payload,
    );
    return Challenge.fromJson(body['challenge'] as Map<String, dynamic>);
  }

  Future<void> deleteChallenge(String apiKey, String id) async =>
      _request('/challenges/$id', method: 'DELETE', apiKey: apiKey);

  Future<Challenge> updateChallenge(
    String apiKey,
    String id,
    Map<String, dynamic> patch,
  ) async {
    final body = await _request(
      '/challenges/$id',
      method: 'PATCH',
      apiKey: apiKey,
      payload: patch,
    );
    return Challenge.fromJson(body['challenge'] as Map<String, dynamic>);
  }

  Future<Challenge> approveChallengeEdit(String apiKey, String id) async {
    final body = await _request(
      '/challenges/$id/pending-edit/approve',
      method: 'POST',
      apiKey: apiKey,
    );
    return Challenge.fromJson(body['challenge'] as Map<String, dynamic>);
  }

  Future<Challenge> rejectChallengeEdit(String apiKey, String id) async {
    final body = await _request(
      '/challenges/$id/pending-edit/reject',
      method: 'POST',
      apiKey: apiKey,
    );
    return Challenge.fromJson(body['challenge'] as Map<String, dynamic>);
  }

  Future<ApiUser> updateProfile(
    String apiKey,
    String name,
    String school,
    String grade, {
    int? age,
    String region = '',
    String bio = '',
    String profileVisibility = 'friends',
  }) async {
    final body = await _request(
      '/auth/me',
      method: 'PATCH',
      apiKey: apiKey,
      payload: {
        'name': name,
        'school': school,
        'grade': grade,
        'age': age,
        'region': region,
        'bio': bio,
        'profileVisibility': profileVisibility,
      },
    );
    return ApiUser.fromJson(body['user'] as Map<String, dynamic>);
  }

  Future<ApiUser> updateAvatar(String apiKey, String avatar) async {
    final body = await _request(
      '/auth/me',
      method: 'PATCH',
      apiKey: apiKey,
      payload: {'avatar': avatar},
    );
    return ApiUser.fromJson(body['user'] as Map<String, dynamic>);
  }

  Future<void> deleteAccount(String apiKey) async {
    await _request('/auth/me', method: 'DELETE', apiKey: apiKey);
  }

  Future<ApiUser> buyBadge(String apiKey, String badgeId) async {
    final body = await _request(
      '/shop/buy',
      method: 'POST',
      apiKey: apiKey,
      payload: {'badgeId': badgeId},
    );
    return ApiUser.fromJson(body['user'] as Map<String, dynamic>);
  }

  Future<ApiUser> equipBadge(String apiKey, String? badgeId) async {
    final body = await _request(
      '/shop/equip',
      method: 'POST',
      apiKey: apiKey,
      payload: {'badgeId': badgeId},
    );
    return ApiUser.fromJson(body['user'] as Map<String, dynamic>);
  }

  Future<void> submitFeedback(
    String apiKey,
    String category,
    String message,
  ) async => _request(
    '/feedback',
    method: 'POST',
    apiKey: apiKey,
    payload: {'category': category, 'message': message},
  );

  Future<Map<String, dynamic>> _request(
    String path, {
    String method = 'GET',
    String? apiKey,
    Map<String, dynamic>? payload,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (apiKey != null) headers['x-api-key'] = apiKey;
    final uri = Uri.parse('$baseUrl$path');
    final response = switch (method) {
      'POST' => await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(payload),
      ),
      'PATCH' => await _client.patch(
        uri,
        headers: headers,
        body: jsonEncode(payload),
      ),
      'DELETE' => await _client.delete(uri, headers: headers),
      _ => await _client.get(uri, headers: headers),
    };
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(decoded['error'] as String? ?? '요청에 실패했어요.');
    }
    return decoded;
  }

  Future<Map<String, dynamic>> _getUri(Uri uri, String apiKey) async {
    final response = await _client.get(
      uri,
      headers: {'Content-Type': 'application/json', 'x-api-key': apiKey},
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(decoded['error'] as String? ?? '요청에 실패했어요.');
    }
    return decoded;
  }
}
