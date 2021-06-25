import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_domain_models/group_domain_models.dart';
import 'package:sharezone/groups/src/widgets/sharecode_text.dart';

void main() {
  group('SharecodeText', () {
    Future<void> _pumpSharecodeText({
      @required WidgetTester tester,
      @required String sharecode,
      VoidCallback onCopied,
    }) async {
      assert(tester != null && sharecode != null);

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Scaffold(
              body: SharecodeText(
                sharecode,
                onCopied: onCopied,
              ),
            ),
          ),
        ),
      );
    }

    final sharecode = Sharecode('123456');

    testWidgets(
        'shows copy confirmation SnackBar, if user taps on SharecodeText',
        (tester) async {
      await _pumpSharecodeText(tester: tester, sharecode: sharecode.toString());

      await tester.tap(find.byType(SharecodeText));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets(
        'shows copy confirmation SnackBar, if user presses long on SharecodeText',
        (tester) async {
      await _pumpSharecodeText(tester: tester, sharecode: sharecode.toString());

      await tester.longPress(find.byType(SharecodeText));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('runs onCopied, if user taps on SharecodeText', (tester) async {
      bool logTapped = false;

      await _pumpSharecodeText(
        tester: tester,
        sharecode: sharecode.toString(),
        onCopied: () => logTapped = true,
      );

      await tester.tap(find.byType(SharecodeText));
      await tester.pump();

      expect(logTapped, true);
    });

    testWidgets('runs onCopied, if user presses long on SharecodeText',
        (tester) async {
      bool logPressedLong = false;

      await _pumpSharecodeText(
        tester: tester,
        sharecode: sharecode.toString(),
        onCopied: () => logPressedLong = true,
      );

      await tester.longPress(find.byType(SharecodeText));
      await tester.pump();

      expect(logPressedLong, true);
    });

    group('spells out the sharecode for screen readers:', () {
      Finder _findSemanticsWidgetWith({@required String spelledOutSharecode}) {
        return find.bySemanticsLabel('Sharecode: $spelledOutSharecode');
      }

      Future<void> testThat({
        @required String sharecode,
        @required String isSpelledOutAs,
        @required WidgetTester tester,
      }) async {
        await _pumpSharecodeText(tester: tester, sharecode: sharecode);

        final finder =
            _findSemanticsWidgetWith(spelledOutSharecode: isSpelledOutAs);

        expect(finder, findsOneWidget);
      }

      testWidgets('Sharecode 00000 (numbers are not written out)',
          (tester) async {
        await testThat(
          sharecode: '00000',
          isSpelledOutAs: '0, 0, 0, 0, 0',
          tester: tester,
        );
      });

      testWidgets('Sharecode AdB23c', (tester) async {
        await testThat(
          sharecode: 'AdB23c',
          isSpelledOutAs: 'großes A, kleines d, großes B, 2, 3, kleines c',
          tester: tester,
        );
      });

      testWidgets('Sharecode 123a4v', (tester) async {
        await testThat(
          sharecode: '123a4v',
          isSpelledOutAs: '1, 2, 3, kleines a, 4, kleines v',
          tester: tester,
        );
      });
    });
  });
}