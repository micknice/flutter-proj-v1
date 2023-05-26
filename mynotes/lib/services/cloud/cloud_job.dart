import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudJob {
  final String documentId;
  final String ownerUserId;
  final String jobName;
  final String jobType;
  final String jobSubType;

  const CloudJob({
    required this.documentId,
    required this.ownerUserId,
    required this.jobName,
    required this.jobType,
    required this.jobSubType,
  });
  CloudJob.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdField],
        jobName = snapshot.data()[jobNameField] as String,
        jobType = snapshot.data()[jobTypeField] as String,
        jobSubType = snapshot.data()[jobSubTypeField] as String;
}
