import 'dart:io';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:keep_up_work/models/step_model.dart';
import 'package:keep_up_work/models/steps_progress.dart';
import 'package:keep_up_work/models/value_progress.dart';
import 'package:keep_up_work/src/database/app_database.dart';
import 'package:keep_up_work/src/variables/var_database.dart';
import 'package:keep_up_work/src/variables/var_progress.dart';
import 'package:path_provider/path_provider.dart';

class DBLayer {
  final AppDatabase _db = AppDatabase();
  late final Directory _appDocDir;

  Future<void> init() async {
    _appDocDir = await getApplicationDocumentsDirectory();
    await _db.openDatabase('${_appDocDir.path}/keep_up_work.db');
    _db.createTables();
    _initVariables();
    _db.closeDatabase();
  }

  void _initVariables() {
    listOfValueProgress = _db.getAllValueProgresses() ?? RxList<ValueProgress>();
    listOfStepsProgress = _db.getAllStepsProgresses() ?? RxList<StepsProgress>();
    currentProgressId = _db.getCurrentProgressId() ;
    currentStepId = _db.getCurrentStepId();
    currentValueProgressId = _db.getCurrentValueProgressId();
    currentStepsProgressId = _db.getCurrentStepProgressId();
  }

  Future<void> insertValueProgress(ValueProgress valueProgress) async {
    await _db.openDatabase('${_appDocDir.path}/keep_up_work.db');
    await _db.insertProgress(
      id: valueProgress.progressId,
      title: valueProgress.title,
      dateCreated: valueProgress.dateCreated.toString(),
      displayColor: valueProgress.displayColor.toString(),
      isCompleted: (valueProgress.isCompleted ?? false) ? 1 : 0,
      goal: valueProgress.goal ?? '',
      note: valueProgress.note ?? '',
    );
    await _db.insertValueProgress(
      progressId: valueProgress.progressId,
      totalValue: valueProgress.totalValue,
      currentValue: valueProgress.currentValue ?? 0,
      name: valueProgress.name,
    );
    listOfValueProgress.add(valueProgress);
    _db.closeDatabase();
  }

  Future<void> insertStepProgress(StepsProgress stepsProgress) async {
    await _db.openDatabase('${_appDocDir.path}/keep_up_work.db');
    await _db.insertProgress(
      id: stepsProgress.progressId,
      title: stepsProgress.title,
      dateCreated: stepsProgress.dateCreated.toString(),
      displayColor: stepsProgress.displayColor.toString(),
      isCompleted: (stepsProgress.isCompleted ?? false) ? 1 : 0,
      goal: stepsProgress.goal ?? '',
      note: stepsProgress.note ?? '',
    );
    await _db.insertStepsProgress(
      progressId: stepsProgress.progressId,
    );
    for (StepModel step in stepsProgress.steps) {
      await _db.insertStep(
        stepId: step.stepId,
        progressId: stepsProgress.progressId,
        label: step.label,
        value: step.value,
        isDone: step.isDone ? 1 : 0,
      );
    }
    listOfStepsProgress.add(stepsProgress);
    _db.closeDatabase();
  }

  Future<void> updateValueProgress(ValueProgress progress) async {
    await _db.openDatabase('${_appDocDir.path}/keep_up_work.db');
    await _db.updateProgress(
      id: progress.progressId,
      title: progress.title,
      dateCreated: progress.dateCreated.toString(),
      displayColor: progress.displayColor.toString(),
      isCompleted: (progress.isCompleted ?? false) ? 1 : 0,
      goal: progress.goal ?? '',
      note: progress.note ?? '',
    );
    await _db.updateValueProgress(
      progressId: progress.progressId,
      totalValue: progress.totalValue,
      currentValue: progress.currentValue ?? 0,
      name: progress.name,
    );
    _db.closeDatabase();
  }

  Future<void> updateStepProgress(StepsProgress progress) async {
    await _db.openDatabase('${_appDocDir.path}/keep_up_work.db');
    await _db.updateProgress(
      id: progress.progressId,
      title: progress.title,
      dateCreated: progress.dateCreated.toString(),
      displayColor: progress.displayColor.toString(),
      isCompleted: (progress.isCompleted ?? false) ? 1 : 0,
      goal: progress.goal ?? '',
      note: progress.note ?? '',
    );
    await _db.updateStepsProgress(
      progressId: progress.progressId,
    );
    for (StepModel step in progress.steps) {
      await _db.updateStep(
        stepId: step.stepId,
        progressId: progress.progressId,
        label: step.label,
        value: step.value,
        isDone: step.isDone ? 1 : 0,
      );
    }
    _db.closeDatabase();
  }

  Future<void> deleteValueProgress(ValueProgress progress) async {
    await _db.openDatabase('${_appDocDir.path}/keep_up_work.db');
    await _db.deleteProgress(
      progress.progressId,
    );
    await _db.deleteValueProgress(
      progress.progressId,
    );
    _db.closeDatabase();
    listOfValueProgress.remove(progress);
  }

  Future<void> deleteStepProgress(StepsProgress progress) async {
    await _db.openDatabase('${_appDocDir.path}/keep_up_work.db');
    await _db.deleteProgress(
      progress.progressId,
    );
    await _db.deleteStepsProgress(
      progress.progressId,
    );
    await _db.deleteStep(
      progress.progressId,
    );
    _db.closeDatabase();
    listOfStepsProgress.remove(progress);
  }
}
