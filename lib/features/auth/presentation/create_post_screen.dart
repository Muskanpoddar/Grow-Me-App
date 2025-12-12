import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:growme/features/auth/data/post_repository.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final captionCtrl = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  bool loading = false;

  final repo = PostRepository();

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (captionCtrl.text.trim().isEmpty && _image == null) return;

    setState(() => loading = true);

    try {
      await repo.createPost(
        caption: captionCtrl.text.trim(),
        imageFile: _image,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const softBorder = Color(0xffD8E8D8);
    const dashedBorder = Color(0xffC8E5C8);
    const cardGreen = Color(0xffEAF8ED);
    const mainGreen = Color(0xff00CC66);
    const buttonGreen = Color(0xff00E676);

    return Scaffold(
      backgroundColor: const Color(0xffF5F8F5),

      // ---------------------- Top App Bar ----------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create Post",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: loading ? null : _submit,
            child: const Text(
              "Post",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: mainGreen,
              ),
            ),
          ),
        ],
      ),

      // ---------------------- BODY CONTENT ----------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Caption Label
            const Text(
              "Caption",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),

            // Caption Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: softBorder, width: 1.4),
              ),
              child: TextField(
                controller: captionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Write something...",
                  hintStyle: TextStyle(color: Colors.black38),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ---------------- Upload Box (Dashed Border) ----------------
            CustomPaint(
              painter: DashedBorderPainter(color: dashedBorder),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: cardGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.camera_alt_rounded,
                      size: 48,
                      color: mainGreen,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Add Photo or Video",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Optionally attach a photo to your post.",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    const SizedBox(height: 20),

                    // Upload Button
                    ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffDFF7E7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.upload, color: Colors.black),
                            SizedBox(width: 8),
                            Text(
                              "Upload Image",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Preview Image
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(
                  _image!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 40),

            // ---------------- Bottom Post Button ----------------
            GestureDetector(
              onTap: loading ? null : _submit,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: buttonGreen,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Center(
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Post",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------
// Dashed Border Painter
// -----------------------------
class DashedBorderPainter extends CustomPainter {
  final Color color;
  DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6;
    const dashSpace = 6;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(20),
    );

    final path = Path()..addRRect(rect);
    final dashPath = Path();

    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0;
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
