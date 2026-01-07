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
import 'package:smart_travel/presentation/theme/app_colors.dart'; // Đảm bảo import đúng

class CreateTourModal extends StatefulWidget {
  const CreateTourModal({super.key});

  @override
  State<CreateTourModal> createState() => _CreateTourModalState();
}

class _CreateTourModalState extends State<CreateTourModal> {
  final _formKey = GlobalKey<FormState>();

  // Style Colors
  final Color primaryColor = const Color(0xFF0066CC); // Xanh dương chủ đạo
  final Color cardBgColor = Colors.white;
  final Color inputFillColor = const Color(0xFFF5F7FA);

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

    final isValidForm = _formKey.currentState!.validate();

    if (destinationId == null) {
      _showErrorSnackBar('Vui lòng chọn điểm đến');
      return;
    }

    // Kiểm tra hình ảnh (Mới thêm)
    if (images.isEmpty) {
      _showErrorSnackBar('Vui lòng thêm ít nhất 1 hình ảnh minh họa!');
      return;
    }

    if (schedules.any((s) => s.title.text.trim().isEmpty)) {
      _showErrorSnackBar('Tiêu đề lịch trình không được để trống');
      return;
    }

    if (!isValidForm) {
      _showErrorSnackBar('Vui lòng kiểm tra lại các trường bắt buộc (được tô đỏ)!');
      return;
    }

    final body = {
      "name": nameCtrl.text.trim(),
      "description": "", // Có thể thêm editor sau này
      "pricePerPerson": double.tryParse(priceCtrl.text) ?? 0,
      "durationDays": int.tryParse(daysCtrl.text) ?? 1,
      "durationNights": int.tryParse(nightsCtrl.text) ?? 0,
      "minPeople": int.tryParse(minPeopleCtrl.text) ?? 1,
      "maxPeople": int.tryParse(maxPeopleCtrl.text) ?? 10,
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

    // Gọi API create nhưng chưa gửi ảnh (cần logic multipart nếu API hỗ trợ gửi ảnh cùng lúc)
    // Hoặc gửi ảnh riêng. Ở đây giả sử gửi body JSON trước.
    context.read<AdminTourBloc>().add(CreateAdminTour(body));
  }

  // --- SHOW SUCCESS DIALOG ---
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.green, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                "Tạo Tour Thành Công!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Tour \"${nameCtrl.text}\" đã được thêm vào hệ thống.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx); // Đóng Dialog
                    Navigator.pop(context, true); // Đóng Modal tạo tour
                  },
                  child: const Text("HOÀN TẤT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Xóa snackbar cũ nếu đang hiện
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Thiếu thông tin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(msg, style: const TextStyle(fontSize: 13)),
                ],
              ),
            )
          ],
        ),
        backgroundColor: Colors.red[700], // Màu đỏ đậm hơn
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wrap Theme để áp dụng style chung cho input
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: inputFillColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 1.5)),
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ),
      child: BlocListener<AdminTourBloc, AdminTourState>(
        listener: (context, state) {
          if (state is AdminTourCreateSuccess) {
            _showSuccessDialog(); // Hiện Dialog đẹp
          }
          if (state is AdminTourError) {
            _showErrorSnackBar(state.message);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF0F2F5), // Nền xám nhạt toàn màn hình
          appBar: AppBar(
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(gradient: AppColors.mainGradient),
            ),
            leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
            title: const Text('Thêm Tour Mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildSectionContainer(
                    title: 'Thông tin chung',
                    icon: Icons.info_outline,
                    child: Column(
                      children: [
                        _buildInputField('Tên tour', nameCtrl, icon: Icons.title),
                        const SizedBox(height: 12),
                        _buildInputField('Giá / người (VND)', priceCtrl, icon: Icons.attach_money, isNumber: true),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildInputField('Số ngày', daysCtrl, icon: Icons.wb_sunny_outlined, isNumber: true)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildInputField('Số đêm', nightsCtrl, icon: Icons.nightlight_round, isNumber: true, isRequired: false)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildInputField('Min khách', minPeopleCtrl, icon: Icons.person_remove_outlined, isNumber: true)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildInputField('Max khách', maxPeopleCtrl, icon: Icons.groups_outlined, isNumber: true)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSectionContainer(
                    title: 'Điểm đến & Hình ảnh',
                    icon: Icons.image_outlined,
                    child: Column(
                      children: [
                        _buildDestinationDropdown(),
                        const SizedBox(height: 16),
                        _buildImagePickerSection(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSectionContainer(
                    title: 'Lịch trình chi tiết',
                    icon: Icons.calendar_month_outlined,
                    child: _buildScheduleSection(),
                  ),
                  const SizedBox(height: 16),

                  _buildSectionContainer(
                    title: 'Dịch vụ bao gồm (Included)',
                    icon: Icons.check_circle_outline,
                    child: _buildDynamicList(includedCtrls, "Vé máy bay, Ăn sáng..."),
                  ),
                  const SizedBox(height: 16),

                  _buildSectionContainer(
                    title: 'Không bao gồm (Excluded)',
                    icon: Icons.cancel_outlined,
                    child: _buildDynamicList(excludedCtrls, "Thuế VAT, Tiền TIP..."),
                  ),
                  const SizedBox(height: 30),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                        shadowColor: primaryColor.withOpacity(0.4),
                      ),
                      child: const Text('TẠO TOUR NGAY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildSectionContainer({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 22),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          child,
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController ctrl, {IconData? icon, bool isNumber = false, bool isRequired = true}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: isRequired ? (v) => v == null || v.isEmpty ? 'Nhập $label' : null : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400], size: 20) : null,
      ),
    );
  }

  Widget _buildDestinationDropdown() {
    return BlocBuilder<DestinationBloc, DestinationState>(
      builder: (context, state) {
        final destinations = _extractDestinations(state);
        return DropdownButtonFormField<int>(
          value: destinationId,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: destinations.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
          onChanged: (v) => setState(() => destinationId = v),
          validator: (v) => v == null ? 'Chọn điểm đến' : null,
          decoration: InputDecoration(
            labelText: 'Chọn điểm đến',
            prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey[400]),
          ),
        );
      },
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _pickImages,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withOpacity(0.3), style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_upload_outlined, color: primaryColor, size: 32),
                const SizedBox(height: 8),
                Text('Tải ảnh lên từ thiết bị', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (images.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(images.length, (index) {
              return Stack(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(image: FileImage(images[index]), fit: BoxFit.cover),
                      border: index == 0 ? Border.all(color: Colors.green, width: 2) : null,
                    ),
                  ),
                  Positioned(
                    top: 2, right: 2,
                    child: InkWell(
                      onTap: () => setState(() => images.removeAt(index)),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                  if (index == 0)
                    Positioned(bottom: 0, left: 0, right: 0, child: Container(decoration: const BoxDecoration(color: Colors.green, borderRadius: BorderRadius.vertical(bottom: Radius.circular(8))), padding: const EdgeInsets.symmetric(vertical: 2), child: const Text("COVER", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)))),
                ],
              );
            }),
          )
        else
          const Center(child: Text("Chưa có ảnh nào được chọn", style: TextStyle(color: Colors.grey, fontSize: 12))),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      children: [
        ...List.generate(schedules.length, (i) {
          final s = schedules[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              initiallyExpanded: i == schedules.length - 1, // Mở cái mới nhất
              title: Text('Ngày ${i + 1}: ${s.title.text.isEmpty ? "(Chưa nhập tiêu đề)" : s.title.text}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              childrenPadding: const EdgeInsets.all(16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField('Tiêu đề ngày', s.title),
                const SizedBox(height: 10),
                _buildInputField('Hoạt động chính', s.activities, isRequired: false),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _buildInputField('Chỗ ở', s.accommodation, isRequired: false)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildInputField('Ăn uống', s.meals, isRequired: false)),
                ]),
                if (schedules.length > 1)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => setState(() => schedules.removeAt(i)),
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      label: const Text('Xóa ngày', style: TextStyle(color: Colors.red)),
                    ),
                  )
              ],
            ),
          );
        }),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => schedules.add(_ScheduleItem())),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Thêm ngày lịch trình'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
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
        ...List.generate(ctrls.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(child: TextFormField(controller: ctrls[i], decoration: InputDecoration(hintText: hint))),
              if (ctrls.length > 1) IconButton(onPressed: () => setState(() => ctrls.removeAt(i)), icon: const Icon(Icons.remove_circle_outline, color: Colors.red)),
            ],
          ),
        )),
        TextButton.icon(
          onPressed: () => setState(() => ctrls.add(TextEditingController())),
          icon: Icon(Icons.add, color: primaryColor),
          label: Text('Thêm dòng mới', style: TextStyle(color: primaryColor)),
        )
      ],
    );
  }
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