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

class AdminTourUpdateModal extends StatefulWidget {
  final AdminTourModel tour;

  const AdminTourUpdateModal({super.key, required this.tour});

  @override
  State<AdminTourUpdateModal> createState() => _AdminTourUpdateModalState();
}

class _AdminTourUpdateModalState extends State<AdminTourUpdateModal> {
  final _formKey = GlobalKey<FormState>();

  // ===== BASIC =====
  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController daysCtrl;
  late TextEditingController nightsCtrl;
  late TextEditingController maxPeopleCtrl;
  late TextEditingController minPeopleCtrl;
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

    nameCtrl = TextEditingController(text: t.name);
    priceCtrl = TextEditingController(text: t.pricePerPerson.toString());
    daysCtrl = TextEditingController(text: t.durationDays.toString());
    nightsCtrl = TextEditingController(text: t.durationNights.toString());
    maxPeopleCtrl = TextEditingController(text: t.maxPeople.toString());
    minPeopleCtrl = TextEditingController(text: t.minPeople.toString());
    isActive = t.isActive;

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

  // ================= IMAGE =================
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files != null) {
      setState(() {
        newImages.addAll(files.map((e) => File(e.path)));
      });
    }
  }

  // ================= SUBMIT =================
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final description = quillCtrl.document.toPlainText().trim();
    if (description.isEmpty) {
      _toast('Mô tả không được để trống');
      return;
    }

    if (schedules.any((s) => s.title.text.trim().isEmpty)) {
      _toast('Tiêu đề lịch trình không được để trống');
      return;
    }

    final data = {
      "name": nameCtrl.text.trim(),
      "pricePerPerson": double.parse(priceCtrl.text),
      "durationDays": int.parse(daysCtrl.text),
      "durationNights": int.tryParse(nightsCtrl.text) ?? 0,
      "minPeople": int.tryParse(minPeopleCtrl.text) ?? 0,
      "maxPeople": int.tryParse(maxPeopleCtrl.text) ?? 0,
      "description": description,
      "isActive": isActive,
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

    context.read<AdminTourDetailBloc>().add(
      UpdateAdminTourDetail(widget.tour.id, data),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminTourDetailBloc, AdminTourDetailState>(
      listener: (context, state) {
        if (state is AdminTourUpdateSuccess) {
          Navigator.pop(context, true);
          context.read<AdminTourBloc>().add(LoadAdminTours());
        }
        if (state is AdminTourDetailError) {
          _toast(state.message ?? 'Cập nhật thất bại');
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 16),

                _section('Thông tin cơ bản'),
                _field(
                  'Tên tour',
                  nameCtrl,
                  icon: Icons.tour,
                  validator: (v) => requiredText(v, 'Tên tour'),
                ),
                _field(
                  'Giá / người',
                  priceCtrl,
                  keyboard: TextInputType.number,
                  icon: Icons.attach_money,
                  validator: (v) => requiredDouble(v, 'Giá / người', min: 1),
                ),

                Row(children: [
                  Expanded(
                    child: _field(
                      'Số ngày',
                      daysCtrl,
                      keyboard: TextInputType.number,
                      icon: Icons.calendar_today,
                      validator: (v) => requiredInt(v, 'Số ngày', min: 1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _field('Số đêm', nightsCtrl,
                        keyboard: TextInputType.number,
                        required: false),
                  ),
                ]),

                _field(
                  'Số khách tối thiểu',
                  minPeopleCtrl,
                  keyboard: TextInputType.number,
                  validator: (v) => requiredInt(v, 'Số khách tối thiểu', min: 1),
                ),

                _field(
                  'Số khách tối đa',
                  maxPeopleCtrl,
                  keyboard: TextInputType.number,
                  validator: (v) => validateMaxPeople(v, minPeopleCtrl),
                ),

                SwitchListTile(
                  title: const Text('Hoạt động'),
                  value: isActive,
                  onChanged: (v) => setState(() => isActive = v),
                ),

                const Divider(),

                _section('Mô tả chi tiết'),
                QuillSimpleToolbar(
                  controller: quillCtrl,
                  configurations: const QuillSimpleToolbarConfigurations(),
                ),
                Container(
                  height: 200,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: QuillEditor(
                    controller: quillCtrl,
                    scrollController: ScrollController(),
                    focusNode: FocusNode(),
                    configurations: const QuillEditorConfigurations(
                      padding: EdgeInsets.all(12),
                    ),
                  ),
                ),

                const Divider(),
                _imageSection(),

                const Divider(),
                _scheduleSection(),

                const Divider(),
                _listEditor('Included', includedCtrls),
                _listEditor('Excluded', excludedCtrls),

                const SizedBox(height: 20),
                _actions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _header() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text('Cập nhật Tour',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
    ],
  );

  Widget _section(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  Widget _field(
      String label,
      TextEditingController ctrl, {
        bool required = true,
        TextInputType keyboard = TextInputType.text,
        IconData? icon,
        String? Function(String?)? validator,
      }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          validator: validator ??
              (required ? (v) => v == null || v.isEmpty ? 'Vui lòng nhập $label' : null : null),
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: icon != null ? Icon(icon) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );

  Widget _imageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section('Ảnh tour'),
        Row(
          children: [
            IconButton(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
            ),
            const Text('Thêm ảnh mới'),
          ],
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [

            // ===== OLD IMAGES (SERVER) =====
            ...widget.tour.images.map((img) {
              final isPrimary = img.isPrimary == true;

              return Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.read<AdminTourDetailBloc>().add(
                        SetPrimaryAdminTourImage(
                          tourId: widget.tour.id,
                          imageId: img.id,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isPrimary ? Colors.green : Colors.grey,
                          width: isPrimary ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.network(
                        img.imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // PRIMARY BADGE
                  if (isPrimary)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.green.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: const Text(
                          'PRIMARY',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // DELETE (nếu có event)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () {
                        context.read<AdminTourDetailBloc>().add(
                          DeleteAdminTourImage(
                            tourId: widget.tour.id,
                            imageId: img.id,
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              );
            }),

            // ===== NEW IMAGES (LOCAL) =====
            ...newImages.map((file) {
              return Stack(
                children: [
                  Image.file(
                    file,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => setState(() => newImages.remove(file)),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _scheduleSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _section('Lịch trình'),
      ...List.generate(schedules.length, (i) {
        final s = schedules[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              Text('Ngày ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
              _field('Tiêu đề', s.title),
              _field('Hoạt động', s.activities, required: false),
              _field('Chỗ ở', s.accommodation, required: false),
              _field('Bữa ăn', s.meals, required: false),
              if (schedules.length > 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => schedules.removeAt(i)),
                  ),
                )
            ]),
          ),
        );
      }),
      TextButton.icon(
        onPressed: () => setState(() => schedules.add(_ScheduleItem())),
        icon: const Icon(Icons.add),
        label: const Text('Thêm ngày'),
      ),
    ],
  );

  Widget _listEditor(String title, List<TextEditingController> ctrls) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _section(title),
      ...List.generate(ctrls.length, (i) {
        return Row(children: [
          Expanded(child: _field('$title ${i + 1}', ctrls[i], required: false)),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: ctrls.length > 1 ? () => setState(() => ctrls.removeAt(i)) : null,
          )
        ]);
      }),
      TextButton.icon(
        onPressed: () => setState(() => ctrls.add(TextEditingController())),
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      )
    ],
  );

  Widget _actions() => Row(children: [
    Expanded(
        child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy'))),
    const SizedBox(width: 12),
    BlocBuilder<AdminTourDetailBloc, AdminTourDetailState>(
      builder: (context, state) {
        final loading = state is AdminTourUpdateLoading;
        return ElevatedButton(
          onPressed: loading ? null : _submit,
          child: loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Cập nhật'),
        );
      },
    )
  ]);

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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

