import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';

/// Screen for editing a photo's metadata (title, description, tags, date).
class EditMetadataScreen extends StatefulWidget {
  const EditMetadataScreen({
    super.key,
    this.initialTitle = '',
    this.initialDescription = '',
    this.initialLocation = '',
  });

  final String initialTitle;
  final String initialDescription;
  final String initialLocation;

  @override
  State<EditMetadataScreen> createState() => _EditMetadataScreenState();
}

class _EditMetadataScreenState extends State<EditMetadataScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  final _tagsController = TextEditingController();
  final List<String> _tags = ['Photography', 'Urban'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
    _locationController = TextEditingController(text: widget.initialLocation);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagsController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        title: Text(
          'Edit Metadata',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'SAVE',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // ── Title ───────────────────────────────────────
            _buildLabel(context, 'TITLE'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.onSurface),
              decoration: const InputDecoration(hintText: 'Photo title'),
            ),

            const SizedBox(height: 24),

            // ── Location ────────────────────────────────────
            _buildLabel(context, 'LOCATION'),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              style: const TextStyle(color: AppColors.onSurface),
              decoration: const InputDecoration(
                hintText: 'Where was this taken?',
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Description ─────────────────────────────────
            _buildLabel(context, 'DESCRIPTION'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.onSurface),
              decoration: const InputDecoration(
                hintText: 'Tell the story behind this moment...',
              ),
            ),

            const SizedBox(height: 24),

            // ── Tags ────────────────────────────────────────
            _buildLabel(context, 'TAGS'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._tags.map(
                  (tag) => Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeTag(tag),
                    backgroundColor: AppColors.surfaceContainerHighest,
                    labelStyle:
                        const TextStyle(color: AppColors.onSurface, fontSize: 12),
                    deleteIconColor: AppColors.onSurfaceVariant,
                    shape: const StadiumBorder(),
                    side: BorderSide.none,
                  ),
                ),
                // Add tag button
                GestureDetector(
                  onTap: () => _showAddTagDialog(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 16,
                          color:
                              AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Add tag',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Date ────────────────────────────────────────
            _buildLabel(context, 'DATE'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'March 24, 2026',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ── CTA ─────────────────────────────────────────
            Center(
              child: GradientButton(
                label: 'Save Changes',
                icon: Icons.save_outlined,
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.onSurfaceVariant,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _showAddTagDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add Tag',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: AppColors.onSurface),
        ),
        content: TextField(
          controller: _tagsController,
          autofocus: true,
          style: const TextStyle(color: AppColors.onSurface),
          decoration: const InputDecoration(hintText: 'Tag name'),
          onSubmitted: (_) {
            _addTag();
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              _addTag();
              Navigator.pop(ctx);
            },
            child: const Text('Add',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
