import 'package:flutter/material.dart';
import 'package:flutterassignment/data/notifiers.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  Color _iconColor(bool isSelected) {
    return isSelected ? Colors.orange : const Color.fromARGB(179, 41, 41, 41);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedIndex, child) {
        return BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          color: const Color.fromARGB(255, 240, 240, 240),
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  tooltip: 'Add',
                  icon: Icon(
                    Icons.add_circle,
                    size: 28,
                    color: _iconColor(selectedIndex == 0),
                  ),
                  onPressed: () => selectedPageNotifier.value = 0,
                ),
                IconButton(
                  tooltip: 'Generate',
                  icon: Icon(
                    Icons.auto_awesome,
                    size: 28,
                    color: _iconColor(selectedIndex == 1),
                  ),
                  onPressed: () => selectedPageNotifier.value = 1,
                ),

                // Placeholder for FAB
                const SizedBox(width: 48),

                IconButton(
                  tooltip: 'Recepies',
                  icon: Icon(
                    Icons.menu_book,
                    size: 28,
                    color: _iconColor(selectedIndex == 3),
                  ),
                  onPressed: () => selectedPageNotifier.value = 3,
                ),
                IconButton(
                  tooltip: 'Settings',
                  icon: Icon(
                    Icons.settings,
                    size: 28,
                    color: _iconColor(selectedIndex == 4),
                  ),
                  onPressed: () => selectedPageNotifier.value = 4,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HomeLayout extends StatelessWidget {
  const HomeLayout({super.key});

  Color _iconColor(bool isSelected) {
    return isSelected ? Colors.orange : const Color.fromARGB(179, 41, 41, 41);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedIndex, _) {
          switch (selectedIndex) {
            case 0:
              return const Center(child: Text("Add Item Page"));
            case 1:
              return const Center(child: Text("Search Page"));
            case 2:
              return const Center(child: Text("Book Page"));
            case 3:
              return const Center(child: Text("Profile Page"));
            case 4:
              return const Center(child: Text("Home Page"));
            default:
              return const Center(child: Text("Home Page"));
          }
        },
      ),

      // Floating button slightly lower and consistent styling
      floatingActionButton: Transform.translate(
        offset: const Offset(50, 40), // Move FAB down by 10 pixels
        child: ValueListenableBuilder(
          valueListenable: selectedPageNotifier,
          builder: (context, selectedIndex, _) {
            return FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: const Color.fromARGB(255, 240, 240, 240),
              elevation: 6,
              onPressed: () => selectedPageNotifier.value = 2,
              child: Icon(
                Icons.home,
                size: 30,
                color: _iconColor(selectedIndex == 2),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}