import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPetCard extends StatelessWidget {
  final Map<String, dynamic> pet;

  const AdminPetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet Name
          Text(
            pet['name'],
            style: GoogleFonts.raleway(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF38B6FF),
            ),
          ),
          SizedBox(height: 12.h),

          // Owner Information
          Row(
            children: [
              Icon(Icons.person, size: 16.w, color: Colors.grey),
              SizedBox(width: 8.w),
              Text(
                'Owner : ${pet['ownerName']}',
                style: GoogleFonts.raleway(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Pet Details
          _buildDetailRow('Type', pet['type']),
          _buildDetailRow('Breed', pet['breed']),
          _buildDetailRow('Color', pet['color']),
          _buildDetailRow('Birth Date', pet['dob']),

          SizedBox(height: 10.h),
          Text(
            'Created: ${_formatDate(pet['createdAt'])}',
            style: GoogleFonts.raleway(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: GoogleFonts.raleway(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.raleway(
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    if (timestamp is Timestamp) {
      return '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}';
    }
    return timestamp.toString();
  }
}
