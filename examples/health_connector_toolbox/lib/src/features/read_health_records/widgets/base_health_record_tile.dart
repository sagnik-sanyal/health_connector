import 'package:flutter/material.dart';
import 'package:health_connector_core/health_connector_core.dart' show Metadata;
import 'package:health_connector_toolbox/src/common/constants/app_icons.dart';
import 'package:health_connector_toolbox/src/common/constants/app_texts.dart';
import 'package:health_connector_toolbox/src/common/theme/app_colors.dart'
    as theme;
import 'package:health_connector_toolbox/src/features/read_health_records/widgets/health_record_metadata_info.dart';

/// A base widget for displaying health records in an expandable tile format.
///
/// This widget provides common functionality for all health record types
/// including:
/// - Expandable tile with custom icon, title, and subtitle
/// - Delete button
/// - Expansion indicator (rotating chevron)
/// - Common detail section layout with metadata
@immutable
final class BaseHealthRecordTile extends StatefulWidget {
  const BaseHealthRecordTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.detailRows,
    required this.metadata,
    required this.onDelete,
    super.key,
  });

  final IconData icon;
  final String title;
  final Widget subtitle;
  final List<Widget> detailRows;
  final Metadata metadata;
  final VoidCallback onDelete;

  @override
  State<BaseHealthRecordTile> createState() => _BaseHealthRecordTileState();
}

class _BaseHealthRecordTileState extends State<BaseHealthRecordTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).primaryColor.withValues(alpha: 0.1),
          child: Icon(widget.icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: widget.subtitle,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(AppIcons.delete, color: theme.AppColors.grey400),
              onPressed: widget.onDelete,
            ),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                AppIcons.expandMore,
                color: theme.AppColors.grey600,
              ),
            ),
          ],
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Text(
                  AppTexts.recordDetails,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                ...widget.detailRows,
                const SizedBox(height: 8),
                HealthRecordMetadataInfo(metadata: widget.metadata),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
