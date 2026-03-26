import 'package:flutter/material.dart';

import 'widgets/blank_page_view_wrapper.dart';


class BlankPageViewWithScaffold extends StatelessWidget {
  const BlankPageViewWithScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) =>
      BlankPageViewWrapper(
        withScaffold: true,
      );
}
