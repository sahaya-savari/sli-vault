import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_svg.dart';
import '../../data/vault_controller.dart';
import '../../domain/vault_item.dart';

class AddItemSheet extends StatefulWidget {
  final VaultController controller;
  final VaultItemType initialType;
  final String? initialUrl;
  final String? initialImagePath;

  const AddItemSheet({
    super.key,
    required this.controller,
    this.initialType = VaultItemType.link,
    this.initialUrl,
    this.initialImagePath,
  });

  static Future<VaultItem?> show(
    BuildContext context, {
    required VaultController controller,
    VaultItemType initialType = VaultItemType.link,
    String? initialUrl,
    String? initialImagePath,
  }) {
    return showModalBottomSheet<VaultItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.90,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SliTokens.radiusXl),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.sli.elevated.withValues(alpha: 0.94),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(SliTokens.radiusXl),
                  ),
                  border: Border.all(
                    color: context.sli.border.withValues(alpha: 0.8),
                  ),
                ),
                child: AddItemSheet(
                  controller: controller,
                  initialType: initialType,
                  initialUrl: initialUrl,
                  initialImagePath: initialImagePath,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  late VaultItemType _selectedType;
  late String _selectedCollection;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _selectedFileName;
  String? _errorMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Screenshots are ordinary imported images now. Existing screenshot
    // records retain their type for filters and backup compatibility.
    _selectedType = widget.initialType == VaultItemType.screenshot
        ? VaultItemType.image
        : widget.initialType;
    _selectedCollection = widget.controller.collections.contains('General')
        ? 'General'
        : (widget.controller.collections.firstOrNull ?? 'General');
    if (widget.initialUrl != null) {
      _urlController.text = widget.initialUrl!;
    }
    if (widget.initialImagePath != null) {
      _loadIncomingImage(widget.initialImagePath!);
    }
  }

  Future<void> _loadIncomingImage(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedImageBytes = bytes;
        _selectedFileName = file.uri.pathSegments.last;
      });
    } catch (_) {
      // Temporary shared files may expire; manual picking remains available.
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFile() async {
    setState(() => _errorMessage = null);
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final picker = ImagePicker();
        final XFile? picked = await picker.pickImage(
          source: ImageSource.gallery,
        );
        if (picked != null) {
          final bytes = await picked.readAsBytes();
          if (!mounted) return;
          setState(() {
            _selectedImageBytes = bytes;
            _selectedFileName = picked.name;
          });
          return;
        }
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        Uint8List? bytes = file.bytes;
        if (bytes == null && file.path != null) {
          bytes = await File(file.path!).readAsBytes();
        }
        if (bytes != null) {
          if (!mounted) return;
          setState(() {
            _selectedImageBytes = bytes;
            _selectedFileName = file.name;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not read image from picker: $e';
      });
    }
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    setState(() => _errorMessage = null);

    final tags = VaultValidators.parseTagInput(_tagsController.text);
    final customTitle = _titleController.text.trim();

    if (_selectedType == VaultItemType.link) {
      final urlCheck = VaultValidators.validateAndNormalizeUrl(
        _urlController.text,
      );
      if (!urlCheck.isValid) {
        setState(() => _errorMessage = urlCheck.errorMessage);
        return;
      }

      setState(() => _isSaving = true);
      try {
        final saved = await widget.controller.addLinkItem(
          rawUrl: _urlController.text,
          customTitle: customTitle,
          description: _descriptionController.text,
          tags: tags,
          collection: _selectedCollection,
        );
        if (!mounted) return;
        Navigator.of(context).pop(saved);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isSaving = false;
          _errorMessage = e.toString().replaceFirst('FormatException: ', '');
        });
      }
    } else {
      if (_selectedImageBytes == null) {
        setState(() {
          _errorMessage =
              'Select an image file before saving to your local vault.';
        });
        return;
      }

      setState(() => _isSaving = true);
      try {
        final saved = await widget.controller.addMediaItem(
          type: _selectedType,
          imageBytes: _selectedImageBytes!,
          fileNameHint: _selectedFileName,
          customTitle: customTitle,
          description: _descriptionController.text,
          tags: tags,
          collection: _selectedCollection,
        );
        if (!mounted) return;
        Navigator.of(context).pop(saved);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isSaving = false;
          _errorMessage = e.toString().replaceFirst('FormatException: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SliTokens.spaceLg,
          SliTokens.spaceSm,
          SliTokens.spaceLg,
          SliTokens.spaceLg,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: SliTokens.spaceMd),
                  decoration: BoxDecoration(
                    color: context.sli.border.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add to Vault',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: SliIcon(
                      SliAssets.navClose,
                      size: 20,
                      semanticLabel: 'Close Add Sheet',
                    ),
                  ),
                ],
              ),
              SizedBox(height: SliTokens.spaceMd),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked =
                      constraints.maxWidth < 360 ||
                      MediaQuery.textScalerOf(context).scale(14) > 18;
                  final actions = [
                    _AddTypeAction(
                      type: VaultItemType.link,
                      label: 'Save Link',
                      iconAsset: SliAssets.contentLink,
                    ),
                    _AddTypeAction(
                      type: VaultItemType.image,
                      label: 'Add Image',
                      iconAsset: SliAssets.contentImage,
                    ),
                  ];
                  final buttons = actions
                      .map(
                        (action) => _AddTypeButton(
                          action: action,
                          selected: action.type == _selectedType,
                          enabled: !_isSaving,
                          onTap: () async {
                            setState(() {
                              _selectedType = action.type;
                              _errorMessage = null;
                            });
                            if (action.type == VaultItemType.image) {
                              await _pickImageFile();
                            }
                          },
                        ),
                      )
                      .toList();
                  return stacked
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            buttons.first,
                            SizedBox(height: SliTokens.spaceSm),
                            buttons.last,
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: buttons.first),
                            SizedBox(width: SliTokens.spaceSm),
                            Expanded(child: buttons.last),
                          ],
                        );
                },
              ),
              SizedBox(height: SliTokens.spaceLg),
              if (_selectedType == VaultItemType.link) ...[
                TextField(
                  key: Key('add_url_field'),
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  enabled: !_isSaving,
                  style: TextStyle(color: context.sli.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'URL (https://...)',
                    hintText: 'https://developer.android.com',
                  ),
                ),
                SizedBox(height: SliTokens.spaceMd),
              ] else ...[
                InkWell(
                  key: Key('pick_image_button'),
                  onTap: _isSaving ? null : _pickImageFile,
                  borderRadius: BorderRadius.circular(SliTokens.radiusLg),
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: context.sli.charcoal,
                      borderRadius: BorderRadius.circular(SliTokens.radiusLg),
                      border: Border.all(color: context.sli.border),
                    ),
                    child: _selectedImageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              SliTokens.radiusLg,
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(
                                  _selectedImageBytes!,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  right: 8,
                                  bottom: 8,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.sli.obsidian.withValues(
                                        alpha: 0.85,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        SliTokens.radiusSm,
                                      ),
                                      border: Border.all(
                                        color: context.sli.border,
                                      ),
                                    ),
                                    child: Text(
                                      'Change image',
                                      style: TextStyle(
                                        color: context.sli.textPrimary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SliIcon(
                                _selectedType.iconAsset,
                                size: 32,
                                color: SliTokens.orange,
                              ),
                              SizedBox(height: SliTokens.spaceSm),
                              Text(
                                'Tap to choose a ${_selectedType.label.toLowerCase()}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Copied into durable app-private storage',
                                style: TextStyle(
                                  color: context.sli.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: SliTokens.spaceMd),
              ],
              TextField(
                key: Key('add_title_field'),
                controller: _titleController,
                enabled: !_isSaving,
                style: TextStyle(color: context.sli.textPrimary),
                decoration: InputDecoration(
                  labelText: _selectedType == VaultItemType.link
                      ? 'Title (optional — defaults to domain)'
                      : 'Title (optional)',
                  hintText: 'e.g. Flutter Architecture Guide',
                ),
              ),
              SizedBox(height: SliTokens.spaceMd),
              TextField(
                key: Key('add_description_field'),
                controller: _descriptionController,
                enabled: !_isSaving,
                minLines: 2,
                maxLines: 4,
                style: TextStyle(color: context.sli.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),
              SizedBox(height: SliTokens.spaceMd),
              TextField(
                key: Key('add_tags_field'),
                controller: _tagsController,
                enabled: !_isSaving,
                style: TextStyle(color: context.sli.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Tags (comma-separated, optional)',
                  hintText: 'flutter, design, reference',
                ),
              ),
              SizedBox(height: SliTokens.spaceMd),
              DropdownButtonFormField<String>(
                key: const Key('add_collection_field'),
                initialValue: _selectedCollection,
                dropdownColor: context.sli.elevated,
                style: TextStyle(color: context.sli.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Collection',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12),
                    child: SliIcon(SliAssets.contentCollection, size: 18),
                  ),
                ),
                items: widget.controller.collections
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c,
                          style: TextStyle(color: context.sli.textPrimary),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _isSaving
                    ? null
                    : (val) {
                        if (val != null) {
                          setState(() => _selectedCollection = val);
                        }
                      },
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: SliTokens.spaceMd),
                Container(
                  padding: EdgeInsets.all(SliTokens.spaceMd),
                  decoration: BoxDecoration(
                    color: context.sli.charcoal,
                    borderRadius: BorderRadius.circular(SliTokens.radiusMd),
                    border: Border.all(color: SliTokens.error),
                  ),
                  child: Row(
                    children: [
                      SliIcon(
                        SliAssets.statusError,
                        size: 18,
                        color: SliTokens.error,
                      ),
                      SizedBox(width: SliTokens.spaceSm),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: context.sli.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: SliTokens.spaceLg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: SliTokens.spaceMd),
                  Expanded(
                    flex: 2,
                    child: SliGradientButton(
                      key: Key('save_item_button'),
                      label: _isSaving ? 'Saving...' : 'Save to Vault',
                      iconAsset: SliAssets.actionCheck,
                      isLoading: _isSaving,
                      onPressed: _handleSave,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddTypeAction {
  final VaultItemType type;
  final String label;
  final String iconAsset;

  const _AddTypeAction({
    required this.type,
    required this.label,
    required this.iconAsset,
  });
}

class _AddTypeButton extends StatelessWidget {
  final _AddTypeAction action;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _AddTypeButton({
    required this.action,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: action.label,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(SliTokens.radiusMd),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: SliTokens.minTouchTarget,
          ),
          child: Ink(
            padding: const EdgeInsets.symmetric(
              horizontal: SliTokens.spaceMd,
              vertical: SliTokens.spaceSm,
            ),
            decoration: BoxDecoration(
              gradient: selected ? SliTokens.primaryGradient : null,
              color: selected ? null : context.sli.charcoal,
              borderRadius: BorderRadius.circular(SliTokens.radiusMd),
              border: Border.all(
                color: selected ? SliTokens.orange : context.sli.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SliIcon(
                  action.iconAsset,
                  size: 18,
                  color: selected
                      ? SliTokens.onPrimaryGradient
                      : context.sli.textSecondary,
                ),
                const SizedBox(width: SliTokens.spaceSm),
                Flexible(
                  child: Text(
                    action.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? SliTokens.onPrimaryGradient
                          : context.sli.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
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
