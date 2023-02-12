import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddPage extends StatefulWidget {
  final Map? todo;
  const AddPage({super.key, this.todo});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;
  @override
  void initState() {
    if (widget.todo != null) {
      isEdit = true;
      final title = widget.todo!['title'];
      final description = widget.todo!['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Todo" : "Add Todo"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(
                hintText: "Title",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: descriptionController,
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
            decoration: InputDecoration(
                hintText: "Description",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                isEdit ? updateData() : sumitData();
              },
              child: Text(isEdit ? 'UpdSate' : 'Submit'))
        ],
      ),
    );
  }

  void sumitData() async {
    //Get the data from form
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    //submit the data to the server
    var client = http.Client();
    var response = await client.post(
        Uri.parse("https://api.nstack.in/v1/todos"),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'});

    //show success or fail message based on status
    if (response.statusCode == 201) {
      titleController.text = '';
      descriptionController.text = '';
      showSuccesMesseage("ToDo Created");
    } else {
      showErrorMesseage("ToDo not Created");
    }
  }

  void showSuccesMesseage(String Message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(Message),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
    ));
  }

  void showErrorMesseage(String Message) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Message Can't add"),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red,
    ));
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print("You can not call updated withOut todo data");
    }
    final id = todo!["_id"];
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    var client = http.Client();
    var response = await client.put(
      Uri.parse("https://api.nstack.in/v1/todos/$id"),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      showSuccesMesseage("Updation Done");
    } else {
      showErrorMesseage("Updation Not Done");
    }
  }
}
