import 'package:smart_travel/core/network/dio_client.dart';
import 'package:smart_travel/data/models/destination/destination_response_modal.dart'; // Import đúng file của bạn
import '../../../domain/params/audio_params.dart';

abstract class AudioDataSource {
  Future<DestinationResponseModal> addAudio(AudioParams params);
  Future<DestinationResponseModal> updateAudio(AudioParams params);
  Future<DestinationResponseModal> deleteAudio(int id);
}

class AudioDataSourceImpl implements AudioDataSource {
  final DioClient dioClient;
  AudioDataSourceImpl({required this.dioClient});

  // ADD AUDIO
  @override
  Future<DestinationResponseModal> addAudio(AudioParams params) async {
    final response = await dioClient.post(
        '/destination/${params.destinationId}/audio-script',
        data: params.toJson()
    );
    return DestinationResponseModal.fromJson(response.data['data']);
  }

  //UPDATE AUDIO
  @override
  Future<DestinationResponseModal> updateAudio(AudioParams params) async {
    final response = await dioClient.put(
        '/destination/${params.destinationId}/audio-script',
        data: params.toJson()
    );
    return DestinationResponseModal.fromJson(response.data['data']);
  }

  // DELETE AUDIO
  @override
  Future<DestinationResponseModal> deleteAudio(int id) async {
    final response = await dioClient.delete('/destination/$id/audio-script');
    return DestinationResponseModal.fromJson(response.data['data']);
  }
}