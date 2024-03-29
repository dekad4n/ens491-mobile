import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickrypt/models/event_model.dart';
import 'package:tickrypt/services/event.dart';

import '../pages/event_page.dart';
import '../providers/metamask.dart';
import '../providers/user_provider.dart';

BottomNavigationBar bottomNavBar(
    BuildContext context, var setState, var pageIdx) {
  var userProvider = Provider.of<UserProvider>(context);
  var metamaskProvider = Provider.of<MetamaskProvider>(context);
  return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () {
              // Navigator.pushNamed(context, '/home');
              setState(0);
            },
            icon: Image.asset(
              'lib/assets/navbar/home.png',
              color: pageIdx != 0 ? Colors.grey : Color(0xFF5200FF),
              width: 22,
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () {
              // Navigator.pushNamed(context, '/search');
              setState(1);
            },
            icon: Image.asset(
              'lib/assets/navbar/search.png',
              width: 22,
              color: pageIdx != 1 ? Colors.grey : Color(0xFF5200FF),
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () {
              // Navigator.pushNamed(context, '/topics');
              setState(2);
            },
            icon: Image.asset(
              'lib/assets/navbar/calendar.png',
              width: 22,
              color: pageIdx != 2 ? Colors.grey : Color(0xFF5200FF),
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () async {
              // Navigator.pushNamed(context, '/notification');
              // setState(3);
              Event event = await EventService().getRandomEvent();

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EventPage(
                            event: event,
                            userProvider: userProvider,
                            metamaskProvider: metamaskProvider,
                          )));
            },
            icon: Image.asset(
              'lib/assets/navbar/random.png',
              width: 22,
              color: pageIdx != 3 ? Colors.grey : Color(0xFF5200FF),
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () {
              // Navigator.pushNamed(context, '/profile');
              setState(4);
            },
            icon: Image.asset(
              'lib/assets/navbar/profile.png',
              width: 22,
              color: pageIdx != 4 ? Colors.grey : Color(0xFF5200FF),
            ),
          ),
          label: '',
        ),
      ]);
}
