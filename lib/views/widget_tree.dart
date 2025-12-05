import 'package:flutter/material.dart';
import 'package:flutterassignment/data/notifiers.dart';
import 'package:flutterassignment/views/pages/generate_page.dart';
import 'package:flutterassignment/views/pages/recepies_page.dart';
import 'package:flutterassignment/views/pages/home_page.dart';
import 'package:flutterassignment/views/pages/profile_page.dart';
import 'package:flutterassignment/views/widgets/navbar_widget.dart';
import 'package:flutterassignment/views/pages/add_page.dart';

class WidgetTree extends StatelessWidget {
  final Function(bool) toggleTheme;

  const WidgetTree({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    final pages = [
      const AddIngredientPage(), // index 0 - leftmost
      const GeneratePage(), // index 1
      const HomePage(), // index 2 - center (FAB)
      const RecepiesPage(), // index 3
      ProfilePage(toggleTheme: toggleTheme), // index 4 - rightmost
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.food_bank, color: Colors.orange, size: 24),
            SizedBox(width: 16),
            Text(
              'Recipie Book',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: const Color.fromARGB(0, 255, 153, 0),
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, child) {
          final safeIndex =
              (selectedPage >= 0 && selectedPage < pages.length)
                  ? selectedPage
                  : 0;
          return pages.elementAt(safeIndex);
        },
      ),
      bottomNavigationBar: const NavbarWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => selectedPageNotifier.value = 2,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.home, color: Colors.white, size: 28),
      ),
    );
  }
}