import 'package:admin/components/custom_button.dart';
import 'package:admin/components/custom_textfield.dart';
import 'package:admin/components/custom_validation_popup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void loginAdmin() async {
    String name = _nameController.text.trim();
    String password = _passwordController.text.trim();

    if (name.isEmpty || password.isEmpty) {
      CustomValidationPopup.show(context, "Please enter all fields");
      return;
    }

    // Generate the same email format as registration
    String email = "${name.replaceAll(' ', '_').toLowerCase()}@admin.com";

    // show loading
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF38B6FF)),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (context.mounted) Navigator.pop(context); // close loading
      if (context.mounted) context.go('/home'); // navigate to dashboard
    } on FirebaseAuthException catch (e) {
      if (context.mounted) Navigator.pop(context);
      String error = _getReadableError(e.code);
      CustomValidationPopup.show(context, error);
    }
  }

  String _getReadableError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No admin found with this name';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid admin name format';
      default:
        return 'Login failed: $code';
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
            onTap: () => context.go('/landing'), // go back or to landing
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
            SizedBox(height: 20.h),
            Center(
              child: Text(
                "Admin Login",
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
                "Access your admin panel",
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  color: const Color(0xFF707B81),
                ),
              ),
            ),
            SizedBox(height: 40.h),
            Text(
              "Full Name",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            CustomTextfield(
              hint: "Enter your full name",
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
              hint: "Enter your password",
              isPassword: true,
              controller: _passwordController,
            ),
            SizedBox(height: 40.h),
            Center(
              child: Text(
                "Only authorized admins can log in",
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: const Color.fromARGB(255, 160, 0, 3),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Center(
              child: CustomButton(
                name: "Login",
                textColor: Colors.white,
                onTap: loginAdmin,
                color: const Color(0xFF38B6FF),
              ),
            ),
            SizedBox(height: 20.h),

            Center(
              child: GestureDetector(
                onTap: () {
                  context.go('/register');
                },
                child: Text(
                  'New Admin? Create Admin Account',
                  style: GoogleFonts.raleway(
                    fontSize: 15.sp,
                    color: const Color(0xFF1A1D1E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
