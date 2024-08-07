import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/restaurant_model.dart';
import '../repository/restaurant_repository.dart';

final restaurantProvider = StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>(
    (ref){
      final repository = ref.watch(restaurantRepositoryProvider);

      final notifier = RestaurantStateNotifier(repository: repository);

      return notifier;
    }
);

class RestaurantStateNotifier extends StateNotifier<CursorPaginationBase> {
  final RestaurantRepository repository;

  RestaurantStateNotifier({
    required this.repository,
  }) : super(CursorPaginationLoading()){
    // 클래스 생성시 paginate 함수 바로 실행
    paginate();
  }

  paginate()async{
    // 레포의 paginate 함수로 data 값 받아오기
    final resp = await repository.paginate();
    // state에 넣어주기
    state = resp;
  }
}
