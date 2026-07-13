import 'package:uruvia/offline/database_helper.dart';
import 'package:uruvia/screens/tasks/task_model.dart';

class TasksRepository {
  static final TasksRepository _instance = TasksRepository._internal();
  static TasksRepository get instance => _instance;
  TasksRepository._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Retrieve all tasks from local SQLite cache
  Future<List<Task>> getTasks() async {
    final List<Map<String, dynamic>> cachedRows = await _dbHelper.queryCache(
      'local_tasks',
      orderBy: 'created_at DESC',
    );

    return cachedRows.map((row) => Task.fromMap(row)).toList();
  }

  // Insert a task
  Future<void> addTask(Task task) async {
    // Prevent duplicate pending auto-tasks for the same item/invoice/expense
    if (task.relatedItemId != null && task.type != 'manual') {
      final existing = await _dbHelper.queryCache(
        'local_tasks',
        where: 'related_item_id = ? AND type = ? AND is_completed = 0',
        whereArgs: [task.relatedItemId, task.type],
      );
      if (existing.isNotEmpty) {
        // Task already exists and is pending, do not add it again
        return;
      }
    }
    await _dbHelper.cacheUpsert('local_tasks', task.toMap());
  }

  // Update task details or state
  Future<void> updateTask(Task task) async {
    await _dbHelper.cacheUpsert('local_tasks', task.toMap());
  }

  // Delete a task by ID
  Future<void> deleteTask(String id) async {
    await _dbHelper.deleteCacheRow('local_tasks', id);
  }
}
