import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_travel/injection_container.dart' as di;
import 'package:smart_travel/presentation/blocs/review/submit_review_bloc.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';

import '../../blocs/review/submit_review_event.dart';
import '../../blocs/review/submit_review_state.dart';

class ReviewSubmitScreen extends StatefulWidget {
  final String invoiceNumber;
  final String serviceName; // ← Thêm để hiển thị tên hotel/tour

  const ReviewSubmitScreen({
    Key? key,
    required this.invoiceNumber,
    required this.serviceName,
  }) : super(key: key);

  @override
  State<ReviewSubmitScreen> createState() => _ReviewSubmitScreenState();
}

class _ReviewSubmitScreenState extends State<ReviewSubmitScreen> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  List<XFile> _images = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile> picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _images.addAll(picked);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đánh giá trải nghiệm"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
      ),
      body: BlocProvider(
        create: (_) => di.sl<SubmitReviewBloc>(),
        child: BlocConsumer<SubmitReviewBloc, SubmitReviewState>(
          listener: (context, state) {
            if (state is SubmitReviewSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Gửi đánh giá thành công! Cảm ơn bạn ❤️"),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            }
            if (state is SubmitReviewError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === KHUNG TÊN + MÃ ĐẶT CHỖ ===
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.serviceName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Mã đặt chỗ: ${widget.invoiceNumber}",
                              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // === ĐÁNH GIÁ SAO – CĂN TRÁI ===
                      const Text("Đánh giá của bạn", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () => setState(() => _rating = index + 1),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                index < _rating ? Icons.star : Icons.star_border,
                                size: 40,
                                color: Colors.amber,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),

                      // === VIẾT NHẬN XÉT ===
                      const Text("Viết nhận xét", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _commentController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: "Chia sẻ trải nghiệm của bạn...",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // === THÊM ẢNH ===
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Thêm ảnh", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ElevatedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text("Chọn ảnh"),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_images.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: FileImage(File(_images[index].path)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),


                if (state is! SubmitReviewLoading)
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: ElevatedButton(
                      onPressed: _rating > 0
                          ? () {
                        context.read<SubmitReviewBloc>().add(
                          SubmitReview(
                            rating: _rating,
                            comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
                            invoiceNumber: widget.invoiceNumber,
                            images: _images,
                          ),
                        );
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Gửi đánh giá",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),

                // Loading overlay
                if (state is SubmitReviewLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}