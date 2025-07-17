import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDrawer extends StatelessWidget {
  final String? adminName;
  final String? adminEmail;

  const CustomDrawer({super.key, this.adminName, this.adminEmail});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              adminName ?? 'Administrator',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              adminEmail ?? 'admin@example.com',
              style: GoogleFonts.poppins(fontSize: 14.sp),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF38B6FF), size: 40),
            ),
            decoration: const BoxDecoration(color: Color(0xFF38B6FF)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(
              'Dashboard',
              style: GoogleFonts.poppins(fontSize: 16.sp),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.pets),
            title: Text(
              'Manage Pets',
              style: GoogleFonts.poppins(fontSize: 16.sp),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: Text(
              'Manage Shops',
              style: GoogleFonts.poppins(fontSize: 16.sp),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(
              'Settings',
              style: GoogleFonts.poppins(fontSize: 16.sp),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text('Logout', style: GoogleFonts.poppins(fontSize: 16.sp)),
            onTap: () {
              // Implement logout functionality
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
