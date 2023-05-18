import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String jobName,
    required String roomName,
    required String roomArea,
    required String roomHeight,
    required String openingArea,
    required String typicalWindSpeed,
    required String result,
  }) async {
    try {
      await notes.doc(documentId).update({
        jobNameField: jobName,
        roomNameField: roomName,
        roomAreaField: roomArea,
        roomHeightField: roomHeight,
        openingAreaField: openingArea,
        typicalWindSpeedField: typicalWindSpeed,
        resultField: result,
      });
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdField: ownerUserId,
      jobNameField: '',
      roomNameField: '',
      roomAreaField: '',
      roomHeightField: '',
      openingAreaField: '',
      typicalWindSpeedField: '',
      resultField: '',
    });
    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      jobName: '',
      roomName: '',
      roomArea: '',
      roomHeight: '',
      openingArea: '',
      typicalWindSpeed: '',
      result: '',
    );
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(ownerUserIdField, isEqualTo: ownerUserId)
          .get()
          .then(
            (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
