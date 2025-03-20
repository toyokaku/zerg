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
      debugPrint('Initializing connection to Badger service');
      
      // Add a retry mechanism
      int retries = 0;
      const maxRetries = 3;
      
      Future<void> tryConnect() async {
        try {
          await _grpcClient.initialize();
          
          setState(() {
            _initialized = true;
            _errorMessage = '';
          });
          
          debugPrint('Successfully connected to Badger service');
        } catch (e, stackTrace) {
          retries++;
          if (retries < maxRetries) {
            debugPrint('Connection attempt $retries failed: $e. Retrying in 2 seconds...');
            debugPrint('Stack trace: $stackTrace');
            await Future.delayed(const Duration(seconds: 2));
            await tryConnect();
          } else {
            setState(() {
              _errorMessage = 'Failed to connect to Badger after $maxRetries attempts: $e';
            });
            debugPrint('Failed to initialize client after $maxRetries attempts: $e');
            debugPrint('Stack trace: $stackTrace');
            
            // Continue with app initialization anyway
            if (mounted) {
              setState(() {
                _initialized = true;
              });
            }
          }
        }
      }
      
      // Start the connection process
      tryConnect();
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = 'Unexpected error connecting to Badger: $e';
      });
      debugPrint('Unexpected error initializing client: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Continue with app initialization anyway
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
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