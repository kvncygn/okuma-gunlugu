// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'book_recommendation.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed.');

BookRecommendation _$BookRecommendationFromJson(Map<String, dynamic> json) {
  return _BookRecommendation.fromJson(json);
}

mixin _$BookRecommendation {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  String get genre => throw _privateConstructorUsedError;
  int get tier => throw _privateConstructorUsedError;
  String get infoBadge => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  String? get googleBooksId => throw _privateConstructorUsedError;
  String? get coverUrl => throw _privateConstructorUsedError;
  double? get averageRating => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookRecommendationCopyWith<BookRecommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $BookRecommendationCopyWith<$Res> {
  factory $BookRecommendationCopyWith(
          BookRecommendation value, $Res Function(BookRecommendation) then) =
      _$BookRecommendationCopyWithImpl<$Res, BookRecommendation>;
  @useResult
  $Res call({
    String id,
    String title,
    String author,
    String genre,
    int tier,
    String infoBadge,
    int totalPages,
    String? googleBooksId,
    String? coverUrl,
    double? averageRating,
  });
}

class _$BookRecommendationCopyWithImpl<$Res, $Val extends BookRecommendation>
    implements $BookRecommendationCopyWith<$Res> {
  _$BookRecommendationCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? author = null,
    Object? genre = null,
    Object? tier = null,
    Object? infoBadge = null,
    Object? totalPages = null,
    Object? googleBooksId = freezed,
    Object? coverUrl = freezed,
    Object? averageRating = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      title: null == title ? _value.title : title as String,
      author: null == author ? _value.author : author as String,
      genre: null == genre ? _value.genre : genre as String,
      tier: null == tier ? _value.tier : tier as int,
      infoBadge: null == infoBadge ? _value.infoBadge : infoBadge as String,
      totalPages: null == totalPages ? _value.totalPages : totalPages as int,
      googleBooksId: freezed == googleBooksId ? _value.googleBooksId : googleBooksId as String?,
      coverUrl: freezed == coverUrl ? _value.coverUrl : coverUrl as String?,
      averageRating: freezed == averageRating ? _value.averageRating : averageRating as double?,
    ) as $Val);
  }
}

abstract class _$$BookRecommendationImplCopyWith<$Res>
    implements $BookRecommendationCopyWith<$Res> {
  factory _$$BookRecommendationImplCopyWith(_$BookRecommendationImpl value,
          $Res Function(_$BookRecommendationImpl) then) =
      __$$BookRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String author,
    String genre,
    int tier,
    String infoBadge,
    int totalPages,
    String? googleBooksId,
    String? coverUrl,
    double? averageRating,
  });
}

class __$$BookRecommendationImplCopyWithImpl<$Res>
    extends _$BookRecommendationCopyWithImpl<$Res, _$BookRecommendationImpl>
    implements _$$BookRecommendationImplCopyWith<$Res> {
  __$$BookRecommendationImplCopyWithImpl(_$BookRecommendationImpl _value,
      $Res Function(_$BookRecommendationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? author = null,
    Object? genre = null,
    Object? tier = null,
    Object? infoBadge = null,
    Object? totalPages = null,
    Object? googleBooksId = freezed,
    Object? coverUrl = freezed,
    Object? averageRating = freezed,
  }) {
    return _then(_$BookRecommendationImpl(
      id: null == id ? _value.id : id as String,
      title: null == title ? _value.title : title as String,
      author: null == author ? _value.author : author as String,
      genre: null == genre ? _value.genre : genre as String,
      tier: null == tier ? _value.tier : tier as int,
      infoBadge: null == infoBadge ? _value.infoBadge : infoBadge as String,
      totalPages: null == totalPages ? _value.totalPages : totalPages as int,
      googleBooksId: freezed == googleBooksId ? _value.googleBooksId : googleBooksId as String?,
      coverUrl: freezed == coverUrl ? _value.coverUrl : coverUrl as String?,
      averageRating: freezed == averageRating ? _value.averageRating : averageRating as double?,
    ));
  }
}

@JsonSerializable()
class _$BookRecommendationImpl implements _BookRecommendation {
  const _$BookRecommendationImpl({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.tier,
    required this.infoBadge,
    this.totalPages = 250,
    this.googleBooksId,
    this.coverUrl,
    this.averageRating,
  });

  factory _$BookRecommendationImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookRecommendationImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String author;
  @override
  final String genre;
  @override
  final int tier;
  @override
  final String infoBadge;
  @override
  @JsonKey()
  final int totalPages;
  @override
  final String? googleBooksId;
  @override
  final String? coverUrl;
  @override
  final double? averageRating;

  @override
  String toString() {
    return 'BookRecommendation(id: $id, title: $title, author: $author, genre: $genre, tier: $tier, infoBadge: $infoBadge)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookRecommendationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.genre, genre) || other.genre == genre) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.infoBadge, infoBadge) ||
                other.infoBadge == infoBadge) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.googleBooksId, googleBooksId) ||
                other.googleBooksId == googleBooksId) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, author, genre, tier,
      infoBadge, totalPages, googleBooksId, coverUrl, averageRating);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookRecommendationImplCopyWith<_$BookRecommendationImpl> get copyWith =>
      __$$BookRecommendationImplCopyWithImpl<_$BookRecommendationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookRecommendationImplToJson(this);
  }
}

abstract class _BookRecommendation implements BookRecommendation {
  const factory _BookRecommendation({
    required final String id,
    required final String title,
    required final String author,
    required final String genre,
    required final int tier,
    required final String infoBadge,
    final int totalPages,
    final String? googleBooksId,
    final String? coverUrl,
    final double? averageRating,
  }) = _$BookRecommendationImpl;

  factory _BookRecommendation.fromJson(Map<String, dynamic> json) =
      _$BookRecommendationImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get author;
  @override
  String get genre;
  @override
  int get tier;
  @override
  String get infoBadge;
  @override
  int get totalPages;
  @override
  String? get googleBooksId;
  @override
  String? get coverUrl;
  @override
  double? get averageRating;
  @override
  @JsonKey(ignore: true)
  _$$BookRecommendationImplCopyWith<_$BookRecommendationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
