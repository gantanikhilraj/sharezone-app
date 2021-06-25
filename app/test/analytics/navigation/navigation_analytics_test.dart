import 'package:analytics/analytics.dart';
import 'package:sharezone/navigation/analytics/events/drawer_event.dart';
import 'package:sharezone/navigation/analytics/events/nav_bottom_bar_event.dart';
import 'package:test/test.dart';

import '../analytics_test.dart';

void main() {
  group('navigation analytics', () {
    LocalAnalyticsBackend backend;
    Analytics analytics;

    setUp(() {
      backend = LocalAnalyticsBackend();
      analytics = Analytics(backend);
    });

    test(
        'A navigation analytics logs a drawer tile click with the correct suffix',
        () {
      final event = DrawerEvent("event");

      analytics.log(event);

      expect(backend.getEvent("navigation_drawer_event"), [
        {"navigation_drawer_event": {}}
      ]);
    });

    test(
        'A navigation analytics logs a nav bottom bar click with the correct suffix',
        () {
      final event = NavBottomBar("event");

      analytics.log(event);

      expect(backend.getEvent("navigation_nav_bottom_bar_event"), [
        {"navigation_nav_bottom_bar_event": {}}
      ]);
    });
  });
}