import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String? initailValue;
  final Icon? icon;
  final Function(String?) onsave;
  final String? Function(String?) onvlaidate;
  const MyTextField(
      {super.key,
      this.initailValue,
      this.icon,
      required this.onsave,
      required this.onvlaidate});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initailValue,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: icon,
        prefixIconColor: Colors.blue,
        labelText: "Name",
        hintText: "e.g., Saad Awan",
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      validator: onvlaidate,
      onSaved: onsave,
    );
  }
}
