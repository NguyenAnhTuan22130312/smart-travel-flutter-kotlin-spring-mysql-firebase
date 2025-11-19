import 'package:equatable/equatable.dart';

class DestinationImage extends Equatable{
  final int? id;
  final String? imageUrl;
  final bool? isPrimary;
  final int? displayOrder;
  final DateTime? uploadedAt;

  DestinationImage({this.id, this.imageUrl, this.isPrimary, this.displayOrder, this.uploadedAt});

  @override
  // TODO: implement props
  List<Object?> get props => [id, imageUrl, isPrimary, displayOrder, uploadedAt];


}