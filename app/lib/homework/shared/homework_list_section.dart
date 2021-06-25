import 'package:flutter/material.dart';
import 'package:sharezone/homework/shared/animated_staggered_scroll_view.dart';
import 'package:sharezone_common/helper_functions.dart';

/// A List of homeworks with a leading title.
///
/// In the HomeworkPage several [HomeworkListSection] are used to group homeworks
/// together, e.g. by subject.
///
/// If [homeworkSection.title] is null or empty no title will be shown.
class HomeworkListSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const HomeworkListSection({
    Key key,
    @required this.title,
    @required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final curve = Curves.easeOutSine;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (isNotEmptyOrNull(title))
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 12, top: 8),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                key: const Key("homework_subcategory_title"),
              ),
            ),
          ),
        AnimatedStaggeredScrollView(
          children: [
            for (final child in children)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 255),
                switchInCurve: curve,
                switchOutCurve: curve,
                child: child,
              )
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}