import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_mingle/firebase-services/firebase-api.dart';
import 'package:chat_mingle/helper/time-formate.dart';
import 'package:chat_mingle/model/message.dart';
import 'package:chat_mingle/widgets/snapbar.dart';
import 'package:flutter/material.dart';

class MessgaeCard extends StatefulWidget {
  final Messages messages;
  const MessgaeCard({super.key, required this.messages});

  @override
  State<MessgaeCard> createState() => _MessgaeCardState();
}

class _MessgaeCardState extends State<MessgaeCard> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return APIs.user.uid == widget.messages.forid
        ? _greenMessage(mq)
        : _blueMessage(mq);
  }

// sender message or blue message
  Widget _blueMessage(mq) {
    // here we have call it because when sender will send mesage its send that he has open our message
    if (widget.messages.read!.isEmpty) {
      APIs.updateMessagesReadStatus(widget.messages);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 241, 245, 255),
                border: Border.all(color: Colors.blue),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                )),
            padding: EdgeInsets.all(widget.messages.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            child: widget.messages.type == Type.text
                ? Text(
                    widget.messages.msg.toString(),
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .01),
                    child: CachedNetworkImage(
                      fit: BoxFit.contain,
                      imageUrl: widget.messages.msg.toString(),
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
        // this is for sender send time
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUtlisP.getformattedTime(
              context: context,
              time: widget.messages.sent.toString(),
            ),
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // our message or green message
  Widget _greenMessage(mq) {
    return GestureDetector(
      onLongPress: () {
        Dailogues.aleratDailogue(
          "Click ok if you want to delete text",
          widget.messages,
          context,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // for adding some space
          Row(
            children: [
              SizedBox(
                width: mq.width * .04,
              ),
              if (widget.messages.read!.isNotEmpty)
                const Icon(
                  Icons.done_all_rounded,
                  color: Colors.blue,
                ),
              // for adding some space
              SizedBox(
                width: mq.width * .04,
              ),
              // for read time when message is read
              Text(
                MyDateUtlisP.getformattedTime(
                  context: context,
                  time: widget.messages.sent.toString(),
                ),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 218, 255, 176),
                  border: Border.all(color: Colors.lightGreen),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  )),
              padding: EdgeInsets.all(mq.width * .04),
              margin: EdgeInsets.symmetric(
                  horizontal: mq.width * .04, vertical: mq.height * .01),
              child: widget.messages.type == Type.text
                  ? Text(
                      widget.messages.msg.toString(),
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black87),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .01),
                      child: CachedNetworkImage(
                        fit: BoxFit.contain,
                        imageUrl: widget.messages.msg.toString(),
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          size: 70,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
