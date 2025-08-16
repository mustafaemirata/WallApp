import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ig/components/botton.dart';
import 'package:ig/components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final email = TextEditingController();
  final sifre = TextEditingController();
  final sifrecontrol = TextEditingController();
  //kayıt işlem
  void kayit() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    if (sifre.text != sifrecontrol.text) {
      Navigator.pop(context);
      //error ver
      displayMessage("Şifreler eşleşmiyor.");
      return;
    }
    //eğer eşleşiyorsa yeni kullanıcı oluşturmayı dene
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.text,
            password: sifre.text,
          );
      //firestore doc
      FirebaseFirestore.instance.collection("Users").doc(userCredential.user!.email!).set({
        'username':email.text.split('@')[0],
        'bio':'Empty bio...'

      });

      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthMultiFactorException catch (e) {
      //circle loading
      Navigator.pop(context);

      displayMessage(e.code);
    }
  }

  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(title: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                //logom
                Icon(Icons.lock, size: 50),
                SizedBox(height: 12),
                const Text("Hesap oluşturalım!"),
                SizedBox(height: 20),
                //email
                MyTextField(
                  controller: email,
                  hintText: "email",
                  obscureText: false,
                ),
                SizedBox(height: 20),
                //şifre
                MyTextField(
                  controller: sifre,
                  hintText: "şifre",
                  obscureText: true,
                ),

                SizedBox(height: 20),
                //doğrulama
                MyTextField(
                  controller: sifrecontrol,
                  hintText: "şifreyi doğrulayın",
                  obscureText: true,
                ),
                SizedBox(height: 30),
                MyButton(text: "Kayıt Ol", onTap: kayit),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Üye  misiniz?",
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Giriş yapın",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
