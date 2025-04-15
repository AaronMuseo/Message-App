import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';
import 'models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UserList extends StatelessWidget{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
            onPressed: (){
              _scaffoldKey.currentState?.openDrawer();
            },
            icon: Icon(Icons.menu)),
        title: Text("Users"),


          
        actions: <Widget>[
          IconButton(
              onPressed: (){
                showAddUser(context);
              },
              icon: Icon(Icons.person_add))


        ],

      ),drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Text('Menu', style: TextStyle(color: Colors.white)),
            
          ),
          ListTile(
            title: Text('Profile'),
            onTap: (){
              Navigator.pop(context);
              showProfile(context);
            },
          )
        ],
      ),
    ),

        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('contacts')
              .snapshots(),
          builder:(context, snapshot){
            if(!snapshot.hasData) return Center(child: CircularProgressIndicator());

            final users = snapshot.data!.docs.where((doc) => doc.id !=currentUserId).toList();

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index){
                final user = AppUser.fromMap(users[index].data() as Map<String, dynamic>);
                return ListTile(
                  title: Text(user.name),
                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Chatscreen(receiver: user),
                        )
                    );
                  },
                );
              }
            );
          }

        )
    );


  }

  void showProfile(BuildContext context){
    showDialog(context: context,
        builder: (context) => AlertDialog(
          title: Text('Your UID'),
          content: Text(currentUserId),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))
          ],
        ),
    );
  }

  void showAddUser(BuildContext context) {
    String enteredUid = '';
    showDialog(context: context,
    builder: (context) => AlertDialog(
      
      title: Text('Add User by UID'),
      content: TextField(
        onChanged: (value) => enteredUid = value,
        decoration: InputDecoration(hintText: 'Enter UID'),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
        ),
        TextButton(onPressed: () async{
          Navigator.pop(context);
          if (enteredUid.isNotEmpty && enteredUid != currentUserId){
            final userDoc = await FirebaseFirestore.instance.collection('users').doc(enteredUid).get();
            if (userDoc.exists){
              final user = AppUser.fromMap(userDoc.data() as Map<String, dynamic>);

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUserId)
                  .collection('contacts')
                  .doc(user.uid)
                  .set({
                    'uid': user.uid,
                    'name': user.name,
                  })
                  .then((_){
                  print("User added to contacts");

              })
              .catchError((error){
                print("Failed to add contact: $error");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to add contact: $error")),
                );;
              });

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Chatscreen(receiver: user)),
              );
            }else{
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User not found. :(")));
            }
          }
        }, child: Text('Add'))

      ]
    )
    );


  }

}


