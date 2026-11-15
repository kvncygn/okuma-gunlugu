// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'book.dart';

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed.');

Book _$BookFromJson(Map<String, dynamic> json) {
  return _Book.fromJson(json);
}

mixin _$Book {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  String get genre => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  BookStatus get status => throw _privateConstructorUsedError;
  String? get googleBooksId => throw _privateConstructorUsedError;
  String? get coverUrl => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get finishedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookCopyWith<Book> get copyWith => throw _privateConstructorUsedError;
}

abstract class $BookCopyWith<$Res> {
  factory $BookCopyWith(Book value, $Res Function(Book) then) =
      _$BookCopyWithImpl<$Res, Book>;
  @useResult
  $Res call({
    String id,
    String title,
    String author,
    String genre,
    int totalPages,
    int currentPage,
    BookStatus status,
    String? googleBooksId,
    String? coverUrl,
    DateTime? startedAt,
    DateTime? finishedAt,
  });
}

class _$BookCopyWithImpl<$Res, $Val extends Book>
    implements $BookCopyWith<$Res> {
  _$BookCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? author = null,
    Object? genre = null,
    Object? totalPages = null,
    Object? currentPage = null,
    Object? status = null,
    Object? googleBooksId = freezed,
    Object? coverUrl = freezed,
    Object? startedAt = freezed,
    Object? finishedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      title: null == title ? _value.title : title as String,
      author: null == author ? _value.author : author as String,
      genre: null == genre ? _value.genre : genre as String,
      totalPages: null == totalPages ? _value.totalPages : totalPages as int,
      currentPage: null == currentPage ? _value.currentPage : currentPage as int,
      status: null == status ? _value.status : status as BookStatus,
      googleBooksId: freezed == googleBooksId ? _value.googleBooksId : googleBooksId as String?,
      coverUrl: freezed == coverUrl ? _value.coverUrl : coverUrl as String?,
      startedAt: freezed == startedAt ? _value.startedAt : startedAt as DateTime?,
      finishedAt: freezed == finishedAt ? _value.finishedAt : finishedAt as DateTime?,
    ) as $Val);
  }
}

abstract class _$$BookImplCopyWith<$Res> implements $BookCopyWith<$Res> {
  factory _$$BookImplCopyWith(
          _$BookImpl value, $Res Function(_$BookImpl) then) =
      __$$BookImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String author,
    String genre,
    int totalPages,
    int currentPage,
    BookStatus status,
    String? googleBooksId,
    String? coverUrl,
    DateTime? startedAt,
    DateTime? finishedAt,
  });
}

class __$$BookImplCopyWithImpl<$Res>
    extends _$BookCopyWithImpl<$Res, _$BookImpl>
    implements _$$BookImplCopyWith<$Res> {
  __$$BookImplCopyWithImpl(_$BookImpl _value, $Res Function(_$BookImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? author = null,
    Object? genre = null,
    Object? totalPages = null,
    Object? currentPage = null,
    Object? status = null,
    Object? googleBooksId = freezed,
    Object? coverUrl = freezed,
    Object? startedAt = freezed,
    Object? finishedAt = freezed,
  }) {
    return _then(_$BookImpl(
      id: null == id ? _value.id : id as String,
      title: null == title ? _value.title : title as String,
      author: null == author ? _value.author : author as String,
      genre: null == genre ? _value.genre : genre as String,
      totalPages: null == totalPages ? _value.totalPages : totalPages as int,
      currentPage: null == currentPage ? _value.currentPage : currentPage as int,
      status: null == status ? _value.status : status as BookStatus,
      googleBooksId: freezed == googleBooksId ? _value.googleBooksId : googleBooksId as String?,
      coverUrl: freezed == coverUrl ? _value.coverUrl : coverUrl as String?,
      startedAt: freezed == startedAt ? _value.startedAt : startedAt as DateTime?,
      finishedAt: freezed == finishedAt ? _value.finishedAt : finishedAt as DateTime?,
    ));
  }
}

@JsonSerializable()
class _$BookImpl implements _Book {
  const _$BookImpl({
    required this.id,
    required this.title,
    required this.author,
    this.genre = 'Roman',
    this.totalPages = 100,
    this.currentPage = 0,
    this.status = BookStatus.reading,
    this.googleBooksId,
    this.coverUrl,
    this.startedAt,
    this.finishedAt,
  });

  factory _$BookImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String author;
  @override
  @JsonKey()
  final String genre;
  @override
  @JsonKey()
  final int totalPages;
  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final BookStatus status;
  @override
  final String? googleBooksId;
  @override
  final String? coverUrl;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? finishedAt;

  @override
  String toString() {
    return 'Book(id: $id, title: $title, author: $author, genre: $genre, totalPages: $totalPages, currentPage: $currentPage, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.genre, genre) || other.genre == genre) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.googleBooksId, googleBooksId) ||
                other.googleBooksId == googleBooksId) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.finishedAt, finishedAt) ||
                other.finishedAt == finishedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, author, genre,
      totalPages, currentPage, status, googleBooksId, coverUrl, startedAt, finishedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookImplCopyWith<_$BookImpl> get copyWith =>
      __$$BookImplCopyWithImpl<_$BookImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookImplToJson(this);
  }
}

abstract class _Book implements Book {
  const factory _Book({
    required final String id,
    required final String title,
    required final String author,
    final String genre,
    final int totalPages,
    final int currentPage,
    final BookStatus status,
    final String? googleBooksId,
    final String? coverUrl,
    final DateTime? startedAt,
    final DateTime? finishedAt,
  }) = _$BookImpl;

  factory _Book.fromJson(Map<String, dynamic> json) = _$BookImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get author;
  @override
  String get genre;
  @override
  int get totalPages;
  @override
  int get currentPage;
  @override
  BookStatus get status;
  @override
  String? get googleBooksId;
  @override
  String? get coverUrl;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get finishedAt;
  @override
  @JsonKey(ignore: true)
  _$$BookImplCopyWith<_$BookImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
