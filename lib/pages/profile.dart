import 'package:admin/components/bottom_nav_two.dart';
import 'package:admin/components/custom_appbar2.dart';
import 'package:admin/components/custom_button.dart';
import 'package:admin/components/custom_shop.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  List<Map<String, dynamic>> shops = [];
  String? _adminName;
  String? _adminEmail;
  bool _isLoading = true;

  Future<void> fetchShops() async {
    try {
      await Firebase.initializeApp();

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('shops')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        shops = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'type': doc['type'],
            'name': doc['name'],
            'price': doc['price'],
            'createdAt': doc['createdAt'],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  void showAddShopForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          ShopForm(onPetAdded: fetchShops, onShopAdded: () {}),
    );
  }

  Future<void> _fetchAdminData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Check admins collection first
        DocumentSnapshot adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.uid)
            .get();

        if (adminDoc.exists) {
          setState(() {
            _adminName = adminDoc['name'];
            _adminEmail = adminDoc['email'];
          });
        } else {
          // Fallback to users collection
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            setState(() {
              _adminName = userDoc['name'];
              _adminEmail = userDoc['email'];
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching admin data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar2(title: "Admin Profile", showBackButton: false),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40.w,
                      backgroundImage: AssetImage('assets/images/boy.png'),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildProfileItem(
                    icon: Icons.person,
                    label: "Name",
                    value: _adminName ?? "Not available",
                  ),
                  SizedBox(height: 20.h),
                  _buildProfileItem(
                    icon: Icons.email,
                    label: "Email",
                    value: _adminEmail ?? "Not available",
                  ),
                  SizedBox(height: 20.h),
                  _buildProfileItem(
                    icon: Icons.lock,
                    label: "Password",
                    value: "••••••••", // Display as asterisks
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: CustomButton(
                      name: "Logout",
                      textColor: Colors.white,
                      onTap: () {
                        context.go('/login');
                      },
                      color: const Color(0xFF38B6FF),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavTwo(
        onPlusPressed: () => showAddShopForm(context),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF38B6FF), size: 24.w),
          SizedBox(width: 20.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
