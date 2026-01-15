import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_event.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_state.dart';
import 'package:smart_travel/presentation/widgets/destination/destination_voice_guide.dart';

class AudioListSheet extends StatefulWidget {
  const AudioListSheet({super.key});

  @override
  State<AudioListSheet> createState() => _AudioListSheetState();
}

class _AudioListSheetState extends State<AudioListSheet> {
  @override
  void initState() {
    super.initState();
    context.read<DestinationBloc>().add(LoadAllDestinations(loadAll: true));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          const Text(
            "HÀNH TRÌNH ÂM THANH",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const Divider(),
          Expanded(
            child: BlocBuilder<DestinationBloc, DestinationState>(
              buildWhen: (previous, current) => current is FilterDestinationLoaded,
              builder: (context, state) {
                if (state is FilterDestinationLoaded) {
                  final listWithAudio = state.destinations
                      .where((item) => item.audioScript != null && item.audioScript!.isNotEmpty)
                      .toList();

                  if (listWithAudio.isEmpty) {
                    return const Center(child: Text("Không có âm thanh nào khả dụng"));
                  }

                  return ListView.builder(
                    itemCount: listWithAudio.length,
                    itemBuilder: (context, index) {
                      final item = listWithAudio[index];
                      return VoiceGuideCard(
                        key: ValueKey(item.id),
                        destinationId: item.id,
                        destinationName: item.name,
                        audioScript: item.audioScript!,
                        experienceReward: item.experienceReward,
                      );
                    },
                  );
                }
                // Hiện vòng tròn quay khi đang nạp lại dữ liệu trong initState
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}