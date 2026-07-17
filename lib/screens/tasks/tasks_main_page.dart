import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/screens/tasks/task_model.dart';
import 'package:uruvia/screens/tasks/tasks_repository.dart';
import 'package:uruvia/services/notification_service.dart';
import 'package:uruvia/widgets/custom_text.dart';
import 'package:uruvia/screens/invoices/model/invoice_model.dart'; // For formatDate helper

class TasksMainPage extends StatefulWidget {
  const TasksMainPage({super.key});

  @override
  State<TasksMainPage> createState() => _TasksMainPageState();
}

class _TasksMainPageState extends State<TasksMainPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await TasksRepository.instance.getTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
    await TasksRepository.instance.updateTask(task);

    // Cancel notification if completed
    if (task.isCompleted) {
      await NotificationService.instance.cancelNotification(task.id);

      // If it is a low stock task, ask if they want to navigate to Inventory to update stock count
      if (task.type == 'inventory' && mounted) {
        _showRestockPrompt(task);
      }
    } else {
      // Re-schedule notification if unmarked (schedule in 24 hours or standard offset)
      if (task.dueDate.isAfter(DateTime.now())) {
        await NotificationService.instance.scheduleNotification(
          task.id,
          task.title,
          task.description,
          task.dueDate,
        );
      }
    }
    _loadTasks();
  }

  void _showRestockPrompt(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: [
            const Icon(
              CupertinoIcons.archivebox_fill,
              color: ConstantColor.blueBackground,
              size: 24.0,
            ),
            const SizedBox(width: 8.0),
            googleSansText(
              text: "Restocked Item?",
              colors: ConstantColor.headingTextPrimary,
              fontWeight: FontWeight.bold,
              size: 18.0,
            ),
          ],
        ),
        content: googleSansText(
          text:
              "Would you like to record the new stock count for this item in the inventory now?",
          colors: ConstantColor.paragraphTextPrimary,
          fontWeight: FontWeight.normal,
          size: 14.5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: googleSansText(
              text: "Later",
              colors: ConstantColor.paragraphTextSecondary,
              fontWeight: FontWeight.bold,
              size: 14.0,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to Inventory page or just pop back to sidebar where they can select Inventory
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: googleSansText(
                    text:
                        "Please select 'Inventory' from the sidebar drawer to update stock counts.",
                    colors: Colors.white,
                    fontWeight: FontWeight.normal,
                    size: 14.0,
                  ),
                  backgroundColor: ConstantColor.blueBackground,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ConstantColor.blueBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 0.0,
            ),
            child: googleSansText(
              text: "Update Stock",
              colors: Colors.white,
              fontWeight: FontWeight.bold,
              size: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDueDate = DateTime.now().add(const Duration(days: 1));
    String selectedType = 'manual';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20.0,
                left: 16.0,
                right: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    googleSansText(
                      text: "Create New Task",
                      colors: ConstantColor.headingTextPrimary,
                      fontWeight: FontWeight.bold,
                      size: 20.0,
                    ),
                    const SizedBox(height: 20.0),

                    // Title
                    _buildTextField(
                      controller: titleController,
                      label: "Task Title",
                      hint: "e.g. Call supplier for bakery items",
                      icon: CupertinoIcons.tag_fill,
                    ),
                    const SizedBox(height: 14.0),

                    // Description
                    _buildTextField(
                      controller: descController,
                      label: "Description / Notes",
                      hint: "e.g. Ask for banana bread discount rates",
                      icon: CupertinoIcons.doc_text_fill,
                    ),
                    const SizedBox(height: 14.0),

                    // Due Date Selector
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setSheetState(() {
                            selectedDueDate = picked;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: const Color(0xFFE8E9EB)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.calendar,
                              color: ConstantColor.paragraphTextSecondary,
                              size: 18.0,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  googleSansText(
                                    text: "Due Date",
                                    colors:
                                        ConstantColor.paragraphTextSecondary,
                                    fontWeight: FontWeight.normal,
                                    size: 11.0,
                                  ),
                                  const SizedBox(height: 2.0),
                                  googleSansText(
                                    text: formatDate(selectedDueDate),
                                    colors: ConstantColor.headingTextPrimary,
                                    fontWeight: FontWeight.bold,
                                    size: 14.0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Task Type Selection Row
                    googleSansText(
                      text: "TASK TYPE",
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.bold,
                      size: 11.0,
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        _buildTypeChip(
                          'manual',
                          'General',
                          CupertinoIcons.square_list,
                          selectedType,
                          (type) {
                            setSheetState(() => selectedType = type);
                          },
                        ),
                        const SizedBox(width: 8.0),
                        _buildTypeChip(
                          'expense',
                          'Expense',
                          CupertinoIcons.creditcard,
                          selectedType,
                          (type) {
                            setSheetState(() => selectedType = type);
                          },
                        ),
                        const SizedBox(width: 8.0),
                        _buildTypeChip(
                          'invoice',
                          'Invoice',
                          CupertinoIcons.doc_text,
                          selectedType,
                          (type) {
                            setSheetState(() => selectedType = type);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: () async {
                          final title = titleController.text.trim();
                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: googleSansText(
                                  text: "Please enter a task title",
                                  colors: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  size: 14.0,
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          final task = Task(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            title: title,
                            description: descController.text.trim(),
                            dueDate: selectedDueDate,
                            type: selectedType,
                            createdAt: DateTime.now(),
                          );

                          await TasksRepository.instance.addTask(task);

                          // Schedule a notification alert for due date morning (e.g. 9:00 AM)
                          final notificationTime = DateTime(
                            selectedDueDate.year,
                            selectedDueDate.month,
                            selectedDueDate.day,
                            9,
                            0,
                          );
                          await NotificationService.instance
                              .scheduleNotification(
                                task.id,
                                "Task Due: ${task.title}",
                                task.description.isNotEmpty
                                    ? task.description
                                    : "This reminder is due today.",
                                notificationTime,
                              );

                          if (context.mounted) Navigator.pop(context);
                          _loadTasks();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ConstantColor.blueBackground,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 0.0,
                        ),
                        child: googleSansText(
                          text: "Create Task",
                          colors: Colors.white,
                          fontWeight: FontWeight.bold,
                          size: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFE8E9EB)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontFamily: "googleSans",
          fontSize: 15.0,
          color: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: "googleSans",
            color: ConstantColor.paragraphTextSecondary,
            fontSize: 13.0,
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: "googleSans",
            color: Color(0xFFBBBBBB),
            fontSize: 14.0,
          ),
          prefixIcon: Icon(
            icon,
            color: ConstantColor.paragraphTextSecondary,
            size: 18.0,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 6.0),
        ),
      ),
    );
  }

  Widget _buildTypeChip(
    String type,
    String label,
    IconData icon,
    String currentSelected,
    ValueChanged<String> onTap,
  ) {
    final isSelected = type == currentSelected;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 14.0,
        color: isSelected ? Colors.white : ConstantColor.paragraphTextSecondary,
      ),
      label: googleSansText(
        text: label,
        colors: isSelected ? Colors.white : ConstantColor.paragraphTextPrimary,
        fontWeight: FontWeight.bold,
        size: 12.0,
      ),
      selected: isSelected,
      selectedColor: ConstantColor.blueBackground,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected
            ? ConstantColor.blueBackground
            : const Color(0xFFE0E0E0),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      onSelected: (selected) {
        if (selected) onTap(type);
      },
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'inventory':
        return CupertinoIcons.archivebox_fill;
      case 'expense':
        return CupertinoIcons.creditcard_fill;
      case 'invoice':
        return CupertinoIcons.doc_text_fill;
      case 'sale':
        return CupertinoIcons.bag_fill;
      default:
        return CupertinoIcons.square_list_fill;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'inventory':
        return const Color(0xFFE65100); // Orange
      case 'expense':
        return const Color(0xFFC62828); // Red
      case 'invoice':
        return ConstantColor.blueBackground; // Blue
      case 'sale':
        return const Color(0xFF2E7D32); // Green
      default:
        return const Color(0xFF546E7A); // Grey
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingTasks = _tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = _tasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        leading: Navigator.canPop(context)
            ? null
            : IconButton(
                icon: const Icon(
                  CupertinoIcons.bars,
                  color: ConstantColor.headingTextPrimary,
                ),
                onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
              ),
        title: googleSansText(
          text: "Tasks & Reminders",
          colors: ConstantColor.headingTextPrimary,
          fontWeight: FontWeight.bold,
          size: 20.0,
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: ConstantColor.blueBackground,
          unselectedLabelColor: ConstantColor.paragraphTextSecondary,
          indicatorColor: ConstantColor.blueBackground,
          tabs: [
            Tab(
              child: googleSansText(
                text: "Pending (${pendingTasks.length})",
                fontWeight: FontWeight.bold,
                size: 14.0,
              ),
            ),
            Tab(
              child: googleSansText(
                text: "Completed (${completedTasks.length})",
                fontWeight: FontWeight.bold,
                size: 14.0,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        backgroundColor: ConstantColor.blueBackground,
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(pendingTasks),
                _buildTaskList(completedTasks),
              ],
            ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.checkmark_seal,
              size: 64.0,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 16.0),
            googleSansText(
              text: "No tasks to display",
              colors: ConstantColor.paragraphTextSecondary,
              fontWeight: FontWeight.bold,
              size: 16.0,
            ),
            const SizedBox(height: 4.0),
            googleSansText(
              text: "Tap the + button to add a task manually.",
              colors: ConstantColor.paragraphTextSecondary.withOpacity(0.7),
              fontWeight: FontWeight.normal,
              size: 13.0,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final typeColor = _getTypeColor(task.type);

        return Dismissible(
          key: Key(task.id),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) async {
            await TasksRepository.instance.deleteTask(task.id);
            await NotificationService.instance.cancelNotification(task.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: googleSansText(
                  text: "Task deleted",
                  colors: Colors.white,
                  size: 14.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            );
            _loadTasks();
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: const Icon(CupertinoIcons.trash, color: Colors.white),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.015),
                  blurRadius: 10.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              leading: GestureDetector(
                onTap: () => _toggleTaskCompletion(task),
                child: Container(
                  width: 24.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? ConstantColor.blueBackground
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted
                          ? ConstantColor.blueBackground
                          : const Color(0xFFCBD5E1),
                      width: 2.0,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(
                          CupertinoIcons.checkmark,
                          size: 14.0,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              title: googleSansText(
                text: task.title,
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 15.0,
                textAlign: TextAlign.left,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4.0),
                    googleSansText(
                      text: task.description,
                      colors: ConstantColor.paragraphTextSecondary,
                      fontWeight: FontWeight.normal,
                      size: 13.0,
                      textAlign: TextAlign.left,
                    ),
                  ],
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.calendar,
                        size: 12.0,
                        color: Colors.redAccent.withOpacity(0.8),
                      ),
                      const SizedBox(width: 4.0),
                      googleSansText(
                        text: "Due: ${formatDate(task.dueDate)}",
                        colors: Colors.redAccent.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        size: 11.5,
                      ),
                      const Spacer(),
                      // Type Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 3.0,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTypeIcon(task.type),
                              size: 10.0,
                              color: typeColor,
                            ),
                            const SizedBox(width: 4.0),
                            googleSansText(
                              text: task.type.toUpperCase(),
                              colors: typeColor,
                              fontWeight: FontWeight.bold,
                              size: 9.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
