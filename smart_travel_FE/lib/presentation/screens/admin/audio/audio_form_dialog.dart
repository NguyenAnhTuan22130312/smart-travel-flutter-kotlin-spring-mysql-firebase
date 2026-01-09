import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:smart_travel/domain/entities/destinations.dart';
import 'package:smart_travel/presentation/blocs/admin_audio/audio_bloc.dart';
import 'package:smart_travel/presentation/blocs/admin_audio/audio_event.dart';
import 'package:smart_travel/presentation/blocs/admin_audio/audio_state.dart';
import 'package:smart_travel/presentation/theme/app_colors.dart';

class AudioFormDialog extends StatefulWidget {
  final DestinationEntity destination;

  const AudioFormDialog({Key? key, required this.destination})
      : super(key: key);

  @override
  State<AudioFormDialog> createState() => _AudioFormDialogState();
}

class _AudioFormDialogState extends State<AudioFormDialog> {
  late TextEditingController _audioController;
  bool _isSpeaking = false;
  late bool _isNew;
  static final FlutterTts _sharedTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _isNew = widget.destination.audioScript == null ||
        widget.destination.audioScript!.isEmpty;
    _audioController = TextEditingController(
      text: widget.destination.audioScript ?? "",
    );

    // Khởi tạo TTS nhưng không await để tránh block UI
    _initTts();
  }

  // --- CẤU HÌNH TTS CHUYÊN SÂU---
  Future<void> _initTts() async {
    try {
      // Dừng mọi tác vụ cũ
      await _sharedTts.stop();

      // 1. Cấu hình Audio Session cho iOS (Quan trọng để hết rè trên iPhone)
      if (Platform.isIOS) {
        await _sharedTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.playback,
            [
              IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
              IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            ]);
      }

      // 2. Cố gắng sử dụng Google TTS trên Android (Chất lượng cao hơn)
      if (Platform.isAndroid) {
        try {
          await _sharedTts.setEngine("com.google.android.tts");
        } catch (_) {
          // Nếu máy không có Google TTS thì dùng mặc định
        }
      }

      await _sharedTts.awaitSpeakCompletion(true);
      await _sharedTts.setLanguage("vi-VN");

      // 3. Tinh chỉnh thông số "Vàng"
      await _sharedTts.setSpeechRate(0.53);
      await _sharedTts.setPitch(0.91);
      await _sharedTts.setVolume(0.85);

      _sharedTts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });

      _sharedTts.setErrorHandler((msg) {
        debugPrint("TTS Error: $msg");
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (e) {
      debugPrint("TTS Init Error: $e");
    }
  }

  void _previewAudio() async {
    // Stop dứt khoát trước khi phát mới
    await _sharedTts.stop();

    if (_isSpeaking) {
      if (mounted) setState(() => _isSpeaking = false);
      return;
    }

    final rawText = _audioController.text;

    // Xử lý text kỹ hơn
    final cleanText = _getCleanAudioText(rawText)
        .trim()
        .replaceAll(RegExp(r'\s+'), ' '); // Xóa khoảng trắng thừa

    if (cleanText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng nhập nội dung để nghe thử")),
        );
      }
      return;
    }

    if (mounted) setState(() => _isSpeaking = true);

    // Delay 100ms (tăng lên chút) để Engine xả hết cache cũ
    await Future.delayed(const Duration(milliseconds: 100));
    String smoothText = "$cleanText.";

    try {
      await _sharedTts.speak(smoothText);
    } catch (e) {
      debugPrint("TTS Speak Error: $e");
      if (mounted) setState(() => _isSpeaking = false);
    }
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

  @override
  void dispose() {
    _sharedTts.stop();
    _audioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AudioBloc, AudioState>(
      listener: (context, state) {
        if (state is AudioUpdateSuccess) {
          Navigator.pop(context);
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isNew ? "Thêm Thuyết Minh" : "Chỉnh Sửa Thuyết Minh",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            IconButton(
              icon: Icon(
                _isSpeaking ? Icons.stop_circle : Icons.play_circle_fill,
              ),
              color: _isSpeaking ? Colors.red : AppColors.primary,
              iconSize: 36,
              onPressed: _previewAudio,
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Địa điểm: ${widget.destination.name}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _audioController,
                maxLines: 12,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText:
                  _isNew
                      ? "Nhập nội dung thuyết minh mới cho địa điểm này..."
                      : "Chỉnh sửa nội dung thuyết minh hiện tại...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isNew ? AppColors.primary : Colors.orangeAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              final content = _audioController.text.trim();
              if (content.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Nội dung thuyết minh không được để trống"),
                  ),
                );
                return;
              }

              if (_isNew) {
                context.read<AudioBloc>().add(
                  AddAudioScriptEvent(
                    id: widget.destination.id,
                    audioScript: content,
                  ),
                );
              } else {
                context.read<AudioBloc>().add(
                  UpdateDestinationAudioEvent(
                    id: widget.destination.id,
                    audioScript: content,
                  ),
                );
              }
            },
            child: BlocBuilder<AudioBloc, AudioState>(
              builder: (context, state) {
                if (state is AudioLoading) {
                  return const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  );
                }
                return Text(
                  _isNew ? "Tạo Audio" : "Cập Nhật Audio",
                  style: const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}