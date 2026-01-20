import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';

import 'package:smart_travel/data/models/tour/admin_tour_model.dart';
import 'package:smart_travel/presentation/blocs/adminTour/tour_bloc.dart';
import 'package:smart_travel/presentation/blocs/adminTour/tour_event.dart';
import 'package:smart_travel/presentation/blocs/adminTour/tour_state.dart';
import 'package:smart_travel/presentation/blocs/adminTour/tour_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/adminTour/tour_detail_event.dart';
import 'package:smart_travel/presentation/blocs/adminTour/tour_detail_state.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';

class AdminTourUpdateModal extends StatefulWidget {
  final AdminTourModel tour;

  const AdminTourUpdateModal({super.key, required this.tour});

  @override
  State<AdminTourUpdateModal> createState() => _AdminTourUpdateModalState();
}

class _AdminTourUpdateModalState extends State<AdminTourUpdateModal> {
  final _formKey = GlobalKey<FormState>();
  int? selectedPrimaryImageId;

  // Colors & Styles
  final Color primaryColor = const Color(0xFF0066CC); // Màu chủ đạo (Xanh dương)
  final InputDecorationTheme inputTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF0066CC), width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  // ===== BASIC =====
  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController daysCtrl;
  late TextEditingController nightsCtrl;
  late TextEditingController maxPeopleCtrl;
  late TextEditingController minPeopleCtrl;
  late List images;
  bool isActive = true;

  // ===== DESCRIPTION =====
  late QuillController quillCtrl;

  // ===== IMAGES =====
  final List<File> newImages = [];

  // ===== SCHEDULE =====
  final List<_ScheduleItem> schedules = [];

  // ===== INCLUDED / EXCLUDED =====
  final List<TextEditingController> includedCtrls = [];
  final List<TextEditingController> excludedCtrls = [];

  @override
  void initState() {
    super.initState();
    final t = widget.tour;
    selectedPrimaryImageId =
        widget.tour.images.firstWhere(
              (e) => e.isPrimary == true,
          orElse: () => widget.tour.images.first,
        ).id;

    nameCtrl = TextEditingController(text: t.name);
    priceCtrl = TextEditingController(text: t.pricePerPerson.toString());
    daysCtrl = TextEditingController(text: t.durationDays.toString());
    nightsCtrl = TextEditingController(text: t.durationNights.toString());
    maxPeopleCtrl = TextEditingController(text: t.maxPeople.toString());
    minPeopleCtrl = TextEditingController(text: t.minPeople.toString());
    isActive = t.isActive;
    images = List.from(widget.tour.images);

    // ===== DESCRIPTION =====
    try {
      quillCtrl = QuillController(
        document: Document.fromJson(jsonDecode(t.description ?? '[]')),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (_) {
      quillCtrl = QuillController.basic();
      quillCtrl.document.insert(0, t.description ?? '');
    }

    // ===== SCHEDULE =====
    if (t.schedules.isNotEmpty) {
      for (final s in t.schedules) {
        schedules.add(_ScheduleItem(
          title: s.title,
          activities: s.activities,
          accommodation: s.accommodation,
          meals: s.meals,
        ));
      }
    } else {
      schedules.add(_ScheduleItem());
    }

    // ===== INCLUDED / EXCLUDED =====
    if (t.included != null) {
      for (var i in t.included) {
        includedCtrls.add(TextEditingController(text: i.toString()));
      }
    }
    if (t.excluded != null) {
      for (var i in t.excluded) {
        excludedCtrls.add(TextEditingController(text: i.toString()));
      }
    }

    if (includedCtrls.isEmpty) includedCtrls.add(TextEditingController());
    if (excludedCtrls.isEmpty) excludedCtrls.add(TextEditingController());
  }

  // ================= ACTION: PICK IMAGES =================
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files != null) {
      setState(() {
        newImages.addAll(files.map((e) => File(e.path)));
      });
    }
  }

  // ================= ACTION: SUBMIT =================
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final description = quillCtrl.document.toPlainText().trim();
    if (description.isEmpty) {
      _showErrorSnackBar('Mô tả không được để trống');
      return;
    }

    if (schedules.any((s) => s.title.text.trim().isEmpty)) {
      _showErrorSnackBar('Tiêu đề lịch trình các ngày không được để trống');
      return;
    }

    // DATA PREPARATION
    final data = {
      "name": nameCtrl.text.trim(),
      "pricePerPerson": double.tryParse(priceCtrl.text) ?? 0,
      "durationDays": int.tryParse(daysCtrl.text) ?? 1,
      "durationNights": int.tryParse(nightsCtrl.text) ?? 0,
      "minPeople": int.tryParse(minPeopleCtrl.text) ?? 0,
      "maxPeople": int.tryParse(maxPeopleCtrl.text) ?? 0,
      "description": description,
      "isActive": isActive,

      // --- QUAN TRỌNG: Gửi lại danh sách ảnh cũ để BE không xóa nhầm ---
      "images": images.map((img) => {
        "id": img.id,
        "imageUrl": img.imageUrl,
        "isPrimary": img.id == selectedPrimaryImageId,
        "displayOrder": img.displayOrder,
      }).toList(),

      "schedules": List.generate(schedules.length, (i) {
        final s = schedules[i];
        return {
          "dayNumber": i + 1,
          "title": s.title.text.trim(),
          "activities": s.activities.text.trim(),
          "accommodation": s.accommodation.text.trim(),
          "meals": s.meals.text.trim(),
        };
      }),
      "included": includedCtrls.map((e) => e.text).where((e) => e.isNotEmpty).toList(),
      "excluded": excludedCtrls.map((e) => e.text).where((e) => e.isNotEmpty).toList(),
    };

    // CALL BLOC
    context.read<AdminTourDetailBloc>().add(
      UpdateAdminTourDetail(widget.tour.id, data),
    );
  }

  // ================= UI BUILD =================
  @override
  Widget build(BuildContext context) {
    // Sử dụng Theme cục bộ để áp dụng style cho Input
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: inputTheme,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      ),
      child: BlocListener<AdminTourDetailBloc, AdminTourDetailState>(
        listener: (context, state) {
          if (state is AdminTourUpdateSuccess) {
            _showSuccessDialog(); // HIỂN THỊ DIALOG THÀNH CÔNG ĐẸP
          }
          if (state is AdminTourDetailError) {
            _showErrorSnackBar(state.message ?? 'Cập nhật thất bại');
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[50], // Nền sáng
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(gradient: AppColors.mainGradient),
            ),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Cập nhật Tour', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            centerTitle: true,
            // ĐÃ XÓA ACTION NÚT LƯU Ở ĐÂY THEO YÊU CẦU
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionContainer(
                    title: 'Thông tin chung',
                    icon: Icons.info_outline,
                    child: Column(
                      children: [
                        _buildTextField('Tên tour', nameCtrl, validator: (v) => requiredText(v, 'Tên tour')),
                        const SizedBox(height: 12),
                        _buildTextField('Giá / người (VND)', priceCtrl, keyboard: TextInputType.number, validator: (v) => requiredDouble(v, 'Giá', min: 1000)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildTextField('Số ngày', daysCtrl, keyboard: TextInputType.number)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField('Số đêm', nightsCtrl, keyboard: TextInputType.number, required: false)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildTextField('Min khách', minPeopleCtrl, keyboard: TextInputType.number)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField('Max khách', maxPeopleCtrl, keyboard: TextInputType.number, validator: (v) => validateMaxPeople(v, minPeopleCtrl))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Đang hoạt động (Active)', style: TextStyle(fontWeight: FontWeight.w500)),
                          activeColor: primaryColor,
                          value: isActive,
                          onChanged: (v) => setState(() => isActive = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  _buildSectionContainer(
                    title: 'Thư viện ảnh',
                    icon: Icons.image_outlined,
                    child: _buildImageSection(),
                  ),

                  const SizedBox(height: 16),
                  _buildSectionContainer(
                    title: 'Mô tả chi tiết',
                    icon: Icons.description_outlined,
                    child: Column(
                      children: [
                        QuillSimpleToolbar(
                          controller: quillCtrl,
                          configurations: const QuillSimpleToolbarConfigurations(
                            showFontFamily: false,
                            showFontSize: false,
                          ),
                        ),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: QuillEditor.basic(
                            controller: quillCtrl,
                            configurations: const QuillEditorConfigurations(
                              padding: EdgeInsets.all(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  _buildSectionContainer(
                    title: 'Lịch trình tour',
                    icon: Icons.calendar_month_outlined,
                    child: _buildScheduleSection(),
                  ),

                  const SizedBox(height: 16),
                  _buildSectionContainer(
                    title: 'Dịch vụ bao gồm (Included)',
                    icon: Icons.check_circle_outline,
                    child: _buildDynamicList(includedCtrls, 'Ví dụ: Vé máy bay, Ăn sáng...'),
                  ),

                  const SizedBox(height: 16),
                  _buildSectionContainer(
                    title: 'Không bao gồm (Excluded)',
                    icon: Icons.cancel_outlined,
                    child: _buildDynamicList(excludedCtrls, 'Ví dụ: Thuế VAT, Tiền TIP...'),
                  ),

                  const SizedBox(height: 40), // Bottom padding

                  // ================= NÚT LƯU DUY NHẤT Ở CUỐI =================
                  BlocBuilder<AdminTourDetailBloc, AdminTourDetailState>(
                    builder: (context, state) {
                      final loading = state is AdminTourUpdateLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('CẬP NHẬT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= CUSTOM WIDGETS =================

  Widget _buildSectionContainer({required String title, required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl,
      {bool required = true, TextInputType keyboard = TextInputType.text, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      validator: validator ?? (required ? (v) => v == null || v.isEmpty ? 'Nhập $label' : null : null),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _pickImages,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: primaryColor, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
              color: primaryColor.withOpacity(0.05),
            ),
            child: Column(
              children: [
                Icon(Icons.add_photo_alternate_outlined, color: primaryColor, size: 30),
                const SizedBox(height: 4),
                Text('Thêm ảnh', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (widget.tour.images.isEmpty && newImages.isEmpty)
          const Center(child: Text('Chưa có hình ảnh nào', style: TextStyle(color: Colors.grey))),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // --- ẢNH CŨ (SERVER) ---
            ...images.map((img) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPrimaryImageId = img.id;
                      });
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedPrimaryImageId == img.id
                              ? Colors.green
                              : Colors.grey[300]!,
                          width: selectedPrimaryImageId == img.id ? 3 : 1,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(img.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  if (selectedPrimaryImageId == img.id)
                    Positioned(bottom: 0, left: 0, right: 0, child: Container(color: Colors.green, padding: const EdgeInsets.all(2), child: const Text('ẢNH BÌA', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
                  Positioned(
                    top: -5,
                    right: -5,
                    child: InkWell(
                      onTap: () {
                        if (img.id == selectedPrimaryImageId) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Không thể xoá ảnh đang làm ảnh bìa"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        setState(() {
                          images.removeWhere((e) => e.id == img.id);
                        });
                      },
                      child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)),
                    ),
                  ),
                ],
              );
            }),
            // --- ẢNH MỚI (LOCAL) ---
            ...newImages.map((file) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryColor, width: 2),
                      image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(top: -5, right: -5, child: InkWell(onTap: () => setState(() => newImages.remove(file)), child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)))),
                ],
              );
            }),
          ],
        )
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: schedules.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final s = schedules[i];
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: ExpansionTile(
                title: Text('Ngày ${i + 1}: ${s.title.text.isNotEmpty ? s.title.text : "(Chưa có tiêu đề)"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                childrenPadding: const EdgeInsets.all(16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Tiêu đề ngày', s.title),
                  const SizedBox(height: 8),
                  _buildTextField('Hoạt động chính', s.activities, required: false),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _buildTextField('Chỗ ở', s.accommodation, required: false)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTextField('Bữa ăn', s.meals, required: false)),
                  ]),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => setState(() => schedules.removeAt(i)),
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      label: const Text('Xóa ngày này', style: TextStyle(color: Colors.red)),
                    ),
                  )
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => schedules.add(_ScheduleItem())),
            icon: const Icon(Icons.add),
            label: const Text('Thêm ngày lịch trình'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicList(List<TextEditingController> ctrls, String hint) {
    return Column(
      children: [
        ...List.generate(ctrls.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: ctrls[i],
                    decoration: InputDecoration(hintText: hint, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () => setState(() => ctrls.removeAt(i)),
                )
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () => setState(() => ctrls.add(TextEditingController())),
          icon: Icon(Icons.add, color: primaryColor),
          label: Text('Thêm dòng mới', style: TextStyle(color: primaryColor)),
        )
      ],
    );
  }

  // ================= FEEDBACK DIALOG =================

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon thành công
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Cập nhật thành công!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    text: 'Tour ',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                    children: [
                      TextSpan(text: nameCtrl.text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      const TextSpan(text: ' đã được lưu vào hệ thống.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Đóng Dialog
                      Navigator.of(context).pop(true); // Đóng Modal cập nhật
                      context.read<AdminTourBloc>().add(LoadAdminTours()); // Load lại danh sách
                    },
                    child: const Text('HOÀN TẤT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [const Icon(Icons.error_outline, color: Colors.white), const SizedBox(width: 8), Expanded(child: Text(msg))]),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ===== PRIVATE =====
class _ScheduleItem {
  final TextEditingController title;
  final TextEditingController activities;
  final TextEditingController accommodation;
  final TextEditingController meals;

  _ScheduleItem({
    String? title,
    String? activities,
    String? accommodation,
    String? meals,
  })  : title = TextEditingController(text: title ?? ''),
        activities = TextEditingController(text: activities ?? ''),
        accommodation = TextEditingController(text: accommodation ?? ''),
        meals = TextEditingController(text: meals ?? '');
}

// ===== VALIDATORS =====
String? requiredText(String? v, String label) {
  if (v == null || v.trim().isEmpty) {
    return '$label không được để trống';
  }
  return null;
}

String? requiredInt(String? v, String label, {int min = 1}) {
  if (v == null || v.trim().isEmpty) {
    return '$label không được để trống';
  }
  final value = int.tryParse(v);
  if (value == null) {
    return '$label phải là số nguyên';
  }
  if (value < min) {
    return '$label phải ≥ $min';
  }
  return null;
}

String? requiredDouble(String? v, String label, {double min = 0}) {
  if (v == null || v.trim().isEmpty) {
    return '$label không được để trống';
  }
  final value = double.tryParse(v);
  if (value == null) {
    return '$label phải là số';
  }
  if (value <= min) {
    return '$label phải > $min';
  }
  return null;
}

String? validateMaxPeople(
    String? v,
    TextEditingController minCtrl,
    ) {
  if (v == null || v.trim().isEmpty) {
    return 'Số khách tối đa không được để trống';
  }

  final max = int.tryParse(v);
  if (max == null) {
    return 'Số khách tối đa phải là số';
  }

  final min = int.tryParse(minCtrl.text);
  if (min != null && max < min) {
    return 'Số khách tối đa phải ≥ số khách tối thiểu';
  }

  return null;
}