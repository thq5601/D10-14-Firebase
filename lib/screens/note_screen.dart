import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_app/note/cubit/note_cubit.dart';
import 'package:firebase_app/note/cubit/note_state.dart';
import 'package:firebase_app/note/repository/note_repository.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _showAddOrEditDialog({String? id, String? title, String? content}) {
    if (title != null) _titleController.text = title;
    if (content != null) _contentController.text = content;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? "Add note" : "Edit note"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: "Content"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _titleController.clear();
              _contentController.clear();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final title = _titleController.text.trim();
              final content = _contentController.text.trim();
              if (id == null) {
                context.read<NoteCubit>().addNote(title, content);
              } else {
                context.read<NoteCubit>().updateNote(id, title, content);
              }
              Navigator.pop(context);
              _titleController.clear();
              _contentController.clear();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NoteCubit(NoteRepository(FirebaseFirestore.instance)),
      child: Scaffold(
        appBar: AppBar(title: const Text("Notes")),
        body: BlocBuilder<NoteCubit, NoteState>(
          builder: (context, state) {
            if (state is NoteLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is NoteError) {
              return Center(child: Text(state.message));
            }
            if (state is NoteLoaded) {
              if (state.notes.isEmpty) {
                return const Center(child: Text("No notes yet"));
              }

              return ListView.builder(
                itemCount: state.notes.length,
                itemBuilder: (context, index) {
                  final note = state.notes[index];
                  final data = note.data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text(data['title'] ?? ""),
                    subtitle: Text(data['content'] ?? ""),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showAddOrEditDialog(
                            id: note.id,
                            title: data['title'],
                            content: data['content'],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              context.read<NoteCubit>().deleteNote(note.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddOrEditDialog(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
