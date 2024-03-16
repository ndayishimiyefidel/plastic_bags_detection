import 'package:flutter/material.dart';

import '../enume/user_state.dart';

final messengerKey = GlobalKey<ScaffoldMessengerState>();

class Utils {
  static showSnackBar(String? text) {
    if (text == null) return;
    final snackBar = SnackBar(content: Text(text), backgroundColor: Colors.red);
    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }


  static int stateToNum(UserState userState) {
    switch (userState) {
      case UserState.offline:
        return 0;
      case UserState.online:
        return 1;
      default:
        return 2;
    }
  }

  static UserState numToState(int number) {
    switch (number) {
      case 0:
        return UserState.offline;
      case 1:
        return UserState.online;
      default:
        return UserState.waiting;
    }
  }

}
