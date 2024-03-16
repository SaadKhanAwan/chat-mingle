import 'package:chat_mingle/firebase-services/firebase-api.dart';
import 'package:chat_mingle/model/message.dart';
import 'package:flutter/material.dart';

class Dailogues {
  static void getSnacBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xffEE99C2),
    ));
  }

  static void getProgrssindecator(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.white,
          ));
        });
  }

  static aleratDailogue(
    message,
    Messages messages,
    BuildContext context,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Sure to Delete"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                APIs.deletemessage(messages);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
