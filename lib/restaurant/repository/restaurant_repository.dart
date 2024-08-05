import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/restaurant/model/restaurant_detail_model.dart';
import 'package:actual/restaurant/model/restaurant_model.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';
part 'restaurant_repository.g.dart';

@RestApi()
abstract class RestaurantRepository {
  // baseUrl에는 http://$ip/restaurant를 넣어주고,
  factory RestaurantRepository(Dio dio, {String baseUrl}) =
      _RestaurantRepository;

  // 나머지는 path에 넣어준다
  @GET('/')
  @Headers({'accessToken': 'true',})
  Future<CursorPagination<RestaurantModel>>paginate();

  @GET('/{id}')
  @Headers({'accessToken': 'true',})
  Future<RestaurantDetailModel> getRestaurantDetail({
    @Path() required String id, // 어노테이션 안이 비어있어도 변수명이 같다면 괜찮다.
  });
}
