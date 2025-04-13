import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';

class AuthPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInAnonymously(BuildContext context) async {
    try {
      await _auth.signInAnonymously();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signed in anonymously")),
      );
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
