import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reports/admin_reports_screen.dart';
import 'queries/admin_queries_screen.dart';

import '../auth/login_screen.dart';

// ✅ NEW IMPORTS (modules)
import 'doctors/doctors_module.dart';
import 'patients/patients_module.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // ✅ Sidebar selection (Doctors / Patients)
  int selectedMenu = 0;

  // Same Theme used in Patient Dashboard
  final Color primaryColor = const Color(0xFF009688);
  final Color textDark = const Color(0xFF263238);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,

        // ✅ Drawer icon automatically left (hamburger)
        title: Text(
          selectedMenu == 0 ? "Admin • Doctors" : "Admin • Patients",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        // ✅ Back button right corner
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () async {
              final canPop = await Navigator.maybePop(context);
              if (!canPop) {
                SystemNavigator.pop(); // exit app
              }
            },
          ),
        ],
      ),

      // ✅ Sidebar / Drawer
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: primaryColor),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 42,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Admin Panel",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Manage doctors and patients",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Doctors Menu
              ListTile(
                leading: Icon(Icons.medical_services, color: primaryColor),
                title: Text(
                  "Doctors",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                selected: selectedMenu == 0,
                onTap: () {
                  setState(() {
                    selectedMenu = 0;
                  });
                  Navigator.pop(context); // close drawer
                },
              ),

              // Patients Menu
              ListTile(
                leading: Icon(Icons.people, color: primaryColor),
                title: Text(
                  "Patients",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                selected: selectedMenu == 1,
                onTap: () {
                  setState(() {
                    selectedMenu = 1;
                  });
                  Navigator.pop(context); // close drawer
                },
              ),
              // Reports Menu
              ListTile(
                leading: Icon(Icons.bar_chart, color: primaryColor),
                title: Text(
                  "Reports",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                selected: selectedMenu == 2,
                onTap: () {
                  setState(() {
                    selectedMenu = 2;
                  });
                  Navigator.pop(context); // close drawer
                },
              ),
              ListTile(
                leading: Icon(Icons.support_agent, color: primaryColor),
                title: Text(
                  "Queries",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminQueriesScreen(),
                    ),
                  );
                },
              ),

              const Spacer(),

              // ✅ Logout (Drawer only) + Auth signOut
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.pop(context); // close drawer

                  bool confirm =
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Logout"),
                          content: const Text(
                            "Are you sure you want to logout?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                "Logout",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ) ??
                      false;

                  if (confirm) {
                    await FirebaseAuth.instance.signOut();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),

      // ✅ IMPORTANT FIX: show modules here
      body: selectedMenu == 0
          ? const DoctorsModule()
          : selectedMenu == 1
          ? const PatientsModule()
          : const AdminReportsScreen(),
    );
  }
}
