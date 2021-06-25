import 'package:filesharing_logic/filesharing_logic_models.dart';
import 'package:meta/meta.dart';
import 'package:firebase_hausaufgabenheft_logik/firebase_hausaufgabenheft_logik.dart';
import 'package:user/user.dart';

class HomeworkDetailsView {
  final String id;

  final String courseName;
  final String title;
  final String todoUntil;
  final String authorName;
  final String description;
  final bool isPrivate;

  final int nrOfCompletedStudents;
  final bool hasPermissionsToViewDoneByList;

  final bool withSubmissions;
  final int nrOfSubmissions;
  final bool hasSubmitted;
  final bool hasPermissionToViewSubmissions;

  final TypeOfUser typeOfUser;

  final bool hasAttachments;
  final List<String> attachmentIDs;
  final Stream<List<CloudFile>> attachmentStream;

  /// Wird zum Laden der Anhänge benötigt.
  final String courseID;

  /// Has user done homework
  final bool isDone;

  /// Permions to edit homeworks
  final bool hasPermission;

  /// Wird benötigt, um die Hausaufgabe zu bearbeiten und zu löschen
  final HomeworkDto homework;

  HomeworkDetailsView({
    @required this.id,
    @required this.isDone,
    @required this.courseName,
    @required this.title,
    @required this.todoUntil,
    @required this.authorName,
    @required this.hasAttachments,
    @required this.attachmentStream,
    @required this.hasPermission,
    @required this.description,
    @required this.homework,
    @required this.isPrivate,
    @required this.attachmentIDs,
    @required this.courseID,
    @required this.withSubmissions,
    @required this.nrOfSubmissions,
    @required this.hasSubmitted,
    @required this.typeOfUser,
    @required this.hasPermissionToViewSubmissions,
    @required this.nrOfCompletedStudents,
    @required this.hasPermissionsToViewDoneByList,
  });

  HomeworkDetailsView copyWith({
    String id,
    String isDone,
    String courseName,
    String title,
    String todoUntil,
    String authorName,
    bool hasAttachments,
    Stream<List<CloudFile>> attachmentStream,
    bool hasPermission,
    String description,
    HomeworkDto homework,
    bool isPrivate,
    List<String> attachmentIDs,
    String courseID,
    bool hasSubmitted,
    TypeOfUser typeOfUser,
    bool withSubmissions,
    int nrOfSubmissions,
    bool hasPermissionToViewSubmissions,
    int nrOfCompletedStudents,
    bool hasPermissionsToViewDoneByList,
  }) {
    return HomeworkDetailsView(
      id: id ?? this.id,
      isDone: isDone ?? this.isDone,
      courseName: courseName ?? this.courseName,
      title: title ?? this.title,
      todoUntil: todoUntil ?? this.todoUntil,
      authorName: authorName ?? this.authorName,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      attachmentStream: attachmentStream ?? this.attachmentStream,
      hasPermission: hasPermission ?? this.hasPermission,
      description: description ?? this.description,
      homework: homework ?? this.homework,
      isPrivate: isPrivate ?? this.isPrivate,
      attachmentIDs: attachmentIDs ?? this.attachmentIDs,
      courseID: courseID ?? this.courseID,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
      withSubmissions: withSubmissions ?? this.withSubmissions,
      typeOfUser: typeOfUser ?? this.typeOfUser,
      nrOfSubmissions: nrOfSubmissions ?? this.nrOfSubmissions,
      hasPermissionToViewSubmissions: hasPermissionToViewSubmissions ?? this.hasPermissionToViewSubmissions,
      nrOfCompletedStudents: nrOfCompletedStudents ?? this.nrOfCompletedStudents,
      hasPermissionsToViewDoneByList: hasPermissionsToViewDoneByList ?? this.hasPermissionsToViewDoneByList,
    );
  }
}