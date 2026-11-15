// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'reading_log.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed.');

ReadingLog _$ReadingLogFromJson(Map<String, dynamic> json) {
  return _ReadingLog.fromJson(json);
}

mixin _$ReadingLog {
  String get id => throw _privateConstructorUsedError;
  String get bookId => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  int get pagesRead => throw _privateConstructorUsedError;
  ReadingLogSource get source => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReadingLogCopyWith<ReadingLog> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $ReadingLogCopyWith<$Res> {
  factory $ReadingLogCopyWith(
          ReadingLog value, $Res Function(ReadingLog) then) =
      _$ReadingLogCopyWithImpl<$Res, ReadingLog>;
  @useResult
  $Res call({
    String id,
    String bookId,
    String date,
    int pagesRead,
    ReadingLogSource source,
  });
}

class _$ReadingLogCopyWithImpl<$Res, $Val extends ReadingLog>
    implements $ReadingLogCopyWith<$Res> {
  _$ReadingLogCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookId = null,
    Object? date = null,
    Object? pagesRead = null,
    Object? source = null,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      bookId: null == bookId ? _value.bookId : bookId as String,
      date: null == date ? _value.date : date as String,
      pagesRead: null == pagesRead ? _value.pagesRead : pagesRead as int,
      source: null == source ? _value.source : source as ReadingLogSource,
    ) as $Val);
  }
}

abstract class _$$ReadingLogImplCopyWith<$Res>
    implements $ReadingLogCopyWith<$Res> {
  factory _$$ReadingLogImplCopyWith(
          _$ReadingLogImpl value, $Res Function(_$ReadingLogImpl) then) =
      __$$ReadingLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String bookId,
    String date,
    int pagesRead,
    ReadingLogSource source,
  });
}

class __$$ReadingLogImplCopyWithImpl<$Res>
    extends _$ReadingLogCopyWithImpl<$Res, _$ReadingLogImpl>
    implements _$$ReadingLogImplCopyWith<$Res> {
  __$$ReadingLogImplCopyWithImpl(
      _$ReadingLogImpl _value, $Res Function(_$ReadingLogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookId = null,
    Object? date = null,
    Object? pagesRead = null,
    Object? source = null,
  }) {
    return _then(_$ReadingLogImpl(
      id: null == id ? _value.id : id as String,
      bookId: null == bookId ? _value.bookId : bookId as String,
      date: null == date ? _value.date : date as String,
      pagesRead: null == pagesRead ? _value.pagesRead : pagesRead as int,
      source: null == source ? _value.source : source as ReadingLogSource,
    ));
  }
}

@JsonSerializable()
class _$ReadingLogImpl implements _ReadingLog {
  const _$ReadingLogImpl({
    required this.id,
    required this.bookId,
    required this.date,
    required this.pagesRead,
    this.source = ReadingLogSource.manual,
  });

  factory _$ReadingLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReadingLogImplFromJson(json);

  @override
  final String id;
  @override
  final String bookId;
  @override
  final String date;
  @override
  final int pagesRead;
  @override
  @JsonKey()
  final ReadingLogSource source;

  @override
  String toString() {
    return 'ReadingLog(id: $id, bookId: $bookId, date: $date, pagesRead: $pagesRead, source: $source)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadingLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.pagesRead, pagesRead) ||
                other.pagesRead == pagesRead) &&
            (identical(other.source, source) || other.source == source));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, bookId, date, pagesRead, source);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadingLogImplCopyWith<_$ReadingLogImpl> get copyWith =>
      __$$ReadingLogImplCopyWithImpl<_$ReadingLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReadingLogImplToJson(this);
  }
}

abstract class _ReadingLog implements ReadingLog {
  const factory _ReadingLog({
    required final String id,
    required final String bookId,
    required final String date,
    required final int pagesRead,
    final ReadingLogSource source,
  }) = _$ReadingLogImpl;

  factory _ReadingLog.fromJson(Map<String, dynamic> json) =
      _$ReadingLogImpl.fromJson;

  @override
  String get id;
  @override
  String get bookId;
  @override
  String get date;
  @override
  int get pagesRead;
  @override
  ReadingLogSource get source;
  @override
  @JsonKey(ignore: true)
  _$$ReadingLogImplCopyWith<_$ReadingLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
