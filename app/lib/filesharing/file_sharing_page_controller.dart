import 'package:bloc_provider/bloc_provider.dart';
import 'package:filesharing_logic/filesharing_logic_models.dart';
import 'package:flutter/material.dart';
import 'package:sharezone/filesharing/models/file_sharing_page_state.dart';
import 'package:sharezone/filesharing/widgets/file_sharing_page_header.dart';
import 'package:sharezone/navigation/logic/navigation_bloc.dart';
import 'package:sharezone/navigation/models/navigation_item.dart';
import 'package:sharezone/navigation/scaffold/app_bar_configuration.dart';
import 'package:sharezone/navigation/scaffold/sharezone_main_scaffold.dart';

import 'file_sharing_view_group.dart';
import 'file_sharing_view_home.dart';
import 'logic/file_sharing_page_state_bloc.dart';
import 'widgets/file_sharing_page_fab.dart';

class FileSharingPageController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pageStateBloc = BlocProvider.of<FileSharingPageStateBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        final pageState = pageStateBloc.currentStateValue;
        if (pageState is FileSharingPageStateGroup) {
          final stateBloc = BlocProvider.of<FileSharingPageStateBloc>(context);
          if (pageState.path == FolderPath.root) {
            final newState = FileSharingPageStateHome();
            stateBloc.changeStateTo(newState);
          } else {
            final newState = FileSharingPageStateGroup(
              initialFileSharingData: pageState.initialFileSharingData,
              groupID: pageState.groupID,
              path: pageState.path.getParentPath(),
            );
            stateBloc.changeStateTo(newState);
          }
          return false;
        } else {
          return popToOverview(context);
        }
      },
      child: StreamBuilder<FileSharingPageState>(
          initialData: FileSharingPageStateHome(),
          stream: pageStateBloc.currentState,
          builder: (context, snapshot) {
            final pageState = snapshot.data;

            return SharezoneMainScaffold(
              navigationItem: NavigationItem.filesharing,
              appBarConfiguration: AppBarConfiguration(
                bottom: FileSharingPageHeader(pageState: pageState),
              ),
              body: FileSharingPageBody(pageState: pageState),
              floatingActionButton: pageState is FileSharingPageStateGroup
                  ? FileSharingPageFAB(groupState: pageState)
                  : null,
            );
          }),
    );
  }
}

class FileSharingPageBody extends StatelessWidget {
  final FileSharingPageState pageState;

  const FileSharingPageBody({Key key, this.pageState}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Align(
        key: ValueKey(pageState is FileSharingPageStateGroup),
        alignment: Alignment.topCenter,
        child: pageState is FileSharingPageStateGroup
            ? FileSharingViewGroup(groupState: pageState)
            : FileSharingViewHome(),
      ),
    );
  }
}