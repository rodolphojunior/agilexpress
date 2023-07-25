import 'package:flutter/material.dart';

void main() {
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

  BacklogItem(this.title, this.description);
}

class BacklogPage extends StatefulWidget {
  const BacklogPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BacklogPageState createState() => _BacklogPageState();
}

class _BacklogPageState extends State<BacklogPage> {
  final List<BacklogItem> backlogItems = [
    BacklogItem('História 1', 'Descrição da história 1'),
    BacklogItem('História 2', 'Descrição da história 2'),
    BacklogItem('História 3', 'Descrição da história 3'),
    BacklogItem('História 4', 'Descrição da história 4'),
    BacklogItem('História 5', 'Descrição da história 5'),
    BacklogItem('História 6', 'Descrição da história 6'),
    BacklogItem('História 7', 'Descrição da história 7'),
    BacklogItem('História 8', 'Descrição da história 8'),
    BacklogItem('História 9', 'Descrição da história 9'),
    BacklogItem('História 10', 'Descrição da história 10'),
    BacklogItem('História 11', 'Descrição da história 11'),
    BacklogItem('História 12', 'Descrição da história 12'),
  ];

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
                      backlogItems.add(BacklogItem(itemTitleController.text,
                          itemDescriptionController.text));
                    });
                  } else {
                    // edit existing item
                    setState(() {
                      item.title = itemTitleController.text;
                      item.description = itemDescriptionController.text;
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
