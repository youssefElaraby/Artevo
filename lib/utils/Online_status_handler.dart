import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnlineStatusHandler extends WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  OnlineStatusHandler() {
    WidgetsBinding.instance.addObserver(this);
    _setOnlineStatus(true); // أول ما التطبيق يفتح
  }

  void _setOnlineStatus(bool status) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': status,
        'lastSeen': FieldValue.serverTimestamp(), // آخر ظهور حقيقي
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setOnlineStatus(true); // رجع للتطبيق
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _setOnlineStatus(false); // خرج من التطبيق أو أغلقه
    }
  }
}
