import 'package:flutter/material.dart';
import 'package:jpumun_website/policies.dart';
import 'package:jpumun_website/register_inst.dart';
import 'home.dart';
import 'register.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  debugPaintBaselinesEnabled = false;
  usePathUrlStrategy();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JPUMUN 2026 | Jain PU Model United Nations',
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomePage(),
        '/policies': (context) => const PoliciesPage(),
        '/register': (context) => RegisterPage(),
        '/register-institute': (context) => RegisterInstitute(),
      },
      // Redirect root to /home for direct visits to '/'
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (_) => const HomePage());
        }
        return null; // fall back to `routes`
      },
    );
  }
}
