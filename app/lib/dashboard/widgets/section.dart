part of '../dashboard_page.dart';

class _Section extends StatelessWidget {
  const _Section({Key key, this.title, this.child}) : super(key: key);

  final Widget title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SafeArea(
          top: false,
          left: true,
          right: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 12, 6),
            child: DefaultTextStyle(
              child: title,
              style: TextStyle(
                color: isDarkThemeEnabled(context)
                    ? Colors.lightBlue
                    : darkBlueColor,
                fontSize: 18,
                fontFamily: rubik,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        child,
      ],
    );
  }
}