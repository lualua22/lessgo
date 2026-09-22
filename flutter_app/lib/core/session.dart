import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'models.dart';

class SessionStore extends ChangeNotifier {
  SessionStore(this.api);
  final ApiClient api;
  ApiUser? user;
  List<Challenge> challenges = const [];
  List<Verification> verifications = const [];
  bool loading = true;
  String? error;
  bool onboardingSeen = false;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('lessgo:user');
    onboardingSeen = prefs.getBool('lessgo:onboarding_seen') ?? false;
    if (raw != null) {
      user = ApiUser.fromJson(jsonDecode(raw));
      await refreshData();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    onboardingSeen = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lessgo:onboarding_seen', true);
    notifyListeners();
  }

  Future<bool> login(String phone, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      user = await api.login(phone, password);
      await _persist();
      return true;
    } on ApiException catch (exception) {
      error = exception.message;
      return false;
    } catch (_) {
      error = '서버에 연결할 수 없어요.';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> signup({
    required String name,
    required String school,
    required String grade,
    required String phone,
    required String password,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      user = await api.signup(
        name: name,
        school: school,
        grade: grade,
        phone: phone,
        password: password,
      );
      await _persist();
      return true;
    } on ApiException catch (exception) {
      error = exception.message;
      return false;
    } catch (_) {
      error = '서버에 연결할 수 없어요.';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    if (user == null) return;
    try {
      challenges = await api.listChallenges(user!.apiKey);
      verifications = await api.listVerifications(user!.apiKey);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> saveUser(ApiUser updated) async {
    user = updated;
    await _persist();
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (user == null) return;
    await api.deleteAccount(user!.apiKey);
    await logout();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lessgo:user', jsonEncode(user!.toJson()));
  }

  Future<void> logout() async {
    user = null;
    challenges = const [];
    verifications = const [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lessgo:user');
    notifyListeners();
  }
}
