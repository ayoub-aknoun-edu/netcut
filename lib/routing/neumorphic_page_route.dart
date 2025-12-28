import 'package:flutter/material.dart';

class NeumorphicPageRoute<T> extends MaterialPageRoute<T> {
  NeumorphicPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
         builder: builder,
         settings: settings,
         maintainState: maintainState,
         fullscreenDialog: fullscreenDialog,
       );
}
