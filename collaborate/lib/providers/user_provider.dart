import 'package:flutter/widgets.dart';
import 'package:collaborate/models/user.dart';
import 'package:collaborate/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User get getUser => _user!;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    print(_user);
    notifyListeners();
  }
}
