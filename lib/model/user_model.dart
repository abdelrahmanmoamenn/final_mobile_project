import 'package:flutter/foundation.dart';

class AuthUserModel extends ChangeNotifier {
  String? _uid;

  String? get uid => _uid;
  bool get isLoggedIn => _uid != null;

  void setUid(String? uid) {
    _uid = uid;
    notifyListeners();
  }
}
