import 'package:flutter/material.dart';

/// Shared page header component with consistent styling
/// Matches the design from the Mindful screen with title, subtitle, and optional action button
class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? actionButton;
  
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        if (actionButton != null) actionButton!,
      ],
    );
  }
}

/// Specialized action button for page headers
/// Creates consistent styling for buttons in the header area
class PageHeaderActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  
  const PageHeaderActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Default colors if not specified
    final bgColor = backgroundColor ?? theme.colorScheme.primaryContainer;
    final fgColor = foregroundColor ?? theme.colorScheme.primary;
    final bdColor = borderColor ?? theme.colorScheme.primary.withValues(alpha: 0.2);
    
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: bdColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: fgColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: fgColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// SOS button specifically for emergency situations
class SOSHeaderButton extends PageHeaderActionButton {
  const SOSHeaderButton({
    super.key,
    required VoidCallback? onTap,
  }) : super(
          label: 'SOS',
          icon: Icons.favorite,
          onTap: onTap,
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PageHeaderActionButton(
      label: label,
      icon: icon,
      backgroundColor: theme.colorScheme.errorContainer,
      foregroundColor: theme.colorScheme.error,
      borderColor: theme.colorScheme.error.withValues(alpha: 0.2),
      onTap: onTap,
    );
  }
}
