import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/note/cubit/note_state.dart';
import 'package:firebase_app/note/repository/note_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NoteCubit extends Cubit<NoteState> {
  final NoteRepository _repository;
  late final Stream<QuerySnapshot> _noteStream;
  late final StreamSubscription _subscription;

  NoteCubit(this._repository) : super(NoteInitial()) {
    _noteStream = _repository.getNotes();
    _subscription = _noteStream.listen((snapshot) {
      emit(NoteLoaded(snapshot.docs));
    });
  }

  //State add note
  Future<void> addNote(String title, String content) async {
    emit(NoteLoading());
    try {
      await _repository.addNote(title, content);
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  //State update note
  Future<void> updateNote(String id, String title, String content) async {
    emit(NoteLoading());
    try {
      await _repository.updateNote(id, title, content);
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  //State delete note
  Future<void> deleteNote(String id) async {
    emit(NoteLoading());
    try {
      await _repository.deleteNote(id);
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
