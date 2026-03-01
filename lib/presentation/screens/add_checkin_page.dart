import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../auth/login_guard.dart';
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
  final _projectSearchController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  ProjectStatus _selectedStatus = ProjectStatus.active;
  String? _selectedProjectId;
  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.projectId;
  }

  @override
  void dispose() {
    _noteController.dispose();
    _projectSearchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 1600,
    );
    if (picked == null) return;
    setState(() => _selectedImage = File(picked.path));
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openProjectPickerSheet(List<Project> projects) {
    _projectSearchController.clear();
    String query = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredProjects = projects.where((p) {
              final normalized = query.toLowerCase().trim();
              if (normalized.isEmpty) return true;
              return p.name.toLowerCase().contains(normalized) ||
                  p.location.toLowerCase().contains(normalized);
            }).toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  top: AppSpacing.md,
                  bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
                ),
                child: SizedBox(
                  height: 460,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select project',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _projectSearchController,
                        onChanged: (value) {
                          setModalState(() => query = value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search project name or location',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.sm,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Expanded(
                        child: filteredProjects.isEmpty
                            ? Center(
                                child: Text(
                                  'No matching projects',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: filteredProjects.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final project = filteredProjects[index];
                                  final isSelected = _selectedProjectId == project.id;
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xs,
                                      vertical: 2,
                                    ),
                                    title: Text(
                                      project.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight:
                                            isSelected ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      project.location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.captionMedium,
                                    ),
                                    trailing: isSelected
                                        ? const Icon(
                                            Icons.check_circle_rounded,
                                            color: AppColors.green600,
                                          )
                                        : null,
                                    onTap: () {
                                      setState(() => _selectedProjectId = project.id);
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!await requireLogin(context)) return;
    if (!mounted) return;

    final projectId = _selectedProjectId;
    if (projectId == null || projectId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project.')),
      );
      return;
    }

    final note = _noteController.text.trim();
    if (note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your observation.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login and try again.')),
      );
      return;
    }

    final userEmail = user.email ?? '';
    final userName = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : (userEmail.isNotEmpty ? userEmail : 'Community User');

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('checkins').add({
        'projectId': projectId,
        'status': _selectedStatus.label,
        'note': note,
        'userId': user.uid,
        'userName': userName,
        'userEmail': userEmail,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final checkIn = CheckIn(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: projectId,
        status: _selectedStatus,
        note: note,
        timestamp: DateTime.now(),
        reporterName: userName,
      );
      if (!mounted) return;
      context.read<ProjectProvider>().addCheckIn(projectId, checkIn);
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit check-in. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
            if (widget.projectId == null) ...[
              Text(
                'Select project',
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildProjectSelector(),
              const SizedBox(height: AppSpacing.xl),
            ],
            Text(
              AppStrings.selectStatus,
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildStatusSelection(),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppStrings.whatDidYouObserve,
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildNoteInput(),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Add photo',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildImageInput(),
            const SizedBox(height: AppSpacing.xxl),
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
                color: isSelected ? _getStatusColor(status) : AppColors.border,
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
                    color: isSelected ? _getStatusColor(status) : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProjectSelector() {
    return Consumer<ProjectProvider>(
      builder: (context, provider, _) {
        final projects = provider.filteredProjects.isNotEmpty
            ? provider.filteredProjects
            : provider.activeProjects;
        final selectedProject = projects
            .where((p) => p.id == _selectedProjectId)
            .cast<Project?>()
            .firstWhere(
              (p) => p != null,
              orElse: () => provider.filteredProjects
                  .where((p) => p.id == _selectedProjectId)
                  .cast<Project?>()
                  .firstWhere((p) => p != null, orElse: () => null),
            );

        return InkWell(
          onTap: () => _openProjectPickerSheet(projects),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedProject?.name ?? 'Choose a project',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      color: selectedProject != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        );
      },
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

  Widget _buildImageInput() {
    if (_selectedImage == null) {
      return InkWell(
        onTap: _showImageSourceSheet,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.add_a_photo_outlined,
                size: 28,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tap to upload image',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusMd),
            ),
            child: Image.file(
              _selectedImage!,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showImageSourceSheet,
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Change'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _selectedImage = null),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Remove'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.slate900,
          foregroundColor: AppColors.textInverse,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
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
