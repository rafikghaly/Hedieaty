import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/init_database.dart';
import 'package:hedieaty/main.dart';
import 'package:workmanager/workmanager.dart';


Future<void> sharedSetup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await DatabaseInitializer().database;
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
}
