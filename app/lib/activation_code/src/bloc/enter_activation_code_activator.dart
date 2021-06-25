import 'package:analytics/analytics.dart';
import 'package:app_functions/app_functions.dart';
import 'package:app_functions/exceptions.dart';
import 'package:app_functions/sharezone_app_functions.dart';
import 'package:crash_analytics/crash_analytics.dart';
import 'package:sharezone/activation_code/src/models/activation_code_events.dart';
import '../models/enter_activation_code_result.dart';

class EnterActivationCodeActivator {
  final SharezoneAppFunctions _appFunctions;
  final CrashAnalytics _crashAnalytics;
  final Analytics _analytics;

  EnterActivationCodeActivator(
    this._appFunctions,
    this._crashAnalytics,
    this._analytics,
  );

  Future<EnterActivationCodeResult> activateCode(String activationCode) async {
    _analytics.log(EnterActivationCodeEvent(activationCode));
    final appFunctionsResult = await _appFunctions.enterActivationCode(
        enteredActivationCode: activationCode);
    final result = _toEnterActivationCodeResult(appFunctionsResult);
    _logResult(activationCode, result);
    return result;
  }

  void _logResult(String activationCode, EnterActivationCodeResult result) {
    // Logs Error to CrashAnalytics if it is an UnknownGroupJoinException!
    if (result is FailedEnterActivationCodeResult &&
        result.enterActivationCodeException
            is UnknownEnterActivationCodeException) {
      final UnknownEnterActivationCodeException
          unknownEnterActivationCodeException =
          result.enterActivationCodeException;
      _crashAnalytics.recordError(
          unknownEnterActivationCodeException.exception, null);
    }
    if (result is SuccessfullEnterActivationCodeResult) {
      _analytics.log(SuccessfullEnterActivationCodeEvent(activationCode));
    } else {
      _analytics.log(FailedEnterActivationCodeEvent(activationCode));
    }
  }

  EnterActivationCodeResult _toEnterActivationCodeResult(
      AppFunctionsResult appFunctionsResult) {
    try {
      if (appFunctionsResult.hasData) {
        return EnterActivationCodeResult.fromData(appFunctionsResult.data);
      } else {
        final exception = appFunctionsResult.exception;
        if (exception is NoInternetAppFunctionsException) {
          return FailedEnterActivationCodeResult(
              NoInternetEnterActivationCodeException());
        }
        return FailedEnterActivationCodeResult(
            UnknownEnterActivationCodeException(exception: exception));
      }
    } catch (exception) {
      return FailedEnterActivationCodeResult(
          UnknownEnterActivationCodeException(exception: exception));
    }
  }
}