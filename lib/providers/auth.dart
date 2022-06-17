import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token; //token expire after an amount of time typically one hour
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  Future<void> _authenticate(
      String email, String password, String urlSeg) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSeg?key=AIzaSyCW866_k3zEEOq1upoVH6R_ZbnyMMdABVE');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);
      // print(responseData);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogOut();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);
      // print('=====================>');
      // print(prefs.getString('userData'));
    } catch (error) {
      //Firebase doesn't return an error, it doesn't have an error status
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> logIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> logOut() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<bool> tryAutoLogIn() async {
    // print('I TRIEEEEEEEEEEEEEEEEEEEEEED');
    final prefs = await SharedPreferences.getInstance();
    // print(prefs.getString('userData'));
    if (!prefs.containsKey('userData')) {
      return false;
    } else {
      // print('Do I get here?');
      final extractedUserData =
          json.decode(prefs.getString('userData') as String)
              as Map<String, dynamic>;
      // print(extractedUserData);
      final expiryDate =
          DateTime.parse(extractedUserData['expiryDate'] as String);
      // print('why');
      if (expiryDate.isBefore(DateTime.now())) {
        return false;
      }
      _token = extractedUserData['token'] as String;
      _userId = extractedUserData['userId'] as String;
      _expiryDate = expiryDate;
      // print(_token);
      // print(_userId);
      // print(_expiryDate);
      notifyListeners();
      _autoLogOut();
    }
    return true;
  }

  void _autoLogOut() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate?.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry!), logOut);
  }

  bool get isAuth {
    // print('****************');
    // print(_token);
    return token != '';
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      // print(_token);
      // print(_userId);
      // print(_expiryDate);
      // print('ok');
      return _token as String;
    }
    // print(_token);
    // print(_userId);
    // print(_expiryDate);
    // print('not Ok');
    return '';
  }

  String get userId {
    return _userId == null ? '' : _userId as String;
  }
}
