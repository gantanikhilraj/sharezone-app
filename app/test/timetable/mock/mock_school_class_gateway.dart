import 'package:app_functions/app_functions.dart';
import 'package:common_domain_models/common_domain_models.dart';
import 'package:group_domain_models/group_domain_accessors.dart';
import 'package:group_domain_models/group_domain_models.dart';
import 'package:meta/meta.dart';
import 'package:optional/optional_internal.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sharezone/groups/src/pages/school_class/my_school_class_bloc.dart';
import 'package:sharezone/util/api/schoolClassGateway.dart';
import 'package:sharezone_common/references.dart';

class MockSchoolClassGateway implements SchoolClassGateway {
  final _schoolClassListSubject = BehaviorSubject.seeded(<SchoolClass>[]);
  final _courses = BehaviorSubject.seeded(<MockCourse>[]);

  @override
  Future<AppFunctionsResult<bool>> addCourse(
      String schoolClassID, String courseID) async {
    final mockCourse = MockCourse(
      courseId: GroupId(courseID),
      schoolClassId: GroupId(schoolClassID),
    );
    _courses.sink.add(_courses.value..add(mockCourse));
    return AppFunctionsResult.data(true);
  }

  @override
  Future<AppFunctionsResult<bool>> createCourse(
      String schoolClassID, CourseData courseData) {
    throw UnimplementedError();
  }

  @override
  Future<AppFunctionsResult<bool>> createSchoolClass(
      SchoolClassData schoolClass) {
    throw UnimplementedError();
  }

  @override
  Future<AppFunctionsResult<bool>> deleteSchoolClass(
      String schoolClassID, SchoolClassDeleteType schoolClassDeleteType) {
    throw UnimplementedError();
  }

  @override
  Future<AppFunctionsResult<bool>> editSchoolClass(SchoolClass schoolClass) {
    throw UnimplementedError();
  }

  @override
  Future<AppFunctionsResult<bool>> editSchoolClassSettings(
      String schoolClassID, CourseSettings schoolClassSettings) {
    throw UnimplementedError();
  }

  @override
  Future<AppFunctionsResult<bool>> generateNewMeetingID(String schoolClassID) {
    throw UnimplementedError();
  }

  @override
  Future<AppFunctionsResult<bool>> kickMember(
      String schoolClassID, String kickedMemberID) {
    throw UnimplementedError();
  }

  @override
  Future<AppFunctionsResult<bool>> leaveSchoolClass(
      String schoolClassID) async {
    _schoolClassListSubject.sink.add(_schoolClassListSubject.value
      ..removeWhere((schoolClass) => schoolClass.id == schoolClassID));
    return AppFunctionsResult.data(true);
  }

  @override
  SchoolClassMemberAccessor get memberAccessor => throw UnimplementedError();

  @override
  String get memberID => throw UnimplementedError();

  @override
  References get references => throw UnimplementedError();

  @override
  Future<AppFunctionsResult<bool>> removeCourse(
      String schoolClassID, String courseID) {
    throw UnimplementedError();
  }

  @override
  Stream<List<SchoolClass>> stream() => _schoolClassListSubject;

  @override
  Stream<List<Course>> streamCourses(String schoolClassID) {
    throw UnimplementedError();
  }

  @override
  Stream<List<String>> streamCoursesID(String schoolClassID) {
    return Stream.value(_courses.value
        .where((course) => course.schoolClassId.value.id == schoolClassID)
        .map((course) => course.courseId.id)
        .toList());
  }

  @override
  Stream<SchoolClass> streamSingleSchoolClass(String id) {
    throw UnimplementedError();
  }

  @override
  Future<AppFunctionsResult<bool>> updateMemberRole(
      String schoolClassID, String memberID, MemberRole newRole) {
    throw UnimplementedError();
  }

  void addSchoolClass(SchoolClass schoolClass) {
    _schoolClassListSubject.sink
        .add(_schoolClassListSubject.value..add(schoolClass));
  }

  void addSchoolClasses(List<SchoolClass> schoolClasses) {
    schoolClasses.forEach(addSchoolClass);
  }

  void dispose() {
    _schoolClassListSubject.close();
    _courses.close();
  }
}

class MockCourse {
  final GroupId courseId;
  final Optional<GroupId> schoolClassId;

  MockCourse({GroupId schoolClassId, @required this.courseId})
      : schoolClassId = Optional.ofNullable(schoolClassId);
}