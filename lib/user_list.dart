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
            icon: Icon(Icons.menu)
        ),
        title: Text("Users"),
        actions: <Widget>[
          IconButton(
              onPressed: (){
                showAddUser(context);
              },
              icon: Icon(Icons.person_add)
          )
        ],
      ),
      drawer: Drawer(
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
          ),
          ListTile(
            title: Text('Friend Requests'),
            onTap: (){
              Navigator.pop(context);
              showFriend(context);
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

            final users = snapshot.data!.docs;

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
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
            )
          ],
        ),
    );
  }

  void showAddUser(BuildContext context) {
    String enteredUid = '';
    showDialog(
        context: context,
    builder: (context) => AlertDialog(
      
      title: Text('Send Friend Request'),
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
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(enteredUid)
                .get();
            if (userDoc.exists){
              final myName = FirebaseAuth.instance.currentUser!.displayName ?? 'Unknown';

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(enteredUid)
                  .collection('friend_requests')
                  .doc(currentUserId)
                  .set({
                    'uid': currentUserId,
                    'name': myName,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Friend request sent!"))
                  );


            }else{
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("User not found. :("))
              );
            }
          }
          }, child: Text('Add')
        )
      ]
    )
    );
  }

  void showFriend(BuildContext context) {
   showDialog(
       context: context,
       builder: (_) => AlertDialog(
         title: Text('Friend Requests'),
         content: StreamBuilder<QuerySnapshot>(
           stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('friend_requests')
              .snapshots(),
           builder: (context, snapshot) {
             if (!snapshot.hasData) return CircularProgressIndicator();

             final requests = snapshot.data!.docs;

             if (requests.isEmpty) return Text("No requests. ");

             return Column(
               mainAxisSize: MainAxisSize.min,
               children: requests.map((doc){
                 final data = doc.data() as Map<String, dynamic>;
                 return ListTile(
                   title: Text(data['name']),
                   trailing: TextButton(
                     child: Text("Accept"),
                       onPressed: () async{

                         await FirebaseFirestore.instance
                             .collection('users')
                             .doc(currentUserId)
                             .collection('contacts')
                             .doc(data['uid'])
                             .set({'uid': data['uid'], 'name': data['name']});

                         final myName = FirebaseAuth.instance.currentUser!.displayName ?? 'Unknown';

                         await FirebaseFirestore.instance
                             .collection('users')
                             .doc(data['uid'])
                             .collection('contacts')
                             .doc(currentUserId)
                             .set({'uid': currentUserId, 'name': myName});


                         await FirebaseFirestore.instance
                             .collection('users')
                             .doc(currentUserId)
                             .collection('friend_requests')
                             .doc(data['uid'])
                             .delete();
                         Navigator.pop(context);
                       },
                 ),
                 );
           }).toList(),
           );
           },
         ),
       ),
   );
  }
}


