import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/semantics.dart' show SemanticsBinding;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/core.dart';
import 'widgets/up_police_badge.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Enable Flutter Web semantics tree so Playwright / screen readers can
  // read text content. Without this, CanvasKit renders text as canvas
  // glyphs and document.body.innerText is empty.
  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }
  runApp(const UPPoliceHrmsApp());
}

class UPPoliceHrmsApp extends StatelessWidget {
  const UPPoliceHrmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'प्रधान लिपिक शाखा जनपद बरेली',
        theme: AppTheme.lightTheme,
        locale: AppTheme.hindiLocale,
        supportedLocales: AppTheme.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // SelectionArea makes every Text widget in the entire app
        // selectable / copyable without changing individual widgets.
        home: const SelectionArea(child: AppEntryPoint()),
      ),
    );
  }
}

/// App Entry Point — loads data first, then shows the Dashboard.
///
/// Wraps the Dashboard in a `PopScope` so the Android back button and
/// Windows Escape key do NOT close the app accidentally — they are
/// simply ignored on the home route. Sub-routes (Profile, Transfer
/// Classification) get a real back arrow in their AppBar plus the
/// hardware back / Escape handlers wired up in their own files.
class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // On the home route, swallow the Android back button so the app
      // is NOT closed by an accidental tap. (Browser back button on
      // web is handled by Flutter's Navigator automatically — at the
      // root route it has nowhere to go, so it stays put.)
      canPop: false,
      child: Consumer<EmployeeProvider>(
        builder: (context, provider, _) {
          if (!provider.isInitialLoadDone) {
            return _InitialLoading(provider: provider);
          }
          return const DashboardScreen();
        },
      ),
    );
  }
}

class _InitialLoading extends StatelessWidget {
  final EmployeeProvider provider;
  const _InitialLoading({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium loading card
              AppTheme.premiumCard(
                borderRadius: 20,
                padding: const EdgeInsets.all(40),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    UPPoliceBadge(size: 66),
                    SizedBox(height: 28),
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'डेटा लोड हो रहा है...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'कर्मचारी प्रबंधन प्रणाली',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (provider.error.isNotEmpty) ...[
                const SizedBox(height: 24),
                AppTheme.premiumCard(
                  borderRadius: 14,
                  padding: const EdgeInsets.all(20),
                  cardBorderColor: AppTheme.errorColor.withOpacity(0.5),
                  child: Column(
                    children: [
                      Text(
                        provider.error,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.errorColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              provider.loadAllData(forceRefresh: true),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('पुनः प्रयास करें'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
