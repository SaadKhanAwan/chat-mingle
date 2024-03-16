import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_mingle/firebase-services/firebase-api.dart';
import 'package:chat_mingle/helper/time-formate.dart';
import 'package:chat_mingle/model/chat-user.dart';
import 'package:chat_mingle/model/message.dart';
import 'package:chat_mingle/screen/chat-screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatCard extends StatefulWidget {
  final Chatuser user;
  const ChatCard({super.key, required this.user});

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  List _list = [];
  Messages? messages;
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Card(
      elevation: 1,
      color: const Color.fromARGB(255, 250, 130, 188),
      margin: EdgeInsets.symmetric(horizontal: mq.width * .03, vertical: 7),
      shadowColor: Colors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
            stream: APIs.getLastmessages(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              _list =
                  data?.map((e) => Messages.fromJson(e.data())).toList() ?? [];
              if (_list.isNotEmpty) messages = _list[0];
              return ListTile(
                  textColor: Colors.white,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                      height: mq.height * 0.16,
                      width: mq.width * 0.16,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image as String,
                      errorWidget: (context, url, error) =>
                          const Icon(CupertinoIcons.person),
                    ),
                  ),
                  title: Text(messages != null
                      ? widget.user.name.toString()
                      : widget.user.about.toString()),
                  subtitle: Text(messages != null
                      ? messages!.type == Type.image
                          ? "Photo"
                          : messages!.msg.toString()
                      : widget.user.about.toString()),
                  trailing: messages == null
                      ? null
                      // if message is sent once and is not open show green dot
                      : messages!.read!.isEmpty &&
                              messages!.forid != APIs.user.uid
                          ? Container(
                              height: 10,
                              width: 10,
                              decoration: const BoxDecoration(
                                  color: Colors.green, shape: BoxShape.circle),
                            )
                          // if message is open once  show its sent time
                          : Text(
                              MyDateUtlisP.getlastmessagetime(
                                  context: context,
                                  time: messages!.sent.toString()),
                              style: const TextStyle(color: Colors.black54),
                            ));
            },
          )),
    );
  }
}
