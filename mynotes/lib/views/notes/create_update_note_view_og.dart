import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utils/calcs.dart';
import 'package:mynotes/utils/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:mynotes/utils/generics/get_arguments.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/views/notes/jobs_view.dart';
import 'package:mynotes/views/notes/notes_view.dart';
import 'package:share_plus/share_plus.dart';

class CreatUpdateNoteView extends StatefulWidget {
  const CreatUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreatUpdateNoteView> createState() => _CreatUpdateNoteViewState();
}

class _CreatUpdateNoteViewState extends State<CreatUpdateNoteView> {
  CloudNote? _notes;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _jobName;
  late final TextEditingController _roomName;
  late final TextEditingController _roomArea;
  late final TextEditingController _roomHeight;
  late final TextEditingController _openingArea;
  late final TextEditingController _typicalWindSpeed;
  late final TextEditingController _result;

  void recalc() {
    setState(() {
      _result.text = calculateNaturalFlow(_roomArea.text, _roomHeight.text,
          _openingArea.text, _typicalWindSpeed.text);
    });
  }

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
      await _notesService.updateNote(
        documentId: notes.documentId,
        jobName: jobName,
        roomName: roomName,
        roomArea: roomArea,
        roomHeight: roomHeight,
        openingArea: openingArea,
        typicalWindSpeed: typicalWindSpeed,
        result: result,
      );
    }
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();
    print('widgetNote');
    print(widgetNote);

    if (widgetNote != null) {
      print('widgetnote != null');
      print(widgetNote.openingArea);
      _notes = widgetNote;
      _jobName.text = widgetNote.jobName;
      _roomName.text = widgetNote.roomName;
      _roomArea.text = widgetNote.roomArea;
      _roomHeight.text = widgetNote.roomHeight;
      _openingArea.text = widgetNote.openingArea;
      _typicalWindSpeed.text = widgetNote.typicalWindSpeed;
      _result.text = widgetNote.result;
      return widgetNote;
    }
    final existingNote = _notes;
    if (existingNote != null) {
      print('existingnote != null');
      print(existingNote.openingArea);
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _notes = newNote;
    return newNote;
  }

  void _deleteNoteIfEmpty() {
    final note = _notes;
    if (_roomName.text.isEmpty && note != null) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _jobName = TextEditingController();
    _roomName = TextEditingController();
    _roomArea = TextEditingController();
    _roomHeight = TextEditingController();
    _openingArea = TextEditingController();
    _typicalWindSpeed = TextEditingController();
    _result = TextEditingController();
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
    print('notesService updateNote invoked');
    await _notesService.updateNote(
      documentId: notes.documentId,
      jobName: jobName,
      roomName: roomName,
      roomArea: roomArea,
      roomHeight: roomHeight,
      openingArea: openingArea,
      typicalWindSpeed: typicalWindSpeed,
      result: result,
    );
  }

  void _setupTextControllerListener() {
    _jobName.removeListener(_textControllerListener);
    _jobName.addListener(_textControllerListener);
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
    // final arguments = ModalRoute.of(context)!.settings.arguments;
    // print(arguments);
    // if (arguments is NotesViewArgsWithNote) {
    //   print('first condition');
    //   final argsWithNote = arguments;
    //   final note = argsWithNote.note;
    //   final jobId = argsWithNote.documentId;
    //   final jobName = argsWithNote.jobName;
    //   final jobType = argsWithNote.jobType;
    //   final jobSubType = argsWithNote.jobSubType;
    //   _jobName.text = jobName;
    // } else if (arguments is NotesViewArgs) {
    //   print('second condition');
    //   final args = arguments;
    //   final jobId = args.documentId;
    //   final jobName = args.jobName;
    //   final jobType = args.jobType;
    //   final jobSubType = args.jobSubType;
    //   _jobName.text = jobName;
    // }

    return Scaffold(
        appBar: AppBar(
          title: const Text(''),
          actions: [
            IconButton(
                onPressed: () async {
                  final resultText =
                      'Shared flow-note: ${_jobName.text} - ${_roomName.text} - ${_result.text}';
                  if (_notes == null || resultText.isEmpty) {
                    await showCannotShareEmptyNoteDialog(context);
                  } else {
                    Share.share(resultText);
                  }
                },
                icon: const Icon(Icons.share)),
          ],
        ),
        body: FutureBuilder(
            future: createOrGetExistingNote(context),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  _setupTextControllerListener();
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text('Job name:'),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: TextField(
                            controller: _jobName,
                            readOnly: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        const Text('Room name:'),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: TextField(
                            controller: _roomName,
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        const Text('Room area m2:'),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: TextField(
                            controller: _roomArea,
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        const Text('Room height m:'),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: TextField(
                            controller: _roomHeight,
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        const Text('Opening area m2:'),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: TextField(
                            controller: _openingArea,
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        const Text('Typical wind speed m/s:'),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: TextField(
                            controller: _typicalWindSpeed,
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        const Text('Result:'),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: TextField(
                            controller: _result,
                            readOnly: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            recalc();
                          },
                          child: const Text('Calculate'),
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
