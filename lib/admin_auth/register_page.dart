import 'package:admin/components/custom_button.dart';
import 'package:admin/components/custom_textfield.dart';
import 'package:admin/components/custom_validation_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminRegisterPage extends StatefulWidget {
  const AdminRegisterPage({super.key});

  @override
  State<AdminRegisterPage> createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adminCodeController = TextEditingController();

  final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  String? _validatePassword(String password) {
    if (password.isEmpty) return "Password cannot be empty";
    if (!_passwordRegExp.hasMatch(password)) {
      return "Password must have at least 8 characters, include an uppercase letter, lowercase letter, number, and special character";
    }
    return null;
  }

  void registerAdmin() async {
    // First validate admin code
    if (_adminCodeController.text.trim() != '6060') {
      CustomValidationPopup.show(context, 'Invalid admin registration code');
      return;
    }

    String? passwordError = _validatePassword(_passwordController.text.trim());

    if (passwordError != null) {
      CustomValidationPopup.show(context, passwordError);
      return;
    }

    // show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF38B6FF)),
      ),
    );

    try {
      // Auto-generate an email for registration
      String email =
          "${_nameController.text.trim().replaceAll(' ', '_').toLowerCase()}@admin.com";

      // Create admin user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email,
            password: _passwordController.text.trim(),
          );

      if (userCredential.user != null) {
        await saveAdminData(
          userCredential.user!.uid,
          _nameController.text,
          email,
        );
      }

      if (context.mounted) Navigator.pop(context); // close loading dialog
      if (context.mounted) context.go('/home');
    } on FirebaseAuthException catch (e) {
      if (context.mounted) Navigator.pop(context);
      String errorMessage = _getReadableErrorMessage(e.code);
      CustomValidationPopup.show(context, errorMessage);
    }
  }

  String _getReadableErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'This admin account is already registered.';
      case 'invalid-email':
        return 'Generated email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return 'An error occurred: $errorCode';
    }
  }

  Future<void> saveAdminData(String uid, String name, String email) async {
    try {
      await FirebaseFirestore.instance.collection('admins').doc(uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'admin',
        'permissions': ['all'],
      });

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': true,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error saving admin data: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F9),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => context.go('/login'),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF707B81),
              ),
              child: Center(child: Icon(Icons.arrow_back_ios, size: 16.sp)),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Center(
              child: Text(
                "Admin Registration",
                style: GoogleFonts.raleway(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF38B6FF),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Center(
              child: Text(
                "Create a new admin account",
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  color: const Color(0xFF707B81),
                ),
              ),
            ),
            SizedBox(height: 30.h),
            Text(
              "Full Name",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            CustomTextfield(
              hint: "Enter admin's full name",
              controller: _nameController,
            ),
            SizedBox(height: 20.h),
            Text(
              "Password",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            CustomTextfield(
              hint: "Enter password",
              isPassword: true,
              controller: _passwordController,
            ),
            SizedBox(height: 5.h),
            Text(
              "Password must have at least 8 characters with uppercase, lowercase, number, and special character",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: const Color(0xFF707B81),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "Admin Registration Code",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            CustomTextfield(
              hint: "Enter admin registration code",
              isPassword: true,
              controller: _adminCodeController,
            ),
            SizedBox(height: 10.h),
            Center(
              child: CustomButton(
                name: "Register Admin",
                textColor: Colors.white,
                onTap: registerAdmin,
                color: const Color(0xFF38B6FF),
              ),
            ),
            SizedBox(height: 10.h),
            Center(
              child: Text(
                "Only authorized personnel can create admin accounts",
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: const Color(0xFF707B81),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
