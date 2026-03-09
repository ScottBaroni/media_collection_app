import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/collection_provider.dart';
import 'screens/shell_screen.dart';

void main() {
  runApp(const MediaShelfApp());
}

class MediaShelfApp extends StatelessWidget {
  const MediaShelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
      CollectionProvider()
        ..loadData(),
      child: MaterialApp(
        title: 'MediaShelf',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const ShellScreen(),
      ),
    );
  }
}