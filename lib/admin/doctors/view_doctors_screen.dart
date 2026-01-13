import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewDoctorsScreen extends StatefulWidget {
  const ViewDoctorsScreen({super.key});

  @override
  State<ViewDoctorsScreen> createState() => _ViewDoctorsScreenState();
}

class _ViewDoctorsScreenState extends State<ViewDoctorsScreen> {
  final Color primaryColor = const Color(0xFF009688);

  final TextEditingController searchController = TextEditingController();

  String searchText = "";
  String selectedSpecialization = "All";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  bool matchSearch(Map<String, dynamic> data) {
    final name = (data['name'] ?? '').toString().toLowerCase();
    final email = (data['email'] ?? '').toString().toLowerCase();
    final q = searchText.toLowerCase().trim();

    if (q.isEmpty) return true;
    return name.contains(q) || email.contains(q);
  }

  bool matchSpec(Map<String, dynamic> data) {
    if (selectedSpecialization == "All") return true;
    final spec = (data['specialization'] ?? '').toString();
    return spec == selectedSpecialization;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: SafeArea(
        child: Column(
          children: [
            // ✅ Search + Filter Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    onChanged: (val) {
                      setState(() {
                        searchText = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search doctor by name / email",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchText.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                searchController.clear();
                                setState(() {
                                  searchText = "";
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // specialization dropdown
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('role', isEqualTo: 'doctor')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final specs = <String>{"All"};
                      if (snapshot.hasData) {
                        for (final doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final spec = (data['specialization'] ?? '').toString();
                          if (spec.trim().isNotEmpty) specs.add(spec);
                        }
                      }

                      final specList = specs.toList()..sort();

                      return DropdownButtonFormField<String>(
                        value: selectedSpecialization,
                        items: specList
                            .map(
                              (s) => DropdownMenuItem<String>(
                                value: s,
                                child: Text(s),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() {
                            selectedSpecialization = val;
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.filter_alt_outlined),
                          labelText: "Filter by specialization",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),

            // ✅ Doctor List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'doctor')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  // filter client side
                  final filtered = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return matchSearch(data) && matchSpec(data);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        "No doctors found",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primaryColor.withOpacity(0.12),
                            child: Icon(Icons.person, color: primaryColor),
                          ),
                          title: Text(
                            (data['name'] ?? 'Doctor').toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${data['email'] ?? ''}\n${data['specialization'] ?? ''}",
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
