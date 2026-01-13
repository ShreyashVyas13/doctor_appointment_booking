import 'package:flutter/material.dart';
import '../add_doctor_screen.dart';
import 'view_doctors_screen.dart';
import 'manage_doctors_screen.dart';

class DoctorsModule extends StatefulWidget {
  const DoctorsModule({super.key});

  @override
  State<DoctorsModule> createState() => _DoctorsModuleState();
}

class _DoctorsModuleState extends State<DoctorsModule> {
  int selectedIndex = 0;

  final Color primaryColor = const Color(0xFF009688);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: selectedIndex == 0
            ? const AddDoctorScreen()
            : selectedIndex == 1
                ? const ViewDoctorsScreen()
                : const ManageDoctorsScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: primaryColor,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1),
            label: "Add Doctor",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "View Doctors",
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
