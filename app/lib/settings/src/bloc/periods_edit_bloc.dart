import 'package:bloc_base/bloc_base.dart';
import 'package:rxdart/subjects.dart';
import 'package:sharezone/timetable/src/models/lesson_length/lesson_length.dart';
import 'package:sharezone/timetable/src/models/lesson_length/lesson_length_cache.dart';
import 'package:time/time.dart';
import 'package:sharezone/settings/src/bloc/user_settings_bloc.dart';
import 'package:user/user.dart';
import 'package:sharezone_common/api_errors.dart';

class PeriodsEditBloc extends BlocBase {
  final UserSettingsBloc _userSettingsBloc;
  final LessonLengthCache _lengthCache;

  final Stream<LessonLength> lessonLengthStream;
  Stream<Time> get timetableStart => _timetableStartSubject;

  final _periodsDataSubject = BehaviorSubject<Periods>();
  final _errorPeriodSubject = BehaviorSubject.seeded(<int>{});
  final _timetableStartSubject = BehaviorSubject<Time>();

  PeriodsEditBloc(this._userSettingsBloc, this._lengthCache)
      : lessonLengthStream = _lengthCache.streamLessonLength() {
    _changePeriods(_userSettingsBloc.current().periods);
    changeTimetableStart(_userSettingsBloc.current().timetableStartTime);
  }

  void saveLessonLengthInCache(int lengthInMinutes) {
    if (lengthInMinutes != null) {
      final lessonLength = LessonLength(lengthInMinutes);
      _lengthCache.setLessonLength(lessonLength);
    }
  }

  Stream<Periods> get periods => _periodsDataSubject;
  Stream<Set<int>> get errorPeriod => _errorPeriodSubject;

  Function(Periods) get _changePeriods => _periodsDataSubject.sink.add;
  Function(Time) get changeTimetableStart => _timetableStartSubject.sink.add;

  bool isSubmitValid() {
    final errors = _errorPeriodSubject.value;
    if (errors != null && errors.isNotEmpty) throw IncorrectPeriods();
    return true;
  }

  void checkForErrors() {
    final periods = _periodsDataSubject.value;
    if (periods != null) {
      periods.getPeriods().forEach((period) {
        isPeriodStartTimeValid(periods, period.number, period.startTime);
        isPeriodEndTimeValid(periods, period.number, period.endTime);
      });
    }
  }

  Future<void> submit() async {
    checkForErrors();
    if (isSubmitValid()) {
      final settings = _userSettingsBloc.current().copyWith(
          periods: _periodsDataSubject.value,
          timetableStartTime: _timetableStartSubject.value);
      _userSettingsBloc.updateSettings(settings);
    }
  }

  bool validate(Periods periods) {
    return periods.validate();
  }

  Future<void> addPeriod() async {
    final periods = await _periodsDataSubject.first;
    _changePeriods(periods.copyWithAddPeriod());
  }

  void isPeriodStartTimeValid(Periods periods, int number, Time startTime) {
    final period = periods.getPeriod(number).copyWith(startTime: startTime);
    final prevPeriod = periods.getPeriod(number - 1);
    final nextPeriod = periods.getPeriod(number + 1);

    if (!period.validate())
      addPeriodToErrorSubject(number);
    else if (period.isBeforePeriod(prevPeriod))
      addPeriodToErrorSubject(number);
    else if (nextPeriod != null &&
        startTime.totalMinutes > nextPeriod.startTime.totalMinutes)
      addPeriodToErrorSubject(number);
    else
      removePeriodFromErrorSubject(number);
  }

  Future<void> editPeriodStartTime(int number, Time startTime) async {
    final lessonLength = await lessonLengthStream.first;
    final periods = await _periodsDataSubject.first;
    final period = periods.getPeriod(number).copyWith(
        startTime: startTime,
        endTime: startTime.add(lessonLength.duration));
    _changePeriods(periods.copyWithEditPeriod(period));

    if (number == 1) _setTimetableBeginToLessonStart(startTime);
  }

  Future<void> editPeriodEndTime(int number, Time endTime) async {
    final periods = await _periodsDataSubject.first;
    final period = periods.getPeriod(number).copyWith(endTime: endTime);
    _changePeriods(periods.copyWithEditPeriod(period));
  }

  void isPeriodEndTimeValid(Periods periods, int number, Time endTime) {
    final period = periods.getPeriod(number).copyWith(endTime: endTime);
    final nextPeriod = periods.getPeriod(number + 1);
    final prevPeriod = periods.getPeriod(number - 1);

    if (!period.validate())
      addPeriodToErrorSubject(number);
    else if (period.isAfterPeriod(nextPeriod))
      addPeriodToErrorSubject(number);
    else if (prevPeriod != null &&
        endTime.totalMinutes < prevPeriod.endTime.totalMinutes)
      addPeriodToErrorSubject(number);
    else
      removePeriodFromErrorSubject(number);
  }

  void _setTimetableBeginToLessonStart(Time time) => changeTimetableStart(time);

  void removePeriodFromErrorSubject(int number) {
    if (_errorPeriodSubject.value != null) {
      final value = _errorPeriodSubject.value;
      value.remove(number);
      _errorPeriodSubject.sink.add(value);
    }
  }

  void addPeriodToErrorSubject(int number) {
    if (_errorPeriodSubject.value != null) {
      final value = _errorPeriodSubject.value;
      value.add(number);
      _errorPeriodSubject.sink.add(value);
    } else {
      _errorPeriodSubject.sink.add(<int>{number});
    }
  }

  Future<void> removePeriod(Period period) async {
    final periods = await _periodsDataSubject.first;
    _changePeriods(periods.copyWithRemovedPeriod(period));
    removePeriodFromErrorSubject(period.number);
  }

  @override
  void dispose() {
    _periodsDataSubject.close();
    _errorPeriodSubject.close();
    _timetableStartSubject.close();
  }
}