import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/project_provider.dart';
import '../../models/project_model.dart';
import '../../models/checkin_model.dart';

/// Premium Add Check-in Page
class AddCheckinPage extends StatefulWidget {
  final String? projectId;

  const AddCheckinPage({super.key, this.projectId});

  @override
  State<AddCheckinPage> createState() => _AddCheckinPageState();
}

class _AddCheckinPageState extends State<AddCheckinPage> {
  final _noteController = TextEditingController();
  final _nameController = TextEditingController();
  ProjectStatus _selectedStatus = ProjectStatus.active;

  @override
  void dispose() {
    _noteController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_noteController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final checkIn = CheckIn(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: widget.projectId ?? '',
      status: _selectedStatus,
      note: _noteController.text.trim(),
      timestamp: DateTime.now(),
      reporterName: _nameController.text.trim(),
    );

    if (widget.projectId != null) {
      context.read<ProjectProvider>().addCheckIn(widget.projectId!, checkIn);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          AppStrings.addNewCheckin,
          style: AppTypography.headlineSmall,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status selection
            Text(
              AppStrings.selectStatus,
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildStatusSelection(),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Note input
            Text(
              AppStrings.whatDidYouObserve,
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildNoteInput(),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Name input
            Text(
              AppStrings.yourName,
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildNameInput(),
            
            const SizedBox(height: AppSpacing.xxl),
            
            // Submit button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelection() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: ProjectStatus.values.map((status) {
        final isSelected = _selectedStatus == status;
        return GestureDetector(
          onTap: () => setState(() => _selectedStatus = status),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected 
                  ? _getStatusColor(status).withValues(alpha: 0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isSelected 
                    ? _getStatusColor(status)
                    : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: _getStatusColor(status),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  status.label,
                  style: AppTypography.labelLarge.copyWith(
                    color: isSelected 
                        ? _getStatusColor(status)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoteInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _noteController,
        maxLines: 5,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: AppStrings.addNote,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppSpacing.md),
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _nameController,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Enter your name',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.slate900,
          foregroundColor: AppColors.textInverse,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          elevation: 0,
        ),
        child: Text(
          AppStrings.submit,
          style: AppTypography.button.copyWith(
            color: AppColors.textInverse,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return AppColors.green600;
      case ProjectStatus.slowing:
        return AppColors.amber600;
      case ProjectStatus.stalled:
        return AppColors.red600;
      case ProjectStatus.unverified:
        return AppColors.gray600;
    }
  }
}
