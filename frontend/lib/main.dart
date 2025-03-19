import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'screens/dashboard_screen.dart';
import 'services/grpc_client.dart';

void main() {
  runApp(const ZergApp());
}

class ZergApp extends StatefulWidget {
  const ZergApp({Key? key}) : super(key: key);

  @override
  State<ZergApp> createState() => _ZergAppState();
}

class _ZergAppState extends State<ZergApp> {
  final _grpcClient = GrpcClient();
  bool _initialized = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeGrpcClient();
  }

  void _initializeGrpcClient() {
    try {
      // Get server address from environment or use default
      final serverAddress = const String.fromEnvironment(
        'BADGER_GRPC_URL', 
        defaultValue: 'localhost:9090'
      );
      
      _grpcClient.initialize(serverAddress);
      setState(() {
        _initialized = true;
      });
      
      debugPrint('Connected to Badger gRPC server at $serverAddress');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect to Badger: $e';
      });
      debugPrint('Failed to initialize gRPC client: $e');
    }
  }

  @override
  void dispose() {
    _grpcClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zerg',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: _initialized
          ? const DashboardScreen()
          : Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Connecting to Badger...'),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SelectableText(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}