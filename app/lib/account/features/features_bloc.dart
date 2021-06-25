import 'dart:async';

import 'package:bloc_base/bloc_base.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sharezone/account/features/feature_gateway.dart';
import 'package:sharezone/account/features/objects/all_colors.dart';
import 'package:sharezone/account/features/objects/hide_donations.dart';

class FeatureBloc extends BlocBase {
  final _isAllColorsUnlockedSubject = BehaviorSubject<bool>();
  Stream<bool> get isAllColorsUnlocked => _isAllColorsUnlockedSubject;

  final _hideDonationsSubject = BehaviorSubject<bool>();
  Stream<bool> get hideDonations => _hideDonationsSubject;

  final _shouldShowSchoolclassLicenseFeaturesSubject = BehaviorSubject<bool>();
  Stream<bool> get shouldShowSchoolclassLicenseFeatures =>
      _shouldShowSchoolclassLicenseFeaturesSubject;

  StreamSubscription _unlockedFeaturesSubscription;

  FeatureBloc(FeatureGateway featureGateway) {
    _loadIsDarkModeUnlocked(featureGateway);

    const _shouldShowSchoolclassLicenseFeatures = kDebugMode;
    _shouldShowSchoolclassLicenseFeaturesSubject
        .add(_shouldShowSchoolclassLicenseFeatures);
  }

  void _loadIsDarkModeUnlocked(FeatureGateway featureGateway) {
    _unlockedFeaturesSubscription =
        featureGateway.unlockedFeatures.listen((featureSet) {
      final isAllColorsUnlocked = featureSet.contains(AllColors());
      final hideDonations = featureSet.contains(HideDonations());

      _isAllColorsUnlockedSubject.sink.add(isAllColorsUnlocked);
      _hideDonationsSubject.sink.add(hideDonations);
    });
  }

  @override
  void dispose() {
    _hideDonationsSubject.close();
    _isAllColorsUnlockedSubject.close();
    _unlockedFeaturesSubscription.cancel();
    _shouldShowSchoolclassLicenseFeaturesSubject.close();
  }
}