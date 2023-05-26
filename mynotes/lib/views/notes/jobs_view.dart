import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/cloud/cloud_job.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';

import 'package:mynotes/utils/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes/jobs_list_view.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

class JobsView extends StatefulWidget {
  const JobsView({super.key});

  @override
  State<JobsView> createState() => _JobsViewState();
}

class _JobsViewState extends State<JobsView> {
  late final FirebaseCloudStorage _jobsService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _jobsService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Jobs'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createOrUpdateJobsRoute);
              },
              icon: const Icon(Icons.add)),
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
      body: StreamBuilder(
        stream: _jobsService.allJobs(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allJobs = snapshot.data as Iterable<CloudJob>;
                return JobsListView(
                  jobs: allJobs,
                  onDeleteJob: (job) async {
                    await _jobsService.deleteJob(documentId: job.documentId);
                    print(allJobs);
                  },
                  onTap: (job) {
                    Navigator.of(context).pushNamed(notesViewRoute,
                        arguments: JobArguments(
                          job.documentId,
                          job.jobName,
                          job.jobType,
                          job.jobSubType,
                        ));
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
    );
  }
}

class JobArguments {
  final String documentId;
  final String jobName;
  final String jobType;
  final String jobSubType;

  JobArguments(this.documentId, this.jobName, this.jobType, this.jobSubType);
}
