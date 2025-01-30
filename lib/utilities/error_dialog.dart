import 'package:flutter/material.dart';
import 'package:kavruk/utilities/generic_dialog.dart';


Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericDialog<void>(
    context: context,
    title: 'An Error Occurred',
    content: text,
    optionBuilder: () => const {'OK': null},
  );
}
