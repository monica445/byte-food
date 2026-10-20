import 'package:flutter/material.dart';

class AppAuthForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> children;

  const AppAuthForm({super.key, required this.formKey, required this.children});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
