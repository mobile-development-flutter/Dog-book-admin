import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopForm extends StatefulWidget {
  const ShopForm({
    super.key,
    required onPetAdded,
    required Null Function() onShopAdded,
  });

  @override
  State<ShopForm> createState() => _ShopFormState();
}

class _ShopFormState extends State<ShopForm> {
  String? selectedType;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController piceController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    piceController.dispose();
    super.dispose();
  }

  Future<void> _registerShop() async {
    if (selectedType != null &&
        nameController.text.isNotEmpty &&
        piceController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('shops').add({
        'type': selectedType,
        'name': nameController.text,
        'price': piceController.text,
        'createdAt': Timestamp.now(),
      });
      // Here you would typically send the data to your backend or database
      // For now, we just print it to the console
      print('Shop Type: $selectedType');
      print('Shop Name: ${nameController.text}');
      print('Shop Price: ${piceController.text}');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Your Items",
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2B2B2B),
                ),
              ),
              SizedBox(height: 20.h),
              _buildTypeDropdown(),
              SizedBox(height: 15.h),
              _buildTextField(controller: nameController, label: 'Item Name'),
              SizedBox(height: 15.h),
              _buildTextField(controller: piceController, label: 'Price'),
              SizedBox(height: 25.h),
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'Pet Type',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF38B6FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF38B6FF), width: 2),
        ),
      ),
      value: selectedType,
      items: ['Dog', 'Cat', 'Bird'].map((type) {
        return DropdownMenuItem(value: type, child: Text(type));
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedType = value;
        });
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF38B6FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF38B6FF), width: 2),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _registerShop,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF38B6FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
      ),
      child: Text(
        "Add Shop",
        style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white),
      ),
    );
  }
}
