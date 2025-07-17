import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class Landing extends StatelessWidget {
  const Landing({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil for responsive design
    ScreenUtil.init(
      context,
      designSize: const Size(360, 690), // Default design size (can adjust)
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w), // Responsive padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets,
                size: 100.r, // Responsive radius-based size
                color: Colors.lightBlue,
              ),
              SizedBox(height: 32.h), // Responsive height
              Text(
                'Welcome to the Pet Plus Admin Panel',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.sp, // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Your Pet Health. Our Priority',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.sp, color: Colors.black54),
              ),
              SizedBox(height: 40.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.w,
                    vertical: 16.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                onPressed: () {
                  context.go('/login');
                },
                child: Text(
                  'Get Started',
                  style: TextStyle(fontSize: 15.sp, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
