import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/widgets/common/custom_app_bar.dart';
import '../../../injection_container.dart' as di;
import '../../blocs/invoice/transaction_bloc.dart';
import '../../blocs/invoice/transaction_event.dart';
import '../../blocs/invoice/transaction_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/invoice/empty_order_widget.dart';
import '../../widgets/invoice/invoice_status_card.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);



  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String selectedType = "Tất cả";
  String selectedStatus = "Tất cả";

  @override
  void initState() {
    super.initState();

    // Load dữ liệu lần đầu khi vào màn hình
    context.read<TransactionBloc>().add(
      LoadTransactionHistory(
        type: "all",
        status: null,
      ),
    );
  }


  final List<String> typeOptions = ["Tất cả", "Khách sạn", "Tour"];
  final List<String> statusOptions = [
    "Tất cả",
    "Đang hoạt động",
    "Đã nhận phòng",
    "Đã hoàn thành",
    "Đã hủy",
    "Chờ hoàn tiền",
    "Đã hoàn tiền",
  ];

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
            CustomAppBar(titleKey: 'transaction_list'),

            // FILTER ROW
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: _buildCustomDropdown(
                      value: selectedType,
                      items: typeOptions,
                      onChanged: (value) {
                        setState(() {
                          selectedType = value ?? "Tất cả"; // An toàn nếu null
                        });
                        final apiType = (value == "Tất cả" || value == null) ? "all" : value.toUpperCase();
                        context.read<TransactionBloc>().add(
                          LoadTransactionHistory(
                            type: apiType,
                            status: _mapStatusToApi(selectedStatus),
                          ),
                        );

                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCustomDropdown(
                      value: selectedStatus,
                      items: statusOptions,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value ?? "Tất cả";
                        });
                        final apiStatus = _mapStatusToApi(value ?? "Tất cả");
                        context.read<TransactionBloc>().add(
                          LoadTransactionHistory(
                            type: selectedType == "Tất cả" ? "all" : selectedType.toUpperCase(),
                            status: apiStatus,
                          ),
                        );

                      },
                    ),
                  ),
                ],
              ),
            ),

            Expanded(

                child: BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, state) {
                    Widget body;

                    if (state is TransactionLoading) {
                      body = const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    } else if (state is TransactionError) {
                      body = Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 60, color: Colors.red),
                            const SizedBox(height: 16),
                            const Text("Đã có lỗi xảy ra", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(state.message),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<TransactionBloc>().add(
                                LoadTransactionHistory(
                                  type: selectedType == "Tất cả" ? "all" : selectedType.toUpperCase(),
                                  status: _mapStatusToApi(selectedStatus),
                                ),
                              ),
                              child: const Text("Thử lại"),
                            ),
                          ],
                        ),
                      );
                    } else if (state is TransactionLoaded) {
                      final invoices = state.invoices;

                      if (invoices.isEmpty) {
                        body = const EmptyInvoiceWidget(
                          title: 'Bạn hiện không có bất kỳ giao dịch nào',
                          description: 'Khi bạn đặt tour hoặc khách sạn, các giao dịch sẽ hiện ra tại đây.',
                        );
                      } else {
                        body = ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          children: invoices.map((invoice) {
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
                          }).toList(),
                        );
                      }
                    } else {
                      body = const SizedBox();
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        context.read<TransactionBloc>().add(
                          LoadTransactionHistory(
                            type: selectedType == "Tất cả" ? "all" : selectedType.toUpperCase(),
                            status: _mapStatusToApi(selectedStatus),
                          ),
                        );
                      },
                      child: () {
                        if (state is TransactionLoaded) {
                          final invoices = state.invoices;

                          if (invoices.isEmpty) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 200),
                                EmptyInvoiceWidget(
                                  title: 'Bạn hiện không có bất kỳ giao dịch nào',
                                  description: 'Khi bạn đặt tour hoặc khách sạn, các giao dịch sẽ hiện ra tại đây.',
                                ),
                              ],
                            );
                          }

                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                            children: invoices.map((invoice) {
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
                            }).toList(),
                          );
                        }

                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(
                                child: state is TransactionLoading
                                    ? const CircularProgressIndicator(color: AppColors.primary)
                                    : state is TransactionError
                                    ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                                    const SizedBox(height: 16),
                                    Text(state.message),
                                  ],
                                )
                                    : const SizedBox(),
                              ),
                            ),
                          ],
                        );
                      }(),
                    );

                  },
                ),
              ),

          ],
        ),
      ),
    );
  }

  String? _mapStatusToApi(String displayStatus) {
    switch (displayStatus) {
      case "Đang hoạt động":
        return "ACTIVE";
      case "Đã hoàn thành":
        return "COMPLETED";
      case "Đã hủy":
        return "CANCELED";
      case "Đã hoàn tiền":
        return "REFUNDED";
      case "Chờ hoàn tiền":
        return "PENDING_REFUND";
      case "Đã nhận phòng": // nếu bạn thêm
        return "CHECKED";
      default:
        return null;
    }
  }

  Widget _buildCustomDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.15),
      itemBuilder: (context) {
        return items.map((String item) {
          return PopupMenuItem<String>(
            value: item,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text(
                item,
                style: TextStyle(
                  color: item == value ? AppColors.primary : Colors.black87,
                  fontWeight: item == value ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}