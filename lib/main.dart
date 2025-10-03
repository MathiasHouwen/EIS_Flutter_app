import 'package:flutter/material.dart';
import 'package:to_do/pages/home.dart';
import 'package:to_do/pages/to_do_classes.dart';
import 'package:provider/provider.dart';

// TODO: BUG - ALS MULTPLE instanties (TODO of lijst pijn)
// TODO: Priority
// TODO: presisten storage

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => HomeModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}