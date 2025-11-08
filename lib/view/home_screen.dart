import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';
import 'edit_task_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTasks = ref.watch(taskListProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: asyncTasks.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const EmptyState(
              icon: Icons.task_alt,
              message: 'No tasks yet',
              subtitle: 'Tap the + button to add your first task',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTaskScreen(task: task),
                    ),
                  );
                },
                onToggle: () {
                  ref
                      .read(taskListProvider.notifier)
                      .toggleTaskCompletion(task.id);
                },
                onDelete: () {
                  ref.read(taskListProvider.notifier).deleteTask(task.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Task deleted'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          ref
                              .read(taskListProvider.notifier)
                              .addTask(task.title, task.description);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: Something went wrong.\nPlease retry'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(taskListProvider.notifier).loadTasks();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
