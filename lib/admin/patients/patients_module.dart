import 'package:flutter/material.dart';
import 'view_patients_screen.dart';
import 'manage_patients_screen.dart';

class PatientsModule extends StatefulWidget {
  const PatientsModule({super.key});

  @override
  State<PatientsModule> createState() => _PatientsModuleState();
}

class _PatientsModuleState extends State<PatientsModule> {
  int selectedIndex = 0;

  final Color primaryColor = const Color(0xFF009688);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: selectedIndex == 0
            ? const ViewPatientsScreen()
            : const ManagePatientsScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: primaryColor,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: "View Patients",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: "Manage",
          ),
        ],
      ),
    );
  }
}
