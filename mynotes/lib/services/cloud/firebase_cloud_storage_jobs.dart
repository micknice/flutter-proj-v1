import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_job.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');
  final jobs = FirebaseFirestore.instance.collection('jobs');

  Future<void> deleteJob({required String documentId}) async {
    try {
      await jobs.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteJobException();
    }
  }

  Future<void> updateJob({
    required String documentId,
    required String jobName,
    required String jobType,
    required String jobSubType,
    // required String result,
  }) async {
    try {
      await notes.doc(documentId).update({
        jobNameField: jobName,
        jobTypeField: jobType,
        jobSubTypeField: jobSubType,
        // resultField: result,
      });
    } catch (e) {
      throw CouldNotUpdateJobException();
    }
  }

  Stream<Iterable<CloudJob>> allJobs({required String ownerUserId}) {
    final allJobs = jobs
        .where(ownerUserIdField, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudJob.fromSnapshot(doc)));
    return allJobs;
  }

  Future<CloudJob> createNewJob({required String ownerUserId}) async {
    final document = await jobs.add({
      ownerUserIdField: ownerUserId,
      jobNameField: '',
      jobTypeField: '',
      jobSubTypeField: '',
      // resultField: '',
    });
    final fetchedJob = await document.get();
    return CloudJob(
      documentId: fetchedJob.id,
      ownerUserId: ownerUserId,
      jobName: '',
      jobType: '',
      jobSubType: '',
    );
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
