import 'dart:async';

import 'package:admin/components/bottom_nav_two.dart';
import 'package:admin/components/custom_appbar2.dart';
import 'package:admin/components/custom_drawer.dart';
import 'package:admin/components/custom_petcard.dart';
import 'package:admin/components/custom_shop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  List<Map<String, dynamic>> shops = [];
  List<Map<String, dynamic>> pets = [];
  final PageController _pageController = PageController(viewportFraction: 0.8);
  bool _isLoading = true;
  String? _error;
  Map<String, String> userNames = {};
  String? _adminName;
  String? _adminEmail;

  // Add stream subscriptions
  StreamSubscription<QuerySnapshot>? _petsSubscription;
  StreamSubscription<QuerySnapshot>? _shopsSubscription;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    // Cancel subscriptions when widget is disposed
    _petsSubscription?.cancel();
    _shopsSubscription?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      await Firebase.initializeApp();
      await _fetchAdminData();
      _setupRealtimeListeners();
    } catch (e) {
      setState(() {
        _error = 'Initialization error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _setupRealtimeListeners() {
    // Set up real-time listener for pets
    _petsSubscription = FirebaseFirestore.instance
        .collection('pets')
        .snapshots()
        .listen(
          (petsSnapshot) async {
            // Get all unique owner IDs
            Set<String> ownerIds = petsSnapshot.docs
                .map((doc) => doc['ownerId'] as String?)
                .where((id) => id != null)
                .toSet()
                .cast<String>();

            // Fetch user names for new owners
            for (String ownerId in ownerIds) {
              if (!userNames.containsKey(ownerId)) {
                DocumentSnapshot userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(ownerId)
                    .get();
                if (userDoc.exists) {
                  userNames[ownerId] = userDoc['name'] ?? 'Unknown';
                }
              }
            }

            if (mounted) {
              setState(() {
                pets = petsSnapshot.docs.map((doc) {
                  return {
                    'id': doc.id,
                    'name': doc['name'] ?? 'Unnamed Pet',
                    'type': doc['type'] ?? 'Unknown',
                    'breed': doc['breed'] ?? 'Unknown',
                    'color': doc['color'] ?? 'Unknown',
                    'dob': doc['dob'] ?? 'Unknown',
                    'ownerId': doc['ownerId'] ?? 'Unknown',
                    'ownerName': userNames[doc['ownerId']] ?? 'Unknown Owner',
                    'createdAt': doc['createdAt'] ?? Timestamp.now(),
                  };
                }).toList();
                _isLoading = false;
              });
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _error = 'Pets listener error: ${error.toString()}';
                _isLoading = false;
              });
            }
          },
        );

    // Set up real-time listener for shops
    _shopsSubscription = FirebaseFirestore.instance
        .collection('shops')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (shopsSnapshot) {
            if (mounted) {
              setState(() {
                shops = shopsSnapshot.docs.map((doc) {
                  return {
                    'id': doc.id,
                    'type': doc['type'],
                    'name': doc['name'],
                    'price': doc['price'],
                    'createdAt': doc['createdAt'],
                  };
                }).toList();
              });
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _error = 'Shops listener error: ${error.toString()}';
              });
            }
          },
        );
  }

  Future<void> _fetchAdminData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
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
          // If not in admins collection, check users collection
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists && userDoc['isAdmin'] == true) {
            setState(() {
              _adminName = userDoc['name'];
              _adminEmail = userDoc['email'];
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching admin data: $e");
    }
  }

  void _showAddShopForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ShopForm(onPetAdded: () {}, onShopAdded: () {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF38B6FF)),
              SizedBox(height: 20.h),
              Text(
                "Loading admin data...",
                style: GoogleFonts.poppins(fontSize: 16.sp),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.w, color: Colors.red),
                SizedBox(height: 20.h),
                Text(
                  "Error Loading Data",
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 16.sp),
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                    });
                    _initializeApp();
                  },
                  child: Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar2(
        title: _adminName != null
            ? "Welcome, ${_adminName!.split(' ').first}"
            : "Admin Dashboard",
        showBackButton: false,
      ),
      drawer: CustomDrawer(adminName: _adminName, adminEmail: _adminEmail),
      backgroundColor: const Color(0xFFF7F7F9),
      body: Column(
        children: [
          SizedBox(height: 20.h),
          Center(
            child: Text(
              "Pet Management",
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2B2B2B),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            flex: 4,
            child: pets.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pets, size: 48.w, color: Colors.grey[400]),
                      SizedBox(height: 16.h),
                      Text(
                        "No pets found",
                        style: GoogleFonts.poppins(fontSize: 16.sp),
                      ),
                    ],
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        return AdminPetCard(pet: pets[index]);
                      },
                    ),
                  ),
          ),
          if (pets.isNotEmpty)
            Expanded(
              flex: 1,
              child: SmoothPageIndicator(
                controller: _pageController,
                count: pets.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Color(0xFF38B6FF),
                  dotHeight: 10,
                  dotWidth: 10,
                ),
              ),
            ),
          SizedBox(height: 20.h),
        ],
      ),
      bottomNavigationBar: BottomNavTwo(
        onPlusPressed: () => _showAddShopForm(context),
      ),
    );
  }
}
