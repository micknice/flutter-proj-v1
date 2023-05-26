import 'package:flutter/material.dart';
import 'package:mynotes/services/cloud/cloud_job.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/utils/dialogs/delete_dialog.dart';

typedef JobCallback = void Function(CloudJob job);

class JobsListView extends StatelessWidget {
  final Iterable<CloudJob> jobs;
  final JobCallback onDeleteJob;
  final JobCallback onTap;

  const JobsListView({
    Key? key,
    required this.jobs,
    required this.onDeleteJob,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs.elementAt(index);
        return ListTile(
          onTap: () {
            onTap(job);
          },
          title: Text(
            'Job: ${job.jobName}.',
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${job.jobType} ${job.jobSubType}',
          ),
          isThreeLine: true,
          trailing: IconButton(
              onPressed: () async {
                final shouldDelete = await showDeleteDialog(context);
                if (shouldDelete) {
                  onDeleteJob(job);
                }
              },
              icon: const Icon(Icons.delete)),
        );
      },
    );
  }
}
