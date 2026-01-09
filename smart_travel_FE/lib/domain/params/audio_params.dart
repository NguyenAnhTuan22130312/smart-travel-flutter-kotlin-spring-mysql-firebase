class AudioParams {
  final int destinationId;
  final String? audioScript;

  AudioParams({required this.destinationId, this.audioScript});

  Map<String, dynamic> toJson() => {
    'audioScript': audioScript,
  };
}