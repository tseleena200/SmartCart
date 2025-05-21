import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: const Text("Registered Users"),
          backgroundColor: secondaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text("No users found.",
                        style: TextStyle(color: Colors.white70)));
              }

              final users = snapshot.data!.docs;

              return ListView.separated(
                separatorBuilder: (context, index) =>
                const Divider(color: Colors.white24),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final data = user.data() as Map<String, dynamic>;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: secondaryColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name: ${data['name'] ?? 'N/A'}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("Email: ${data['email'] ?? 'N/A'}",
                            style: const TextStyle(color: Colors.white70)),
                        Text("Phone: ${data['phoneNumber'] ?? 'N/A'}",
                            style: const TextStyle(color: Colors.white70)),
                        Text("DOB: ${data['dob'] ?? 'N/A'}",
                            style: const TextStyle(color: Colors.white70)),
                        Text("Preferred Branch: ${data['preferredBranch'] ?? 'N/A'}",
                            style: const TextStyle(color: Colors.white70)),
                        Text("Receive Promos: ${data['receivePromos'] == true ? 'Yes' : 'No'}",
                            style: const TextStyle(color: Colors.white70)),
                        Text("Account Status: ${data.containsKey('accountStatus') ? data['accountStatus'] : 'Not set'}",
                            style: const TextStyle(color: Colors.white70)),
                        Text("User Role: ${data['userRole'] ?? 'N/A'}",
                            style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 6),
                        Text(
                          "Last Active: ${data.containsKey('lastActiveAt') ? (data['lastActiveAt'] as Timestamp).toDate().toLocal().toString() : 'N/A'}",
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
