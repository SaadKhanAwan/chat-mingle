import 'package:chat_mingle/firebase-services/firebase-api.dart';
import 'package:chat_mingle/model/chat-user.dart';
import 'package:chat_mingle/screen/auth/profile_screen.dart';
import 'package:chat_mingle/widgets/chat-card.dart';
import 'package:chat_mingle/widgets/snapbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  List<Chatuser> _list = [];
  final List _isSearching = [];
  bool isSerach = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains("resume")) APIs.upateActivestatus(true);
        if (message.toString().contains("pause")) APIs.upateActivestatus(false);
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: isSerach
            ? TextField(
                decoration: const InputDecoration(
                  hintText: "Name,Email...",
                  border: InputBorder.none,
                ),
                autofocus: true,
                maxLines: null,
                onChanged: (val) {
                  _isSearching.clear();
                  for (var i in _list) {
                    if (i.name!.toLowerCase().contains(val.toLowerCase()) ||
                        i.email!.toLowerCase().contains(val.toLowerCase())) {
                      _isSearching.add(i);
                    }
                    // TODO
                    setState(() {});
                  }
                },
              )
            : const Text("Chat-Mingle"),
        leading: const Icon(Icons.home),
        actions: [
          IconButton(
            onPressed: () {
              // TODO:
              setState(() {
                isSerach = !isSerach;
              });
            },
            icon: Icon(
                isSerach ? CupertinoIcons.clear_circled_solid : Icons.search),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProfileScreen(
                            user: APIs.me,
                          )));
            },
            icon: const Icon(Icons.person_pin),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: APIs.getMyUserid(),

        //get id of only known users
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            //if data is loading
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());

            //if some or all data is loaded then show it
            case ConnectionState.active:
            case ConnectionState.done:
              return StreamBuilder(
                stream: APIs.getAllUser(
                    snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                //get only those user, who's ids are provided
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    //if data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                    // return const Center(
                    //     child: CircularProgressIndicator());

                    //if some or all data is loaded then show it
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      _list = data
                              ?.map((e) => Chatuser.fromJson(e.data()))
                              .toList() ??
                          [];

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                            itemCount:
                                isSerach ? _isSearching.length : _list.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ChatCard(
                                user: isSerach
                                    ? _isSearching[index]
                                    : _list[index],
                              );
                            });
                      } else {
                        return const Center(
                          child: Text('No Connections Found!',
                              style: TextStyle(fontSize: 20)),
                        );
                      }
                  }
                },
              );
          }
        },
      ),

      // floating action button
      floatingActionButton: FloatingActionButton(
        elevation: 7.5,
        backgroundColor: const Color(0xffEE99C2),
        onPressed: () {
          _addChatUserDialog();
        },
        child: const Icon(Icons.chat_bubble_outlined,
            size: 35, color: Colors.white),
      ),
    );
  }

  // for adding new chat user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: const Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text('  Add User')
                ],
              ),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.blue, fontSize: 16))),

                //add button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await APIs.addChatuser(email).then((value) {
                          if (!value) {
                            Dailogues.getSnacBar(
                                context, 'User does not Exists!');
                          }
                        });
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}
