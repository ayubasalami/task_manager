import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../models/task_model.dart';
import '../repository/task_repository.dart';

class TaskViewModel extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TaskRepository _repository;
  final Uuid _uuid = const Uuid();

  TaskViewModel(this._repository) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _repository.loadTasks();
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = AsyncValue.data(tasks);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addTask(String title, String description) async {
    final currentState = state;

    final task = TaskModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );

    await currentState.whenData((tasks) async {
      final updatedTasks = [task, ...tasks];
      state = AsyncValue.data(updatedTasks);

      final success = await _repository.addTask(task, tasks);
      if (!success) {
        state = AsyncValue.data(tasks);
      }
    });
  }

  Future<void> updateTask(TaskModel task) async {
    final currentState = state;

    await currentState.whenData((tasks) async {
      final updatedTasks = tasks.map((t) {
        return t.id == task.id ? task : t;
      }).toList();

      state = AsyncValue.data(updatedTasks);

      final success = await _repository.updateTask(task, tasks);
      if (!success) {
        state = AsyncValue.data(tasks);
      }
    });
  }

  Future<void> deleteTask(String id) async {
    final currentState = state;

    await currentState.whenData((tasks) async {
      final updatedTasks = tasks.where((t) => t.id != id).toList();

      state = AsyncValue.data(updatedTasks);

      final success = await _repository.deleteTask(id, tasks);
      if (!success) {
        state = AsyncValue.data(tasks);
      }
    });
  }

  Future<void> toggleTaskCompletion(String id) async {
    final currentState = state;

    await currentState.whenData((tasks) async {
      final task = tasks.firstWhere((t) => t.id == id);
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await updateTask(updatedTask);
    });
  }
}
