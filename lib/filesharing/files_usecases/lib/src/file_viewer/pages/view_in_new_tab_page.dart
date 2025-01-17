// Copyright (c) 2022 Sharezone UG (haftungsbeschränkt)
// Licensed under the EUPL-1.2-or-later.
//
// You may obtain a copy of the Licence at:
// https://joinup.ec.europa.eu/software/page/eupl
//
// SPDX-License-Identifier: EUPL-1.2

import 'package:files_usecases/file_saver.dart';
import 'package:files_web/web_file_open.dart';
import 'package:filesharing_logic/filesharing_gateways.dart';
import 'package:filesharing_logic/filesharing_logic_models.dart';
import 'package:flutter/material.dart';
import '../widgets/file_page_app_bar.dart';

/// Die ViewInNewTabPage ist ein aktueller Ersatz für die WebFilePage, weil das Embedden in Flutter Web
/// mit CanvasKit nicht unterstützt wird.
class ViewInNewTabPage extends StatelessWidget {
  static const String tag = 'ViewInNewTabPage';
  const ViewInNewTabPage(
      {super.key,
      required this.attachment,
      required this.cloudFileAccessor,
      this.actions});

  final CloudFile attachment;
  final CloudFileAccessor cloudFileAccessor;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FilePageAppBar(
        name: attachment.name,
        nameStream: cloudFileAccessor.nameStream(attachment.id!),
        actions: actions,
      ),
      body: FutureBuilder<String>(
        future:
            getFileSaver()!.downloadAndReturnObjectUrl(attachment.downloadURL),
        builder: (context, resultSnapshot) {
          if (resultSnapshot.hasError) {
            return const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
              ),
            );
          }
          if (!resultSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final src = resultSnapshot.data;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                    "Das Darstellen von PDF-Dateien wird vorübergehend nicht unterstützt."
                    " Du kannst dir diese PDF aber in einem neuen Tab ansehen."),
                MaterialButton(
                  child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.open_in_new),
                        SizedBox(width: 8),
                        Text("In neuem Tab öffnen"),
                      ]),
                  onPressed: () {
                    openWebFile(src!, attachment.name);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
