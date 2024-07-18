import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final IconData icondata1;
  final String title1;
  final Widget Page1;
  final IconData icondata2;
  final String title2;
  final Widget Page2;
  final IconData icondata3;
  final String title3;
  final Widget Page3;

  const NavBar(
      {super.key,
      required this.Page1,
      required this.Page2,
      required this.title1,
      required this.icondata1,
      required this.icondata2,
      required this.title2,
      required this.icondata3,
      required this.title3,
      required this.Page3});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.only(top: 50),
        children: [
          ListTile(
            leading: Icon(
              icondata1,
              size: 35,
            ),
            title: Text(
              title1,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Page1,
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              icondata2,
              size: 35,
            ),
            title: Text(
              title2,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Page2,
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              icondata3,
              size: 35,
            ),
            title: Text(
              title3,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Page3,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
