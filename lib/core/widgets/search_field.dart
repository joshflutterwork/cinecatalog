import 'package:cinecatalog/core/theme/app_tokens.dart';
import 'package:cinecatalog/core/widgets/app_icon.dart';
import 'package:cinecatalog/core/widgets/glass.dart';
import 'package:flutter/material.dart';

/// Glass search input with a clear button, used by Search and Popular
/// People.
class SearchField extends StatelessWidget {
  const SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.hintText = 'Search movies, shows, people',
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;

  @override
  Widget build(BuildContext context) => Glass(
    height: 48,
    radius: 24,
    blur: 20,
    color: AppColors.glassBadge,
    borderColor: AppColors.glassBorderStrong,
    shadow: AppShadows.searchField,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        const AppIcon(AppIcons.searchBold, color: AppColors.accent),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: true,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            cursorColor: AppColors.accent,
            style: const TextStyle(
              fontFamily: AppFonts.dmSans,
              fontSize: 14.5,
              color: AppColors.ink,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: AppFonts.dmSans,
                fontSize: 14.5,
                color: AppColors.inkMuted,
              ),
            ),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : Semantics(
                  button: true,
                  label: 'Clear',
                  child: GestureDetector(
                    onTap: onClear,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.clearBg,
                      ),
                      alignment: Alignment.center,
                      child: const AppIcon(
                        AppIcons.close,
                        color: AppColors.inkButton,
                        size: 10,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    ),
  );
}
