import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:to_do_api/add_page.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;
  List items = [];

  @override
  void initState() {
    fetchTodo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To Do"),
        centerTitle: true,
      ),
      body: Visibility(
        visible: isLoading,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: ListView.builder(
            itemBuilder: ((context, index) {
              final item = items[index] as Map;
              final id = item['_id'] as String;

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text("${index + 1}"),
                    ),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    trailing: PopupMenuButton(onSelected: (value) {
                      if (value == 'edit') {
                        navigateToEditPage(item);
                        //open edit page
                      } else if (value == 'delete') {
                        //delete and remove the item
                        deleteById(id);
                      }
                    }, itemBuilder: ((context) {
                      return [
                        const PopupMenuItem(
                          child: Text('Edit'),
                          value: 'edit',
                        ),
                        const PopupMenuItem(
                          child: Text('Delete'),
                          value: 'delete',
                        ),
                      ];
                    })),
                  ),
                ),
              );
            }),
            itemCount: items.length,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToAddPage();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> navigateToAddPage() async {
    await Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return const AddPage();
      },
    ));
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToEditPage(Map item) async {
    await Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return AddPage(todo: item);
      },
    ));
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  //get the data from server
  Future<void> fetchTodo() async {
    var client = http.Client();
    var response = await client
        .get(Uri.parse("https://api.nstack.in/v1/todos?page=1&limit=20"));
    if (response.statusCode == 200) {
      var jsonBody = jsonDecode(response.body) as Map;
      final result = jsonBody['items'] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future deleteById(String id) async {
    //Delete item from server
    var client = http.Client();
    var response =
        await client.delete(Uri.parse("https://api.nstack.in/v1/todos/$id"));
    if (response.statusCode == 200) {
// Remove item from List
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    }
  }
}
