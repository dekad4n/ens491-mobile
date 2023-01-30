import 'package:flutter/material.dart';

BottomNavigationBar bottomNavBar(BuildContext context, var setState) {
  return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () {
              // Navigator.pushNamed(context, '/home');
              setState(0);
            },
            icon: const Icon(Icons.home),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () {
              // Navigator.pushNamed(context, '/search');
              setState(1);
            },
            icon: const Icon(Icons.search),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () {
              // Navigator.pushNamed(context, '/topics');
              setState(2);
            },
            icon: const Icon(Icons.tag),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/notification');
              setState(3);
            },
            icon: const Icon(Icons.notifications),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
              setState(4);
            },
            icon: const Icon(Icons.person),
          ),
          label: '',
        ),
      ]);
}
