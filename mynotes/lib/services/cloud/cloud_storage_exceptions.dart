class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotCreateNoteException extends CloudStorageException {}

class CouldNotGetAllNotesException extends CloudStorageException {}

class CouldNotUpdateNoteException extends CloudStorageException {}

class CouldNotDeleteNoteException extends CloudStorageException {}

class CouldNotCreateJobException extends CloudStorageException {}

class CouldNotGetAllJobsException extends CloudStorageException {}

class CouldNotUpdateJobException extends CloudStorageException {}

class CouldNotDeleteJobException extends CloudStorageException {}