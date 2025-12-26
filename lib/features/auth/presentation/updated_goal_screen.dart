import 'dart:async'; // FIX: for StreamSubscription
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:growme/features/auth/data/catogery_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/goal_repository.dart';

class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});
  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _picker = ImagePicker();
  File? _pickedImage;
  bool _loading = false;
  bool _isPickingImage = false;

  final _goalRepo = GoalRepository();
  final _catRepo = CategoryRepository();

  List<String> _categories = [];
  String _selectedCategory = 'Fitness';
  DateTime _deadline = DateTime.now().add(const Duration(days: 1));

  StreamSubscription<List<String>>? _catSub; // FIX

  @override
  void initState() {
    super.initState();
    _listenCategories();
  }

  void _listenCategories() {
    _catSub = _catRepo.streamAllCategories().listen(
      (cats) {
        if (!mounted) return;
        setState(() {
          _categories = cats;
          if (_categories.isNotEmpty &&
              !_categories.contains(_selectedCategory)) {
            _selectedCategory = _categories.first;
          }
        });
      },
      onError: (e) {
        debugPrint('Category stream error: $e');
      },
    );
  }

  Future<void> _pickImage() async {
    if (_loading || _isPickingImage) return;

    _isPickingImage = true;

    try {
      final XFile? f = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (f != null && mounted) {
        setState(() {
          _pickedImage = File(f.path);
        });
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _onSetGoalPressed() async {
    if (_loading) return; // FIX: prevent double submit

    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter goal title')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login')));
      return;
    }

    setState(() => _loading = true);

    try {
      final has = await _goalRepo.userHasActiveGoalToday(user.uid);
      if (has) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You already have an active goal today'),
          ),
        );
        setState(() => _loading = false);
        return;
      }

      if (!_categories.contains(_selectedCategory)) {
        await _catRepo.addCategoryIfNotExists(_selectedCategory);
      }

      final goal = await _goalRepo.createGoal(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imagePath: _pickedImage?.path,
        category: _selectedCategory,
        deadline: _deadline,
      );

      if (!mounted) return;

      setState(() => _loading = false);

      Navigator.pushNamed(context, '/goalSummary', arguments: goal);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // ---------------- UI (UNCHANGED) ----------------

  Widget _buildCategoryChips() {
    final chips = <Widget>[];

    for (final c in _categories) {
      final selected = c == _selectedCategory;
      chips.add(
        GestureDetector(
          onTap: () => setState(() => _selectedCategory = c),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: selected ? Colors.green : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.green.withOpacity(0.4)),
            ),
            child: Text(
              c,
              style: TextStyle(
                color: selected ? Colors.white : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    chips.add(
      GestureDetector(
        onTap: _showAddCategoryDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.green.withOpacity(0.4)),
          ),
          child: const Text(
            '+ Add',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: chips),
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add category'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(hintText: 'e.g., Meditation'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newCat = ctrl.text.trim();
                if (newCat.isNotEmpty) {
                  setState(() => _selectedCategory = newCat);
                  _catRepo.addCategoryIfNotExists(newCat);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _catSub?.cancel(); // FIX
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final softGreen = const Color(0xffEAF8ED);
    final mainGreen = const Color(0xff00CC66);
    return Scaffold(
      backgroundColor: const Color(0xfff7faf7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(fontSize: 18)),
                  ),
                  const Text(
                    'New Daily Goal',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: _onSetGoalPressed,
                    child: const Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // One goal per day card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: mainGreen.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: mainGreen.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'One goal per day',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'You can only have one active goal per day.',
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Goal Title',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _inputBox(
                hint: 'e.g., Run 5km in morning',
                controller: _titleCtrl,
              ),

              const SizedBox(height: 18),
              // Add photo (dashed border look)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: softGreen,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.green.withOpacity(0.25)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_camera,
                        size: 36,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add a Photo',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Optionally add an image to represent your goal',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          'Upload Image',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (_pickedImage != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _pickedImage!,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),
              const Text(
                'Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(height: 48, child: _buildCategoryChips()),

              const SizedBox(height: 18),
              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _bigInputBox(
                hint: 'Add details (optional)',
                controller: _descCtrl,
              ),

              const SizedBox(height: 18),
              const Text(
                'Deadline',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final dt = await showDatePicker(
                    context: context,
                    initialDate: _deadline,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (dt != null && mounted) setState(() => _deadline = dt);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        DateFormat.yMMMd().format(_deadline),
                        style: const TextStyle(color: Colors.green),
                      ),
                      const Spacer(),
                      const Icon(Icons.calendar_today, color: Colors.green),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // Set goal button
              GestureDetector(
                onTap: _onSetGoalPressed,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade400,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Set Goal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputBox({
    required String hint,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.25)),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }

  Widget _bigInputBox({
    required String hint,
    required TextEditingController controller,
  }) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.25)),
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }
}
