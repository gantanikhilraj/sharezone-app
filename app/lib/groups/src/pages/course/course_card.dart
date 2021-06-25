import 'package:analytics/analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sharezone/additional/course_permission.dart';
import 'package:sharezone/blocs/application_bloc.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:group_domain_models/group_domain_models.dart';

import 'package:sharezone/groups/src/pages/course/course_details.dart';
import 'package:sharezone/groups/src/pages/course/course_details/course_details_bloc.dart';
import 'package:sharezone/groups/src/pages/course/course_edit/course_edit_page.dart';
import 'package:sharezone/groups/src/widgets/group_share.dart';
import 'package:sharezone_widgets/state_sheet.dart';
import 'package:sharezone_widgets/theme.dart';
import 'package:sharezone_widgets/adaptive_dialog.dart';
import 'package:sharezone_widgets/widgets.dart';

Future<bool> showCourseLeaveDialog(
    BuildContext context, bool isLastMember) async {
  return showLeftRightAdaptiveDialog<bool>(
      context: context,
      right: isLastMember
          ? AdaptiveDialogAction.delete
          : AdaptiveDialogAction(
              title: "Verlassen",
              isDefaultAction: true,
              isDestructiveAction: true,
              popResult: true,
              textColor: Colors.red,
            ),
      defaultValue: false,
      title: "Kurs verlassen${isLastMember ? " und löschen?" : "?"}",
      content: Text(
          "Möchtest du den Kurs wirklich verlassen? ${isLastMember ? "Da du der letzte Teilnehmer im Kurs bist, wird der Kurs gelöscht." : ""}"));
}

Future<bool> showDeleteCourseDialog(
    BuildContext context, String courseName) async {
  return await showLeftRightAdaptiveDialog<bool>(
      context: context,
      right: AdaptiveDialogAction.delete,
      defaultValue: false,
      title: "Kurs löschen?",
      content: Text(
          'Möchtest du den Kurs "$courseName" wirklich endgültig löschen?\n\nEs werden alle Stunden & Termine aus dem Stundenplan, Hausaufgaben und Einträge aus dem Schwarzen Brett und gelöscht.\n\nAuf den Kurs kann von niemanden mehr zugegriffen werden!'));
}

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard(this.course, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(child: CourseTile(course));
  }
}

class CourseCardRedesign extends StatelessWidget {
  const CourseCardRedesign(this.course, {Key key}) : super(key: key);

  final Course course;

  Future<void> onLongPress(BuildContext context, bool isAdmin) async {
    final api = BlocProvider.of<SharezoneContext>(context).api;
    final analytics = BlocProvider.of<SharezoneContext>(context).analytics;

    final result =
        await showLongPressAdaptiveDialog<_CourseCardLongPressResult>(
      context: context,
      title: "Kurs: ${course.name}",
      longPressList: [
        LongPress(
          popResult: _CourseCardLongPressResult.share,
          title: "Teilen",
          icon: Icon(
              themeIconData(Icons.share, cupertinoIcon: CupertinoIcons.share)),
        ),
        if (isAdmin)
          const LongPress(
            popResult: _CourseCardLongPressResult.edit,
            title: "Bearbeiten",
            icon: Icon(Icons.edit),
          ),
        const LongPress(
          popResult: _CourseCardLongPressResult.leave,
          title: "Verlassen",
          icon: Icon(Icons.cancel),
        ),
        if (isAdmin)
          const LongPress(
            popResult: _CourseCardLongPressResult.delete,
            title: "Löschen",
            icon: Icon(Icons.delete),
          ),
      ],
    );

    switch (result) {
      case _CourseCardLongPressResult.share:
        showDialog(
          context: context,
          builder: (context) =>
              ShareThisGroupDialogContent(groupInfo: course.toGroupInfo()),
        );
        break;
      case _CourseCardLongPressResult.edit:
        _logCourseEditViaCourseCardLongPress(analytics);
        openCourseEditPage(context, course);
        break;
      case _CourseCardLongPressResult.leave:
        _logCourseLeaveViaCourseCardLongPress(analytics);
        final bloc = CourseDetailsBloc(
            CourseDetailsBlocGateway(api.course, course), api.userId);
        final isLastMember = await bloc.isLastMember.first;
        final confirmed = await showCourseLeaveDialog(context, isLastMember);
        if (confirmed) {
          final leaveCourseFuture = api.course.leaveCourse(course.id);
          showAppFunctionStateDialog(context, leaveCourseFuture);
        }
        break;
      case _CourseCardLongPressResult.delete:
        _logCourseDeleteViaCourseCardLongPress(analytics);
        final confirmed = await showDeleteCourseDialog(context, course.name);
        if (confirmed) {
          final deleteCourseFunction = api.course.deleteCourse(course.id);
          showAppFunctionStateDialog(context, deleteCourseFunction);
        }
        break;
      default:
        break;
    }
  }

  void _logCourseEditViaCourseCardLongPress(Analytics analytics) {
    analytics.log(NamedAnalyticsEvent(name: "course_edit_via_card_long_press"));
  }

  void _logCourseDeleteViaCourseCardLongPress(Analytics analytics) {
    analytics
        .log(NamedAnalyticsEvent(name: "course_delete_via_card_long_press"));
  }

  void _logCourseLeaveViaCourseCardLongPress(Analytics analytics) {
    analytics
        .log(NamedAnalyticsEvent(name: "course_leave_via_card_long_press"));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) {
        final fullWidth = constrains.maxWidth;
        final width = (fullWidth / (fullWidth > 1200 ? 4 : 3)) - 6;
        final courseColor = course.getDesign().color;
        final isAdmin = isUserAdminOrOwnerFromCourse(course.myRole);
        return SizedBox(
          width: width,
          height: 120,
          child: CustomCard(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            onLongPress: () => onLongPress(context, isAdmin),
            onTap: () => openCourseDetailsPageAndShowConfirmationIfSuccessful(
                context, course),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: courseColor.withOpacity(0.2),
                        borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(500),
                            right: Radius.circular(500))),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        course.abbreviation,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: courseColor, fontSize: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    course.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDarkThemeEnabled(context)
                          ? Colors.lightBlue[100]
                          : darkBlueColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Die CourseTile für die SchoolClass Page. Diese überprüft zusätzlich,
/// ob der Nutzer überhaupt Mitglied des Kurses ist. Ansonsten bietet er
/// die Möglichkeit, diesem Kurs per Button beizutreten.
class SchoolClassVariantCourseTile extends StatelessWidget {
  final Course course;
  final String schoolClassId;

  const SchoolClassVariantCourseTile({
    @required this.course,
    @required this.schoolClassId,
    Key key,
  }) : super(key: key);

  Future<void> onLongPress(
      BuildContext context, bool isMember, bool isAdmin) async {
    final api = BlocProvider.of<SharezoneContext>(context).api;
    final analytics = BlocProvider.of<SharezoneContext>(context).analytics;

    final result =
        await showLongPressAdaptiveDialog<_CourseCardLongPressResult>(
      context: context,
      title: "Kurs: ${course.name}",
      longPressList: [
        LongPress(
          popResult: _CourseCardLongPressResult.share,
          title: "Teilen",
          icon: Icon(
              themeIconData(Icons.share, cupertinoIcon: CupertinoIcons.share)),
        ),
        if (isMember && isAdmin)
          const LongPress(
            popResult: _CourseCardLongPressResult.edit,
            title: "Bearbeiten",
            icon: Icon(Icons.edit),
          ),
        if (isMember)
          const LongPress(
            popResult: _CourseCardLongPressResult.join,
            title: "Beitreten",
            icon: Icon(Icons.add_circle_outline),
          ),
        if (isMember)
          const LongPress(
            popResult: _CourseCardLongPressResult.leave,
            title: "Verlassen",
            icon: Icon(Icons.cancel),
          ),
        if (isMember && isAdmin)
          const LongPress(
            popResult: _CourseCardLongPressResult.delete,
            title: "Löschen",
            icon: Icon(Icons.delete),
          ),
      ],
    );

    switch (result) {
      case _CourseCardLongPressResult.share:
        showDialog(
          context: context,
          builder: (context) =>
              ShareThisGroupDialogContent(groupInfo: course.toGroupInfo()),
        );
        break;
      case _CourseCardLongPressResult.edit:
        _logCourseEditViaCourseCardLongPress(analytics);
        openCourseEditPage(context, course);
        break;
      case _CourseCardLongPressResult.leave:
        _logCourseLeaveViaCourseCardLongPress(analytics);
        final bloc = CourseDetailsBloc(
            CourseDetailsBlocGateway(api.course, course), api.userId);
        final isLastMember = (await bloc.members.first).length <= 1;
        final confirmed = await showCourseLeaveDialog(context, isLastMember);
        if (confirmed) {
          final leaveCourseFuture = api.course.leaveCourse(course.id);
          showAppFunctionStateDialog(context, leaveCourseFuture);
        }
        break;
      case _CourseCardLongPressResult.delete:
        _logCourseDeleteViaCourseCardLongPress(analytics);
        final confirmed = await showDeleteCourseDialog(context, course.name);
        if (confirmed) {
          final deleteCourseFunction = api.course.deleteCourse(course.id);
          showAppFunctionStateDialog(context, deleteCourseFunction);
        }
        break;
      case _CourseCardLongPressResult.join:
        _logCourseJoinViaCourseCardLongPress(analytics);
        final joinCourseFunction = api.course.joinCourse(course.id);
        showAppFunctionStateDialog(context, joinCourseFunction);
        break;
      default:
        break;
    }
  }

  void _logCourseEditViaCourseCardLongPress(Analytics analytics) {
    analytics.log(NamedAnalyticsEvent(name: "course_edit_via_card_long_press"));
  }

  void _logCourseDeleteViaCourseCardLongPress(Analytics analytics) {
    analytics
        .log(NamedAnalyticsEvent(name: "course_delete_via_card_long_press"));
  }

  void _logCourseJoinViaCourseButton(Analytics analytics) {
    analytics
        .log(NamedAnalyticsEvent(name: "course_join_via_school_class_button"));
  }

  void _logCourseJoinViaCourseCardLongPress(Analytics analytics) {
    analytics.log(NamedAnalyticsEvent(name: "course_join_via_card_long_press"));
  }

  void _logCourseLeaveViaCourseCardLongPress(Analytics analytics) {
    analytics
        .log(NamedAnalyticsEvent(name: "course_leave_via_card_long_press"));
  }

  @override
  Widget build(BuildContext context) {
    final gateway = BlocProvider.of<SharezoneContext>(context).api.course;
    return StreamBuilder<Course>(
        stream: gateway.streamCourse(course.id),
        builder: (context, snapshot) {
          final courseFromOwn = snapshot.data;
          final isMember = courseFromOwn != null;
          final isAdmin = isMember
              ? isUserAdminOrOwnerFromCourse(courseFromOwn.myRole)
              : null;
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 19, vertical: 3),
            onTap: () => openCourseDetailsPageAndShowConfirmationIfSuccessful(
                context, course),
            leading: CourseCircleAvatar(
                courseId: course.id, abbreviation: course.abbreviation),
            title: Text(course.name),
            trailing: courseFromOwn == null
                ? MaterialButton(
                    child: const Text('Beitreten'),
                    onPressed: () async {
                      final analytics =
                          BlocProvider.of<SharezoneContext>(context).analytics;
                      final courseGateway =
                          BlocProvider.of<SharezoneContext>(context).api.course;
                      _logCourseJoinViaCourseButton(analytics);
                      final joinCourseFunction =
                          courseGateway.joinCourse(course.id);
                      showAppFunctionStateDialog(context, joinCourseFunction);
                    },
                  )
                : null,
            onLongPress: () => onLongPress(context, isMember, isAdmin),
          );
        });
  }
}

enum _CourseCardLongPressResult { share, leave, edit, delete, join }

class CourseTile extends StatelessWidget {
  final Course course;
  final bool withShareOption;

  const CourseTile(
    this.course, {
    Key key,
    this.withShareOption = true,
  }) : super(key: key);

  Future<void> onLongPress(BuildContext context, bool isAdmin) async {
    final api = BlocProvider.of<SharezoneContext>(context).api;
    final analytics = BlocProvider.of<SharezoneContext>(context).analytics;

    final result =
        await showLongPressAdaptiveDialog<_CourseCardLongPressResult>(
      context: context,
      title: "Kurs: ${course.name}",
      longPressList: [
        LongPress(
          popResult: _CourseCardLongPressResult.share,
          title: "Teilen",
          icon: Icon(
              themeIconData(Icons.share, cupertinoIcon: CupertinoIcons.share)),
        ),
        if (isAdmin)
          const LongPress(
            popResult: _CourseCardLongPressResult.edit,
            title: "Bearbeiten",
            icon: Icon(Icons.edit),
          ),
        const LongPress(
          popResult: _CourseCardLongPressResult.leave,
          title: "Verlassen",
          icon: Icon(Icons.cancel),
        ),
        if (isAdmin)
          const LongPress(
            popResult: _CourseCardLongPressResult.delete,
            title: "Löschen",
            icon: Icon(Icons.delete),
          ),
      ],
    );

    switch (result) {
      case _CourseCardLongPressResult.share:
        showDialog(
          context: context,
          builder: (context) =>
              ShareThisGroupDialogContent(groupInfo: course.toGroupInfo()),
        );
        break;
      case _CourseCardLongPressResult.edit:
        _logCourseEditViaCourseCardLongPress(analytics);
        openCourseEditPage(context, course);
        break;
      case _CourseCardLongPressResult.leave:
        _logCourseLeaveViaCourseCardLongPress(analytics);
        final bloc = CourseDetailsBloc(
            CourseDetailsBlocGateway(api.course, course), api.userId);
        final isLastMember = (await bloc.members.first).length <= 1;
        final confirmed = await showCourseLeaveDialog(context, isLastMember);
        if (confirmed) {
          final leaveCourseFuture = api.course.leaveCourse(course.id);
          showAppFunctionStateDialog(context, leaveCourseFuture);
        }
        break;
      case _CourseCardLongPressResult.delete:
        _logCourseDeleteViaCourseCardLongPress(analytics);
        final confirmed = await showDeleteCourseDialog(context, course.name);
        if (confirmed) {
          final deleteCourseFunction = api.course.deleteCourse(course.id);
          showAppFunctionStateDialog(context, deleteCourseFunction);
        }
        break;
      default:
        break;
    }
  }

  void _logCourseEditViaCourseCardLongPress(Analytics analytics) {
    analytics.log(NamedAnalyticsEvent(name: "course_edit_via_card_long_press"));
  }

  void _logCourseDeleteViaCourseCardLongPress(Analytics analytics) {
    analytics
        .log(NamedAnalyticsEvent(name: "course_delete_via_card_long_press"));
  }

  void _logCourseLeaveViaCourseCardLongPress(Analytics analytics) {
    analytics
        .log(NamedAnalyticsEvent(name: "course_leave_via_card_long_press"));
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = isUserAdminOrOwnerFromCourse(course.myRole);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 19, vertical: 3),
      onTap: () =>
          openCourseDetailsPageAndShowConfirmationIfSuccessful(context, course),
      leading: CourseCircleAvatar(
          courseId: course.id, abbreviation: course.abbreviation),
      title: Text(course.name),
      trailing: withShareOption ? ShareIconButton(course: course) : null,
      onLongPress: () => onLongPress(context, isAdmin),
    );
  }
}

class CourseCircleAvatar extends StatelessWidget {
  const CourseCircleAvatar(
      {Key key, this.abbreviation, this.courseId, this.heroTag})
      : super(key: key);

  final String courseId;
  final String heroTag;
  final String abbreviation;

  @override
  Widget build(BuildContext context) {
    final courseGateway = BlocProvider.of<SharezoneContext>(context).api.course;
    final course = courseGateway.getCourse(courseId) ?? Course.create();
    final color = course.getDesign().color;
    return Hero(
      tag: heroTag ?? courseId,
      child: CircleAvatar(
        backgroundColor: color.withOpacity(0.20),
        child: Text(
          abbreviation ?? "-",
          style: TextStyle(color: color),
        ),
      ),
    );
  }
}

class ShareIconButton extends StatelessWidget {
  const ShareIconButton({@required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final analytics = BlocProvider.of<SharezoneContext>(context).analytics;
    return IconButton(
      icon: Icon(Theme.of(context).platform == TargetPlatform.iOS
          ? CupertinoIcons.share
          : Icons.share),
      onPressed: () {
        analytics.log(NamedAnalyticsEvent(name: "course_page_share_dialog"));
        showDialog(
          context: context,
          builder: (context) =>
              ShareThisGroupDialogContent(groupInfo: course.toGroupInfo()),
        );
      },
    );
  }
}