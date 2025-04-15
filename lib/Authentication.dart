import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInAnonymously(BuildContext context) async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;

      if(user != null){
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': "User_${user.uid.substring(0,4)}",//User ID length
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signed in as User_${user.uid.substring(0,5)}"))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   body:  Center(
     child: Card(
       margin: EdgeInsets.symmetric(horizontal: 20),
       child: Column(
         mainAxisSize: MainAxisSize.min,
         children: <Widget>[
            ListTile(
              title: Text("Sign in/ Log in"),
              subtitle: Text("Click button to sign in"),


            ),
           Row(
             mainAxisAlignment: MainAxisAlignment.end,
             children: [
               TextButton(
                   child: Text("Sign in"),
                   onPressed: () => signInAnonymously(context))
               
             ],
           )

         ],
       ),
     ),
   ),
    );
  }
}
