void _jobNameListener() async {
    final notes = _notes;
    if (notes == null) {
      return;
    }
    final jobName = _jobName.text;
    final roomName = _roomName.text;
    final roomArea = _roomArea.text;
    final roomHeight = _roomHeight.text;
    final openingArea = _openingArea.text;
    final typicalWindSpeed = _typicalWindSpeed.text;
    var result = 'dummy';
    if (jobName.isNotEmpty &&
        roomName.isNotEmpty &&
        roomArea.isNotEmpty &&
        roomHeight.isNotEmpty &&
        openingArea.isNotEmpty &&
        typicalWindSpeed.isNotEmpty) {
       result = calculateNaturalFlow(
          roomArea, roomHeight, openingArea, typicalWindSpeed);
    }
    await _notesService.updateNotes(
        notes: notes, result: result, job: jobName, room: roomName);
  }



void _textControllerListener() async {
    final notes = _notes;
    if (notes == null) {
      return;
    }
    final jobName = _jobName.text;
    final roomName = _roomName.text;
    final roomArea = _roomArea.text;
    final roomHeight = _roomHeight.text;
    final openingArea = _openingArea.text;
    final typicalWindSpeed = _typicalWindSpeed.text;
    var result = 'dummy';
    if (jobName.isNotEmpty &&
        roomName.isNotEmpty &&
        roomArea.isNotEmpty &&
        roomHeight.isNotEmpty &&
        openingArea.isNotEmpty &&
        typicalWindSpeed.isNotEmpty) {
       result = calculateNaturalFlow(
          roomArea, roomHeight, openingArea, typicalWindSpeed);
    }
    await _notesService.updateNotes(
        notes: notes, result: result, job: jobName, room: roomName);
  }