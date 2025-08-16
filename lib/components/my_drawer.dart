import 'package:flutter/material.dart';
import 'package:ig/components/my_list_tile.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onLogOut;

  const MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onLogOut,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Icon(Icons.person, color: Colors.white30, size: 50),
              ),
              MyListTile(
                icon: Icons.home,
                text: "H O M E",
                onTap: () => Navigator.pop(context),
              ),

              //profil
              MyListTile(
                icon: Icons.person,
                text: "P R O F I L E",
                onTap: onProfileTap,
              ),
            ],
          ),

          //logout
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: MyListTile(
              icon: Icons.person,
              text: "L O G   O U T",
              onTap: onLogOut,
            ),
          ),
        ],
      ),
    );
  }
}
