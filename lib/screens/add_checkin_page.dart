import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../providers/project_provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../models/project_model.dart';
import '../models/checkin_model.dart';
import '../config/app_config.dart';
import '../services/storage_service.dart';

enum _ImageSourceOption { camera, gallery, files }

class AddCheckinPage extends StatefulWidget {
  final String projectId;

  const AddCheckinPage({super.key, required this.projectId});

  @override
  State<AddCheckinPage> createState() => _AddCheckinPageState();
}

class _AddCheckinPageState extends State<AddCheckinPage> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  ProjectStatus _selectedStatus = ProjectStatus.active;
  File? _pickedImage;
  bool _isSubmitting = false;

  final ImagePicker _imagePicker = ImagePicker();
  static const _uuid = Uuid();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<_ImageSourceOption>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(ctx, _ImageSourceOption.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, _ImageSourceOption.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.folder_rounded),
              title: const Text('Choose from Files (Downloads)'),
              onTap: () => Navigator.pop(ctx, _ImageSourceOption.files),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    if (source == _ImageSourceOption.files) {
      await _pickImageFromFiles();
      return;
    }

    try {
      final picked = await _imagePicker.pickImage(
        source: source == _ImageSourceOption.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _pickedImage = File(picked.path));
      }
    } catch (e) {
      _showImageError('Could not pick image: $e');
    }
  }

  Future<void> _pickImageFromFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: false,
      );

      if (result == null) return;

      final selectedPath = result.files.single.path;
      if (selectedPath == null) {
        _showImageError('Could not read selected file path.');
        return;
      }

      setState(() => _pickedImage = File(selectedPath));
    } catch (e) {
      _showImageError('Could not pick image from files: $e');
    }
  }

  void _showImageError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _statusDescription(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return 'Work is clearly progressing';
      case ProjectStatus.slowing:
        return 'Some work but pace has reduced';
      case ProjectStatus.stalled:
        return 'No visible work activity';
      case ProjectStatus.unverified:
        return 'Unable to determine status';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      String? photoUrl;

      // Upload photo if picked and in firebase mode
      if (_pickedImage != null &&
          AppConfig.runtimeDataMode == DataMode.firebase) {
        final auth = context.read<app_auth.AuthProvider>();
        final userId = auth.currentUser?.id ?? 'anonymous';
        photoUrl = await StorageService().uploadCheckInPhoto(
          userId: userId,
          projectId: widget.projectId,
          imageFile: _pickedImage!,
        );
      } else if (_pickedImage != null) {
        // In mock mode, use local path as placeholder
        photoUrl = _pickedImage!.path;
      }

      if (!mounted) return;
      final auth = context.read<app_auth.AuthProvider>();
      final checkIn = CheckIn(
        id: _uuid.v4(),
        projectId: widget.projectId,
        status: _selectedStatus,
        note: _noteController.text.trim(),
        photoUrl: photoUrl,
        photoUrls: photoUrl != null ? [photoUrl] : [],
        timestamp: DateTime.now(),
        reporterName: auth.currentUser?.name ?? 'Anonymous',
        userId: auth.currentUser?.id,
      );

      if (mounted) {
        context.read<ProjectProvider>().addCheckIn(widget.projectId, checkIn);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Check-in submitted successfully!'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF22C55E),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Color _statusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return const Color(0xFF22C55E);
      case ProjectStatus.slowing:
        return const Color(0xFFEAB308);
      case ProjectStatus.stalled:
        return const Color(0xFFEF4444);
      case ProjectStatus.unverified:
        return const Color(0xFF9CA3AF);
    }
  }

  IconData _statusIcon(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return Icons.check_circle_outline_rounded;
      case ProjectStatus.slowing:
        return Icons.speed_rounded;
      case ProjectStatus.stalled:
        return Icons.pause_circle_outline_rounded;
      case ProjectStatus.unverified:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Add Check-in',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Project info
            Consumer<ProjectProvider>(
              builder: (context, provider, _) {
                final project = provider.getProjectById(widget.projectId);
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF1A1A2E).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.business_rounded,
                            color: Color(0xFF1A1A2E), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              project.location,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Status selection
            const Text(
              'What did you observe?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select the status that best describes what you saw',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 12),
            ...ProjectStatus.values.map((status) {
              final isSelected = status == _selectedStatus;
              final color = _statusColor(status);
              return GestureDetector(
                onTap: () => setState(() => _selectedStatus = status),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? color : const Color(0xFFE5E7EB),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _statusIcon(status),
                        color: isSelected ? color : const Color(0xFF9CA3AF),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              status.label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? color
                                    : const Color(0xFF374151),
                              ),
                            ),
                            Text(
                              _statusDescription(status),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded,
                            color: color, size: 22),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),

            // Note
            const Text(
              'Your observations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe what you saw at the site (required)...',
                hintStyle:
                    const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFF1A1A2E), width: 1.5),
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please add a note' : null,
            ),
            const SizedBox(height: 20),

            // Photo picker
            const Text(
              'Add a photo (optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: _pickedImage != null ? 200 : 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    style: _pickedImage != null
                        ? BorderStyle.solid
                        : BorderStyle.solid,
                  ),
                ),
                child: _pickedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_pickedImage!, fit: BoxFit.cover),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _pickedImage = null),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.camera_alt_rounded,
                                  color: Color(0xFF6B7280), size: 28),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap to add a photo',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Take a photo, gallery, or Downloads file',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 28),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A2E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF1A1A2E).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit Check-in',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 18, color: Color(0xFF9CA3AF)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your check-in is attributed to your account. Please provide factual observations only.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
