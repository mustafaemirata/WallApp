import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ig/components/comment.dart';
import 'package:ig/components/comment_buton.dart';
import 'package:ig/components/delete_button.dart';
import 'package:ig/components/like_button.dart';
import 'package:ig/helper/helper_methods.dart';

class WallPosts extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;
  const WallPosts({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
  });

  @override
  State<WallPosts> createState() => _WallPostsState();
}

class _WallPostsState extends State<WallPosts> {
  // USER
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  //yorum controller
  final yorumController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  //toggle button
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    //Acces doc firestore
    DocumentReference postRef = FirebaseFirestore.instance
        .collection('User Posts')
        .doc(widget.postId);

    if (isLiked) {
      //field'a ekle.
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email]),
      });
    } else {
      //field'dan sil
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email]),
      });
    }
  }

  //yorum ekle
  void yorumEkle(String yorumText) {
    //comment collections on firestore
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
          "CommentText": yorumText,
          "CommentedBy": currentUser.email,
          "CommentTime": Timestamp.now(),
        });
  }
  //dialog içinde yorumları göster

  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Yorum Ekle"),
        content: TextField(
          controller: yorumController,
          decoration: InputDecoration(hintText: "Yorum yazın..."),
        ),
        actions: [
          //cancel
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              yorumController.clear();
            },
            child: Text("İptal"),
          ),
          //gönder
          TextButton(
            onPressed: () {
              yorumEkle(yorumController.text);
              yorumController.clear();

              Navigator.pop(context);
            },
            child: Text("Gönder"),
          ),
        ],
      ),
    );
  }

  void deletePost() {
    //show dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Gönderi Silme"),
        content: const Text("Göndereiyi silmek istediğinizden emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () async {
              //   delete firestore
              final commentDocs = await FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .get();

              for (var doc in commentDocs.docs) {
                await FirebaseFirestore.instance
                    .collection("User Posts")
                    .doc(widget.postId)
                    .collection("Comments")
                    .doc(doc.id)
                    .delete();
              }

              //delete post
              FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .delete()
                  .then((value) => print("post silindi."))
                  .catchError((error) => print("silme başarısız oldu:$error"));
              Navigator.pop(context);
            },
            child: const Text("Sil"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.only(top: 25, right: 25, left: 25),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //group of text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.message),
                  SizedBox(height: 11),

                  Text(
                    widget.user,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 132, 131, 131),
                    ),
                  ),
                ],
              ),

              //delete
              if (widget.user == currentUser.email)
                DeleteButton(onTap: deletePost),
            ],
          ),

          //butonlar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //beğen
              Column(
                children: [
                  //like buton
                  LikeButton(isLiked: isLiked, onTap: toggleLike),
                  //beüeni sayısı gettir
                  Text(
                    widget.likes.length.toString(),
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 25),
              //yorum
              Column(
                children: [
                  //yorum buton
                  CommentButon(onTap: showCommentDialog),
                  SizedBox(height: 6),
                  //yorum sayısı gettir
                  Text(
                    "0",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          //postun altına yorum
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .collection("Comments")
                .orderBy("CommentTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              //loading circle
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView(
                shrinkWrap: true, // nested list
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  final commentVeri = doc.data() as Map<String, dynamic>;

                  return Comment(
                    text: commentVeri["CommentText"],
                    user: commentVeri["CommentedBy"],
                    time: formatData(commentVeri["CommentTime"]),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
