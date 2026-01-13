import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminQueriesScreen extends StatefulWidget {
  const AdminQueriesScreen({super.key});

  @override
  State<AdminQueriesScreen> createState() => _AdminQueriesScreenState();
}

class _AdminQueriesScreenState extends State<AdminQueriesScreen> {
  final Color primaryColor = const Color(0xFF009688);
  final Color textDark = const Color(0xFF263238);

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(selectedIndex == 0 ? "View Queries" : "Manage Queries"),
      ),

      // ✅ BODY switch based on bottom tab
      body: selectedIndex == 0 ? _viewQueriesTab() : _manageQueriesTab(),

      // ✅ Bottom Tabs
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.visibility_outlined),
            label: "View Queries",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined),
            label: "Manage Queries",
          ),
        ],
      ),
    );
  }

  // ✅ TAB 1: View Queries (same as before)
  Widget _viewQueriesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("support_requests")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No queries submitted yet"),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(14),
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final title = (data["title"] ?? "").toString();
            final message = (data["message"] ?? "").toString();
            final status = (data["status"] ?? "pending").toString();
            final uid = (data["uid"] ?? "").toString();

            final patientName = (data["patientName"] ?? "Unknown").toString();
            final patientEmail = (data["patientEmail"] ?? "").toString();

            Color statusColor =
                status == "resolved" ? Colors.green : Colors.orange;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      message.length > 80
                          ? "${message.substring(0, 80)}..."
                          : message,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Patient: $patientName",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (patientEmail.isNotEmpty)
                      Text(
                        "Email: $patientEmail",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      "UID: $uid",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => _QueryDetailsDialog(
                      docId: doc.id,
                      title: title,
                      message: message,
                      status: status,
                      uid: uid,
                      patientName: patientName,
                      patientEmail: patientEmail,
                      primaryColor: primaryColor,
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ✅ TAB 2: Manage Queries (Resolve/Delete directly from list)
  Widget _manageQueriesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("support_requests")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No queries submitted yet"),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(14),
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final title = (data["title"] ?? "").toString();
            final message = (data["message"] ?? "").toString();
            final status = (data["status"] ?? "pending").toString();

            final patientName = (data["patientName"] ?? "Unknown").toString();
            final patientEmail = (data["patientEmail"] ?? "").toString();

            Color statusColor =
                status == "resolved" ? Colors.green : Colors.orange;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textDark,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Patient: $patientName",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (patientEmail.isNotEmpty)
                    Text(
                      "Email: $patientEmail",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    message.length > 120
                        ? "${message.substring(0, 120)}..."
                        : message,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),

                  // ✅ status + actions row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // ✅ Resolve
                      TextButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection("support_requests")
                              .doc(doc.id)
                              .update({"status": "resolved"});

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Marked as Resolved ✅"),
                              backgroundColor: primaryColor,
                            ),
                          );
                        },
                        child: Text(
                          "Resolve",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // ✅ Delete
                      TextButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection("support_requests")
                              .doc(doc.id)
                              .delete();

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Query Deleted ✅"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                        child: const Text(
                          "Delete",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ✅ Dialog (same as last time, only added patientName/patientEmail fields)
class _QueryDetailsDialog extends StatelessWidget {
  final String docId;
  final String title;
  final String message;
  final String status;
  final String uid;

  final String patientName;
  final String patientEmail;

  final Color primaryColor;

  const _QueryDetailsDialog({
    required this.docId,
    required this.title,
    required this.message,
    required this.status,
    required this.uid,
    required this.patientName,
    required this.patientEmail,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Query Details"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Title:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(title),
            const SizedBox(height: 12),

            const Text("Message:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(message),
            const SizedBox(height: 12),

            const Text("Patient Name:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(patientName),
            const SizedBox(height: 10),

            const Text("Patient Email:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(patientEmail.isEmpty ? "Not Available" : patientEmail),
            const SizedBox(height: 12),

            const Text("Patient UID:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(uid),
            const SizedBox(height: 12),

            const Text("Status:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(status.toUpperCase()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),

        TextButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection("support_requests")
                .doc(docId)
                .update({"status": "resolved"});

            if (context.mounted) Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Marked as Resolved ✅"),
                backgroundColor: primaryColor,
              ),
            );
          },
          child: Text(
            "Resolve",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ),

        TextButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection("support_requests")
                .doc(docId)
                .delete();

            if (context.mounted) Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Query Deleted ✅"),
                backgroundColor: Colors.red,
              ),
            );
          },
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
