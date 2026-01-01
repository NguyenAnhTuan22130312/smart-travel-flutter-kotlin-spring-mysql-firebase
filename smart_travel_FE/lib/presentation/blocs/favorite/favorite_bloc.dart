import 'package:flutter_bloc/flutter_bloc.dart';

// Event
abstract class FavoriteEvent {}
class AddToFavorite extends FavoriteEvent { final dynamic item; AddToFavorite(this.item); }
class RemoveFromFavorite extends FavoriteEvent { final String id; RemoveFromFavorite(this.id); }

// State
class FavoriteState {
  final List<dynamic> favoriteItems;
  FavoriteState({this.favoriteItems = const []});
}

// Bloc
class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc() : super(FavoriteState()) {
    on<AddToFavorite>((event, emit) {
      // Kiểm tra nếu chưa có thì mới thêm vào
      if (!state.favoriteItems.any((x) => x['id'] == event.item['id'])) {
        final updatedList = List.from(state.favoriteItems)..add(event.item);
        emit(FavoriteState(favoriteItems: updatedList));
      }
    });

    on<RemoveFromFavorite>((event, emit) {
      final updatedList = state.favoriteItems.where((x) => x['id'] != event.id).toList();
      emit(FavoriteState(favoriteItems: updatedList));
    });
  }
}