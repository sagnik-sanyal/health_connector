import 'package:flutter/material.dart';
import 'package:health_connector_toolbox/src/common/theme/app_colors.dart';
import 'package:health_connector_toolbox/src/common/widgets/loading_indicator.dart';

/// A widget that displays a gray transparent overlay with a loading indicator
/// in the center. Typically used during button operations like form submission
/// to prevent user interaction while an operation is in progress.
@immutable
final class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    required this.isLoading,
    required this.child,
    super.key,
    this.message,
  });

  /// Whether the overlay should be displayed.
  final bool isLoading;

  /// The child widget to display behind the overlay.
  final Widget child;

  /// Optional message to display below the loading indicator.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // ignore: avoid_redundant_argument_values
      child: Stack(
        children: [
          child,
          if (isLoading)
            Positioned.fill(
              child: AbsorbPointer(
                child: ColoredBox(
                  color: AppColors.grey.withValues(alpha: 0.5),
                  child: LoadingIndicator(message: message),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
