import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  final Color primaryColor = const Color(0xFF009688);
  final Color textDark = const Color(0xFF263238);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Reports & Analytics",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Live statistics from Firestore database.",
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 18),

              // ✅ Top Stats Cards (Doctors, Patients)
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      title: "Doctors",
                      icon: Icons.medical_services,
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('role', isEqualTo: 'doctor')
                          .snapshots(),
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      title: "Patients",
                      icon: Icons.people,
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('role', isEqualTo: 'patient')
                          .snapshots(),
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ✅ Wide card (appointments)
              _wideStatCard(
                title: "Total Appointments",
                icon: Icons.event_note,
                stream: FirebaseFirestore.instance
                    .collection('appointments')
                    .snapshots(),
                color: Colors.purple,
              ),

              const SizedBox(height: 20),

              Text(
                "Appointment Status",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: ListView(
                  children: [
                    _statusTile(
                      title: "Pending",
                      icon: Icons.hourglass_empty,
                      color: Colors.orange,
                      stream: FirebaseFirestore.instance
                          .collection('appointments')
                          .where('status', isEqualTo: 'pending')
                          .snapshots(),
                    ),
                    _statusTile(
                      title: "Accepted",
                      icon: Icons.check_circle_outline,
                      color: Colors.green,
                      stream: FirebaseFirestore.instance
                          .collection('appointments')
                          .where('status', isEqualTo: 'accepted')
                          .snapshots(),
                    ),
                    _statusTile(
                      title: "Rejected",
                      icon: Icons.cancel_outlined,
                      color: Colors.red,
                      stream: FirebaseFirestore.instance
                          .collection('appointments')
                          .where('status', isEqualTo: 'rejected')
                          .snapshots(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Small Card - FIXED OVERFLOW
  Widget _statCard({
    required String title,
    required IconData icon,
    required Stream<QuerySnapshot> stream,
    required Color color,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) count = snapshot.data!.docs.length;

        return Container(
          // height: 120, // ❌ REMOVED: Fixed height caused overflow
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),

              const SizedBox(height: 10),

              Text(
                "$count",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Wide Card
  Widget _wideStatCard({
    required String title,
    required IconData icon,
    required Stream<QuerySnapshot> stream,
    required Color color,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) count = snapshot.data!.docs.length;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Total appointments booked in app",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                "$count",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Status Tile
  Widget _statusTile({
    required String title,
    required IconData icon,
    required Color color,
    required Stream<QuerySnapshot> stream,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) count = snapshot.data!.docs.length;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "$count",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}