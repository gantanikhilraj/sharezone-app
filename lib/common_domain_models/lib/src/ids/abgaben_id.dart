import 'package:common_domain_models/common_domain_models.dart';

import 'src/id.dart';

final _seperator = '.';

class AbgabeId extends Id {
  final AbgabezielId abgabenzielId;
  final UserId nutzerId;

  AbgabeId(this.abgabenzielId, this.nutzerId)
      : super('$nutzerId$_seperator$abgabenzielId', 'AbgabenId') {
    ArgumentError.checkNotNull(abgabenzielId, 'abgabenzielId');
    ArgumentError.checkNotNull(nutzerId, 'nutzerId');
  }

  factory AbgabeId.fromOrThrow(String id) {
    final semikolonIndex = id.indexOf(_seperator);
    if (semikolonIndex == -1) {
      ArgumentError.value(
          id, 'AbgabenId', 'muss mindestens ein "$_seperator" enthalten');
    }
    final nutzerId = UserId(id.substring(0, semikolonIndex));
    final abgabenzielId =
        AbgabezielId.fromOrThrow(id.substring(semikolonIndex + 1));
    return AbgabeId(abgabenzielId, nutzerId);
  }
}