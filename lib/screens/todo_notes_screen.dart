import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/todo_note.dart';
import '../providers/todo_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import 'auth_screen.dart';

class TodoNotesScreen extends StatefulWidget {
  const TodoNotesScreen({super.key});

  @override
  State<TodoNotesScreen> createState() => _TodoNotesScreenState();
}

class _TodoNotesScreenState extends State<TodoNotesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<TodoProvider>().updateUser(auth.user?.uid);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditModal([TodoNote? todo]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddEditTodoSheet(todo: todo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final todoProvider = context.watch<TodoProvider>();

    // Keep user ID in sync with Auth
    if (authProvider.user?.uid != null) {
      todoProvider.updateUser(authProvider.user!.uid);
    }

    if (!authProvider.isAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Tasks & Floral Notes'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('📝', style: TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Cloud Tasks & Notes',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to access and sync your personal tasks, floral reminders, and notes across all your devices in real-time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthScreen(initialIsRegister: false)),
                    );
                  },
                  icon: const Icon(Icons.login, size: 18),
                  label: const Text('Sign In to Sync Notes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filteredList = todoProvider.filteredTodos;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tasks & Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded, color: AppColors.primary),
            tooltip: 'Add Task',
            onPressed: () => _showAddEditModal(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditModal(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('New Task', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 3,
      ),
      body: Column(
        children: [
          // Header Stats Card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('All Tasks', todoProvider.totalCount.toString(), Colors.white),
                Container(height: 28, width: 1, color: Colors.white24),
                _buildStatItem('In Progress', todoProvider.activeCount.toString(), AppColors.accentGoldLight),
                Container(height: 28, width: 1, color: Colors.white24),
                _buildStatItem('Completed', todoProvider.completedCount.toString(), const Color(0xFFB7E4C7)),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => todoProvider.setSearchQuery(val),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search tasks, tags, or notes...',
                hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          todoProvider.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filter Segmented Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All (${todoProvider.totalCount})',
                  isSelected: todoProvider.currentFilter == TodoFilter.all && todoProvider.priorityFilter == null,
                  onSelected: () {
                    todoProvider.setFilter(TodoFilter.all);
                    todoProvider.setPriorityFilter(null);
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Active (${todoProvider.activeCount})',
                  isSelected: todoProvider.currentFilter == TodoFilter.active,
                  onSelected: () => todoProvider.setFilter(TodoFilter.active),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Completed (${todoProvider.completedCount})',
                  isSelected: todoProvider.currentFilter == TodoFilter.completed,
                  onSelected: () => todoProvider.setFilter(TodoFilter.completed),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '🔥 High Priority',
                  isSelected: todoProvider.priorityFilter == TodoPriority.high,
                  onSelected: () {
                    if (todoProvider.priorityFilter == TodoPriority.high) {
                      todoProvider.setPriorityFilter(null);
                    } else {
                      todoProvider.setPriorityFilter(TodoPriority.high);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Todo List / Empty State
          Expanded(
            child: todoProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : filteredList.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 48,
                                  color: AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'No tasks found',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                todoProvider.searchQuery.isNotEmpty
                                    ? 'Try adjusting your search or filter'
                                    : 'Tap + New Task to create your first note or reminder',
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: filteredList.length,
                        itemBuilder: (ctx, index) {
                          final todo = filteredList[index];
                          return _TodoCard(
                            todo: todo,
                            onToggle: (val) => todoProvider.toggleTodoStatus(todo.id, val ?? false),
                            onEdit: () => _showAddEditModal(todo),
                            onDelete: () => _confirmDelete(context, todo),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TodoNote todo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Task', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TodoProvider>().deleteTodo(todo.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _TodoCard extends StatelessWidget {
  final TodoNote todo;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TodoCard({
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final isOverdue = todo.dueDate != null &&
        todo.dueDate!.isBefore(DateTime.now()) &&
        !todo.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: todo.isCompleted
              ? AppColors.borderLight
              : isOverdue
                  ? AppColors.accentRose.withValues(alpha: 0.5)
                  : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Completion Checkbox
                Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: todo.isCompleted,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    onChanged: onToggle,
                  ),
                ),
                const SizedBox(width: 8),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges Row
                      Row(
                        children: [
                          _buildPriorityBadge(todo.priority),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              todo.category,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        todo.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: todo.isCompleted ? AppColors.textLight : AppColors.textPrimary,
                          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),

                      // Description
                      if (todo.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          todo.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: todo.isCompleted ? AppColors.textLight : AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],

                      // Due Date
                      if (todo.dueDate != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: isOverdue ? AppColors.error : AppColors.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Due: ${dateFormat.format(todo.dueDate!)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                                color: isOverdue ? AppColors.error : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Action Menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textLight),
                  onSelected: (val) {
                    if (val == 'edit') onEdit();
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 16),
                          SizedBox(width: 8),
                          Text('Edit Task'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(TodoPriority priority) {
    Color bg;
    Color fg;
    String label;

    switch (priority) {
      case TodoPriority.high:
        bg = AppColors.accentRoseLight;
        fg = const Color(0xFFC93B38);
        label = 'High';
        break;
      case TodoPriority.medium:
        bg = AppColors.accentGoldLight;
        fg = AppColors.accentGold;
        label = 'Medium';
        break;
      case TodoPriority.low:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        label = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _AddEditTodoSheet extends StatefulWidget {
  final TodoNote? todo;

  const _AddEditTodoSheet({this.todo});

  @override
  State<_AddEditTodoSheet> createState() => _AddEditTodoSheetState();
}

class _AddEditTodoSheetState extends State<_AddEditTodoSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TodoPriority _priority;
  late String _category;
  DateTime? _dueDate;
  bool _isLoading = false;

  final List<String> _categories = [
    'Floral Reminder',
    'Gift Planning',
    'Special Occasion',
    'Personal',
    'Work',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descController = TextEditingController(text: widget.todo?.description ?? '');
    _priority = widget.todo?.priority ?? TodoPriority.medium;
    _category = widget.todo?.category ?? 'Floral Reminder';
    _dueDate = widget.todo?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final todoProvider = context.read<TodoProvider>();

    bool success;
    if (widget.todo == null) {
      success = await todoProvider.addTodo(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _priority,
        category: _category,
        dueDate: _dueDate,
      );
    } else {
      success = await todoProvider.updateTodo(
        todoId: widget.todo!.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _priority,
        category: _category,
        dueDate: _dueDate,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.todo == null ? 'Task added!' : 'Task updated!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.todo != null;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Task' : 'New Task / Note',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Title Field
              TextFormField(
                controller: _titleController,
                autofocus: true,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  labelText: 'Task Title *',
                  hintText: 'e.g. Order Orchid Bouquet for Mom',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 14),

              // Description Field
              TextFormField(
                controller: _descController,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Notes / Description (Optional)',
                  hintText: 'Add details, recipient preferences, ribbon color...',
                ),
              ),
              const SizedBox(height: 16),

              // Category & Priority Row
              Row(
                children: [
                  // Category Dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Priority Dropdown
                  Expanded(
                    child: DropdownButtonFormField<TodoPriority>(
                      initialValue: _priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: const [
                        DropdownMenuItem(value: TodoPriority.low, child: Text('🟢 Low', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: TodoPriority.medium, child: Text('🟡 Medium', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: TodoPriority.high, child: Text('🔴 High', style: TextStyle(fontSize: 13))),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _priority = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Due Date Picker Button
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
                title: Text(
                  _dueDate == null
                      ? 'No due date set'
                      : 'Due: ${DateFormat('EEE, MMM d, yyyy').format(_dueDate!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: _dueDate == null ? AppColors.textSecondary : AppColors.textPrimary,
                    fontWeight: _dueDate == null ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
                trailing: _dueDate != null
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _dueDate = null),
                      )
                    : TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dueDate ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() => _dueDate = picked);
                          }
                        },
                        child: const Text('Pick Date'),
                      ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        isEditing ? 'Save Changes' : 'Create Task',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
