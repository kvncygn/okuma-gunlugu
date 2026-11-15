// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'reading_session.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed.');

ReadingSession _$ReadingSessionFromJson(Map<String, dynamic> json) {
  return _ReadingSession.fromJson(json);
}

mixin _$ReadingSession {
  String get id => throw _privateConstructorUsedError;
  String get bookId => throw _privateConstructorUsedError;
  int get durationSeconds => throw _privateConstructorUsedError;
  int get pagesRead => throw _privateConstructorUsedError;
  double get minutesPerPage => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime get endedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReadingSessionCopyWith<ReadingSession> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $ReadingSessionCopyWith<$Res> {
  factory $ReadingSessionCopyWith(
          ReadingSession value, $Res Function(ReadingSession) then) =
      _$ReadingSessionCopyWithImpl<$Res, ReadingSession>;
  @useResult
  $Res call({
    String id,
    String bookId,
    int durationSeconds,
    int pagesRead,
    double minutesPerPage,
    DateTime startedAt,
    DateTime endedAt,
  });
}

class _$ReadingSessionCopyWithImpl<$Res, $Val extends ReadingSession>
    implements $ReadingSessionCopyWith<$Res> {
  _$ReadingSessionCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookId = null,
    Object? durationSeconds = null,
    Object? pagesRead = null,
    Object? minutesPerPage = null,
    Object? startedAt = null,
    Object? endedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      bookId: null == bookId ? _value.bookId : bookId as String,
      durationSeconds: null == durationSeconds ? _value.durationSeconds : durationSeconds as int,
      pagesRead: null == pagesRead ? _value.pagesRead : pagesRead as int,
      minutesPerPage: null == minutesPerPage ? _value.minutesPerPage : minutesPerPage as double,
      startedAt: null == startedAt ? _value.startedAt : startedAt as DateTime,
      endedAt: null == endedAt ? _value.endedAt : endedAt as DateTime,
    ) as $Val);
  }
}

abstract class _$$ReadingSessionImplCopyWith<$Res>
    implements $ReadingSessionCopyWith<$Res> {
  factory _$$ReadingSessionImplCopyWith(_$ReadingSessionImpl value,
          $Res Function(_$ReadingSessionImpl) then) =
      __$$ReadingSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String bookId,
    int durationSeconds,
    int pagesRead,
    double minutesPerPage,
    DateTime startedAt,
    DateTime endedAt,
  });
}

class __$$ReadingSessionImplCopyWithImpl<$Res>
    extends _$ReadingSessionCopyWithImpl<$Res, _$ReadingSessionImpl>
    implements _$$ReadingSessionImplCopyWith<$Res> {
  __$$ReadingSessionImplCopyWithImpl(
      _$ReadingSessionImpl _value, $Res Function(_$ReadingSessionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookId = null,
    Object? durationSeconds = null,
    Object? pagesRead = null,
    Object? minutesPerPage = null,
    Object? startedAt = null,
    Object? endedAt = null,
  }) {
    return _then(_$ReadingSessionImpl(
      id: null == id ? _value.id : id as String,
      bookId: null == bookId ? _value.bookId : bookId as String,
      durationSeconds: null == durationSeconds ? _value.durationSeconds : durationSeconds as int,
      pagesRead: null == pagesRead ? _value.pagesRead : pagesRead as int,
      minutesPerPage: null == minutesPerPage ? _value.minutesPerPage : minutesPerPage as double,
      startedAt: null == startedAt ? _value.startedAt : startedAt as DateTime,
      endedAt: null == endedAt ? _value.endedAt : endedAt as DateTime,
    ));
  }
}

@JsonSerializable()
class _$ReadingSessionImpl implements _ReadingSession {
  const _$ReadingSessionImpl({
    required this.id,
    required this.bookId,
    required this.durationSeconds,
    required this.pagesRead,
    required this.minutesPerPage,
    required this.startedAt,
    required this.endedAt,
  });

  factory _$ReadingSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReadingSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String bookId;
  @override
  final int durationSeconds;
  @override
  final int pagesRead;
  @override
  final double minutesPerPage;
  @override
  final DateTime startedAt;
  @override
  final DateTime endedAt;

  @override
  String toString() {
    return 'ReadingSession(id: $id, bookId: $bookId, durationSeconds: $durationSeconds, pagesRead: $pagesRead, minutesPerPage: $minutesPerPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadingSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.pagesRead, pagesRead) ||
                other.pagesRead == pagesRead) &&
            (identical(other.minutesPerPage, minutesPerPage) ||
                other.minutesPerPage == minutesPerPage) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, bookId, durationSeconds,
      pagesRead, minutesPerPage, startedAt, endedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadingSessionImplCopyWith<_$ReadingSessionImpl> get copyWith =>
      __$$ReadingSessionImplCopyWithImpl<_$ReadingSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReadingSessionImplToJson(this);
  }
}

abstract class _ReadingSession implements ReadingSession {
  const factory _ReadingSession({
    required final String id,
    required final String bookId,
    required final int durationSeconds,
    required final int pagesRead,
    required final double minutesPerPage,
    required final DateTime startedAt,
    required final DateTime endedAt,
  }) = _$ReadingSessionImpl;

  factory _ReadingSession.fromJson(Map<String, dynamic> json) =
      _$ReadingSessionImpl.fromJson;

  @override
  String get id;
  @override
  String get bookId;
  @override
  int get durationSeconds;
  @override
  int get pagesRead;
  @override
  double get minutesPerPage;
  @override
  DateTime get startedAt;
  @override
  DateTime get endedAt;
  @override
  @JsonKey(ignore: true)
  _$$ReadingSessionImplCopyWith<_$ReadingSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
