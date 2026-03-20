import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/collection_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/shell_screen.dart';

void main() {
  runApp(const MediaShelfApp());
}

class MediaShelfApp extends StatelessWidget {
  const MediaShelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CollectionProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'MediaShelf',
          debugShowCheckedModeBanner: false,
          theme: settings.themeData,
          home: const ShellScreen(),
        ),
      ),
    );
  }
}