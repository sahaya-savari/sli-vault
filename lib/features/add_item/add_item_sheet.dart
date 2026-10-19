import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_svg.dart';
import '../../data/link_metadata_service.dart';
import '../../data/local_image_storage.dart';
import '../../data/vault_controller.dart';
import '../../domain/vault_item.dart';

/// Bottom sheet for saving a link or an image into the vault.
///
/// Mode policy (Link <-> Image):
/// * Shared fields (title, description, tags, collection) are always kept when
///   switching modes.
/// * Mode-specific input (the URL text, the picked image) is kept in memory
///   while the sheet is open so switching back never loses it, but only the
///   *active* mode's input is validated and saved - the hidden mode's input is
///   never written to the database or image store.
/// * Switching modes clears any stale validation message.
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
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.92,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SliTokens.radiusXl),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.sli.elevated.withValues(alpha: 0.98),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(SliTokens.radiusXl),
                ),
                border: Border.all(color: context.sli.border),
              ),
              // Material gives InkWell/Ink descendants a surface that is
              // *above* the sheet decoration (an Ink painted on the route's
              // Material would be hidden underneath it).
              child: Material(
                type: MaterialType.transparency,
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
  String? _urlError;
  String? _errorMessage;
  bool _isSaving = false;
  bool _isPicking = false;
  bool _isFetchingMetadata = false;
  LinkMetadata? _fetchedMetadata;
  Timer? _metadataDebounceTimer;
  String? _lastFetchedUrl;
  String? _metadataFeedbackMessage;

  bool get _isLinkMode => _selectedType == VaultItemType.link;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType == VaultItemType.screenshot
        ? VaultItemType.image
        : widget.initialType;
    _selectedCollection = widget.controller.collections.contains('General')
        ? 'General'
        : (widget.controller.collections.firstOrNull ?? 'General');

    _urlController.addListener(_onUrlChanged);

    if (widget.initialUrl != null) {
      final extracted = VaultValidators.extractUrlFromText(widget.initialUrl!);
      if (extracted.url != null) {
        _urlController.text = extracted.url!;
        if (extracted.remainingText != null &&
            extracted.remainingText!.isNotEmpty) {
          _descriptionController.text = extracted.remainingText!;
        }
      } else {
        _urlController.text = widget.initialUrl!;
      }
      if (widget.controller.autoFetchMetadata &&
          _urlController.text.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tryFetchMetadata();
        });
      }
    }
    if (widget.initialImagePath != null) {
      _loadIncomingImage(widget.initialImagePath!);
    }
  }

  void _onUrlChanged() {
    if (_urlError != null) {
      setState(() => _urlError = null);
    }
    if (!_isLinkMode || !widget.controller.autoFetchMetadata) return;

    final text = _urlController.text.trim();
    final check = VaultValidators.validateAndNormalizeUrl(text);
    if (!check.isValid || check.normalizedUrl == null) return;
    if (check.normalizedUrl == _lastFetchedUrl) return;

    _metadataDebounceTimer?.cancel();
    _metadataDebounceTimer = Timer(const Duration(milliseconds: 650), () {
      if (mounted && _isLinkMode) {
        _tryFetchMetadata();
      }
    });
  }

  Future<void> _tryFetchMetadata({bool isManual = false}) async {
    final text = _urlController.text.trim();
    final check = VaultValidators.validateAndNormalizeUrl(text);
    if (!check.isValid || check.normalizedUrl == null) {
      if (isManual && mounted) {
        setState(() {
          _urlError = check.errorMessage ?? 'Enter a valid URL first.';
        });
      }
      return;
    }
    if (_isFetchingMetadata) return;

    _metadataDebounceTimer?.cancel();
    setState(() {
      _isFetchingMetadata = true;
      _metadataFeedbackMessage = null;
    });

    try {
      final meta = await LinkMetadataService.fetchMetadata(
        check.normalizedUrl!,
      );
      if (!mounted) return;
      _lastFetchedUrl = check.normalizedUrl;
      setState(() {
        _fetchedMetadata = meta;
        if (meta.hasContent) {
          if (_titleController.text.trim().isEmpty &&
              meta.title != null &&
              meta.title!.isNotEmpty) {
            _titleController.text = meta.title!;
          }
          if (_descriptionController.text.trim().isEmpty &&
              meta.description != null &&
              meta.description!.isNotEmpty) {
            _descriptionController.text = meta.description!;
          }
          _metadataFeedbackMessage =
              'Auto-filled details from ${meta.domain ?? 'link'}';
        } else {
          _metadataFeedbackMessage =
              isManual ? 'No metadata found for this link' : null;
        }
      });
    } catch (_) {
      if (isManual && mounted) {
        setState(() {
          _metadataFeedbackMessage = 'Could not load preview metadata';
        });
      }
    } finally {
      if (mounted) setState(() => _isFetchingMetadata = false);
    }
  }

  Future<void> _loadIncomingImage(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      _acceptImage(bytes, file.uri.pathSegments.last);
    } catch (_) {
      // Temporary shared files may expire; manual picking remains available.
    }
  }

  @override
  void dispose() {
    _metadataDebounceTimer?.cancel();
    _urlController.removeListener(_onUrlChanged);
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _selectMode(VaultItemType type) {
    if (_isSaving || type == _selectedType) return;
    setState(() {
      _selectedType = type;
      _urlError = null;
      _errorMessage = null;
    });
  }

  /// Validates the picked bytes up-front so an unsupported file is reported
  /// immediately instead of only failing on save.
  void _acceptImage(Uint8List bytes, String name) {
    final extension = LocalImageStorage.detectImageExtension(bytes);
    setState(() {
      if (extension == null) {
        _errorMessage = 'That file is not a supported image. Choose a PNG, JPG, WEBP, GIF, BMP, or HEIC file.';
        return;
      }
      _selectedImageBytes = bytes;
      _selectedFileName = name;
      _errorMessage = null;
    });
  }

  void _removeImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedFileName = null;
    });
  }

  Future<void> _pickImageFile() async {
    if (_isPicking || _isSaving) return;
    setState(() {
      _errorMessage = null;
      _isPicking = true;
    });
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final picked = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );
        // A cancelled pick simply returns - it must not open a second picker.
        if (picked == null) return;
        final bytes = await picked.readAsBytes();
        if (!mounted) return;
        _acceptImage(bytes, picked.name);
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }
      if (bytes == null || !mounted) return;
      _acceptImage(bytes, file.name);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not read image from picker: $e';
      });
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _handleSave() async {
    // Set synchronously (before any await) so rapid double taps cannot start
    // two saves.
    if (_isSaving) return;
    final tags = VaultValidators.parseTagInput(_tagsController.text);
    final customTitle = _titleController.text.trim();

    if (_isLinkMode) {
      final urlCheck = VaultValidators.validateAndNormalizeUrl(
        _urlController.text,
      );
      if (!urlCheck.isValid) {
        setState(() {
          _urlError = urlCheck.errorMessage;
          _errorMessage = null;
        });
        return;
      }
    } else if (_selectedImageBytes == null) {
      setState(() {
        _errorMessage = 'Choose an image before saving to your local vault.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _urlError = null;
      _errorMessage = null;
    });
    try {
      final VaultItem saved;
      if (_isLinkMode) {
        saved = await widget.controller.addLinkItem(
          rawUrl: _urlController.text,
          customTitle: customTitle,
          description: _descriptionController.text,
          tags: tags,
          collection: _selectedCollection,
        );
      } else {
        saved = await widget.controller.addMediaItem(
          type: VaultItemType.image,
          imageBytes: _selectedImageBytes!,
          fileNameHint: _selectedFileName,
          customTitle: customTitle,
          description: _descriptionController.text,
          tags: tags,
          collection: _selectedCollection,
        );
      }
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

  Future<void> _createNewCollectionInline() async {
    final textController = TextEditingController();
    String? errorText;

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final dialogPalette = dialogCtx.sli;
          return AlertDialog(
            scrollable: true,
            title: const Text('New Collection'),
            content: TextField(
              key: const Key('inline_collection_name_field'),
              controller: textController,
              autofocus: true,
              style: TextStyle(color: dialogPalette.textPrimary),
              decoration: InputDecoration(
                labelText: 'Collection Name',
                hintText: 'e.g., Work, Reading, Recipes',
                errorText: errorText,
                errorStyle: TextStyle(color: dialogPalette.errorText),
              ),
              onSubmitted: (val) async {
                final trimmed = val.trim();
                try {
                  await widget.controller.createCollection(trimmed);
                  if (dialogCtx.mounted) Navigator.of(dialogCtx).pop(trimmed);
                } catch (e) {
                  setDialogState(() {
                    errorText = e.toString().replaceFirst(
                      'FormatException: ',
                      '',
                    );
                  });
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                key: const Key('inline_collection_save_button'),
                onPressed: () async {
                  final trimmed = textController.text.trim();
                  try {
                    await widget.controller.createCollection(trimmed);
                    if (dialogCtx.mounted) Navigator.of(dialogCtx).pop(trimmed);
                  } catch (e) {
                    setDialogState(() {
                      errorText = e.toString().replaceFirst(
                        'FormatException: ',
                        '',
                      );
                    });
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );

    if (name != null && name.isNotEmpty && mounted) {
      setState(() {
        _selectedCollection = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final collections = widget.controller.collections;
    final collectionValue = collections.contains(_selectedCollection)
        ? _selectedCollection
        : 'General';
    return PopScope(
      canPop: !_isSaving,
      child: SafeArea(
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
                      color: palette.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Add to Vault',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const SliIcon(
                        SliAssets.navClose,
                        size: 20,
                        semanticLabel: 'Close Add Sheet',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SliTokens.spaceMd),
                _ModeSwitcher(
                  selected: _selectedType,
                  enabled: !_isSaving,
                  onChanged: _selectMode,
                ),
                const SizedBox(height: SliTokens.spaceLg),
                if (_isLinkMode)
                  TextField(
                    key: const Key('add_url_field'),
                    controller: _urlController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enabled: !_isSaving,
                    style: TextStyle(color: palette.textPrimary),
                    onChanged: (_) {
                      if (_urlError != null) setState(() => _urlError = null);
                    },
                    decoration: InputDecoration(
                      labelText: 'URL (https://...)',
                      hintText: 'https://developer.android.com',
                      errorText: _urlError,
                      errorMaxLines: 2,
                      errorStyle: TextStyle(color: palette.errorText),
                      suffixIcon: _isFetchingMetadata
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : IconButton(
                              tooltip: 'Fetch preview metadata',
                              icon: const Icon(Icons.auto_awesome, size: 18),
                              onPressed: _isSaving
                                  ? null
                                  : () => _tryFetchMetadata(isManual: true),
                            ),
                    ),
                  )
                else
                  _ImagePickerTile(
                    bytes: _selectedImageBytes,
                    fileName: _selectedFileName,
                    busy: _isPicking,
                    enabled: !_isSaving,
                    onPick: _pickImageFile,
                    onRemove: _removeImage,
                  ),
                if (_isLinkMode &&
                    _fetchedMetadata != null &&
                    _fetchedMetadata!.hasContent) ...[
                  const SizedBox(height: SliTokens.spaceSm),
                  Container(
                    padding: const EdgeInsets.all(SliTokens.spaceSm),
                    decoration: BoxDecoration(
                      color: palette.elevated,
                      borderRadius: BorderRadius.circular(SliTokens.radiusMd),
                      border: Border.all(color: palette.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.link, size: 16, color: palette.accentText),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _metadataFeedbackMessage ??
                                'Preview retrieved for ${_fetchedMetadata!.domain ?? 'link'}. You can customize title and notes below.',
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_isLinkMode && _metadataFeedbackMessage != null) ...[
                  const SizedBox(height: SliTokens.spaceSm),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      _metadataFeedbackMessage!,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: SliTokens.spaceMd),
                TextField(
                  key: const Key('add_title_field'),
                  controller: _titleController,
                  enabled: !_isSaving,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(color: palette.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Title (optional)',
                    hintText: _isLinkMode
                        ? 'Defaults to the site domain'
                        : 'e.g. Trip photo',
                  ),
                ),
                const SizedBox(height: SliTokens.spaceMd),
                TextField(
                  key: const Key('add_description_field'),
                  controller: _descriptionController,
                  enabled: !_isSaving,
                  minLines: 2,
                  maxLines: 4,
                  style: TextStyle(color: palette.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                ),
                const SizedBox(height: SliTokens.spaceMd),
                TextField(
                  key: const Key('add_tags_field'),
                  controller: _tagsController,
                  enabled: !_isSaving,
                  style: TextStyle(color: palette.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Tags (optional)',
                    hintText: 'Separate with commas: flutter, design',
                  ),
                ),
                const SizedBox(height: SliTokens.spaceMd),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: const Key('add_collection_field'),
                        initialValue: collectionValue,
                        isExpanded: true,
                        dropdownColor: palette.elevated,
                        style: TextStyle(color: palette.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Collection',
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12),
                            child: SliIcon(
                              SliAssets.contentCollection,
                              size: 18,
                            ),
                          ),
                        ),
                        items: [
                          for (final c in collections)
                            DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: palette.textPrimary),
                              ),
                            ),
                        ],
                        onChanged: _isSaving
                            ? null
                            : (val) {
                                if (val != null) {
                                  setState(() => _selectedCollection = val);
                                }
                              },
                      ),
                    ),
                    const SizedBox(width: SliTokens.spaceSm),
                    Tooltip(
                      message: 'Create new collection',
                      child: InkWell(
                        key: const Key('add_new_collection_button'),
                        borderRadius: BorderRadius.circular(SliTokens.radiusMd),
                        onTap: _isSaving ? null : _createNewCollectionInline,
                        child: Container(
                          height: 56,
                          width: 52,
                          decoration: BoxDecoration(
                            color: palette.elevated,
                            borderRadius: BorderRadius.circular(
                              SliTokens.radiusMd,
                            ),
                            border: Border.all(color: palette.border),
                          ),
                          alignment: Alignment.center,
                          child: SliIcon(
                            SliAssets.actionAdd,
                            size: 20,
                            color: palette.accentText,
                            semanticLabel: 'Create new collection',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: SliTokens.spaceMd),
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      key: const Key('add_error_banner'),
                      padding: const EdgeInsets.all(SliTokens.spaceMd),
                      decoration: BoxDecoration(
                        color: palette.charcoal,
                        borderRadius: BorderRadius.circular(SliTokens.radiusMd),
                        border: Border.all(color: palette.errorText),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SliIcon(
                            SliAssets.statusError,
                            size: 18,
                            color: palette.errorText,
                          ),
                          const SizedBox(width: SliTokens.spaceSm),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: SliTokens.spaceLg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: SliTokens.spaceMd),
                    Expanded(
                      flex: 2,
                      child: SliGradientButton(
                        key: const Key('save_item_button'),
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
      ),
    );
  }
}

/// Two-option segmented control (Save Link / Add Image) with an explicit,
/// high-contrast selected state.
class _ModeSwitcher extends StatelessWidget {
  final VaultItemType selected;
  final bool enabled;
  final ValueChanged<VaultItemType> onChanged;

  const _ModeSwitcher({
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Side by side whenever both labels fit; stack only on very narrow
        // sheets or at large accessibility text scales.
        final stacked =
            constraints.maxWidth < 280 ||
            MediaQuery.textScalerOf(context).scale(14) > 19;
        final link = _AddTypeButton(
          key: const Key('add_mode_link'),
          label: 'Save Link',
          iconAsset: SliAssets.contentLink,
          selected: selected == VaultItemType.link,
          enabled: enabled,
          onTap: () => onChanged(VaultItemType.link),
        );
        final image = _AddTypeButton(
          key: const Key('add_mode_image'),
          label: 'Add Image',
          iconAsset: SliAssets.contentImage,
          selected: selected == VaultItemType.image,
          enabled: enabled,
          onTap: () => onChanged(VaultItemType.image),
        );
        return stacked
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  link,
                  const SizedBox(height: SliTokens.spaceSm),
                  image,
                ],
              )
            : Row(
                children: [
                  Expanded(child: link),
                  const SizedBox(width: SliTokens.spaceSm),
                  Expanded(child: image),
                ],
              );
      },
    );
  }
}

class _AddTypeButton extends StatelessWidget {
  final String label;
  final String iconAsset;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _AddTypeButton({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    // Selected: ink on the brand gradient (>=5.8:1). Unselected: primary text
    // on the card surface. The decoration is a plain DecoratedBox *around* a
    // transparent Material so it always paints above the sheet background.
    final foreground = selected ? palette.onAccent : palette.textPrimary;
    final iconColor = selected ? palette.onAccent : palette.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      inMutuallyExclusiveGroup: true,
      label: label,
      excludeSemantics: true,
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled || selected ? 1 : 0.6,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: selected ? SliTokens.primaryGradient : null,
            color: selected ? null : palette.charcoal,
            borderRadius: BorderRadius.circular(SliTokens.radiusMd),
            border: Border.all(
              color: selected ? SliTokens.orange : palette.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(SliTokens.radiusMd),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: SliTokens.minTouchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SliTokens.spaceMd,
                    vertical: SliTokens.spaceSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SliIcon(iconAsset, size: 18, color: iconColor),
                      const SizedBox(width: SliTokens.spaceSm),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  final Uint8List? bytes;
  final String? fileName;
  final bool busy;
  final bool enabled;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _ImagePickerTile({
    required this.bytes,
    required this.fileName,
    required this.busy,
    required this.enabled,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final radius = BorderRadius.circular(SliTokens.radiusLg);
    final hasImage = bytes != null;
    return Semantics(
      container: true,
      label: hasImage
          ? 'Selected image ${fileName ?? ''}. Double tap to change.'
          : 'Choose an image from your device',
      button: true,
      // Keep the Remove button reachable by screen readers once an image
      // is selected.
      excludeSemantics: !hasImage,
      onTap: enabled ? onPick : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.charcoal,
          borderRadius: radius,
          border: Border.all(color: palette.border),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: const Key('pick_image_button'),
            onTap: enabled ? onPick : null,
            borderRadius: radius,
            // minHeight (not a fixed height) so large text scales grow the
            // empty tile instead of overflowing it.
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 150),
              child: hasImage
                  ? SizedBox(
                      height: 150,
                      child: ClipRRect(
                        borderRadius: radius,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(
                              bytes!,
                              fit: BoxFit.cover,
                              cacheWidth: 720,
                              gaplessPlayback: true,
                              errorBuilder: (_, _, _) => Center(
                                child: Text(
                                  'Preview unavailable',
                                  style: TextStyle(
                                    color: palette.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: _Chip(label: 'Change image'),
                            ),
                            Positioned(
                              right: 4,
                              top: 4,
                              child: IconButton.filled(
                                key: const Key('remove_image_button'),
                                tooltip: 'Remove image',
                                onPressed: enabled ? onRemove : null,
                                style: IconButton.styleFrom(
                                  backgroundColor: palette.elevated,
                                  foregroundColor: palette.textPrimary,
                                  minimumSize: const Size(
                                    SliTokens.minTouchTarget,
                                    SliTokens.minTouchTarget,
                                  ),
                                ),
                                icon: const SliIcon(
                                  SliAssets.navClose,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(SliTokens.spaceLg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (busy)
                            const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          else
                            SliIcon(
                              SliAssets.contentImage,
                              size: 32,
                              color: palette.accentText,
                            ),
                          const SizedBox(height: SliTokens.spaceSm),
                          Text(
                            'Tap to choose an image',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Copied into durable app-private storage',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: palette.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.elevated.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(SliTokens.radiusSm),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        label,
        style: TextStyle(color: palette.textPrimary, fontSize: 12),
      ),
    );
  }
}
