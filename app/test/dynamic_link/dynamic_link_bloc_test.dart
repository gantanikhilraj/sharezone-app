import 'package:dynamic_links/dynamic_links.dart';
import 'package:dynamic_links/test.dart';
import 'package:sharezone/dynamic_links/dynamic_link_bloc.dart';
import 'package:test/test.dart';

void main() {
  group('DynamicLinkBloc', () {
    DynamicLinkBloc bloc;
    LocalDynamicLinks dynamicLinks;
    setUp(() {
      dynamicLinks = LocalDynamicLinks();
      bloc = DynamicLinkBloc(dynamicLinks);
    });

    // Ich weiß nicht wie ich dynamicLinks.onLink stubben kann, daher gehen wir einfach davon aus, dass bei beiden Methoden das selbe gemacht wird.
    test('gibt keinen EinkommendenLink aus, wenn initialLink null emittiert.',
        () async {
      dynamicLinks.getInitialDataReturn = null;
      expect(bloc.einkommendeLinks, neverEmits(anything));
      bloc.dispose();
    });

    test('gibt keinen EinkommendenLink aus, wenn onLink null emittiert.',
        () async {
      dynamicLinks.onLinkSuccessReturn = null;
      expect(bloc.einkommendeLinks, neverEmits(anything));
      bloc.dispose();
    });

    test(
        'gibt einen EinkommendenLink mit typ = "" und keinen Zusatzattributen aus, linkData.link null ist.',
        () async {
      dynamicLinks.getInitialDataReturn = DynamicLinkData(null, null, null);

      await expectBlocEmitsEmptyLink(bloc);
    });
  });
}

Future expectBlocEmitsEmptyLink(DynamicLinkBloc bloc) async {
  await bloc.initialisere();
  final link = await bloc.einkommendeLinks.first;
  expect(link.typ, "");
  expect(link.zusatzinformationen, <String, String>{});
}

DynamicLinkData createMockLinkData(Map<String, String> queryParameters) {
  final url = Uri.https("sharezone.net", "/SOMEPATH/", queryParameters);
  final linkData = DynamicLinkData(url, null, null);
  return linkData;
}