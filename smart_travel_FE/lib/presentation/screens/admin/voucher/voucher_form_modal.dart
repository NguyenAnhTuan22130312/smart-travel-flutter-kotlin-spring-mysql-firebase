import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_travel/domain/entities/voucher.dart';
import 'package:smart_travel/domain/params/voucher_params.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/admin_voucher/voucher_bloc.dart';
import 'package:smart_travel/presentation/blocs/admin_voucher/voucher_event.dart';
import 'package:smart_travel/presentation/blocs/admin_voucher/voucher_state.dart';

class VoucherFormModal extends StatefulWidget {
  final Voucher? voucher;
  final VoidCallback onReset;

  const VoucherFormModal({Key? key, this.voucher, required this.onReset}) : super(key: key);

  @override
  State<VoucherFormModal> createState() => _VoucherFormModalState();
}

class _VoucherFormModalState extends State<VoucherFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _discountController;
  late TextEditingController _limitController;

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.voucher?.code ?? '');
    _discountController = TextEditingController(
        text: widget.voucher?.discountAmount.toStringAsFixed(0) ?? '');
    _limitController = TextEditingController(
        text: widget.voucher?.usageLimit.toString() ?? '100');

    if (widget.voucher != null) {
      _selectedDate = widget.voucher!.expiryDate;
      _isActive = widget.voucher!.isActive;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _discountController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final code = _codeController.text.toUpperCase().trim();
      final discount = double.tryParse(_discountController.text) ?? 0;
      final limit = int.tryParse(_limitController.text) ?? 0;

      // Set thời gian là cuối ngày (23:59:59)
      final expiry = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59
      );

      if (widget.voucher == null) {
        // Tạo mới
        final params = VoucherCreateParams(
          code: code,
          discountAmount: discount,
          expiryDate: expiry,
          isActive: _isActive,
          usageLimit: limit,
        );
        context.read<VoucherBloc>().add(CreateVoucherEvent(params));
      } else {
        // Cập nhật
        final params = VoucherUpdateParams(
          id: widget.voucher!.id,
          code: code,
          discountAmount: discount,
          expiryDate: expiry,
          isActive: _isActive,
          usageLimit: limit,
        );
        context.read<VoucherBloc>().add(UpdateVoucherEvent(params));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe trạng thái Bloc để disable nút khi đang loading
    return BlocBuilder<VoucherBloc, VoucherState>(
      builder: (context, state) {
        final isLoading = state is VoucherActionLoading;

        return AlertDialog(
          title: Text(widget.voucher == null ? "Thêm Voucher" : "Cập nhật Voucher"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // CODE
                  TextFormField(
                    controller: _codeController,
                    enabled: !isLoading,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: "Mã Code (VD: SUMMER2026)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.confirmation_number),
                    ),
                    validator: (v) => v!.isEmpty ? "Không được để trống" : null,
                  ),
                  const SizedBox(height: 12),

                  // DISCOUNT & LIMIT
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _discountController,
                          enabled: !isLoading,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: "Giảm (VND)",
                              border: OutlineInputBorder(),
                              suffixText: "đ"
                          ),
                          validator: (v) => v!.isEmpty ? "Nhập số tiền" : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _limitController,
                          enabled: !isLoading,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Số lượng",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // DATE PICKER
                  InkWell(
                    onTap: isLoading ? null : _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Hạn sử dụng",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // IS ACTIVE
                  SwitchListTile(
                    title: const Text("Kích hoạt"),
                    subtitle: Text(_isActive ? "Đang hoạt động" : "Đã khóa"),
                    value: _isActive,
                    onChanged: isLoading ? null : (v) => setState(() => _isActive = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(widget.voucher == null ? "Tạo mới" : "Lưu"),
            ),
          ],
        );
      },
    );
  }
}