import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/presentation/blocs/adminTour/tour_bloc.dart';
import 'package:smart_travel/presentation/blocs/adminTour/tour_event.dart';
import 'package:smart_travel/presentation/blocs/adminTour/tour_state.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_event.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_state.dart';

class CreateTourModal extends StatefulWidget {
  const CreateTourModal({super.key});

  @override
  State<CreateTourModal> createState() => _CreateTourModalState();
}

class _CreateTourModalState extends State<CreateTourModal> {
  final _formKey = GlobalKey<FormState>();

  // ===== BASIC =====
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final daysCtrl = TextEditingController();
  final nightsCtrl = TextEditingController();
  final minPeopleCtrl = TextEditingController();
  final maxPeopleCtrl = TextEditingController();

  int? destinationId;

  // ===== IMAGES =====
  final List<File> images = [];

  // ===== SCHEDULE =====
  final List<_ScheduleItem> schedules = [_ScheduleItem()];

  // ===== INCLUDED / EXCLUDED =====
  final List<TextEditingController> includedCtrls = [TextEditingController()];
  final List<TextEditingController> excludedCtrls = [TextEditingController()];

  @override
  void initState() {
    super.initState();
    context.read<DestinationBloc>().add(LoadAllDestinations(loadAll: true));
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    daysCtrl.dispose();
    nightsCtrl.dispose();
    minPeopleCtrl.dispose();
    maxPeopleCtrl.dispose();
    for (final s in schedules) s.dispose();
    for (final c in includedCtrls) c.dispose();
    for (final c in excludedCtrls) c.dispose();
    super.dispose();
  }

  List<DestinationEntity> _extractDestinations(DestinationState state) {
    if (state is FeaturedDestinationLoaded) return state.destinations;
    if (state is FilterDestinationLoaded) return state.destinations;
    return [];
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() {
        images.addAll(picked.map((e) => File(e.path)));
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (destinationId == null) {
      _toast('Vui lòng chọn điểm đến');
      return;
    }

    if (schedules.any((s) => s.title.text.trim().isEmpty)) {
      _toast('Tiêu đề lịch trình không được để trống');
      return;
    }

    final body = {
      "name": nameCtrl.text.trim(),
      "description": "",
      "pricePerPerson": double.parse(priceCtrl.text),
      "durationDays": int.parse(daysCtrl.text),
      "durationNights": int.tryParse(nightsCtrl.text) ?? 0,
      "minPeople": int.parse(minPeopleCtrl.text),
      "maxPeople": int.parse(maxPeopleCtrl.text),
      "destinationId": destinationId,
      "included": includedCtrls.map((e) => e.text).where((e) => e.isNotEmpty).toList(),
      "excluded": excludedCtrls.map((e) => e.text).where((e) => e.isNotEmpty).toList(),
      "schedules": List.generate(schedules.length, (i) {
        final s = schedules[i];
        return {
          "dayNumber": i + 1,
          "title": s.title.text.trim(),
          "activities": s.activities.text.trim(),
          "meals": s.meals.text.trim(),
          "accommodation": s.accommodation.text.trim(),
        };
      }),
    };

    context.read<AdminTourBloc>().add(CreateAdminTour(body));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminTourBloc, AdminTourState>(
      listener: (context, state) {
        if (state is AdminTourCreateSuccess) {
          Navigator.pop(context, true);
          _toast('🎉 Tạo tour thành công');
        }
        if (state is AdminTourError) _toast(state.message);
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
                const SizedBox(height: 12),
                _sectionCard(
                  title: 'Thông tin cơ bản',
                  child: Column(
                    children: [
                      _field('Tên tour', nameCtrl),
                      _field('Giá / người', priceCtrl, keyboard: TextInputType.number),
                      Row(children: [
                        Expanded(child: _field('Số ngày', daysCtrl, keyboard: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _field('Số đêm', nightsCtrl, required: false)),
                      ]),
                      _field('Số khách tối thiểu', minPeopleCtrl, keyboard: TextInputType.number),
                      _field('Số khách tối đa', maxPeopleCtrl, keyboard: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _sectionCard(title: 'Điểm đến', child: _destinationDropdown()),
                const SizedBox(height: 12),
                _sectionCard(title: 'Ảnh tour', child: _imageSection()),
                const SizedBox(height: 12),
                _sectionCard(title: 'Lịch trình', child: _scheduleSection()),
                const SizedBox(height: 12),
                _sectionCard(title: 'Included', child: _includedExcludedSection(includedCtrls)),
                const SizedBox(height: 12),
                _sectionCard(title: 'Excluded', child: _includedExcludedSection(excludedCtrls)),
                const SizedBox(height: 12),
                _actions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text('Tạo Tour', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 24)),
    ],
  );

  Widget _sectionCard({required String title, required Widget child}) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 3,
    shadowColor: Colors.black26,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    ),
  );

  Widget _field(String label, TextEditingController ctrl,
      {bool required = true, TextInputType keyboard = TextInputType.text}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          validator: required ? (v) => v == null || v.isEmpty ? 'Không được để trống' : null : null,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      );

  Widget _destinationDropdown() {
    return BlocBuilder<DestinationBloc, DestinationState>(
      builder: (context, state) {
        if (state is FeaturedDestinationLoading || state is FilterDestinationLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final destinations = _extractDestinations(state);
        if (destinations.isNotEmpty) {
          return DropdownButtonFormField<int>(
            value: destinationId,
            items: destinations
                .map((d) => DropdownMenuItem<int>(value: d.id, child: Text(d.name)))
                .toList(),
            onChanged: (v) => setState(() => destinationId = v),
            validator: (v) => v == null ? 'Vui lòng chọn điểm đến' : null,
            decoration: const InputDecoration(
              labelText: 'Điểm đến',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          );
        }
        if (state is FeaturedDestinationError || state is FilterDestinationError) {
          return const Text('Không tải được danh sách điểm đến');
        }
        return const SizedBox();
      },
    );
  }

  Widget _imageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.add_a_photo),
          label: const Text('Thêm ảnh'),
        ),
        if (images.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: images.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(images[index], fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => images.removeAt(index)),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Primary', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _scheduleSection() {
    return Column(
      children: [
        ...List.generate(schedules.length, (i) {
          final s = schedules[i];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              initiallyExpanded: true,
              title: Text('Ngày ${i + 1}: ${s.title.text.isEmpty ? "Chưa đặt tiêu đề" : s.title.text}'),
              children: [
                _field('Tiêu đề', s.title),
                _field('Hoạt động', s.activities, required: false),
                _field("Chỗ ở", s.accommodation),
                _field("Ăn uống", s.meals),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (schedules.length > 1)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            schedules.removeAt(i);
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                schedules.add(_ScheduleItem());
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Thêm ngày'),
          ),
        ),
      ],
    );
  }

  Widget _includedExcludedSection(List<TextEditingController> ctrls) {
    return Column(
      children: [
        ...List.generate(ctrls.length, (i) {
          final c = ctrls[i];
          return Row(
            children: [
              Expanded(child: _field('', c, required: false)),
              if (ctrls.length > 1)
                IconButton(
                  onPressed: () => setState(() => ctrls.removeAt(i)),
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                ),
            ],
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => ctrls.add(TextEditingController())),
            icon: const Icon(Icons.add),
            label: const Text('Thêm'),
          ),
        ),
      ],
    );
  }

  Widget _actions() => Row(
    children: [
      Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy'))),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Tạo', style: TextStyle(fontSize: 16)),
        ),
      ),
    ],
  );

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

class _ScheduleItem {
  final title = TextEditingController();
  final activities = TextEditingController();
  final meals = TextEditingController();
  final accommodation = TextEditingController();

  void dispose() {
    title.dispose();
    activities.dispose();
    meals.dispose();
    accommodation.dispose();
  }
}
