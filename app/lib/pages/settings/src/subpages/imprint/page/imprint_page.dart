import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:sharezone/groups/src/widgets/contact_support.dart';
import 'package:sharezone/pages/settings/src/subpages/imprint/bloc/imprint_bloc.dart';
import 'package:sharezone/pages/settings/src/subpages/imprint/bloc/imprint_bloc_factory.dart';
import 'package:sharezone/pages/settings/src/subpages/imprint/models/imprint.dart';
import 'package:sharezone/util/launch_link.dart';

class ImprintPage extends StatefulWidget {
  static const tag = 'imprint-page';

  @override
  _ImprintPageState createState() => _ImprintPageState();
}

class _ImprintPageState extends State<ImprintPage> {
  ImprintBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<ImprintBlocFactory>(context).create();
  }

  @override
  Widget build(BuildContext context) {
    final offlineData = Imprint.offline().asMarkdown;
    return Scaffold(
      appBar: AppBar(title: Text("Impressum")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: SafeArea(
          child: StreamBuilder<String>(
            initialData: offlineData,
            stream: bloc.markdownStream,
            builder: (context, snapshot) {
              final data = snapshot.data ?? offlineData;
              return MarkdownBody(
                data: data,
                onTapLink: (link) => launchURL(link),
                selectable: true,
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: ContactSupport(),
    );
  }
}