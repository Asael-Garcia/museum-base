import 'package:flutter/material.dart';
import 'package:muse_base/screens/home.dart';
import 'package:muse_base/screens/profile.dart';
import 'package:muse_base/screens/tickets.dart';

class HomeNavBar extends StatefulWidget {
  const HomeNavBar({super.key});

  @override
  State<HomeNavBar> createState() => _HomeNavBarState();
}

class _HomeNavBarState extends State<HomeNavBar> {

   int index=0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final screens = [Home(), Tickets(), Profile()];
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index=value;
          });
        },
        elevation: 0,
        items : [
            BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
            backgroundColor:  colors.primary,
            ),
             BottomNavigationBarItem(
            icon: Icon(Icons.airplane_ticket_outlined),
            activeIcon: Icon(Icons.airplane_ticket),
            label: 'Boletos',
            backgroundColor:  colors.primary,
            ),
            BottomNavigationBarItem(
            icon: Icon(Icons.person_3_outlined),
            activeIcon: Icon(Icons.person_3),
            label: 'Perfil',
            backgroundColor:  colors.primary,
            ),
        ]
      ),
    );
  }
}