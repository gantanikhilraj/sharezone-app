import 'package:meta/meta.dart';
import 'package:sharezone/groups/group_join/models/group_info_with_selection_state.dart';
import 'package:sharezone/groups/group_join/models/group_join_exception.dart';
import 'package:group_domain_models/group_domain_models.dart';
import 'package:sharezone_common/helper_functions.dart';

abstract class GroupJoinResult {}

/// Der initialState, wenn kein GroupJoin Versuch ausgeführt wurde. Dies wird anstelle
/// eines leeren Streams oder null verwendet, um beispielsweise nach einem JoinVersuch wieder
/// zu clearen (wird aktuell noch nicht in ganzer Fülle genutzt).
class NoDataResult implements GroupJoinResult {}

/// Der GroupJoin Versuch befindet sich gerade in der Verarbeitung.
class LoadingJoinResult implements GroupJoinResult {}

/// Das Beitreten der Gruppe hat erfolgreich funktionert und wurde von der CF ausgeführt.
class SuccessfullJoinResult implements GroupJoinResult {
  final GroupInfo groupInfo;

  const SuccessfullJoinResult({
    @required this.groupInfo,
  }) : assert(groupInfo != null);

  factory SuccessfullJoinResult.fromData(Map<String, dynamic> data) {
    return SuccessfullJoinResult(
      groupInfo:
          GroupInfo.fromData(Map<String, dynamic>.from(data['groupData'])),
    );
  }
}

/// Es wird eine Selection an Kursen benötigt, um der Klasse beitreten zu können.
/// Wenn dieses Result erscheint, ruft der Client die [GroupJoinCourseSelectionPage] auf.
/// Dieses JoinResult hier wird an den [GroupJoinSelectCoursesBloc] übergeben.
class RequireCourseSelectionsJoinResult implements GroupJoinResult {
  final GroupInfo groupInfo;
  final List<GroupInfoWithSelectionState> courses;
  final String enteredValue;

  const RequireCourseSelectionsJoinResult({
    @required this.groupInfo,
    @required this.courses,
    @required this.enteredValue,
  }) : assert(groupInfo != null && courses != null);

  factory RequireCourseSelectionsJoinResult.fromData(
      Map<String, dynamic> data) {
    return RequireCourseSelectionsJoinResult(
      groupInfo:
          GroupInfo.fromData(Map<String, dynamic>.from(data['groupData'])),
      courses: decodeList(
          data['courses'],
          (courseData) => GroupInfoWithSelectionState.fromData(
              Map<String, dynamic>.from(courseData))),
      enteredValue: data['enteredValue'],
    );
  }
}

/// Es gab einen Fehler beim GroupJoin Versuch
class ErrorJoinResult implements GroupJoinResult {
  final GroupJoinException groupJoinException;

  ErrorJoinResult(this.groupJoinException);
}