import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_bloc.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_event.dart';
import 'package:smart_travel/presentation/blocs/destiantion/destination_state.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';
import 'package:smart_travel/presentation/widgets/destination/CooldownManager.dart';

class VoiceGuideCard extends StatefulWidget {
  final int destinationId;
  final String audioScript;
  final String destinationName;
  final int? experienceReward;

  const VoiceGuideCard({
    super.key,
    required this.destinationId,
    required this.audioScript,
    required this.destinationName,
    required this.experienceReward,
  });

  static final ValueNotifier<int?> activeDestinationId = ValueNotifier<int?>(null);

  @override
  State<VoiceGuideCard> createState() => _VoiceGuideCardState();
}

class _VoiceGuideCardState extends State<VoiceGuideCard> {
  late ConfettiController _confettiController;
  bool _isPlaying = false;
  final _cooldownManager = CooldownManager();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _initTts();
    VoiceGuideCard.activeDestinationId.addListener(_handleGlobalAudioChange);
  }

  void _handleGlobalAudioChange() {
    // Nếu ID đang phát thay đổi và không phải là ID của Card này
    if (VoiceGuideCard.activeDestinationId.value != widget.destinationId) {
      if (mounted && _isPlaying) {
        setState(() => _isPlaying = false); // Tắt icon sóng âm của Card cũ
      }
    }
  }

  static final FlutterTts _sharedTts = FlutterTts();

  void _initTts() async {
    // Chỉ cấu hình các thông số cơ bản một lần
    await _sharedTts.awaitSpeakCompletion(true);
    await _sharedTts.setLanguage("vi-VN");
    await _sharedTts.setSpeechRate(0.52);
    await _sharedTts.setPitch(0.9);
    await _sharedTts.setVolume(0.85);
  }

  @override
  void dispose() {
    VoiceGuideCard.activeDestinationId.removeListener(_handleGlobalAudioChange);
    _sharedTts.stop();
    _confettiController.dispose();
    super.dispose();
  }


  void _togglePlay() async {
    if (_isPlaying) {
      await _sharedTts.stop();
      VoiceGuideCard.activeDestinationId.value = null;
      if (mounted) setState(() => _isPlaying = false);
    } else {
      // 1. TÍNH TOÁN GIỜ SERVER HIỆN TẠI DỰA TRÊN OFFSET
      int remaining = _cooldownManager.getRemainingSeconds(widget.destinationId);

      if (remaining > 0) {
        _showCenterWarningNotification();
        return; // Chặn đứng tại đây
      }
      // 2. NẾU ĐÃ HẾT COOLDOWN HOẶC CHƯA NGHE LẦN NÀO THÌ MỚI PHÁT AUDIO
      await _sharedTts.stop();
      // DÒNG QUAN TRỌNG NHẤT: Thông báo cho các Card khác biết mình đang phát
      VoiceGuideCard.activeDestinationId.value = widget.destinationId;

      final destinationBloc = context.read<DestinationBloc>();
      _sharedTts.setCompletionHandler(() {
        if (mounted) {
          setState(() => _isPlaying = false);
          VoiceGuideCard.activeDestinationId.value = null;
          debugPrint(
            "TTS Finished: ${widget.destinationName} (ID: ${widget
                .destinationId})",
          );
          destinationBloc.add(CompleteVoiceEvent(widget.destinationId));
        }
      });

      _sharedTts.setErrorHandler((msg) {
        if (mounted) setState(() => _isPlaying = false);
      });

      String cleanText = _getCleanAudioText(
        widget.audioScript,
      ).trim().replaceAll(RegExp(r'\s+'), ' ');

      if (cleanText.isNotEmpty) {
        String smoothText = "$cleanText . . . . , ,";
        if (mounted) setState(() => _isPlaying = true);
        await _sharedTts.speak(smoothText);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DestinationBloc, DestinationState>(
      listenWhen:
          (previous, current) =>
      current is CompleteVoiceSuccess &&
          current.destinationId == widget.destinationId ||
          (current is CompleteVoiceError),

      // Cho phép trạng thái Error đi qua để hiện thông báo
      listener: (context, state) {
        if (state is CompleteVoiceSuccess) {
          if (!mounted) return;
          setState(() {
            _isPlaying = false;
            _cooldownManager.updateCooldown(state.destinationId, state.levelData.serverTime);
          });
          if (state.levelData.isLevelUp) {
            _confettiController.play();
            _showLevelUpDialog(state.levelData.currentLevel);
          } else {
            _showCenterSuccessNotification(state.levelData.earnedExp);
          }
        }
        if (state is CompleteVoiceError) {
          if (!mounted) return;
          setState(() => _isPlaying = false);
        }
      },
      child: Stack(
        children: [
          _buildCardUI(),
          // Pháo hoa bắn từ trên xuống
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLevelUpDialog(String rank) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("🎉 THĂNG HẠNG!", textAlign: TextAlign.center),
            content: Text(
              "Chúc mừng! Bạn đã đạt danh hiệu: $rank",
              textAlign: TextAlign.center,
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Tuyệt vời!",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildCardUI() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: _isPlaying ? Colors.blue.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isPlaying ? Colors.blue : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          alignment: Alignment.center,
          child:
          _isPlaying
              ? Lottie.asset(
            'assets/lottie/audio_wave.json',
            width: 40,
            height: 40,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.graphic_eq, // Icon sóng âm mặc định của Material
                color: Colors.blue,
                size: 30,
              );
            },
          )
              : const Icon(
            Icons.play_circle_fill,
            color: AppColors.success,
            size: 40,
          ),
        ),
        title: Text(
          widget.destinationName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _isPlaying
              ? "Đang thuyết minh..."
              : "Nghe để nhận 20 - 50 EXP ngẫu nhiên",
          style: TextStyle(color: _isPlaying ? Colors.blue : Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: Icon(_isPlaying ? Icons.stop_circle : Icons.headset_mic),
          onPressed: _togglePlay,
          color: _isPlaying ? Colors.red : Colors.grey,
        ),
      ),
    );
  }

  String _getCleanAudioText(String rawData) {
    try {
      if (rawData.startsWith('[') && rawData.contains('insert')) {
        final List<dynamic> decoded = jsonDecode(rawData);
        String combinedText = "";
        for (var item in decoded) {
          if (item is Map && item.containsKey('insert')) {
            combinedText += item['insert'];
          }
        }
        return combinedText;
      }
      return rawData.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
    } catch (e) {
      return rawData;
    }
  }

  void _showCenterSuccessNotification(int exp) {
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho phép bấm ra ngoài tắt để tránh lỗi
      barrierColor: Colors.black26, // Làm tối nhẹ nền xung quanh
      builder: (context) {
        // Tự động đóng dialog sau 2 giây
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars, color: Colors.white, size: 50),
                  const SizedBox(height: 15),
                  Text(
                    "+$exp EXP",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Thuyết minh hoàn tất!",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Hàm hiển thị thông báo cảnh báo (Cooldown/No Points)
  void _showCenterWarningNotification() {
    showDialog(
      context: context,
      barrierDismissible: true, // Cho phép chạm ra ngoài để tắt nhanh
      barrierColor: Colors.black12,
      builder: (context) {
        // Dùng Timer để tự đóng Dialog sau 2.5 giây
        Timer? autoCloseTimer;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Lấy thời gian còn lại từ "nhà kho" ngầm
            int remaining = _cooldownManager.getRemainingSeconds(widget.destinationId);

            // Timer cập nhật con số nhảy lùi trong lúc Dialog đang hiện
            final tickTimer = Timer.periodic(const Duration(seconds: 1), (t) {
              if (remaining > 0) {
                if (context.mounted) setDialogState(() => remaining--);
              } else {
                t.cancel();
                if (context.mounted) Navigator.of(context).pop();
              }
            });

            // Tự động đóng sau 2500ms để không làm phiền người dùng
            autoCloseTimer ??= Timer(const Duration(milliseconds: 2500), () {
              tickTimer.cancel();
              if (context.mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            });

            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 50),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.white, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        // Hiển thị dạng MM:SS cho chuyên nghiệp
                        "${(remaining ~/ 60).toString().padLeft(2, '0')}:${(remaining % 60).toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Vui lòng đợi để tiếp tục nhận EXP!\nHãy khám phá nơi khác trong khi chờ nhé!",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
