import 'package:flutter/material.dart';
import 'package:todoapp/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // key: _formKey,
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _bodyController = TextEditingController();

  bool _isLoading = true;
  final dbHelper = DatabaseHelper();

  List<Contact> _posts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchContacts();
  }

  _fetchContacts() async {
    List<Contact> allContacts = await dbHelper.getContacts();
    setState(() {
      _posts = allContacts;
      _isLoading = false;
    });

    setState(() {
      _isLoading = true;
    });
  
  }

  void clear() {
    _titleController.clear();
    _bodyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Book'),
        actions: [
          IconButton(
              onPressed: () {
                _fetchContacts();
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (ctx, ind) {
                return ListTile(
                  title: Text(_posts[ind].name),
                  subtitle: Text(_posts[ind].phone),
                  leading: const Icon(Icons.work),
                  trailing: Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: () {
                           AddorUpdatePost(context, true, _posts[ind]);
                        }, icon: const Icon(Icons.edit)),
                        IconButton(
                            onPressed: () async {
                              showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      title: const Text("Confirm Delete"),
                                      content: Text(
                                          "Do you want to delete ${_posts[ind].name}?"),
                                      actions: [
                                        TextButton(
                                          child: const Text("Cancel"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        TextButton(
                                          child: const Text("Delete"),
                                          onPressed: () {
                                            setState(() {
                                              _posts.removeAt(ind);
                                            });
                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                    );
                                  });
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ))
                      ],
                    ),
                  ),
                  onTap: () {
                  
                  },
                );
              }),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            // Create show dialog with form
            AddorUpdatePost(context, false, null);
          }),
    );
  }

  Future<dynamic> AddorUpdatePost(
      BuildContext context, bool isUpdate, Contact? post) {
        clear();
    if (isUpdate) {
      _titleController.text = post!.name;
      _bodyController.text = post.phone;
    }
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: isUpdate ? const Text("Update Contact") : const Text("Create Contact"),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Name"),
                    validator: (value) =>
                        value!.isEmpty ? "Name is required" : null,
                  ),
                  TextFormField(
                    controller: _bodyController,
                    decoration: const InputDecoration(
                      labelText: "Phone",
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Phone is required" : null,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                       
                        if(isUpdate){
                          
                          
                        }else{
                           // create new Contact
                             Contact c = Contact(id: 1, name: _titleController.text, phone: _bodyController.text);
                            await dbHelper.saveContact(c);
                            _fetchContacts();
                        }
                          clear();
                          Navigator.pop(context);
                        }
                      },
                      child: isUpdate ? const Text("Update") : const Text("Create"))
                ],
              ),
            ),
          );
        });
  }
}
