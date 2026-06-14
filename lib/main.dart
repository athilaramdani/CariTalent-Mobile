import 'package:caritalent_mobile/app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
    debugPrint("On Web, ensure you have generated firebase_options.dart and passed it to initializeApp.");
  }
  runApp(const ProviderScope(child: CariTalentApp()));
}
