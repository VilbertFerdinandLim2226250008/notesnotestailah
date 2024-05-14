import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/models/note.dart';
import 'package:notes/services/note_service.dart';

class NoteDialog extends StatefulWidget {
  final Note? note;

  const NoteDialog({super.key, this.note});

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.note == null ? 'Add Notes' : 'Update Notes'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Title: ',
            textAlign: TextAlign.start,
          ),
          TextField(
            controller: _titleController,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Description: ',
            ),
          ),
            const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Image: ',
            ),
          ),
          Expanded(child: _imageFile != null
              ? Image.file(_imageFile!, fit: BoxFit.cover,)
              : (widget.note?.imageUrl != null && 
                  Uri.parse(widget.note!.imageUrl!).isAbsolute)
              ? Image.network(widget.note!.imageUrl!, fit:BoxFit.cover,)
              : Container();
          TextButton(onPressed: _pickImage, child: const Text('Pick Image')),
          TextField(
            controller: _descriptionController,
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (widget.note == null) {
              NoteService.addNote(Note(
                title: _titleController.text,
                description: _descriptionController.text,
                imageUrl: null,
              )).whenComplete(() {
                Navigator.of(context).pop();
              });
            } else {
              NoteService.updateNote(Note(
                id: widget.note!.id,
                title: _titleController.text,
                description: _descriptionController.text,
                createdAt: widget.note!.createdAt,
                imageUrl: null,
              )).whenComplete(() => Navigator.of(context).pop());
            }
          },
          child: Text(widget.note == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
