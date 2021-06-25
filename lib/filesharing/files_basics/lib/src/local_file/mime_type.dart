import 'package:mime/mime.dart';

class MimeType {
  final String _mimeType;

  MimeType(this._mimeType);

  static final any = MimeType('application');

  factory MimeType.fromFileNameOrNull(String fileName) {
    final mimetype = lookupMimeType(fileName);
    if (mimetype == null || mimetype == 'null')
      return null;
    else
      return MimeType(mimetype);
  }

  factory MimeType.fromPathOrNull(String path) {
    final mimetype = lookupMimeType(path);
    if (mimetype == null || mimetype == 'null')
      return null;
    else
      return MimeType(mimetype);
  }

  factory MimeType.fromBlobType(String blobType) {
    final mimetype = lookupMimeType(blobType);
    if (mimetype == null || mimetype == 'null')
      return MimeType(blobType);
    else
      return MimeType(mimetype);
  }

  String toData() {
    return _mimeType;
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        other is MimeType && other.toData() == toData();
  }

  @override
  int get hashCode => toData().hashCode;
}