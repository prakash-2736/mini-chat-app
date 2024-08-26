// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/chat_bubble.dart';
import 'package:flutter_application_2/components/my_textfield.dart';
import 'package:flutter_application_2/services/auth/auth_service.dart';
import 'package:flutter_application_2/services/chat/chta_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  ChatPage({super.key, required this.receiverEmail, required this.receiverID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //text controller
  final TextEditingController _messageController = TextEditingController();

  // chat and auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  //for textfield focus
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    //add listener to focus node
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 200),
          () => scrollDown(),
        );
      }
    });

    //wait a bit for list

    Future.delayed(
      const Duration(milliseconds: 200),
      () => scrollDown(),
    );
  }

//scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  //send msg
  void sendMessage() async {
    //if there issomething inside the textfield
    if (_messageController.text.isNotEmpty) {
      //send the msg
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);
      // clear text controller
      _messageController.clear();
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.receiverEmail),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.grey,
          elevation: 0,
        ),
        body: Column(
          children: [
            //display all msgs
            Expanded(
              child: _buildMessageList(),
            ),
            //user input
            _buildUserInput(),
          ],
        ));
  }

  // build message List
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    print("456");
    return StreamBuilder(
      stream: _chatService.getMessage(senderID, widget.receiverID),
      builder: (context, snapshot) {
        //error
        if (snapshot.hasError) {
          return Center(child: Text("Error"));
        }

        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );

        // var docs = snapshot.data!.docs;
        // print(docs.length);
        // return ListView.builder(
        //     itemCount: docs.length,
        //     itemBuilder: (context, index) {
        //       Map<String, dynamic> data =
        //           docs[index].data() as Map<String, dynamic>;
        //       print(data);
        //       return Text(data["message"]);
        //     });
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //is current user
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

    //align msg to right if  sender is the current user ,otherwise left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(message: data["message"], isCurrentUser: isCurrentUser)
        ],
      ),
    );
  }

  //build message input
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: "Type a message",
              obscureText: false,
              focusNode: myFocusNode,
            ),
          ),

          //send btn
          Container(
            decoration:
                BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            margin: EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMessage,
              icon: Icon(Icons.arrow_upward),
            ),
          ),
        ],
      ),
    );
  }
}
