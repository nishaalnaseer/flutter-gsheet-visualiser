import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class SetCredentials extends StatefulWidget {
  const SetCredentials({super.key});

  @override
  State<SetCredentials> createState() => _SetCredentialsState();
}

class _SetCredentialsState extends State<SetCredentials> {
  var urlController = TextEditingController();
  var sheetNameController = TextEditingController();
  String? message;
  final _storage = const FlutterSecureStorage();
  bool pickingFiles = false;

  void setSheetID() {
    var uriRaw = urlController.text;

    if(uriRaw.isEmpty) {
      return;
    }

    var uri = Uri.parse(uriRaw);

    String sheetID;
    try {
      sheetID = uri.path.split("/")[3];
    } on RangeError {
      message = "Invalid URL";
      setState(() {

      });
      return;
    }

    _storage.write(key: "sheetID", value: sheetID);
    message = "Sheet ID successfully set as $sheetID";
    setState(() {

    });
  }

  Future<void> loadFile() async {

    if(pickingFiles) {
      return;
    }
    pickingFiles = true;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        String filePath = result.files.single.path!;

        File file = File(filePath);
        var content = await file.readAsString();
        _storage.write(key: "credentials", value: content);
        message = "Successfully loaded credentials";
        setState(() {

        });
      }
    } catch (e) {
      message = "Error while picking the file: $e";
    }
    pickingFiles = false;
  }

  void setSheetName() async {
    String sheetName = sheetNameController.text;

    if(sheetName.isEmpty) {
      return;
    }

    await _storage.write(key: "sheetName", value: sheetName);
    message = "Sheet name successfully set as $sheetName";
    setState(() {

    });

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 500,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
            child: ElevatedButton(
              onPressed: (loadFile),
              child: const Text("Load File"),
            )
          ),

          Container(
            width: 500,
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
            child: TextField(
              controller: sheetNameController,
              decoration: const InputDecoration(
                hintText: "Sheet Name"
              )
            )
          ),
          Container(
            width: 500,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
            child: ElevatedButton(
              onPressed: (setSheetName),
              child: const Text("Set Sheet Name"),
            )
          ),

          Container(
            width: 500,
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: "Sheet URL"
              )
            )
          ),

          Container(
            width: 500,
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: (setSheetID),
              child: const Text("Set ID"),
            )
          ),
          message != null ? Container(
            width: 500,
            padding: const EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Text(
              message ?? "",
              style: const TextStyle(
                color: Colors.red
              ),
            )
          ) : const SizedBox(),
        ],
      ),
    );
  }
}


