import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String jobName;
  final String roomName;
  final String roomArea;
  final String roomHeight;
  final String openingArea;
  final String typicalWindSpeed;
  final String result;

  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.jobName,
    required this.roomName,
    required this.roomArea,
    required this.roomHeight,
    required this.openingArea,
    required this.typicalWindSpeed,
    required this.result,
  });
  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdField],
        jobName = snapshot.data()[jobNameField] as String,
        roomName = snapshot.data()[roomNameField] as String,
        roomArea = snapshot.data()[roomAreaField] as String,
        roomHeight = snapshot.data()[roomHeightField] as String,
        openingArea = snapshot.data()[openingAreaField] as String,
        typicalWindSpeed = snapshot.data()[typicalWindSpeedField] as String,
        result = snapshot.data()[resultField] as String;
}
