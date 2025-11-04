import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title; // Changed from String to Widget
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color titleColor;
  final Color iconColor;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixPressed;

  const CustomAppBar({
    Key? key,
    required this.title, // Now accepts Widget
    this.onBackPressed,
    this.actions,
    this.backgroundColor = Colors.white,
    this.titleColor = Colors.black,
    this.iconColor = Colors.black,
    this.suffixIcon,
    this.onSuffixPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: _buildLeadingIcon(),
      title: title, // Use the podcast widget directly
      centerTitle: true,
      actions: _buildActions(),
    );
  }

  Widget _buildLeadingIcon() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onBackPressed ?? () => Get.back(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: iconColor,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    final List<Widget> actionWidgets = [];

    if (suffixIcon != null) {
      actionWidgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: onSuffixPressed,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: suffixIcon,
            ),
          ),
        ),
      );
    }

    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    return actionWidgets;
  }
}