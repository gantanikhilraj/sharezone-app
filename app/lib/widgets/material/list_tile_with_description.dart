import 'package:flutter/material.dart';
import 'package:sharezone_widgets/theme.dart';

class ListTileWithDescription extends StatelessWidget {
  const ListTileWithDescription({
    Key key,
    @required this.title,
    this.description,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.leading,
    this.trailing,
    this.subtitle,
    this.bottomPadding = 8,
  })  : assert(bottomPadding != null),
        super(key: key);

  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDoubleTap;

  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final Widget trailing;
  final Widget description;

  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: leading,
            title: title,
            subtitle: subtitle,
            trailing: trailing,
          ),
          if (description != null)
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: isDarkThemeEnabled(context)
                      ? Colors.white54
                      : Colors.black45,
                  fontSize: 12,
                  fontFamily: rubik,
                ),
                child: description,
              ),
            )
        ],
      ),
    );
  }
}