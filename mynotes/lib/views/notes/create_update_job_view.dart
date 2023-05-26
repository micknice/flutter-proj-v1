import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/utils/calcs.dart';
import 'package:mynotes/utils/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:mynotes/utils/generics/get_arguments.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_job.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

const List<String> jobTypeList = <String>[
  '',
  'Residential',
  'Commercial',
  'Industrial'
];
const List<String> jobSubTypeListResidential = <String>[
  '2 bed',
  '4 bed',
  '6 bed'
];
const List<String> jobSubTypeListCommercial = <String>[
  'Retail',
  'Healthcare',
  'School',
  'Public Building'
];
const List<String> jobSubTypeListIndustrial = <String>[
  'Warehouse',
];
const List<String> jobSubTypeListUnselectedJobType = <String>[
  'Please select a job type first',
];

class CreatUpdateJobView extends StatefulWidget {
  const CreatUpdateJobView({Key? key}) : super(key: key);

  @override
  State<CreatUpdateJobView> createState() => _CreatUpdateJobViewState();
}

class _CreatUpdateJobViewState extends State<CreatUpdateJobView> {
  CloudJob? _jobs;

  List jobSubTypeList = jobSubTypeListUnselectedJobType;
  late String jobTypeDropDownValue = jobTypeList.first;
  late String jobSubTypeDropDownValue = jobSubTypeListUnselectedJobType.first;

  late final FirebaseCloudStorage _jobsService;
  late final TextEditingController _jobName;
  late final TextEditingController _jobType;
  late final TextEditingController _jobSubType;
  late final TextEditingController _result;

  void _handleJobTypeChangeToJobSubTypeListSelection() {
    if (jobTypeDropDownValue == 'Residential') {
      setState(() {
        jobSubTypeList = jobSubTypeListResidential;
        jobSubTypeDropDownValue = jobSubTypeListResidential.first;
      });
    } else if (jobTypeDropDownValue == 'Commercial') {
      setState(() {
        jobSubTypeList = jobSubTypeListCommercial;
        jobSubTypeDropDownValue = jobSubTypeListCommercial.first;
      });
    } else if (jobTypeDropDownValue == 'Industrial') {
      setState(() {
        jobSubTypeList = jobSubTypeListIndustrial;
        jobSubTypeDropDownValue = jobSubTypeListIndustrial.first;
      });
    } else {
      setState(() {
        jobSubTypeList = jobSubTypeListUnselectedJobType;
        jobSubTypeDropDownValue = jobSubTypeListUnselectedJobType.first;
      });
    }
  }

  void _saveJobIfTextNotEmpty() async {
    final jobs = _jobs;
    final jobName = _jobName.text;
    final jobType = _jobType.text;
    final jobSubType = _jobSubType.text;

    print('_saveJobIfTextNotEmpty');
    print(jobs);
    print(jobName);
    if (jobs != null &&
        jobName.isNotEmpty &&
        jobType.isNotEmpty &&
        jobSubType.isNotEmpty) {
      const result = 'dummy here !';
      // when implementing calculation adding all rooms flow together remember to use final as below
      // final result = calcFunc(params)
      await _jobsService.updateJob(
        documentId: jobs.documentId,
        jobName: jobName,
        jobType: jobType,
        jobSubType: jobSubType,
      );
    }
  }

  Future<CloudJob> createOrGetExistingJob(BuildContext context) async {
    final widgetJob = context.getArgument<CloudJob>();
    print(widgetJob);

    if (widgetJob != null) {
      print('widgetJob');
      print(widgetJob.jobName);
      print(widgetJob.jobType);
      print(widgetJob.jobSubType);
      _jobs = widgetJob;
      _jobName.text = widgetJob.jobName;
      _jobType.text = widgetJob.jobType;
      _jobSubType.text = widgetJob.jobSubType;

      return widgetJob;
    }
    final existingJob = _jobs;
    if (existingJob != null) {
      print('existingJOb');
      return existingJob;
    }
    print('falls through');
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newJob = await _jobsService.createNewJob(ownerUserId: userId);
    _jobs = newJob;
    return newJob;
  }

  void _deleteJobIfEmpty() {
    final job = _jobs;
    if (_jobName.text.isEmpty && job != null) {
      _jobsService.deleteJob(documentId: job.documentId);
    }
  }

  @override
  void initState() {
    _jobsService = FirebaseCloudStorage();
    _jobName = TextEditingController();
    _jobType = TextEditingController();
    _jobSubType = TextEditingController();
    _result = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final jobs = _jobs;
    if (jobs == null) {
      return;
    }
    final jobName = _jobName.text;
    final jobType = _jobType.text;
    final jobSubType = _jobSubType.text;

    var result = 'dummy';
    if (jobName.isNotEmpty && jobType.isNotEmpty && jobSubType.isNotEmpty) {
      result = 'dummy now !';
    }
    print('jobsService updateJob invoked');
    await _jobsService.updateJob(
      documentId: jobs.documentId,
      jobName: jobName,
      jobType: jobType,
      jobSubType: jobSubType,
      // result: result,
    );
  }

  void _setupTextControllerListener() {
    _jobName.removeListener(_textControllerListener);
    _jobName.addListener(_textControllerListener);
  }

  @override
  void dispose() {
    _deleteJobIfEmpty();
    _saveJobIfTextNotEmpty();
    _jobName.dispose();
    _jobType.dispose();
    _jobSubType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Job'),
        ),
        body: FutureBuilder(
            future: createOrGetExistingJob(context),
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
                            enableSuggestions: false,
                            autocorrect: false,
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        const Text('Job type:'),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          // change to radio button or dropdown with premises types when i get spec sheet
                          child: DropdownButton<String>(
                            value: jobTypeDropDownValue,
                            icon: const Icon(Icons.arrow_downward),
                            elevation: 16,
                            style: const TextStyle(color: Colors.blue),
                            underline: Container(
                              height: 2,
                              color: Colors.blueAccent,
                            ),
                            onChanged: (dynamic value) {
                              _jobType.text = value!;
                              setState(() {
                                jobTypeDropDownValue = value!.toString();
                                _handleJobTypeChangeToJobSubTypeListSelection();
                              });
                              print(value);
                            },
                            items: jobTypeList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                        const Text('Job sub-type:'),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          // change to radio button or dropdown with premises types when i get spec sheet
                          child: DropdownButton<String>(
                            value: jobSubTypeDropDownValue,
                            icon: const Icon(Icons.arrow_downward),
                            elevation: 16,
                            style: const TextStyle(color: Colors.blue),
                            underline: Container(
                              height: 2,
                              color: Colors.blueAccent,
                            ),
                            onChanged: (String? value) {
                              _jobSubType.text = value!;
                              setState(() {
                                jobSubTypeDropDownValue = value!.toString();
                              });
                              print(value);
                            },
                            items: jobSubTypeList
                                .map<DropdownMenuItem<String>>((dynamic value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
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
