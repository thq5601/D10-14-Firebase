import 'package:cloud_firestore/cloud_firestore.dart';

class NoteRepository {
  final FirebaseFirestore firestore;

  NoteRepository(this.firestore);

  Stream<QuerySnapshot> getNotes() => firestore
      .collection("notes")
      .orderBy("createdAt", descending: true)
      .snapshots();

  Future<void> addNote(String title, String content) async {
    await firestore.collection("notes").add({
      "title": title,
      "content": content,
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNote(String id, String title, String content) async {
    await firestore.collection("notes").doc(id).update({
      "title": title,
      "content": content,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote(String id) async {
    await firestore.collection("notes").doc(id).delete();
  }
}
