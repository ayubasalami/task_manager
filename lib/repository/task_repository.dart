import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';

class TaskRepository {
  static const String _tasksKey = 'tasks';

  Future<List<TaskModel>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_tasksKey);

      if (tasksJson != null) {
        final List<dynamic> decoded = jsonDecode(tasksJson);
        return decoded.map((json) => TaskModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      return [];
    }
  }

  Future<bool> saveTasks(List<TaskModel> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = jsonEncode(tasks.map((task) => task.toJson()).toList());
      return await prefs.setString(_tasksKey, tasksJson);
    } catch (e) {
      debugPrint('Error saving tasks: $e');
      return false;
    }
  }

  Future<bool> addTask(TaskModel task, List<TaskModel> currentTasks) async {
    final updatedTasks = [...currentTasks, task];
    return await saveTasks(updatedTasks);
  }

  Future<bool> updateTask(TaskModel task, List<TaskModel> currentTasks) async {
    final updatedTasks = currentTasks.map((t) {
      return t.id == task.id ? task : t;
    }).toList();
    return await saveTasks(updatedTasks);
  }

  Future<bool> deleteTask(String id, List<TaskModel> currentTasks) async {
    final updatedTasks = currentTasks.where((t) => t.id != id).toList();
    return await saveTasks(updatedTasks);
  }
}
