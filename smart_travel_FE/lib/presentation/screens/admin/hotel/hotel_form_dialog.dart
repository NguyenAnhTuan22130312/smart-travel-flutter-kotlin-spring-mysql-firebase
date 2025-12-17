import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_travel/domain/entities/hotel.dart';
import 'package:smart_travel/domain/entities/room_type.dart';
import 'package:smart_travel/data/models/hotel/hotel_create_request.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotail_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_event.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_detail_state.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_bloc.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_event.dart';
import 'package:smart_travel/presentation/blocs/hotel/hotel_state.dart';

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
  final TextEditingController _hotelAmenitiesController = TextEditingController();
  final TextEditingController _latController = TextEditingController(text: "0.0");
  final TextEditingController _lngController = TextEditingController(text: "0.0");

  // --- CONTROLLERS ROOM ---
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _roomPriceController = TextEditingController();
  final TextEditingController _roomCapacityController = TextEditingController(text: "2");
  final TextEditingController _roomTotalController = TextEditingController(text: "10");
  final TextEditingController _roomAmenitiesController = TextEditingController(text: "Wifi, Điều hòa, TV");

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
      context.read<HotelBloc>().add(LoadHotelsEvent());

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
        duration: Duration(milliseconds: 500),
      ),
    );
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
    return input.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  void _onSubmit() {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _destIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập các trường bắt buộc (*)')),
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
      if (_editingRoomIndex != null && _editingRoomIndex! < roomRequests.length) {
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
      context.read<HotelBloc>().add(CreateHotelEvent(request: requestData));
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
    return BlocListener<HotelDetailBloc, HotelDetailState>(
      listener: (context, state) {
        if (state is HotelDetailLoaded) {
          setState(() {
            _isLoadingDetail = false;
            _fillDataFromEntity(state.hotel);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã tải xong chi tiết (${state.hotel.rooms?.length ?? 0} phòng)'),
                duration: const Duration(seconds: 1),
              ),
            );
          });
        } else if (state is HotelDetailError) {
          setState(() => _isLoadingDetail = false);
        }
      },
      child: BlocListener<HotelBloc, HotelState>(
        listener: (context, state) {
          if (state is HotelOperationSuccess) {
            Navigator.of(context).pop(true);
          } else if (state is HotelError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Có lỗi: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              children: [
                _buildHeader(context),
                if (_isLoadingDetail) const LinearProgressIndicator(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("1. Thông tin Khách sạn"),
                        const SizedBox(height: 10),
                        _buildHotelInfoSection(),
                        const Divider(height: 30, thickness: 2),
                        _buildRoomListSection(),
                        _buildRoomFormSection(),
                      ],
                    ),
                  ),
                ),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _editingId == null ? 'Thêm Khách Sạn' : 'Cập Nhật Thông Tin',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
  );

  Widget _buildHotelInfoSection() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Tên khách sạn *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Địa chỉ *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _descController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Mô tả',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _destIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Dest ID *',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _latController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Lat',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _lngController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Lng',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _hotelAmenitiesController,
                decoration: const InputDecoration(
                  labelText: 'Tiện ích KS',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                Text(
                  "Sao: ${_selectedStar.toInt()}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: _selectedStar,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  activeColor: Colors.amber,
                  onChanged: (val) => setState(() => _selectedStar = val),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildImagePicker(),
      ],
    );
  }

  Widget _buildRoomListSection() {
    if (_fetchedRooms.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Danh sách phòng hiện có (${_fetchedRooms.length})"),
        const Text(
          "Chạm vào phòng để sửa thông tin ở dưới",
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 5),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: _fetchedRooms.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final room = _fetchedRooms[index];
              final isEditingThis = _editingRoomIndex == index;
              return InkWell(
                onTap: () => _fillRoomInputsForEdit(index),
                child: Container(
                  color: isEditingThis ? Colors.blue.withOpacity(0.1) : null,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bed,
                        size: 20,
                        color: isEditingThis ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          room.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isEditingThis ? Colors.blue : Colors.black,
                          ),
                        ),
                      ),
                      Text("${room.price?.toStringAsFixed(0)} đ"),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildRoomFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(
              _editingRoomIndex == null
                  ? "2. Thêm Loại phòng mới"
                  : "2. Đang sửa: Phòng #${_editingRoomIndex! + 1}",
            ),
            if (_editingRoomIndex != null)
              TextButton.icon(
                onPressed: _clearRoomInputs,
                icon: const Icon(Icons.cancel, size: 16),
                label: const Text("Hủy chọn"),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _roomNameController,
          decoration: const InputDecoration(
            labelText: 'Tên loại phòng *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _roomPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá/đêm *',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _roomCapacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Sức chứa',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _roomTotalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số lượng',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _roomAmenitiesController,
          decoration: const InputDecoration(
            labelText: 'Tiện nghi phòng',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[50],
              foregroundColor: Colors.orange[800],
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _saveRoomToLocalList,
            icon: Icon(_editingRoomIndex == null ? Icons.add : Icons.save),
            label: Text(
              _editingRoomIndex == null
                  ? "THÊM PHÒNG NÀY VÀO DANH SÁCH"
                  : "LƯU CẬP NHẬT PHÒNG",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedImage != null
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
              errorBuilder: (_, __, ___) => const Icon(Icons.error),
            ),
          )
              : const Icon(Icons.image)),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.upload),
          label: const Text("Chọn ảnh"),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _onSubmit,
              child: Text(_editingId == null ? "Thêm Mới" : "Lưu Thay Đổi"),
            ),
          ),
        ],
      ),
    );
  }
}