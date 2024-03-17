import 'dart:convert';
import 'dart:io';

import 'package:chat_mingle/model/chat-user.dart';
import 'package:chat_mingle/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static User get user => auth.currentUser!;
  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;
  static late Chatuser me;

  // for firease messaging token
  static Future getFirebaseMessagingToken() async {
    await fmessaging.requestPermission();
    await fmessaging.getToken().then((t) {
      me.pushToken = t;
    });
  }

  static Future sendPushnotification(Chatuser chatuser, String msg) async {
    try {
      final body = {
        "to": chatuser.pushToken,
        "notification": {"title": chatuser.name, "body": msg}
      };
      await post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader:
              "Key=AAAAwAQikFk:APA91bH2toxngoGn6AjOouOJ2elh3J_LhOaFDl3SI9ZB2pGAZ_LbOOHblT_kf9e1EO8QaLwDrOofttYKJKiJbX3HLvROCsR_seDrPKWXBZnZsig4a5kV2Sj5NNSahkIx3YKyIhWIs5RW"
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      debugPrint("$e");
    }
  }

  // for checking user already exist
  static Future userExist() async {
    return (await firestore.collection("users").doc(user.uid).get()).exists;
  }

  // for checking user already exist
  static Future addChatuser(String email) async {
    final data = await firestore
        .collection("users")
        .where("email", isEqualTo: email)
        .get();
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      // user exist
      firestore
          .collection("users")
          .doc(user.uid)
          .collection("my_user")
          .doc(data.docs.first.id)
          .set({});
      return true;
    }
    {
      // dosent exist
      return false;
    }
  }

  // for get current user info for profile screen
  static Future getSelfInfo() async {
    await firestore.collection("users").doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = Chatuser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        // for getting online or offline
        APIs.upateActivestatus(true);
      } else {
        await createuser().then((value) => getSelfInfo());
      }
    });
  }

  // for  creating new user
  static Future<void> createuser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatuser = Chatuser(
        email: user.email.toString(),
        id: user.uid,
        createdAt: time,
        image: user.photoURL,
        name: user.displayName.toString(),
        isOnline: false,
        lastActive: time,
        pushToken: "",
        about: "Hey I am using Chat Mingle");
    return await firestore
        .collection("users")
        .doc(user.uid)
        .set(chatuser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserid() {
    return firestore
        .collection("users")
        .doc(user.uid)
        .collection("my_user")
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(
      List<String> userIds) {
    if (userIds.isNotEmpty) {
      return firestore
          .collection("users")
          .where("id", whereIn: userIds)
          .snapshots();
    } else {
      debugPrint("User IDs list is empty");
      return const Stream.empty();
    }
  }

  // for adding a user to my user when first message is send
  static Future<void> sendFirstMessage(
      // this type is for sending image or text
      Chatuser chatuser,
      String msg,
      Type type) async {
    // this is for update
    await firestore
        .collection('users')
        .doc(chatuser.id)
        .collection('my_user')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatuser, msg, type));
  }

  // for updating name and about
  static Future<void> updateUserInfo() async {
    await firestore
        .collection("users")
        .doc(user.uid)
        .update({"name": me.name, 'about': me.about});
  }

// for updating profile image in storage and firestore
  static Future uploadProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child("profile-picture/${user.uid}.$ext");
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    me.image = await ref.getDownloadURL();
    firestore.collection("users").doc(user.uid).update({"image": me.image});
  }

// for getting user onlinr info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getuserinfo(
      Chatuser chatuser) {
    return firestore
        .collection("users")
        .where("id", isEqualTo: chatuser.id)
        .snapshots();
  }

  static Future<void> upateActivestatus(bool isOnline) async {
    firestore.collection("users").doc(user.uid).update({
      "isOnline": isOnline,
      "lastActive": DateTime.now().millisecondsSinceEpoch.toString(),
      "pushToken": me.pushToken
    });
  }

  /// *********************chat screen related apis**************///

  // useful for gretting conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for sending message
  static Future<void> sendMessage(
      Chatuser chatuser, String msg, Type type) async {
    final date = DateTime.now().millisecondsSinceEpoch.toString();
    Messages messages = Messages(
      forid: user.uid,
      msg: msg,
      read: "",
      sent: date,
      toid: chatuser.id,
      type: type,
    );
//here this getconversationid is for more accurate datesvaing in firestore
    final ref = await firestore.collection(
        "chats/${getConversationId(chatuser.id.toString())}/messages");
    await ref.doc(date).set(messages.toJson()).then((value) =>
        sendPushnotification(chatuser, type == Type.text ? msg : "Image"));
  }

// for getting all messages for specific conversation
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllmessages(
      Chatuser chatuser) {
    return firestore
        .collection(
            "chats/${getConversationId(chatuser.id.toString())}/messages")
        .orderBy("sent", descending: true)
        .snapshots();
  }

  // for update read staus
  static Future<void> updateMessagesReadStatus(Messages messages) async {
    firestore
        .collection(
            // we dont want to update our read status thats why i am using for id
            // because if i use toid then my own read status will be update
            "chats/${getConversationId(messages.forid.toString())}/messages")
        // here we have use message .sent because in sendmessage funtion
        // we are saving data in doc by time of sent thats why we are giving
        .doc(messages.sent)
        .update({"read": DateTime.now().millisecondsSinceEpoch.toString()});
  }

// fro getting lastmessage
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastmessages(
      Chatuser chatuser) {
    return firestore
        .collection(
            "chats/${getConversationId(chatuser.id.toString())}/messages")
        .orderBy("sent", descending: true)
        .limit(1)
        .snapshots();
  }

  // for image chat
  static Future<void> sendChatImage(Chatuser chatuser, File file) async {
    // getting image file extention
    final ext = file.path.split('.').last;
    // storage file reference with path
    final ref = storage.ref().child(
        'images/${getConversationId(chatuser.id.toString())}/ ${DateTime.now().millisecondsSinceEpoch}.$ext');
    // uploading image
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    // uploading image in firebase datababse FOR MESSAGING
    final imageurl = await ref.getDownloadURL();
    await sendMessage(chatuser, imageurl, Type.image);
  }

  static Future<void> deletemessage(Messages message) async {
    firestore
        // due to this toID i only delete my messages
        .collection(
            'chats/${getConversationId(message.toid.toString())}/messages')
        .doc(message.sent)
        .delete();
    if (message.type == Type.image) {
      storage.refFromURL(message.msg.toString()).delete();
    }
  }
}
