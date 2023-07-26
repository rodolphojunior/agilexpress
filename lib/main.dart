import 'dart:convert';

import 'package:localstorage/localstorage.dart';
import 'package:flutter/material.dart';

final LocalStorage storage = LocalStorage('my_app');

void main() async {
  final LocalStorage storage = LocalStorage('agilexpress');
  await storage.ready;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgileXpress',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BacklogPage(),
    );
  }
}

class BacklogItem {
  String title;
  String description;

  BacklogItem({required this.title, required this.description});

  // Transforma o objeto em JSON para facilitar o armazenamento
  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
      };

  factory BacklogItem.fromJson(Map<String, dynamic> json) {
    return BacklogItem(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}

BacklogItem titleDescription =
    BacklogItem(title: 'Your title', description: 'Your description');

class BacklogPage extends StatefulWidget {
  const BacklogPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BacklogPageState createState() => _BacklogPageState();
}

class _BacklogPageState extends State<BacklogPage> {
  List<BacklogItem> backlogItems = [];

  void loadBacklogItems() {
    List<dynamic> backlogJson = json.decode(storage.getItem('backlog') ?? '[]');
    backlogItems = backlogJson
        .map((i) => BacklogItem.fromJson(Map<String, dynamic>.from(i)))
        .toList();
  }

  void saveBacklogItems() {
    storage.setItem(
        'backlog', json.encode(backlogItems.map((i) => i.toJson()).toList()));
  }

  @override
  void initState() {
    super.initState();
    loadBacklogItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backlog do Produto'),
      ),
      body: ReorderableListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: backlogItems.map((item) => _buildListTile(item)).toList(),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final BacklogItem item = backlogItems.removeAt(oldIndex);
            backlogItems.insert(newIndex, item);
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showAddEditDialog(context), // show dialog on button press
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListTile(BacklogItem item) {
    return GestureDetector(
      key: Key(item.title), // move the key here
      onTap: () => _showAddEditDialog(context, item),
      child: Card(
        child: ListTile(
          title: Text(item.title),
          subtitle: Text(item.description),
        ),
      ),
    );
  }

  // function to show a dialog for adding or editing an item
  Future<void> _showAddEditDialog(BuildContext context,
      [BacklogItem? item]) async {
    final formKey = GlobalKey<FormState>();
    final itemTitleController = TextEditingController(text: item?.title);
    final itemDescriptionController =
        TextEditingController(text: item?.description);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item == null ? 'Adicionar História' : 'Editar História'),
          content: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: itemTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira algum texto';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: itemDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira algum texto';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Salvar'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (item == null) {
                    // add new item
                    setState(() {
                      backlogItems.add(BacklogItem(
                          title: itemTitleController.text,
                          description: itemDescriptionController.text));
                    });
                  } else {
                    // edit existing item
                    setState(() {
                      int itemIndex = backlogItems.indexWhere((i) => i == item);
                      if (itemIndex != -1) {
                        backlogItems[itemIndex].title =
                            itemTitleController.text;
                        backlogItems[itemIndex].description =
                            itemDescriptionController.text;
                      }
                      saveBacklogItems();
                      print(backlogItems);
                    });
                  }

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
