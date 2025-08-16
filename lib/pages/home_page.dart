import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ig/components/my_drawer.dart';
import 'package:ig/components/text_field.dart';
import 'package:ig/components/wall_posts.dart';
import 'package:ig/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //USER
  final currentUser = FirebaseAuth.instance.currentUser!;

  final textControlle = TextEditingController();
  void signout() {
    FirebaseAuth.instance.signOut();
  }

  void postMesaj() {
    if (textControlle.text.isNotEmpty) {
      //veritabanına kaydet
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textControlle.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }
    //clear text
    setState(() {
      textControlle.clear();
    });
  }

  void goToProfilePage() {
    //pop driver
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text("Home Page"),
      ),
      drawer: MyDrawer(onProfileTap: goToProfilePage, onLogOut: signout),
      body: Center(
        child: Column(
          children: [
            // wall
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy("TimeStamp", descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        //get message
                        final post = snapshot.data!.docs[index];
                        return WallPosts(
                          message: post["Message"],
                          user: post["UserEmail"],
                          postId: post.id,
                          likes: post.data().containsKey('Likes')
                              ? List<String>.from(post['Likes'])
                              : [],
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: $snapshot.error"));
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),

            //post
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  Expanded(
                    child: MyTextField(
                      controller: textControlle,
                      hintText: "Bir şeyler yazın...",
                      obscureText: false,
                    ),
                  ),
                  //buton
                  IconButton(onPressed: postMesaj, icon: Icon(Icons.send)),
                ],
              ),
            ),

            //logged in
            Text(
              "logged in: " + currentUser.email!,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
