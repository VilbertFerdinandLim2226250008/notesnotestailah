import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: const NoteList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add'),
                    const Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Title: ',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    TextField(
                      controller: _titleController,
                    ),
                    const Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Description: ',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    TextField(
                      controller: _descriptionController,
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Map<String, dynamic> notes = {};
                        notes['title'] = _titleController.text;
                        notes['description'] = _descriptionController.text;

                        FirebaseFirestore.instance
                            .collection('notes')
                            .add(notes)
                            .whenComplete(() {
                          Navigator.of(context).pop();
                        });
                      },
                      child: const Text('Save'))
                ],
              );
            },
          );
        },
        tooltip: 'Add notes',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteList extends StatelessWidget {
  const NoteList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('notes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(),
            );
          default:
            return ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: snapshot.data!.docs.map((document) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                  child: Card(
                    child: ListTile(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            final TextEditingController titleController =
                                TextEditingController();
                            final TextEditingController descriptionController =
                                TextEditingController();
                            return AlertDialog(
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Update'),
                                  const Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      'Title: ',
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  TextField(
                                    controller: titleController,
                                  ),
                                  const Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      'Description: ',
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  TextField(
                                    controller: descriptionController,
                                  ),
                                ],
                              ),
                              actions: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      Map<String, dynamic> updateNotes = {};
                                      updateNotes['title'] =
                                          titleController.text;
                                      updateNotes['description'] =
                                          descriptionController.text;

                                      FirebaseFirestore.instance
                                          .collection('notes')
                                          .doc(document.id)
                                          .update(updateNotes)
                                          .whenComplete(() {
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    child: const Text('Update'))
                              ],
                            );
                          },
                        );
                      },
                      title: Text(document['title']),
                      subtitle: Text(document['description']),
                      trailing: InkWell(
                        onTap: () {
                          FirebaseFirestore.instance
                              .collection('notes')
                              .doc(document.id)
                              .delete();
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Icon(Icons.delete),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
        }
      },
    );
  }
}
