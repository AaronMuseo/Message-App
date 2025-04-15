import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/user_model.dart';

class Chatscreen extends StatefulWidget{
  final AppUser receiver;

  Chatscreen({required this.receiver});

  @override
  _ChatscreenState createState() => _ChatscreenState();

}

class _ChatscreenState extends State<Chatscreen>{
 final _controller = TextEditingController();
 final currentUser = FirebaseAuth.instance.currentUser!;

  void sendMessage() async{
    final text = _controller.text.trim();

    if (text.isEmpty) return;

  final chatId = getChatId(currentUser.uid, widget.receiver.uid);

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'text': text,
          'senderId': currentUser.uid,
          'receiverId': widget.receiver.uid,
          'createdAt': Timestamp.now(),
    });

    _controller.clear();
  }

  String getChatId (String uid1, String uid2){
    return uid1.hashCode <= uid2.hashCode ? '$uid1\_$uid2' : '$uid2\_$uid1';

  }

  @override
  Widget build(BuildContext context){
    final chatId = getChatId(currentUser.uid, widget.receiver.uid);

    return Scaffold(
      appBar: AppBar(title: Text(widget.receiver.name)),
      body: Column(
        children: [
          Expanded(child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats/$chatId/messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              
              builder: (context, snapshot){
                if(!snapshot.hasData) return CircularProgressIndicator();

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index){
                    final msg = messages[index];
                    final isMe = msg['senderId'] == currentUser.uid;
                    return ListTile(
                      title: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.deepPurple: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(msg['text']),
                        ),
                      ),
                    );
                  },
                );

              }
              )
          
          ),
          Divider(height: 1,),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(labelText: "Send a message..."),
                      ),
                  ),
                  IconButton(onPressed: sendMessage, icon: Icon(Icons.send))
                ],
              ),
          )
        ],
      ),

    );
  }



}