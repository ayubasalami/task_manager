import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task_model.dart';
import '../provider/provider.dart';
import '../widgets/custom_text_field.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  final TaskModel? task;

  const EditTaskScreen({super.key, this.task});

  @override
  ConsumerState<EditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get isEditMode => widget.task != null;

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final taskViewModel = ref.read(taskListProvider.notifier);

      if (isEditMode) {
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
        );
        taskViewModel.updateTask(updatedTask);
      } else {
        taskViewModel.addTask(
          _titleController.text.trim(),
          _descriptionController.text.trim(),
        );
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditMode ? 'Task updated' : 'Task added')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Task' : 'Add Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTask,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _titleController,
              label: 'Title',
              hint: 'Enter task title',
              icon: Icons.title,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter task description',
              icon: Icons.description,
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saveTask,
              icon: const Icon(Icons.save),
              label: Text(isEditMode ? 'Update Task' : 'Add Task'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ],
        ),
      ),
    );
  }
}
