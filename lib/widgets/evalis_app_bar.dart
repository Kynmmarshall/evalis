import 'package:flutter/material.dart';

import 'language_menu_button.dart';
import 'theme_toggle_button.dart';

class EvalisAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EvalisAppBar({required this.title, this.showBack = true, super.key});

  final String title;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      actions: const [ThemeToggleButton(), LanguageMenuButton()],
    );
  }
}
