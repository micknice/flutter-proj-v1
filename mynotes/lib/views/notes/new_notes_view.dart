import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utils/calcs.dart';

class NewNotesView extends StatefulWidget {
  const NewNotesView({Key? key}) : super(key: key);

  @override
  State<NewNotesView> createState() => _NewNotesViewState();
}

class _NewNotesViewState extends State<NewNotesView> {
  DatabaseNotes? _notes;
  late final NotesService _notesService;

  late final TextEditingController _jobName;
  late final TextEditingController _roomName;
  late final TextEditingController _roomArea;
  late final TextEditingController _roomHeight;
  late final TextEditingController _openingArea;
  late final TextEditingController _typicalWindSpeed;

  void _saveNoteIfTextNotEmpty() async {
    final notes = _notes;
    final jobName = _jobName.text;
    final roomName = _roomName.text;
    final roomArea = _roomArea.text;
    final roomHeight = _roomHeight.text;
    final openingArea = _openingArea.text;
    final typicalWindSpeed = _typicalWindSpeed.text;

    if (notes != null &&
        jobName.isNotEmpty &&
        roomName.isNotEmpty &&
        roomArea.isNotEmpty &&
        roomHeight.isNotEmpty &&
        openingArea.isNotEmpty &&
        typicalWindSpeed.isNotEmpty) {
      final result = calculateNaturalFlow(
          roomArea, roomHeight, openingArea, typicalWindSpeed);
      await _notesService.updateNotes(
          notes: notes, result: result, job: jobName, room: roomName);
    }
  }

  Future<DatabaseNotes> createNewNote() async {
    final existingNote = _notes;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
  }

  void _deleteNoteIfEmpty() {
    final note = _notes;
    if (_jobName.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  @override
  void initState() {
    _notesService = NotesService();
    _jobName = TextEditingController();
    _roomName = TextEditingController();
    _roomArea = TextEditingController();
    _roomHeight = TextEditingController();
    _openingArea = TextEditingController();
    _typicalWindSpeed = TextEditingController();
    super.initState();
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

  void _setupTextControllerListener() {
    _jobName.removeListener(_textControllerListener);
    _roomName.removeListener(_textControllerListener);
    _roomArea.removeListener(_textControllerListener);
    _roomHeight.removeListener(_textControllerListener);
    _openingArea.removeListener(_textControllerListener);
    _typicalWindSpeed.removeListener(_textControllerListener);

    _jobName.addListener(_textControllerListener);
    _roomName.addListener(_textControllerListener);
    _roomArea.addListener(_textControllerListener);
    _roomHeight.addListener(_textControllerListener);
    _openingArea.addListener(_textControllerListener);
    _typicalWindSpeed.addListener(_textControllerListener);
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfTextNotEmpty();
    _jobName.dispose();
    _roomName.dispose();
    _roomArea.dispose();
    _roomHeight.dispose();
    _openingArea.dispose();
    _typicalWindSpeed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New note'),
        ),
        body: FutureBuilder(
            future: createNewNote(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  _notes = snapshot.data as DatabaseNotes;
                  _setupTextControllerListener();
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: TextField(
                              controller: _jobName,
                              enableSuggestions: false,
                              autocorrect: false,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                hintText: 'Job name',
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: TextField(
                              controller: _roomName,
                              enableSuggestions: false,
                              autocorrect: false,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                hintText: 'Room name',
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: TextField(
                              controller: _roomArea,
                              enableSuggestions: false,
                              autocorrect: false,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Room area',
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: TextField(
                              controller: _roomHeight,
                              enableSuggestions: false,
                              autocorrect: false,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Room height',
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: TextField(
                              controller: _openingArea,
                              enableSuggestions: false,
                              autocorrect: false,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Opening area',
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: TextField(
                              controller: _typicalWindSpeed,
                              enableSuggestions: false,
                              autocorrect: false,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Typical wind speed',
                              )),
                        ),
                      ],
                    ),
                  );
                default:
                  return const CircularProgressIndicator();
              }
            }));
  }
}
