import 'package:admin/components/bottom_nav_two.dart';
import 'package:admin/components/custom_appbar2.dart';
import 'package:admin/components/custom_drawer.dart';
import 'package:admin/components/custom_shop.dart';
import 'package:admin/components/custom_shopcart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Shops extends StatefulWidget {
  const Shops({super.key});

  @override
  State<Shops> createState() => _ShopsState();
}

class _ShopsState extends State<Shops> {
  String? _adminName;
  String? _error;
  late Stream<QuerySnapshot> _shopsStream;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _shopsStream = FirebaseFirestore.instance
        .collection('shops')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _initializeApp() async {
    try {
      await _fetchAdminData();
    } catch (e) {
      setState(() {
        _error = 'Initialization error: ${e.toString()}';
      });
    }
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
          });
        } else {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists && userDoc['isAdmin'] == true) {
            setState(() {
              _adminName = userDoc['name'];
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching admin data: $e");
    }
  }

  void _editShop(String id, Map<String, dynamic> currentData) async {
    final nameController = TextEditingController(text: currentData['name']);
    final typeController = TextEditingController(text: currentData['type']);
    final priceController = TextEditingController(text: currentData['price']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Shop'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('shops')
                      .doc(id)
                      .update({
                        'name': nameController.text,
                        'type': typeController.text,
                        'price': priceController.text,
                      });
                  if (!mounted) return;
                  Navigator.of(context).pop();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update shop: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteShop(String id) async {
    try {
      await FirebaseFirestore.instance.collection('shops').doc(id).delete();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete shop: $e')));
    }
  }

  void showAddShopForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ShopForm(onShopAdded: () {}, onPetAdded: null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar2(
        title: _adminName != null
            ? "Admin, ${_adminName!.split(' ').first}"
            : "Admin",
        showBackButton: false,
      ),
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xFFF7F7F9),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Center(
              child: Text(
                "Shops",
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2B2B2B),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _shopsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_shopping_cart_rounded,
                        size: 80.w,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "No Items Yet",
                        style: GoogleFonts.poppins(fontSize: 16.sp),
                      ),
                      TextButton(
                        onPressed: () => showAddShopForm(context),
                        child: const Text("Add Your First Item"),
                      ),
                    ],
                  );
                }

                final shops = snapshot.data!.docs.map((doc) {
                  return {
                    'id': doc.id,
                    'type': doc['type'],
                    'name': doc['name'],
                    'price': doc['price'],
                    'createdAt': doc['createdAt'],
                  };
                }).toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    // Force refresh if needed
                  },
                  child: GridView.builder(
                    padding: EdgeInsets.all(16.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: shops.length,
                    itemBuilder: (context, index) {
                      return ShopCard(
                        shop: shops[index],
                        onEdit: () =>
                            _editShop(shops[index]['id'], shops[index]),
                        onDelete: () => _deleteShop(shops[index]['id']),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavTwo(
        onPlusPressed: () => showAddShopForm(context),
      ),
    );
  }
}
