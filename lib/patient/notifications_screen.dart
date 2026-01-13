import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsScreen extends StatefulWidget {
  final String uid;
  const NotificationsScreen({super.key, required this.uid});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _marked = false;

  @override
  void initState() {
    super.initState();
    markAllSeenOnce();
  }

  Future<void> markAllSeenOnce() async {
    if (_marked) return;
    _marked = true;

    final query = await FirebaseFirestore.instance
        .collection('appointments')
        .where('patientId', isEqualTo: widget.uid)
        .where('seen', isEqualTo: false)
        .get();

    final batch = FirebaseFirestore.instance.batch();

    for (final doc in query.docs) {
      batch.update(doc.reference, {'seen': true});
    }

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: widget.uid)
            .where('status', whereIn: ['accepted', 'rejected'])
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              // ✅ FIX: Null-safe parsing
              final status = (data['status'] ?? '').toString();
              final doctorName = (data['doctorName'] ?? 'Doctor').toString();

              final Timestamp? ts = data['date'] as Timestamp?;
              final DateTime? date = ts?.toDate();

              final time = (data['time'] ?? '').toString();

              return Card(
                child: ListTile(
                  leading: Icon(
                    status == 'accepted' ? Icons.check_circle : Icons.cancel,
                    color: status == 'accepted' ? Colors.green : Colors.red,
                  ),
                  title: Text("Dr. $doctorName"),
                  subtitle: Text(
                    "Status: ${status.isEmpty ? 'PENDING' : status.toUpperCase()}\n"
                    "${date == null ? 'No Date' : '${date.day}/${date.month}/${date.year}'} • ${time.isEmpty ? 'No Time' : time}",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
