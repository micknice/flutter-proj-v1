import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';

import 'package:mynotes/utils/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes/jobs_view.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  late final CloudNote _note;
  late String _sumString;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _sumString = '';
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as JobArguments;
    final documentId = args.documentId;
    final jobName = args.jobName;
    final jobType = args.jobType;
    final jobSubType = args.jobSubType;

    return Scaffold(
      appBar: AppBar(
        title: Text(jobName),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                createOrUpdateNotesRoute,
                arguments: NotesViewArgs(
                  documentId,
                  jobName,
                  jobType,
                  jobSubType,
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                ),
              ];
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _notesService.allNotes(ownerUserId: userId),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    if (snapshot.hasData) {
                      final allNotes = snapshot.data as Iterable<CloudNote>;
                      final allJobNotes =
                          allNotes.where((n) => n.jobName == jobName);
                      // final test =
                      //     snapshot.data!.map((e) => double.parse(e.result));
                      // double sum = test.fold(0, (p, c) => p + c);
                      // print('XXXXXXXX');
                      // final sumString = sum.toStringAsFixed(2);
                      // // NEED TO WRITE A FUNCTION TO DO
                      // _sumString = sumString;
                      // print(sumString);

                      return NotesListView(
                        notes: allJobNotes,
                        onDeleteNote: (note) async {
                          await _notesService.deleteNote(
                            documentId: note.documentId,
                          );
                          print(allJobNotes);
                        },
                        onTap: (note) {
                          Navigator.of(context).pushNamed(
                            createOrUpdateNotesRoute,
                            arguments: NotesViewArgsWithNote(
                              note,
                              documentId,
                              jobName,
                              jobType,
                              jobSubType,
                            ),
                          );
                        },
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  default:
                    return const CircularProgressIndicator();
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Text('Natural flow for job total: $_sumString'),
          ),
        ],
      ),
    );
  }
}

class NotesViewArgs {
  
  final String documentId;
  final String jobName;
  final String jobType;
  final String jobSubType;

  NotesViewArgs(
    
    this.documentId,
    this.jobName,
    this.jobType,
    this.jobSubType,
  );
}
class NotesViewArgsWithNote {
  final CloudNote note;
  final String documentId;
  final String jobName;
  final String jobType;
  final String jobSubType;

  NotesViewArgsWithNote(
    this.note,
    this.documentId,
    this.jobName,
    this.jobType,
    this.jobSubType,
  );
}
