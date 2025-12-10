import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/domain/entities/province.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';
import 'package:smart_travel/presentation/blocs/province/provicne_detail_bloc.dart';

import 'package:smart_travel/presentation/blocs/province/province_bloc.dart';
import 'package:smart_travel/presentation/blocs/province/province_detail_event.dart';
import 'package:smart_travel/presentation/blocs/province/province_detail_state.dart';
import 'package:smart_travel/presentation/blocs/province/province_event.dart';
import 'package:smart_travel/presentation/blocs/province/province_state.dart';
import '../../theme/app_colors.dart';

class ProvinceDetailScreen extends StatefulWidget {
  const ProvinceDetailScreen({Key? key}) : super(key: key);

  @override
  State<ProvinceDetailScreen> createState() => _ProvinceDetailScreenState();
}

class _ProvinceDetailScreenState extends State<ProvinceDetailScreen> {
  late ScrollController _scrollController;
  bool _isAppBarExpanded = true;
  late int _provinceId;
  ProvinceEntity? _province;
  bool _isLoadingProvince = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy ID từ arguments
    _provinceId = ModalRoute.of(context)!.settings.arguments as int;
    // Load chi tiết tỉnh thành
    _loadProvinceDetail();
  }

  // Gọi API để lấy chi tiết tỉnh thành
  void _loadProvinceDetail() {
    context.read<ProvinceDetailBloc>().add(LoadProvinceDetail( provinceId: _provinceId));
  }

  void _onScroll() {
    if (_scrollController.offset > 200) {
      if (_isAppBarExpanded) {
        setState(() {
          _isAppBarExpanded = false;
        });
      }
    } else {
      if (!_isAppBarExpanded) {
        setState(() {
          _isAppBarExpanded = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<ProvinceDetailBloc, ProvinceDetailState>(
        listener: (context, state) {
          if (state is ProvinceDetailLoaded) {
            setState(() {
              _province = state.response;
              _isLoadingProvince = false;
            });
          } else if (state is ProvinceDetailError) {
            setState(() {
              _errorMessage = state.message;
              _isLoadingProvince = false;
            });
          }
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // Đang tải dữ liệu tỉnh thành
    if (_isLoadingProvince) {
      return Center(
        child: Lottie.asset(
          'assets/lottie/travel_is_fun.json',
          width: 200,
          height: 500,
          repeat: true,

        ),
      );
    }

    // Có lỗi
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Lỗi: $_errorMessage',
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProvinceDetail,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // Dữ liệu không tìm thấy
    if (_province == null) {
      return const Center(
        child: Text('Không tìm thấy tỉnh thành'),
      );
    }

    // Hiển thị chi tiết tỉnh thành
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        _buildAppBar(),
        _buildProvinceHeader(),
        _buildProvinceInfo(),
        _buildDestinationsList(),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  // Custom App Bar
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {

          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              Icons.favorite_border,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: _isAppBarExpanded
            ? null
            : Text(
          _province!.name,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Province Image
            _province!.imageUrl != null
                ? Image.network(
              _province!.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.image_not_supported,
                    color: AppColors.primary,
                    size: 48,
                  ),
                );
              },
            )
                : Container(
              color: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 64,
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
            // Province name overlay
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _province!.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                  ),
                  if (_province!.region != null)
                    Text(
                      'Vùng: ${_province!.region}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Province Header with basic info
  Widget _buildProvinceHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoCard(
              icon: Icons.location_on,
              label: 'Vùng',
              value: _province!.region ?? 'N/A',
            ),
            _buildInfoCard(
              icon: Icons.code,
              label: 'Mã',
              value: _province!.code,
            ),
            _buildInfoCard(
              icon: Icons.star,
              label: 'Phổ biến',
              value: _province!.isPopular ? 'Có' : 'Không',
            ),
          ],
        ),
      ),
    );
  }

  // Info Card
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  // Province Description and Info
  Widget _buildProvinceInfo() {
    QuillController readOnlyController;
    try {
      //decode JSON
      if (_province!.description != null && _province!.description!.isNotEmpty) {
        final jsonDesc = jsonDecode(_province!.description!);
        readOnlyController = QuillController(
          document: Document.fromJson(jsonDesc),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true, //chỉ đọc
        );
      } else {
        // Nếu null hoặc rỗng
        readOnlyController = QuillController.basic();
      }
    } catch (e) {
      // Nếu lỗi decode (do dữ liệu cũ là text thường), load như text
      readOnlyController = QuillController(
        document: Document()..insert(0, _province!.description ?? ''),
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Giới thiệu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: QuillEditor.basic(
                controller: readOnlyController, // Controller đã tạo ở trên
                configurations: const QuillEditorConfigurations(
                  // Cấu hình hiển thị
                  showCursor: false,     // Ẩn con trỏ
                  enableInteractiveSelection: false, // Tắt chọn text (tuỳ chọn)
                  padding: EdgeInsets.zero, // Bỏ padding mặc định
                  sharedConfigurations: QuillSharedConfigurations(
                    locale: Locale('vi'), // Hỗ trợ tiếng Việt nếu cần
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Destinations in this Province
  Widget _buildDestinationsList() {
    if (_province == null || _province!.destination!.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.location_off,
                  size: 48,
                  color: AppColors.textGray,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có điểm đến trong tỉnh này',
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final destinations = _province!.destination;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index == 0) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Điểm đến du lịch',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              );
            }

            final destination = destinations![index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildDestinationCard(destination),
            );
          },
          childCount: destinations!.length + 1,
        ),
      ),
    );
  }

  // Destination Card
  Widget _buildDestinationCard(DestinationEntity destination) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to destination detail
        Navigator.pushNamed(context, "/destination-detail", arguments: destination.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination Image
            Container(
              height: 180,
              width: double.infinity,
              color: AppColors.primary.withOpacity(0.1),
              child:
              destination.imageUrl != null
                  ? Image.network(
                destination.imageUrl ?? "", // lấy ảnh đầu tiên
                fit: BoxFit.cover,
              )
                  : Image.asset(
                "assets/images/img.png",
                fit: BoxFit.cover,
              )
            ),
            // Destination Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          destination.category == "BEACH"
                              ? "Biển"
                              : destination.category == "MOUNTAIN"
                              ? "Núi"
                              : destination.category == "CULTURE"
                              ? "Văn hóa"
                              : destination.category == "CITY"
                              ? "Thành phố"
                              : destination.category == "NATURE"
                              ? "Thiên nhiên"
                              : "Không xác định",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  if (destination.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      destination.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textGray,
                        height: 1.4,
                      ),
                      maxLines: 2,
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (destination.averageRating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${destination.averageRating} (${destination.reviewCount ?? 0} reviews)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}