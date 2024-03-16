import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_mingle/firebase-services/firebase-api.dart';
import 'package:chat_mingle/helper/time-formate.dart';
import 'package:chat_mingle/model/chat-user.dart';
import 'package:chat_mingle/model/message.dart';
import 'package:chat_mingle/widgets/message-card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final Chatuser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Messages> _list = [];
  final _texteditingcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: _appBar(mq),
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder(
                  stream: APIs.getAllmessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      // if loading data
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        );
                      case ConnectionState.done:
                      case ConnectionState.active:
                        final data = snapshot.data!.docs;
                        _list = data
                            .map((e) => Messages.fromJson(e.data()))
                            .toList();
                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessgaeCard(messages: _list[index]);
                              });
                        } else {
                          return const Center(
                            child: Text(
                              "Say Hi! 👋",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }
                    }
                  })),
          chatinputfield(mq),
        ],
      ),
    );
  }

  _appBar(mq) {
    return StreamBuilder(
        stream: APIs.getuserinfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final mylist =
              // here this Chatser is model of chatuser
              data?.map((e) => Chatuser.fromJson(e.data())).toList() ?? [];

          return Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  )),
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .4),
                child: CachedNetworkImage(
                  height: mq.height * 0.07,
                  width: mq.width * 0.15,
                  fit: BoxFit.fill,
                  imageUrl: mylist.isNotEmpty
                      ? mylist[0].image as String
                      : widget.user.image as String,
                  errorWidget: (context, url, error) =>
                      const Icon(CupertinoIcons.person),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name!.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    mylist.isNotEmpty
                        ? mylist[0].isOnline!
                            ? "Online"
                            : MyDateUtlisP.getLastActive(
                                context: context,
                                lastActive: mylist[0].lastActive as String)
                        : MyDateUtlisP.getLastActive(
                            context: context,
                            lastActive: widget.user.lastActive as String),
                    style: const TextStyle(
                      color: Colors.black38,
                      fontSize: 15,
                    ),
                  )
                ],
              ),
            ],
          );
        });
  }

  Widget chatinputfield(mq) {
    // this is for show background
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: mq.height * .01,
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27)),
              child: Row(
                children: [
                  // this is for textfield
                  Expanded(
                      child: TextField(
                    onTap: () {},
                    controller: _texteditingcontroller,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: "Type something...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none),
                  )),
                  // this is gallery button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final List<XFile> image =
                            await picker.pickMultiImage(imageQuality: 80);

                        for (var i in image) {
                          APIs.sendChatImage(widget.user, File(i.path));
                        }
                      },
                      icon: const Icon(
                        Icons.image,
                        color: Colors.blue,
                      )),
                  // camera button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          APIs.sendChatImage(widget.user, File(image.path));
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blue,
                      )),
                ],
              ),
            ),
          ),
          // this is send button
          MaterialButton(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            minWidth: 0,
            color: Colors.green,
            onPressed: () {
              if (_texteditingcontroller.text.isNotEmpty) {
                if (_list.isEmpty) {
                  APIs.sendFirstMessage(widget.user,
                      _texteditingcontroller.text.toString(), Type.text);
                } else {
                  APIs.sendMessage(widget.user,
                      _texteditingcontroller.text.toString(), Type.text);
                }
                _texteditingcontroller.clear();
              }
            },
            child: const Icon(
              Icons.send,
              size: 28,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
