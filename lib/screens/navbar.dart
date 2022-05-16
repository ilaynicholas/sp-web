import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sp_web/screens/approve_screen.dart';
import 'package:sp_web/screens/login_screen.dart';

class Navbar extends StatefulWidget {
  const Navbar({ Key? key }) : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  FirebaseAuth auth = FirebaseAuth.instance;

  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Text("0"),
    Text("1"),
    ApproveScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00CDA6),
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF008999),
              shape: BoxShape.circle
            )
          ),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              child: const Text("View Dashboard", style: TextStyle(color: Colors.white)),
              onPressed: () {
                _onItemTapped(0);
              },
            ),
            TextButton(
              child: const Text("Search Database", style: TextStyle(color: Colors.white)),
              onPressed: () {
                _onItemTapped(1);
              },
            ),
            TextButton(
              child: const Text("Approve Establishments", style: TextStyle(color: Colors.white)),
              onPressed: () {
                _onItemTapped(2);
              },
            )
          ]
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: const Text("LOG OUT", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await auth.signOut();
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const LoginScreen())
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0)
                ),
                primary: const Color(0xFF008999),
                onPrimary: Colors.white,
              )
            ),
          )
        ]
      )
    );
  }
}