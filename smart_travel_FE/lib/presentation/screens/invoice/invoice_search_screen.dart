import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/injection_container.dart' as di;
import 'package:smart_travel/presentation/blocs/invoice/search_bloc.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'package:smart_travel/presentation/widgets/invoice/empty_order_widget.dart';
import 'package:smart_travel/presentation/widgets/invoice/invoice_status_card.dart';

import '../../blocs/invoice/search_event.dart';
import '../../blocs/invoice/search_state.dart';

class InvoiceSearchScreen extends StatefulWidget {
  const InvoiceSearchScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceSearchScreen> createState() => _InvoiceSearchScreenState();
}

class _InvoiceSearchScreenState extends State<InvoiceSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentKeyword = "";

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<SearchBloc>().add(SearchInvoices(""));
  }


  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_currentKeyword != value) {
        _currentKeyword = value;
        context.read<SearchBloc>().add(SearchInvoices(value.trim()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Column(
          children: [
            // HEADER SEARCH
            Container(
              color: AppColors.primary,
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + 10,
                16,
                16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: const TextStyle(fontSize: 15),
                              decoration: const InputDecoration(
                                hintText: "Tìm kiếm lịch sử đặt chỗ",
                                border: InputBorder.none,
                              ),
                              onChanged: _onSearchChanged,
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _onSearchChanged("");
                              },
                              child: const Icon(
                                Icons.clear,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Hủy",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // KẾT QUẢ TÌM KIẾM + PULL TO REFRESH
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (state is SearchError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 60, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text(
                            "Đã có lỗi xảy ra",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<SearchBloc>()
                                  .add(SearchInvoices(_currentKeyword));
                            },
                            child: const Text("Thử lại"),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is SearchLoaded) {
                    final invoices = state.invoices;

                    // EMPTY STATE
                    if (invoices.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context
                              .read<SearchBloc>()
                              .add(SearchInvoices(_currentKeyword));
                        },
                        color: AppColors.primary,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            EmptyInvoiceWidget(
                              title: 'Không tìm thấy kết quả nào',
                              description:
                              'Thử tìm kiếm với từ khóa khác hoặc kiểm tra lại lịch sử đặt chỗ.',
                            ),
                          ],
                        ),
                      );
                    }

                    // HAS DATA
                    return RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<SearchBloc>()
                            .add(SearchInvoices(_currentKeyword));
                      },
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                        itemCount: invoices.length,
                        itemBuilder: (context, index) {
                          final invoice = invoices[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InvoiceStatusCard(
                              bookingId: invoice.bookingId,
                              invoiceNumber: invoice.invoiceNumber,
                              itemName: invoice.itemName,
                              startDate: invoice.startDate,
                              endDate: invoice.endDate,
                              nights: invoice.nights,
                              status: invoice.status,
                              reviewed: invoice.reviewed,
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
