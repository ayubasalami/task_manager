import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/task_model.dart';
import '../repository/task_repository.dart';
import '../view_model/app_theme_view_model.dart';
import '../view_model/task_view_model.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final taskListProvider =
    StateNotifierProvider<TaskViewModel, AsyncValue<List<TaskModel>>>((ref) {
      final repository = ref.watch(taskRepositoryProvider);
      return TaskViewModel(repository);
    });

final completedTasksProvider = Provider<List<TaskModel>>((ref) {
  final asyncTasks = ref.watch(taskListProvider);
  return asyncTasks.when(
    data: (tasks) => tasks.where((task) => task.isCompleted).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final incompleteTasksProvider = Provider<List<TaskModel>>((ref) {
  final asyncTasks = ref.watch(taskListProvider);
  return asyncTasks.when(
    data: (tasks) => tasks.where((task) => !task.isCompleted).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final taskCountProvider = Provider<int>((ref) {
  final asyncTasks = ref.watch(taskListProvider);
  return asyncTasks.when(
    data: (tasks) => tasks.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
final themeModeProvider = StateNotifierProvider<ThemeViewModel, ThemeMode>((
  ref,
) {
  return ThemeViewModel();
});

final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  return themeMode == ThemeMode.dark;
});
