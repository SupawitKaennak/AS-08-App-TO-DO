import 'package:flutter/material.dart'; 
import 'package:provider/provider.dart'; 
import '../providers/todo_provider.dart'; 
import '../models/todo.dart';
import '../widgets/todo_card.dart';
 
class HomeScreen extends StatefulWidget { 
  const HomeScreen({super.key}); 
 
  @override 
  State<HomeScreen> createState() => _HomeScreenState(); 
} 
 
class _HomeScreenState extends State<HomeScreen> { 
  final _controller = TextEditingController();
  final _descriptionController = TextEditingController();
 
  // โหมดเลือกหลายรายการ 
  bool _selectionMode = false; 
  final Set<int> _selectedIds = {}; 
 
  @override 
  void dispose() { 
    _controller.dispose(); 
    super.dispose(); 
  } 
 
  Future<void> _showAddDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('เพิ่มงานใหม่'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'ชื่องาน',
                hintText: 'ใส่ชื่องาน',
                border: OutlineInputBorder(),
                // เพิ่ม style สำหรับ label และ hint
                labelStyle: TextStyle(fontSize: 16),
                hintStyle: TextStyle(fontSize: 16),
              ),
              // เพิ่ม style สำหรับตัวอักษรที่พิมพ์
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'รายละเอียด (ไม่บังคับ)',
                hintText: 'ใส่รายละเอียดงาน',
                border: OutlineInputBorder(),
                // เพิ่ม style สำหรับ label และ hint
                labelStyle: TextStyle(fontSize: 16),
                hintStyle: TextStyle(fontSize: 16),
              ),
              // เพิ่ม style สำหรับตัวอักษรที่พิมพ์
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                Navigator.pop(context, {
                  'title': title,
                  'description': descController.text.trim(),
                });
              }
            },
            child: const Text('เพิ่ม'),
          ),
        ],
      ),
    );

    if (result != null) {
      if (!mounted) return;
      await context.read<TodoProvider>().addTodo(
        result['title']!,
        description: result['description']!,
      );
    }
  }

  Future<void> _showEditDialog(Todo todo) async {
    final titleController = TextEditingController(text: todo.title);
    final descController = TextEditingController(text: todo.description);
    
    final result = await showDialog<Map<String, String>>( 
      context: context, 
      builder: (_) => AlertDialog( 
        title: const Text('แก้ไขงาน'), 
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField( 
              controller: titleController, 
              autofocus: true,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration( 
                labelText: 'ชื่องาน',
                hintText: 'พิมพ์ชื่องาน', 
                border: OutlineInputBorder(),
                labelStyle: TextStyle(fontSize: 16),
                hintStyle: TextStyle(fontSize: 16),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField( 
              controller: descController,
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration( 
                labelText: 'รายละเอียด',
                hintText: 'พิมพ์รายละเอียดงาน', 
                border: OutlineInputBorder(),
                labelStyle: TextStyle(fontSize: 16),
                hintStyle: TextStyle(fontSize: 16),
              ),
              style: const TextStyle(fontSize: 16), 
            ),
          ],
        ),
        actions: [ 
          TextButton( 
            onPressed: () => Navigator.pop(context), 
            child: const Text('ยกเลิก'), 
          ), 
          FilledButton( 
            onPressed: () => Navigator.pop(context, {
              'title': titleController.text.trim(),
              'description': descController.text.trim(),
            }), 
            child: const Text('บันทึก'), 
          ), 
        ], 
      ), 
    ); 
    if (result != null && result['title']!.isNotEmpty) { 
      if (!mounted) return; // ป้องกัน context หลัง await 
      await context.read<TodoProvider>().editTodo(
        todo,
        newTitle: result['title'],
        newDescription: result['description'],
      ); 
    } 
  } 
 
  void _enterSelectionMode([Todo? first]) { 
    setState(() { 
      _selectionMode = true; 
      _selectedIds.clear(); 
      if (first?.id != null) _selectedIds.add(first!.id!); 
    }); 
  } 
 
  void _exitSelectionMode() { 
    setState(() { 
      _selectionMode = false; 
      _selectedIds.clear(); 
    }); 
  } 
 
  void _toggleSelection(Todo todo) { 
    final id = todo.id; 
    if (id == null) return; 
    setState(() { 
      if (_selectedIds.contains(id)) { 
        _selectedIds.remove(id); 
      } else { 
        _selectedIds.add(id); 
      } 
      if (_selectedIds.isEmpty) { 
        _selectionMode = false; 
      } 
    }); 
  } 
 
  Future<void> _deleteSelected() async { 
    if (_selectedIds.isEmpty) return; 
 
    final provider = context.read<TodoProvider>(); 
    final count = _selectedIds.length; 
 
    final confirm = await showDialog<bool>( 
      context: context, 
      builder: (_) => AlertDialog( 
        title: const Text('ลบรายการที่เลือก?'), 
        content: Text('ต้องการลบ $count รายการที่เลือกหรือไม่'), 
        actions: [ 
          TextButton( 
            onPressed: () => Navigator.pop(context, false), 
            child: const Text('ยกเลิก'), 
          ), 
          FilledButton( 
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('ลบ'), 
          ), 
        ], 
      ), 
    ); 
 
    if (confirm == true) { 
      // ลบทีละตัวผ่ำน provider 
      // (ถ้ำต้องกำรเร็วขึ ้น อนำคตท ำฟังก์ชัน bulk delete ใน provider/db) 
      final items = List<Todo>.from(provider.items); 
      for (final t in items) { 
        if (t.id != null && _selectedIds.contains(t.id)) { 
          await provider.deleteTodo(t); 
        } 
      } 
      if (!mounted) return; 
      _exitSelectionMode(); 
    } 
  } 
 
  @override 
  Widget build(BuildContext context) { 
    final provider = context.watch<TodoProvider>(); 
 
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar( 
        backgroundColor: const Color(0xFFB5C7E3), // สีฟ้าพาสเทล
        foregroundColor: Colors.white,
        title: _selectionMode 
            ? Text('เลือกแล้ว ${_selectedIds.length} รายการ') 
            : const Text('รายการสิ่งที่ต้องทำ'), 
        leading: _selectionMode 
            ? IconButton( 
                tooltip: 'ยกเลิก', 
                icon: const Icon(Icons.close), 
                onPressed: _exitSelectionMode, 
              ) 
            : null, 
        actions: [ 
          if (_selectionMode) ...[ 
            IconButton( 
              tooltip: 'ลบที่เลือก', 
              onPressed: _selectedIds.isEmpty ? null : _deleteSelected, 
              icon: const Icon(Icons.delete), 
            ), 
          ] else ...[ 
            // ปุ ่มเข้ำโหมดเลือก (แทนที ่จะมี "ลบทั ้งหมด") 
            IconButton( 
              tooltip: 'เลือกรายการ', 
              icon: const Icon(Icons.checklist), 
              onPressed: provider.items.isEmpty 
                  ? null 
                  : () => _enterSelectionMode(), 
            ), 
            // ถ้ำยังอยำกเก็บ "ลบทั ้งหมด" ไว้ ให้ซ่อนไว้ในเมนูสำมจุด 
            PopupMenuButton<String>( 
              onSelected: (value) async { 
                // หลีกเลี ่ยงกำรใช้ context หลัง async โดยเก็บ provider ไว้ก่อน 
                final provider = context.read<TodoProvider>(); 
                 
                if (value == 'clear_all' && provider.items.isNotEmpty) { 
                  final confirm = await showDialog<bool>( 
                    context: context, 
                    builder: (_) => AlertDialog( 
                      title: const Text('ลบทั้งหมด?'), 
                      content: const Text('ต้องกำรลบงานทั้งหมดหรือไม่'), 
                      actions: [ 
                        TextButton( 
                          onPressed: () => Navigator.pop(context, false), 
                          child: const Text('ยกเลิก'), 
                        ), 
                        FilledButton( 
                          onPressed: () => Navigator.pop(context, true), 
                          child: const Text('ลบทั้งหมด'), 
                        ), 
                      ], 
                    ), 
                  ); 
                  if (confirm == true) { 
                    if (!mounted) return; // เช็คว่ำ State ยังอยู่ 
                    await provider.clearAll(); // ใช้ provider ที ่เก็บไว้ 
                  } 
                } 
              }, 
              itemBuilder: (_) => [ 
                const PopupMenuItem( 
                  value: 'clear_all', 
                  child: Text('ลบทั้งหมด'), 
                ), 
              ], 
            ), 
          ], 
        ], 
      ), 
      body: Column( 
        children: [ 
          // ที่ว่างไว้สำหรับเพิ่มคอนเทนต์อื่นๆ ในอนาคต 
          Expanded( 
            child: provider.isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : provider.items.isEmpty 
                ? const Center( 
                    child: Text('ยังไม่มีงาน ใส่ชื่องานด้านบนแล้วกด "เพิ่ม"'), 
                  ) 
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.items.length,
                    itemBuilder: (context, index) {
                      final todo = provider.items[index];
                      final id = todo.id;
                      final selected = id != null && _selectedIds.contains(id);

                      Widget tile = TodoCard(
                        todo: todo,
                        isSelected: selected,
                        onTap: () {
                          if (_selectionMode) {
                            _toggleSelection(todo);
                          } else {
                            context.read<TodoProvider>().toggleDone(todo);
                          }
                        },
                        onLongPress: () => _enterSelectionMode(todo),
                        onCheckboxChanged: (_) {
                          if (_selectionMode) {
                            _toggleSelection(todo);
                          } else {
                            context.read<TodoProvider>().toggleDone(todo);
                          }
                        },
                      );                      // คงควำมสำมำรถ "ปัดซ้ำยเพื ่อลบรำยบุคคล" (เฉพำะตอนที ่ไม่ได้อยู่ในโหมดเลือก) 
                      if (_selectionMode) { 
                        return tile; 
                      } else { 
                        return Dismissible( 
                          key: ValueKey(id ?? '${todo.title}-$index'), 
                          direction: DismissDirection.endToStart, 
                          background: Container( 
                            alignment: Alignment.centerRight, 
                            padding: const EdgeInsets.symmetric(horizontal: 16), 
                            color: Colors.red, 
                            child: const Icon( 
                              Icons.delete, 
                              color: Colors.white, 
                            ), 
                          ), 
                          confirmDismiss: (_) async { 
                            final ok = await showDialog<bool>( 
                              context: context, 
                              builder: (_) => AlertDialog( 
                                title: const Text('ลบงานนี้หรือไม่?'), 
                                content: Text(todo.title), 
                                actions: [ 
                                  TextButton( 
                                    onPressed: () => 
                                        Navigator.pop(context, false), 
                                    child: const Text('ยกเลิก'), 
                                  ), 
                                  FilledButton( 
                                    onPressed: () => 
                                        Navigator.pop(context, true), 
                                    child: const Text('ลบ'), 
                                  ), 
                                ], 
                              ), 
                            ); 
                            return ok ?? false; 
                          }, 
                          onDismissed: (_) => 
                              context.read<TodoProvider>().deleteTodo(todo), 
                          child: tile, 
                        ); 
                      } 
                    }, 
                  ), 
          ), 
        ], 
      ), 
    ); 
  } 
} 