import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid ?? "";

  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  bool sending = false;

  // same theme
  final Color primaryColor = const Color(0xFF009688);
  final Color textDark = const Color(0xFF263238);

  Future<void> submitIssue() async {
    final title = titleController.text.trim();
    final msg = messageController.text.trim();

    if (title.isEmpty || msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter title and message")),
      );
      return;
    }

    setState(() => sending = true);

    try {
      // ✅ Fetch Patient Name + Email
      final userDoc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
      final userData = userDoc.data() ?? {};

      final name = (userData["name"] ?? "Unknown").toString();
      final email = (userData["email"] ?? FirebaseAuth.instance.currentUser?.email ?? "").toString();

      await FirebaseFirestore.instance.collection("support_requests").add({
        "uid": uid,
        "patientName": name,
        "patientEmail": email,
        "title": title,
        "message": msg,
        "status": "pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      titleController.clear();
      messageController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Request sent ✅ Our team will contact you soon"),
          backgroundColor: primaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => sending = false);
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text("Help & Support"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.support_agent, color: primaryColor),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Need help?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Check FAQs or contact support anytime.",
                          style: TextStyle(fontSize: 12),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ FAQs
            sectionTitle("FAQs"),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Column(
                children: const [
                  _FAQTile(
                    q: "How do I book an appointment?",
                    a: "Go to Doctors tab → select doctor → press Book → choose date/time.",
                  ),
                  Divider(height: 1),
                  _FAQTile(
                    q: "How to cancel appointment?",
                    a: "Currently cancellation is not available. You can request admin/doctor to cancel.",
                  ),
                  Divider(height: 1),
                  _FAQTile(
                    q: "My appointment is pending. What to do?",
                    a: "Wait for doctor approval. Once accepted/rejected you will get notification.",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Contact options
            sectionTitle("Contact Support"),
            Row(
              children: [
                Expanded(
                  child: _ContactCard(
                    icon: Icons.phone_in_talk_outlined,
                    title: "Call",
                    subtitle: "+91 99999 99999",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ContactCard(
                    icon: Icons.mail_outline,
                    title: "Email",
                    subtitle: "support@medicare.com",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ Report Issue Form
            sectionTitle("Report a Problem"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Title",
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Describe your issue",
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: sending ? null : submitIssue,
                      icon: sending
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                      label: Text(
                        sending ? "Sending..." : "Submit Request",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ✅ About section
            sectionTitle("About App"),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text("MediCare Appointment System"),
                subtitle: Text("Version 1.0 • College Project\nBuilt in Flutter + Firebase"),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// ✅ FAQ Tile widget
class _FAQTile extends StatelessWidget {
  final String q;
  final String a;

  const _FAQTile({required this.q, required this.a});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600)),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      children: [
        Text(a, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }
}

// ✅ Contact card widget
class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 26),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
