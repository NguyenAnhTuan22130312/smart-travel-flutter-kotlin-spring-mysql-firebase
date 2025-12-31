import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_travel/domain/entities/hotel.dart';
import 'package:smart_travel/domain/entities/room_type.dart';
import 'package:smart_travel/data/models/hotel/hotel_create_request.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_event.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_state.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_event.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_state.dart';
import '../../../theme/app_colors.dart';

class HotelFormDialog extends StatefulWidget {
  final Hotel? hotel;

  const HotelFormDialog({Key? key, this.hotel}) : super(key: key);

  @override
  State<HotelFormDialog> createState() => _HotelFormDialogState();
}

class _HotelFormDialogState extends State<HotelFormDialog> {
  // --- CONTROLLERS KHÁCH SẠN ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _destIdController = TextEditingController();
  final TextEditingController _hotelAmenitiesController =
      TextEditingController();
  final TextEditingController _latController = TextEditingController(
    text: "0.0",
  );
  final TextEditingController _lngController = TextEditingController(
    text: "0.0",
  );
  final _formKey = GlobalKey<FormState>();

  // --- CONTROLLERS ROOM ---
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _roomPriceController = TextEditingController();
  final TextEditingController _roomCapacityController = TextEditingController(
    text: "2",
  );
  final TextEditingController _roomTotalController = TextEditingController(
    text: "10",
  );
  final TextEditingController _roomAmenitiesController = TextEditingController(
    text: "Wifi, Điều hòa, TV",
  );

  // State local
  int? _editingId;
  double _selectedStar = 5;
  File? _selectedImage;

  // State quản lý danh sách phòng
  List<RoomType> _fetchedRooms = [];
  bool _isLoadingDetail = false;

  // Biến để biết đang sửa phòng ở vị trí nào (null = đang thêm mới)
  int? _editingRoomIndex;

  @override
  void initState() {
    super.initState();
    if (widget.hotel != null) {
      _editingId = widget.hotel!.id;

      // 1. Fill dữ liệu khách sạn
      _fillDataFromEntity(widget.hotel!);

      // 2. Gọi API lấy chi tiết
      context.read<HotelDetailBloc>().add(
        GetHotelDetailEvent(
          hotelId: _editingId!,
          checkIn: DateTime.now(),
          checkOut: DateTime.now().add(const Duration(days: 1)),
        ),
      );

      _isLoadingDetail = true;
    } else {
      // Nếu là tạo mới khách sạn
      _roomNameController.text = "Phòng Tiêu Chuẩn";
    }
  }

  void _fillDataFromEntity(Hotel hotel) {
    _nameController.text = hotel.name ?? "";
    _addressController.text = hotel.address ?? "";
    _descController.text = hotel.description ?? "";
    _phoneController.text = hotel.phone ?? "";
    _emailController.text = hotel.email ?? "";
    _destIdController.text = hotel.destinationId?.toString() ?? "";
    _hotelAmenitiesController.text = (hotel.amenities ?? []).join(", ");
    _latController.text = hotel.latitude?.toString() ?? "0.0";
    _lngController.text = hotel.longitude?.toString() ?? "0.0";
    _selectedStar = (hotel.starRating ?? 5).toDouble();

    // Logic fill phòng
    if (hotel.rooms != null && hotel.rooms!.isNotEmpty) {
      setState(() {
        _fetchedRooms = hotel.rooms!;
      });
      _clearRoomInputs();
    } else {
      _roomNameController.text = "Phòng ${hotel.name}";
      _roomPriceController.text = hotel.minPrice?.toStringAsFixed(0) ?? "";
      _roomTotalController.text = hotel.totalRooms?.toString() ?? "10";
    }
  }

  void _clearRoomInputs() {
    setState(() {
      _editingRoomIndex = null;
      _roomNameController.clear();
      _roomPriceController.clear();
      _roomCapacityController.text = "2";
      _roomTotalController.text = "5";
      _roomAmenitiesController.text = "Wifi, Điều hòa, TV";
    });
  }

  void _fillRoomInputsForEdit(int index) {
    final room = _fetchedRooms[index];
    setState(() {
      _editingRoomIndex = index;
      _roomNameController.text = room.name;
      _roomPriceController.text = room.price?.toStringAsFixed(0) ?? "";
      _roomCapacityController.text = room.capacity?.toString() ?? "2";
      _roomTotalController.text = "5";
      _roomAmenitiesController.text = (room.amenities ?? []).join(", ");
    });
  }

  void _saveRoomToLocalList() {
    if (_roomNameController.text.isEmpty || _roomPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Tên và Giá phòng')),
      );
      return;
    }

    final newRoom = RoomType(
      id: 0,
      name: _roomNameController.text,
      price: double.tryParse(_roomPriceController.text) ?? 0,
      capacity: int.tryParse(_roomCapacityController.text) ?? 2,
      amenities: _parseStringToList(_roomAmenitiesController.text),
    );

    setState(() {
      if (_editingRoomIndex != null) {
        _fetchedRooms[_editingRoomIndex!] = newRoom;
      } else {
        _fetchedRooms.add(newRoom);
      }
      _clearRoomInputs();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu phòng vào danh sách!'),
        backgroundColor: AppColors.green,
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  // Hàm format tiền tệ (Ví dụ: 500000 -> 500.000)
  String _formatCurrency(double? value) {
    if (value == null) return "0";
    return value
        .toStringAsFixed(0)
        .replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ".");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _destIdController.dispose();
    _hotelAmenitiesController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _roomNameController.dispose();
    _roomPriceController.dispose();
    _roomCapacityController.dispose();
    _roomTotalController.dispose();
    _roomAmenitiesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final File file = File(image.path);
      if ((file.lengthSync() ~/ (1024 * 1024)) > 5) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ảnh tối đa 5MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() => _selectedImage = file);
    }
  }

  List<String> _parseStringToList(String input) {
    if (input.isEmpty) return [];
    return input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  void _onSubmit() {
    // 1. Kiểm tra định dạng & Trường bắt buộc (Tên, Địa chỉ, Email, SĐT...)
    // Chữ đỏ sẽ tự hiện ở từng ô nếu có lỗi, không cần check thủ công nữa
    if (!_formKey.currentState!.validate()) {
      return; // Dừng lại để người dùng sửa các ô báo đỏ
    }

    // 2. Kiểm tra logic Nghiệp vụ riêng (Danh sách phòng)
    if (_fetchedRooms.isEmpty && _roomPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm ít nhất một loại phòng!'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    List<RoomTypeCreateRequest> roomRequests = [];

    for (var r in _fetchedRooms) {
      roomRequests.add(
        RoomTypeCreateRequest(
          name: r.name,
          capacity: r.capacity ?? 2,
          price: r.price ?? 0,
          totalRooms: 5,
          amenities: r.amenities ?? [],
        ),
      );
    }

    if (_roomPriceController.text.isNotEmpty) {
      if (_editingRoomIndex != null &&
          _editingRoomIndex! < roomRequests.length) {
        roomRequests[_editingRoomIndex!] = RoomTypeCreateRequest(
          name: _roomNameController.text,
          capacity: int.tryParse(_roomCapacityController.text) ?? 2,
          price: double.tryParse(_roomPriceController.text) ?? 0,
          totalRooms: int.tryParse(_roomTotalController.text) ?? 5,
          amenities: _parseStringToList(_roomAmenitiesController.text),
        );
      } else {
        roomRequests.add(
          RoomTypeCreateRequest(
            name: _roomNameController.text,
            capacity: int.tryParse(_roomCapacityController.text) ?? 2,
            price: double.tryParse(_roomPriceController.text) ?? 0,
            totalRooms: int.tryParse(_roomTotalController.text) ?? 5,
            amenities: _parseStringToList(_roomAmenitiesController.text),
          ),
        );
      }
    }

    if (roomRequests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất 1 loại phòng')),
      );
      return;
    }

    final requestData = HotelCreateRequest(
      name: _nameController.text,
      address: _addressController.text,
      stars: _selectedStar.toInt(),
      description: _descController.text,
      destinationId: int.tryParse(_destIdController.text) ?? 1,
      phone: _phoneController.text,
      email: _emailController.text,
      amenities: _parseStringToList(_hotelAmenitiesController.text),
      totalRooms: int.tryParse(_roomTotalController.text) ?? 5,
      availableRooms: int.tryParse(_roomTotalController.text) ?? 5,
      latitude: double.tryParse(_latController.text) ?? 0.0,
      longitude: double.tryParse(_lngController.text) ?? 0.0,
      thumbnail: widget.hotel?.thumbnail ?? "",
      images: [],
      roomTypes: roomRequests,
    );

    if (_editingId == null) {
      context.read<HotelBloc>().add(
        CreateHotelEvent(
          request: requestData,
          imageFile: _selectedImage,
        ),
      );
    } else {
      context.read<HotelBloc>().add(
        UpdateHotelEvent(hotelId: _editingId!, request: requestData),
      );
      if (_selectedImage != null) {
        context.read<HotelBloc>().add(
          UploadHotelImagesEvent(
            hotelId: _editingId!,
            images: [_selectedImage!],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Giữ Dialog ở ngoài cùng để tạo khung
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.all(16),

      // 2. Cho Scaffold vào ĐÂY để làm nền cho các thông báo
      child: Scaffold(
        backgroundColor: Colors.transparent, // Trong suốt để thấy màu Dialog
        resizeToAvoidBottomInset: false,

        // 3. Cho Listeners vào bên TRONG Scaffold
        body: MultiBlocListener(
          listeners: [
            BlocListener<HotelDetailBloc, HotelDetailState>(
              listener: (context, state) {
                if (state is HotelDetailLoaded) {
                  setState(() {
                    _isLoadingDetail = false;
                    _fillDataFromEntity(state.hotel);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã tải xong chi tiết (${state.hotel.rooms?.length ?? 0} phòng)'),
                        backgroundColor: AppColors.green,
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  });
                } else if (state is HotelDetailError) {
                  setState(() => _isLoadingDetail = false);
                }
              },
            ),
            BlocListener<HotelBloc, HotelState>(
              listener: (context, state) {
                if (state is HotelLoading) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đang xử lý dữ liệu và hình ảnh...'),
                      backgroundColor: AppColors.success,
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
                if (state is HotelOperationSuccess) {
                  Navigator.of(context).pop(true);
                } else if (state is HotelError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Có lỗi: ${state.message}'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
          child: Form(
            key: _formKey,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 900),
              child: Column(
                children: [
                  _buildHeader(context),
                  if (_isLoadingDetail)
                    const LinearProgressIndicator(
                      color: AppColors.secondary,
                      backgroundColor: AppColors.dividerGray,
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                            "1. Thông tin Khách sạn",
                            Icons.hotel,
                          ),
                          const SizedBox(height: 12),
                          _buildHotelInfoSection(),
                          const SizedBox(height: 30),
                          Divider(
                            color: AppColors.dividerGray.withOpacity(0.5),
                            thickness: 1,
                          ),
                          const SizedBox(height: 20),

                          // Phần quản lý phòng
                          _buildRoomListSection(),
                          const SizedBox(height: 10),
                          _buildRoomFormSection(),
                        ],
                      ),
                    ),
                  ),
                  _buildFooter(context),
                ],
              ),
            ),
          )
        ),
      ),
    );
  }

  // --- WIDGET : PHẦN ĐẦU CỦA DIALOG-----
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        gradient: AppColors.mainGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _editingId == null ? Icons.add_business : Icons.edit_note,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text(
                _editingId == null
                    ? 'Thêm Khách Sạn Mới'
                    : 'Cập Nhật Khách Sạn',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // --- WIDGET :  TẠO Ô NHẬP LIỆU (TEXT FIELD) ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(color: AppColors.textGray, fontSize: 14),
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          labelStyle: const TextStyle(color: AppColors.menuIconGray),
          prefixIcon:
              icon != null
                  ? Icon(
                    icon,
                    color: AppColors.primary.withOpacity(0.7),
                    size: 20,
                  )
                  : null,
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.dividerGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.dividerGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  // --- WIDGET : TẠO TIÊU ĐỀ CHO TỪNG PHẦN ---
  Widget _buildSectionTitle(String title, IconData icon) => Row(
    children: [
      Icon(icon, color: AppColors.button, size: 22),
      const SizedBox(width: 8),
      Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textGray,
          fontSize: 15,
          letterSpacing: 0.5,
        ),
      ),
    ],
  );

  //------ WIDGET giao diện nhập liệu thông tin chung---------
  Widget _buildHotelInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Tên khách sạn',
            icon: Icons.title,
            isRequired: true,
            validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên khách sạn' : null,
          ),
          _buildTextField(
            controller: _addressController,
            label: 'Địa chỉ',
            icon: Icons.location_on,
            isRequired: true,
            validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập địa chỉ' : null,
          ),
          _buildTextField(
            controller: _descController,
            label: 'Mô tả',
            icon: Icons.description,
            maxLines: 3,
          ),

          _buildTextField(
            controller: _phoneController,
            label: 'Số điện thoại',
            icon: Icons.phone,
            type: TextInputType.phone,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Số điện thoại chỉ được chứa số';
                if (value.length < 10 || value.length > 11) return 'Số điện thoại phải từ 10-11 số';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email,
            type: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) return 'Định dạng email không hợp lệ';
              }
              return null;
            },
          ),

          _buildTextField(
            controller: _destIdController,
            label: 'Destination ID',
            icon: Icons.map,
            type: TextInputType.number,
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Bắt buộc nhập Destination ID';
              if (int.tryParse(value) == null) return 'ID phải là số nguyên';
              return null;
            },
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _latController,
                  label: 'Vĩ độ (Lat)',
                  icon: Icons.location_searching,
                  type: TextInputType.number,
                  validator: (value) => (value != null && value.isNotEmpty && double.tryParse(value) == null) ? 'Phải là số' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _lngController,
                  label: 'Kinh độ (Lng)',
                  icon: Icons.explore,
                  type: TextInputType.number,
                  validator: (value) => (value != null && value.isNotEmpty && double.tryParse(value) == null) ? 'Phải là số' : null,
                ),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _hotelAmenitiesController,
                  label: 'Tiện ích',
                  icon: Icons.pool,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      "Đánh giá: ${_selectedStar.toInt()} sao",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                        fontSize: 12,
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.secondary,
                        inactiveTrackColor: AppColors.secondary.withOpacity(
                          0.2,
                        ),
                        thumbColor: AppColors.secondary,
                        overlayColor: AppColors.secondary.withOpacity(0.1),
                      ),
                      child: Slider(
                        value: _selectedStar,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: "${_selectedStar.toInt()}",
                        onChanged: (val) => setState(() => _selectedStar = val),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildImagePicker(),
        ],
      ),
    );
  }

  // --- WIDGET: HIỂN THỊ DANH SÁCH PHÒNG ĐÃ THÊM ---
  Widget _buildRoomListSection() {
    if (_fetchedRooms.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(
              "Danh sách phòng (${_fetchedRooms.length})",
              Icons.meeting_room,
            ),
            if (_editingRoomIndex == null)
              const Text(
                "Chọn phòng để sửa",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          constraints: const BoxConstraints(maxHeight: 180),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.dividerGray),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[50],
          ),
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            shrinkWrap: true,
            itemCount: _fetchedRooms.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final room = _fetchedRooms[index];
              final isEditingThis = _editingRoomIndex == index;
              return InkWell(
                onTap: () => _fillRoomInputsForEdit(index),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isEditingThis
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isEditingThis
                              ? AppColors.primary
                              : Colors.transparent,
                    ),
                    boxShadow: [
                      if (!isEditingThis)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              isEditingThis
                                  ? AppColors.primary.withOpacity(0.2)
                                  : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bed,
                          size: 18,
                          color:
                              isEditingThis
                                  ? AppColors.primary
                                  : AppColors.menuIconGray,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    isEditingThis
                                        ? AppColors.primary
                                        : AppColors.textGray,
                              ),
                            ),
                            Text(
                              "Sức chứa: ${room.capacity ?? 2} người",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${_formatCurrency(room.price)} VNĐ",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- WIDGET : tạo phòng-----
  Widget _buildRoomFormSection() {
    bool isEditing = _editingRoomIndex != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isEditing
                ? AppColors.primary.withOpacity(0.05)
                : Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isEditing
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.secondary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing
                    ? "SỬA PHÒNG #${_editingRoomIndex! + 1}"
                    : "THÊM LOẠI PHÒNG MỚI",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isEditing ? AppColors.primary : AppColors.secondary,
                  fontSize: 14,
                ),
              ),
              if (isEditing)
                TextButton.icon(
                  onPressed: _clearRoomInputs,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text("Hủy chọn"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _roomNameController,
            label: 'Tên loại phòng',
            icon: Icons.label,
            isRequired: true,
          ),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _roomPriceController,
                  label: 'Giá/đêm',
                  type: TextInputType.number,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  controller: _roomCapacityController,
                  label: 'Sức chứa',
                  type: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  controller: _roomTotalController,
                  label: 'Số lượng',
                  type: TextInputType.number,
                ),
              ),
            ],
          ),

          _buildTextField(
            controller: _roomAmenitiesController,
            label: 'Tiện nghi phòng',
            icon: Icons.featured_play_list,
          ),

          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isEditing ? AppColors.primary : AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              onPressed: _saveRoomToLocalList,
              icon: Icon(isEditing ? Icons.save : Icons.add_circle_outline),
              label: Text(
                isEditing ? "CẬP NHẬT PHÒNG NÀY" : "THÊM VÀO DANH SÁCH",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: CHỌN ẢNH BÌA ---
  Widget _buildImagePicker() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.dividerGray,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child:
                _selectedImage != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                    : (widget.hotel?.thumbnail != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.hotel!.thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                          ),
                        )
                        : const Icon(
                          Icons.add_photo_alternate,
                          color: AppColors.menuIconGray,
                        )),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ảnh bìa khách sạn",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Kích thước tối đa 5MB. Định dạng JPG, PNG.",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "Tải ảnh lên",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET : FOOTER----------
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.dividerGray.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Hủy Bỏ",
                style: TextStyle(color: AppColors.textGray),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 3,
                shadowColor: AppColors.primary.withOpacity(0.4),
              ),
              onPressed: _onSubmit,
              child: Text(
                _editingId == null ? "Tạo Mới" : "Lưu Thay Đổi",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
