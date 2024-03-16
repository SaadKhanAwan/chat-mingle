import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_mingle/firebase-services/firebase-api.dart';
import 'package:chat_mingle/model/chat-user.dart';
import 'package:chat_mingle/widgets/snapbar.dart';
import 'package:chat_mingle/widgets/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Chatuser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _forkey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text("Chat-Mingle"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
            child: Form(
              key: _forkey,
              child: Column(
                children: [
                  SizedBox(
                    height: mq.height * 0.03,
                  ),
                  Stack(children: [
                    _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(mq.height * .4),
                            child: Image.file(
                              File(_image!),
                              height: mq.height * 0.23,
                              width: mq.width * 0.45,
                              fit: BoxFit.fill,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(mq.height * .4),
                            child: CachedNetworkImage(
                              height: mq.height * 0.23,
                              width: mq.width * 0.45,
                              fit: BoxFit.fill,
                              imageUrl: widget.user.image as String,
                              errorWidget: (context, url, error) =>
                                  const Icon(CupertinoIcons.person),
                            ),
                          ),
                    Positioned(
                      bottom: mq.height * .025,
                      right: mq.width * .01,
                      child: GestureDetector(
                        onTap: () {
                          _showbuttonsheet(mq);
                        },
                        child: const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(
                              Icons.add,
                              size: 40,
                              color: Colors.white,
                            )),
                      ),
                    )
                  ]),
                  SizedBox(
                    height: mq.height * 0.03,
                  ),
                  Text(
                    widget.user.email.toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 25),
                  ),
                  SizedBox(
                    height: mq.height * 0.03,
                  ),
                  MyTextField(
                    initailValue: widget.user.name,
                    icon: const Icon(Icons.person),
                    onvlaidate: (val) => val != null && val.isNotEmpty
                        ? null
                        : 'please fill the field',
                    onsave: (val) => APIs.me.name = val ?? "",
                  ),
                  SizedBox(
                    height: mq.height * 0.03,
                  ),
                  MyTextField(
                    initailValue: widget.user.about,
                    icon: const Icon(Icons.abc_outlined),
                    onvlaidate: (val) => val != null && val.isNotEmpty
                        ? null
                        : 'please fill the field',
                    onsave: (val) => APIs.me.about = val ?? "",
                  ),
                  SizedBox(
                    height: mq.height * 0.05,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(mq.width * 0.65, mq.height * .074)),
                    onPressed: () {
                      if (_forkey.currentState!.validate()) {
                        _forkey.currentState!.save();
                        APIs.updateUserInfo().then((value) =>
                            Dailogues.getSnacBar(
                                context, "Update Succussfully"));
                      }
                    },
                    label: const Text(
                      "Update",
                      style: TextStyle(color: Colors.white),
                    ),
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),

        // floating action button
        floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.logout, size: 35, color: Colors.white),
            elevation: 7.5,
            backgroundColor: Colors.red,
            onPressed: () async {
              APIs.upateActivestatus(false);
              Dailogues.getProgrssindecator(context);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.pop(context);
                  APIs.auth = FirebaseAuth.instance;
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen())).then((value) {
                    return Dailogues.getSnacBar(context, "LogOut succussfully");
                  });
                });
              });
            },
            label: const Text(
              "Logout",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            )),
      ),
    );
  }

  void _showbuttonsheet(mq) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .02, bottom: mq.height * .05),
            children: [
              const Text(
                " Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // for picking image from camera
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 80);
                      if (image != null) {
                        // TODO
                        setState(() {
                          _image = image.path;
                        });
                        APIs.uploadProfilePicture(File(_image!));
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(mq.width * .3, mq.height * .15)),
                    child: Image.asset("images/camera.png"),
                  ),
                  // for picking image from gallery
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 80);
                      if (image != null) {
                        // TODO
                        setState(() {
                          _image = image.path;
                        });
                        APIs.uploadProfilePicture(File(_image!));
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(mq.width * .3, mq.height * .15)),
                    child: Image.asset("images/gallery.png"),
                  )
                ],
              )
            ],
          );
        });
  }
}
