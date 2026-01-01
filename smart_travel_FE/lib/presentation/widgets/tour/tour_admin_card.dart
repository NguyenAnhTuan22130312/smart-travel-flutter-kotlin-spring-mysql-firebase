import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/adminTour/tour_detail_bloc.dart';
import 'package:smart_travel/presentation/blocs/adminTour/tour_detail_state.dart';

class _TourDetailSheet extends StatelessWidget {
  const _TourDetailSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return BlocBuilder<AdminTourDetailBloc, AdminTourDetailState>(
          builder: (context, state) {
            if (state is AdminTourDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AdminTourDetailError) {
              return Center(child: Text(state.message));
            }

            if (state is! AdminTourDetailLoaded) {
              return const SizedBox();
            }

            final tour = state.tour;

            return SingleChildScrollView(
              controller: controller,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // ===== DRAG HANDLE =====
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== IMAGE =====
                  tour.image != null && tour.image!.isNotEmpty
                      ? Image.network(
                    tour.image!,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : _defaultImage(),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== NAME =====
                        Text(
                          tour.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        _info('📍 Điểm đến', tour.destinationName),
                        _info('💰 Giá', '${tour.pricePerPerson} đ'),
                        _info(
                          '⏱ Thời gian',
                          '${tour.durationDays}N${tour.durationNights}Đ',
                        ),
                        _info('👥 Số khách', tour.maxPeople.toString()),
                        _info('🛒 Lượt đặt', tour.bookingCount.toString()),

                        const SizedBox(height: 16),

                        // ===== DESCRIPTION =====
                        if (tour.description != null &&
                            tour.description!.isNotEmpty) ...[
                          const Text(
                            'Mô tả',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tour.description!,
                            style: const TextStyle(height: 1.4),
                          ),
                        ],

                        // ===== SCHEDULE =====
                        if (tour.schedules.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Lịch trình chi tiết',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),

                          ...tour.schedules.map(
                                (s) => Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ngày ${s.dayNumber}: ${s.title}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (s.activities != null)
                                    Text('📌 ${s.activities}'),
                                  if (s.accommodation != null)
                                    Text('🏨 ${s.accommodation}'),
                                  if (s.meals != null)
                                    Text('🍽 ${s.meals}'),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text('$label: $value'),
    );
  }

  static Widget _defaultImage() {
    return Image.asset(
      'assets/images/img_4.png',
      height: 240,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
