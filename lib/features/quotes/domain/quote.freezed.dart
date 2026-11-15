// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'quote.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed.');

Quote _$QuoteFromJson(Map<String, dynamic> json) {
  return _Quote.fromJson(json);
}

mixin _$Quote {
  String get id => throw _privateConstructorUsedError;
  String get bookId => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  QuoteSource get source => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuoteCopyWith<Quote> get copyWith => throw _privateConstructorUsedError;
}

abstract class $QuoteCopyWith<$Res> {
  factory $QuoteCopyWith(Quote value, $Res Function(Quote) then) =
      _$QuoteCopyWithImpl<$Res, Quote>;
  @useResult
  $Res call({
    String id,
    String bookId,
    int page,
    String text,
    String note,
    QuoteSource source,
    DateTime createdAt,
  });
}

class _$QuoteCopyWithImpl<$Res, $Val extends Quote>
    implements $QuoteCopyWith<$Res> {
  _$QuoteCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookId = null,
    Object? page = null,
    Object? text = null,
    Object? note = null,
    Object? source = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      bookId: null == bookId ? _value.bookId : bookId as String,
      page: null == page ? _value.page : page as int,
      text: null == text ? _value.text : text as String,
      note: null == note ? _value.note : note as String,
      source: null == source ? _value.source : source as QuoteSource,
      createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
    ) as $Val);
  }
}

abstract class _$$QuoteImplCopyWith<$Res> implements $QuoteCopyWith<$Res> {
  factory _$$QuoteImplCopyWith(
          _$QuoteImpl value, $Res Function(_$QuoteImpl) then) =
      __$$QuoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String bookId,
    int page,
    String text,
    String note,
    QuoteSource source,
    DateTime createdAt,
  });
}

class __$$QuoteImplCopyWithImpl<$Res>
    extends _$QuoteCopyWithImpl<$Res, _$QuoteImpl>
    implements _$$QuoteImplCopyWith<$Res> {
  __$$QuoteImplCopyWithImpl(
      _$QuoteImpl _value, $Res Function(_$QuoteImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookId = null,
    Object? page = null,
    Object? text = null,
    Object? note = null,
    Object? source = null,
    Object? createdAt = null,
  }) {
    return _then(_$QuoteImpl(
      id: null == id ? _value.id : id as String,
      bookId: null == bookId ? _value.bookId : bookId as String,
      page: null == page ? _value.page : page as int,
      text: null == text ? _value.text : text as String,
      note: null == note ? _value.note : note as String,
      source: null == source ? _value.source : source as QuoteSource,
      createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
    ));
  }
}

@JsonSerializable()
class _$QuoteImpl implements _Quote {
  const _$QuoteImpl({
    required this.id,
    required this.bookId,
    this.page = 0,
    required this.text,
    this.note = '',
    this.source = QuoteSource.manual,
    required this.createdAt,
  });

  factory _$QuoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuoteImplFromJson(json);

  @override
  final String id;
  @override
  final String bookId;
  @override
  @JsonKey()
  final int page;
  @override
  final String text;
  @override
  @JsonKey()
  final String note;
  @override
  @JsonKey()
  final QuoteSource source;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Quote(id: $id, bookId: $bookId, page: $page, text: $text, source: $source)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuoteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, bookId, page, text, note, source, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuoteImplCopyWith<_$QuoteImpl> get copyWith =>
      __$$QuoteImplCopyWithImpl<_$QuoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuoteImplToJson(this);
  }
}

abstract class _Quote implements Quote {
  const factory _Quote({
    required final String id,
    required final String bookId,
    final int page,
    required final String text,
    final String note,
    final QuoteSource source,
    required final DateTime createdAt,
  }) = _$QuoteImpl;

  factory _Quote.fromJson(Map<String, dynamic> json) = _$QuoteImpl.fromJson;

  @override
  String get id;
  @override
  String get bookId;
  @override
  int get page;
  @override
  String get text;
  @override
  String get note;
  @override
  QuoteSource get source;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$QuoteImplCopyWith<_$QuoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
