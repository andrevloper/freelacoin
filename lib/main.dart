// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'services/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/order_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/orders_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const FreelaCoinApp(),
    ),
  );
}

class FreelaCoinApp extends StatelessWidget {
  const FreelaCoinApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Freela Coin',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const _Shell(),
      );
}

class _Shell extends StatefulWidget {
  const _Shell();
  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  static const _screens = <Widget>[
    DashboardScreen(),
    CatalogScreen(),
    OrderScreen(),
    ClientsScreen(),
    OrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final tab      = state.activeTab;
    final cartCount = state.cartCount;

    return Scaffold(
      body: IndexedStack(index: tab, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => context.read<AppState>().setTab(i),
        height: 64,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Início',
          ),
          const NavigationDestination(
            icon: Icon(Icons.design_services_outlined),
            selectedIcon: Icon(Icons.design_services_rounded),
            label: 'Serviços',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount', style: const TextStyle(fontSize: 10)),
              child: const Icon(Icons.add_circle_outline_rounded),
            ),
            selectedIcon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount', style: const TextStyle(fontSize: 10)),
              child: const Icon(Icons.add_circle_rounded),
            ),
            label: 'Projeto',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Clientes',
          ),
          const NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Projetos',
          ),
        ],
      ),
    );
  }
}
