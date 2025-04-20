import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/db_handler.dart';
import 'core/profile.dart';
import 'screens/home_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/pool_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/screen.dart';
import 'screens/settings_screen.dart';

import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

void main() async {
  // NOTE: Must always stay at top for other things to work.
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool('isFirstTime') ?? true;
  final db = await DbHandler.getInstance();

  if (kDebugMode) {
    await db.setToDebugMode();
  } else if (isFirstTime) {
    await prefs.setBool('isFirstTime', false);
    await db.setToDefault();
  }

  late final Profile profile;

  try {
    profile = await Profile.fromDb(db);
  } catch (e) {
    // TODO: add error screen thing (Anuj)
    runApp(MaterialApp(
      title: 'Lvl Up',
      debugShowCheckedModeBanner: kDebugMode,
      theme: ThemeData(
          useMaterial3: true, scaffoldBackgroundColor: Colors.grey.shade300),
      home: Text(e.toString()),
    ));
    return;
  }

  runApp(MaterialApp(
    title: 'Lvl Up',
    debugShowCheckedModeBanner: kDebugMode,
    theme: ThemeData(
        useMaterial3: true, scaffoldBackgroundColor: Colors.grey.shade400),
    home: MyApp(profile),
  ));
}

final class MyApp extends StatefulWidget {
  const MyApp(this.profile, {super.key});

  final Profile profile;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late int pageIdx;
  late final List<Screen> pages;
  late final PageController pageController;
  late final Profile profile;

  @override
  void initState() {
    profile = widget.profile;
    pageIdx = 0;
    pages = [
      HomeScreen(profile),
      PoolScreen(profile),
      InventoryScreen(profile),
      SettingsScreen(profile),
    ];
    pageController = PageController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final page = pages[pageIdx];

    return Scaffold(
        drawer: Drawer(child: SettingsScreen(profile)),
        appBar: AppBar(
          elevation: 5,
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.7),
          title: Text(
            page.title,
            style: GoogleFonts.monda(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(profile),
                  ),
                );
              },
              icon: Icon(
                Icons.person_2_sharp,
                size: 30,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
        body: PageView(
          controller: pageController,
          physics: NeverScrollableScrollPhysics(),
          children: pages,
        ),
        bottomNavigationBar: StylishBottomBar(
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.7),
          option: DotBarOptions(
            dotStyle: DotStyle.tile,
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 0, 0, 0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          items: [
            BottomBarItem(
              icon: const Icon(
                Icons.home,
                size: 34,
              ),
              title: const Text('Home'),
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              selectedIcon: const Icon(Icons.home_filled),
            ),
            BottomBarItem(
              icon: const Icon(Icons.add_circle),
              title: const Text('Add Tasks'),
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            ),
            BottomBarItem(
              icon: const Icon(Icons.inventory),
              title: const Text('Rewards'),
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            ),
            BottomBarItem(
              icon: const Icon(Icons.settings),
              title: const Text('Settings'),
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            ),
          ],
          currentIndex: pageIdx,
          onTap: (index) {
            setState(() {
              pageIdx = index;
              pageController.jumpToPage(index);
            });
          },
        ));
  }
}
