// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/theme_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/audio_provider.dart';
import 'screens/splash_screen.dart';
import 'services/gemini_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set full-screen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('Environment variables loaded');
  } catch (e) {
    debugPrint('Warning: .env file not found. App will work in offline mode.');
  }

  // Initialize Gemini service
  try {
    await GeminiService().initialize();
    debugPrint('Gemini service initialized');
  } catch (e) {
    debugPrint('Gemini initialization failed: $e');
    // App will work in offline mode
  }

  runApp(const SakuraChatApp());
}

class SakuraChatApp extends StatefulWidget {
  const SakuraChatApp({super.key});

  @override
  State<SakuraChatApp> createState() => _SakuraChatAppState();
}

class _SakuraChatAppState extends State<SakuraChatApp> with WidgetsBindingObserver {
  late ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _chatProvider = ChatProvider();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chatProvider.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Clear chat when app is closed/paused
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _chatProvider.clearChat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: _chatProvider),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'SakuraChat',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}