import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prueba_2/features/camera/camera_screen.dart';
import 'package:prueba_2/features/history/description_screen.dart';
import 'package:prueba_2/features/history/detail_screen.dart';
import 'package:prueba_2/features/history/history_screen.dart';
import 'package:prueba_2/features/history/predict_model.dart';
import 'package:prueba_2/features/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

final appRouter = GoRouter(
  initialLocation: "/${MainScreen.name}",
  routes: [
    GoRoute(
      path: "/${MainScreen.name}",
      name: MainScreen.name,
      builder: (context, state) {
        final index = state.extra as int?;
        return MainScreen(
          initialIndex: index ?? 0,
        );
      },
    ),
    GoRoute(
      path: "/${DescriptionScreen.name}",
      name: DescriptionScreen.name,
      builder: (context, state) {
        final model = state.extra as PredictModel;
        return DescriptionScreen(model: model);
      },
    ),
    GoRoute(
      path: "/${DetailScreen.name}",
      name: DetailScreen.name,
      builder: (context, state) {
        final model = state.extra as PredictModel;
        return DetailScreen(model: model);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Mi App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}

class MainScreen extends StatefulWidget {
  static const name = "MainScreen";
  final int? initialIndex;
  const MainScreen({
    super.key,
    this.initialIndex,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex ?? 0;
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget buildBody(int index) {
    // Crear una nueva instancia del widget cada vez que se cambie de tab
    switch (index) {
      case 0:
        return HomeScreen(
          onTapCamera: () {
            _onItemTapped(1);
          },
        );
      case 1:
        return CameraScreen();
      case 2:
        return HistoryScreen();
      default:
        return HomeScreen(
          onTapCamera: () {
            _onItemTapped(1);
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.pink[400],
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: _selectedIndex == 0 ? 40 : 25),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt, size: _selectedIndex == 1 ? 40 : 25),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_snippet, size: _selectedIndex == 2 ? 40 : 25),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
