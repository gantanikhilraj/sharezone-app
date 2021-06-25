import 'package:flutter/material.dart';
import 'package:sharezone/account/features/features_bloc.dart';
import 'package:sharezone/additional/course_permission.dart';
import 'package:sharezone/blocs/application_bloc.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:design/design.dart';
import 'package:sharezone/groups/src/pages/course/course_edit/design/src/bloc/course_edit_design_bloc.dart';
import 'package:sharezone_widgets/snackbars.dart';

part 'src/dialog/select_design_dialog.dart';
part 'src/dialog/select_type_dialog.dart';

enum _EditDesignType {
  course,
  personal,
}

Future<void> editCourseDesign(BuildContext context, String courseId) async {
  final courseGateway = BlocProvider.of<SharezoneContext>(context).api.course;
  final bloc = CourseEditDesignBloc(courseId, courseGateway);

  final selectTypePopResult = await showDialog<_SelectTypePopResult>(
      context: context, builder: (context) => _SelectTypeDialog(bloc: bloc));

  if (selectTypePopResult != null) {
    final initalDesign = selectTypePopResult.initalDesign;

    final selectDesignPopResult = await _selectDesign(context, initalDesign,
        type: selectTypePopResult.editDesignType);

    if (selectDesignPopResult != null) {
      if (selectDesignPopResult.navigateBackToSelectType) {
        editCourseDesign(context, courseId);
      } else if (selectDesignPopResult.removePersonalColor) {
        bloc.removePersonalDesign();
        showSnackSec(
          context: context,
          text: "Persönliche Farbe wurde entfernt.",
          seconds: 2,
        );
      } else if (selectDesignPopResult.design != null) {
        if (selectTypePopResult.editDesignType == _EditDesignType.personal) {
          bloc.submitPersonalDesign(
              selectedDesign: selectDesignPopResult.design,
              initalDesign: initalDesign);
          showSnackSec(
            context: context,
            text: "Persönliche Farbe wurde gesetzt.",
            seconds: 2,
          );
        } else if (selectTypePopResult.editDesignType ==
            _EditDesignType.course) {
          sendDataToFrankfurtSnackBar(context);
          await bloc.submitCourseDesign(
              selectedDesign: selectDesignPopResult.design,
              initalDesign: initalDesign);
          showSnackSec(
            context: context,
            text: "Farbe wurde erfolgreich für den gesamten Kurs geändert.",
            seconds: 2,
          );
        }
      }
    }
  }
}