import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ig/helper/helper_methods.dart';
import 'package:ig/components/text_box.dart';
import 'package:ig/components/wall_posts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  // Firestore update için edit dialog
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Color.fromARGB(255, 139, 139, 139)),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Yeni $field girin!",
            hintStyle: const TextStyle(color: Colors.white),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue),
            child: const Text("Kaydet", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (newValue.trim().isNotEmpty) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Güncelleme işlemi başarılı!"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // timestamp'i okunabilir formata çevir
  String formatTimestamp(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile Page",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: usersCollection.doc(currentUser.email).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              children: [
                const SizedBox(height: 45),
                const Icon(Icons.person, size: 45),
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 35),

                // My Details başlığı
                const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    "My Details",
                    style: TextStyle(color: Color.fromARGB(255, 57, 57, 57)),
                  ),
                ),

                MyTextBox(
                  text: userData['username'] ?? 'No username',
                  sectionName: 'username',
                  onPressed: () => editField('username'),
                ),

                MyTextBox(
                  text: userData['bio'] ?? 'Empty bio',
                  sectionName: 'bio',
                  onPressed: () => editField('bio'),
                ),

                const SizedBox(height: 35),

                // My Posts başlığı
                const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    "My Posts",
                    style: TextStyle(color: Color.fromARGB(255, 57, 57, 57)),
                  ),
                ),

                // Kullanıcının postları
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("User Posts")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Henüz gönderi yok"),
                      );
                    }

                    // Filter posts for current user
                    final allPosts = snapshot.data!.docs;
                    final userPosts = allPosts.where((doc) {
                      final postData = doc.data() as Map<String, dynamic>;
                      return postData['UserEmail'] == currentUser.email;
                    }).toList();

                    // Sort posts by timestamp (newest first)
                    userPosts.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aTime = aData['TimeStamp'] as Timestamp;
                      final bTime = bData['TimeStamp'] as Timestamp;
                      return bTime.compareTo(aTime);
                    });

                    if (userPosts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Henüz gönderi yok"),
                      );
                    }

                    final posts = userPosts;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final postData = post.data() as Map<String, dynamic>;

                        return WallPosts(
                          message: postData["Message"] ?? "",
                          user: postData["UserEmail"] ?? "",
                          postId: post.id,
                          likes: postData.containsKey('Likes')
                              ? List<String>.from(postData['Likes'])
                              : [],
                        );
                      },
                    );
                  },
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
