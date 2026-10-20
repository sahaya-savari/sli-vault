import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/vault_controller.dart';
import '../../domain/vault_item.dart';
import '../assets/sli_assets.dart';
import '../theme/sli_theme.dart';
import 'sli_spotlight_card.dart';
import 'sli_svg.dart';

class VaultItemCard extends StatefulWidget {
  final VaultItem item;
  final VaultController controller;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final bool isGrid;
  final bool isSelected;
  final bool isSelectionMode;
  final bool? isCompact;

  const VaultItemCard({
    super.key,
    required this.item,
    required this.controller,
    required this.onTap,
    required this.onToggleFavorite,
    this.onLongPress,
    this.onDelete,
    this.isGrid = false,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.isCompact,
  });

  @override
  State<VaultItemCard> createState() => _VaultItemCardState();
}

class _VaultItemCardState extends State<VaultItemCard> {
  Future<File?>? _imageFuture;

  @override
  void initState() {
    super.initState();
    _initImageFuture();
  }

  @override
  void didUpdateWidget(covariant VaultItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.localImageId != widget.item.localImageId ||
        oldWidget.item.type != widget.item.type ||
        oldWidget.controller != widget.controller) {
      _initImageFuture();
    }
  }

  void _initImageFuture() {
    final imageId = widget.item.localImageId;
    if (widget.item.type == VaultItemType.link ||
        imageId == null ||
        imageId.trim().isEmpty) {
      _imageFuture = null;
    } else {
      _imageFuture = widget.controller.resolveImageFile(imageId);
    }
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  bool get _isCompact =>
      widget.isCompact ?? (widget.controller.browseDensity == 'compact');

  @override
  Widget build(BuildContext context) {
    if (widget.isGrid) {
      return _buildGridCard(context);
    }
    return _buildListCard(context);
  }

  Widget _buildThumbnail(
    BuildContext context, {
    required double width,
    required double height,
  }) {
    final thumbRadius = BorderRadius.circular(
      context.sli.visualStyle == SliVisualStyle.minimal
          ? 6
          : (context.sli.visualStyle == SliVisualStyle.express ? 16 : 10),
    );

    if (widget.item.type == VaultItemType.link) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.sli.charcoal,
          borderRadius: thumbRadius,
          border: Border.all(color: context.sli.border),
        ),
        alignment: Alignment.center,
        child: SliIllustration(
          SliAssets.illLinkPlaceholder,
          width: width * 0.72,
          height: height * 0.72,
        ),
      );
    }

    if (_imageFuture == null) {
      return _missingImageFallback(context, width: width, height: height);
    }

    return FutureBuilder<File?>(
      future: _imageFuture,
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file != null) {
          return ClipRRect(
            borderRadius: thumbRadius,
            child: Image.file(
              file,
              width: width,
              height: height,
              fit: BoxFit.cover,
              cacheWidth: 360,
              errorBuilder: (_, _, _) =>
                  _missingImageFallback(context, width: width, height: height),
            ),
          );
        }
        return _missingImageFallback(context, width: width, height: height);
      },
    );
  }

  Widget _missingImageFallback(
    BuildContext context, {
    required double width,
    required double height,
  }) {
    final thumbRadius = BorderRadius.circular(
      context.sli.visualStyle == SliVisualStyle.minimal
          ? 6
          : (context.sli.visualStyle == SliVisualStyle.express ? 16 : 10),
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.sli.charcoal,
        borderRadius: thumbRadius,
        border: Border.all(color: context.sli.border),
      ),
      alignment: Alignment.center,
      child: SliIllustration(
        SliAssets.illImagePlaceholder,
        width: width * 0.72,
        height: height * 0.72,
      ),
    );
  }

  BorderRadius _badgeRadius(BuildContext context) {
    switch (context.sli.visualStyle) {
      case SliVisualStyle.minimal:
        return BorderRadius.circular(4);
      case SliVisualStyle.express:
        return BorderRadius.circular(SliTokens.radiusPill);
      case SliVisualStyle.classic:
        return BorderRadius.circular(SliTokens.radiusSm + 2);
    }
  }

  BorderRadius _tagRadius(BuildContext context) {
    switch (context.sli.visualStyle) {
      case SliVisualStyle.minimal:
        return BorderRadius.circular(4);
      case SliVisualStyle.express:
        return BorderRadius.circular(SliTokens.radiusPill);
      case SliVisualStyle.classic:
        return BorderRadius.circular(SliTokens.radiusSm + 4);
    }
  }

  Widget _buildTypePill(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: context.sli.charcoal,
        borderRadius: _badgeRadius(context),
        border: Border.all(color: context.sli.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliIcon(
            widget.item.type.iconAsset,
            size: 11,
            color: context.sli.amberText,
          ),
          const SizedBox(width: 4),
          Text(
            widget.item.type.label,
            style: TextStyle(
              color: context.sli.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: SliTokens.coral.withValues(alpha: 0.16),
        borderRadius: _badgeRadius(context),
        border: Border.all(color: SliTokens.coral.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, size: 10.5, color: SliTokens.coral),
          const SizedBox(width: 2.5),
          Text(
            'Favorite',
            style: TextStyle(
              color: SliTokens.coral,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: SliTokens.amber.withValues(alpha: 0.16),
        borderRadius: _badgeRadius(context),
        border: Border.all(color: SliTokens.amber.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.push_pin, size: 10.5, color: SliTokens.amber),
          const SizedBox(width: 2.5),
          Text(
            'Pinned',
            style: TextStyle(
              color: SliTokens.amber,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.sli.charcoal,
        borderRadius: _badgeRadius(context),
        border: Border.all(color: context.sli.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_outlined, size: 11, color: context.sli.amberText),
          const SizedBox(width: 3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 85),
            child: Text(
              widget.item.collection,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.sli.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return SizedBox(
      width: SliTokens.minTouchTarget,
      height: SliTokens.minTouchTarget,
      child: IconButton(
        tooltip: widget.item.isFavorite
            ? 'Remove from favorites'
            : 'Add to favorites',
        onPressed: widget.onToggleFavorite,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: SliIcon(
            widget.item.isFavorite
                ? SliAssets.actionFavoriteFilled
                : SliAssets.actionFavoriteOutline,
            key: ValueKey<bool>(widget.item.isFavorite),
            size: 20,
            color: widget.item.isFavorite
                ? SliTokens.coral
                : context.sli.textSecondary,
            semanticLabel: widget.item.isFavorite
                ? 'Unfavorite ${widget.item.title}'
                : 'Favorite ${widget.item.title}',
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    final subtitle = widget.item.type == VaultItemType.link
        ? (widget.item.domain ?? widget.item.url ?? 'Saved link')
        : _formatDate(widget.item.createdAt);

    final thumbSize = _isCompact ? 56.0 : 72.0;
    final cardPadding = _isCompact
        ? const EdgeInsets.all(SliTokens.spaceSm + 2)
        : const EdgeInsets.all(SliTokens.spaceMd);

    return SliSpotlightCard(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      padding: cardPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isSelectionMode) ...[
            Padding(
              padding: EdgeInsets.only(top: _isCompact ? 16 : 22, right: 10),
              child: Icon(
                widget.isSelected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: widget.isSelected
                    ? context.sli.primaryAccent
                    : context.sli.textSecondary,
                size: 22,
              ),
            ),
          ],
          _buildThumbnail(context, width: thumbSize, height: thumbSize),
          const SizedBox(width: SliTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildTypePill(context),
                    if (widget.controller.isItemPinned(widget.item.id))
                      _buildPinBadge(context),
                    if (widget.item.isFavorite) _buildFavoriteBadge(context),
                    if (widget.item.collection.isNotEmpty &&
                        widget.item.collection != 'General')
                      _buildCollectionBadge(context),
                    if (widget.item.description != null &&
                        widget.item.description!.isNotEmpty)
                      Tooltip(
                        message: 'Has note or description',
                        child: Icon(
                          Icons.description_outlined,
                          size: 13,
                          color: context.sli.textSecondary,
                        ),
                      ),
                    Text(
                      _formatDate(widget.item.createdAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.sli.textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  widget.item.title,
                  maxLines: _isCompact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontSize: _isCompact ? 14 : 15),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontSize: _isCompact ? 12 : 13),
                ),
                if (!_isCompact && widget.item.tags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: widget.item.tags.take(3).map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.sli.charcoal,
                          borderRadius: _tagRadius(context),
                          border: Border.all(color: context.sli.border),
                        ),
                        child: Text(
                          '#$t',
                          style: TextStyle(
                            color: context.sli.amberText,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          if (!widget.isSelectionMode && widget.onDelete != null)
            PopupMenuButton<String>(
              tooltip: 'Item options',
              icon: Icon(
                Icons.more_vert,
                size: 18,
                color: context.sli.textSecondary,
              ),
              color: context.sli.elevated,
              padding: EdgeInsets.zero,
              onSelected: (val) {
                if (val == 'favorite') {
                  widget.onToggleFavorite();
                } else if (val == 'pin') {
                  widget.controller.togglePin(widget.item.id);
                } else if (val == 'delete') {
                  widget.onDelete!();
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'pin',
                  child: Row(
                    children: [
                      Icon(
                        widget.controller.isItemPinned(widget.item.id)
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        size: 16,
                        color: widget.controller.isItemPinned(widget.item.id)
                            ? SliTokens.amber
                            : ctx.sli.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.controller.isItemPinned(widget.item.id)
                            ? 'Unpin from top'
                            : 'Pin to top',
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'favorite',
                  child: Row(
                    children: [
                      Icon(
                        widget.item.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16,
                        color: widget.item.isFavorite
                            ? SliTokens.coral
                            : ctx.sli.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(widget.item.isFavorite ? 'Unfavorite' : 'Favorite'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: ctx.sli.errorText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Delete with Undo',
                        style: TextStyle(color: ctx.sli.errorText),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            _buildFavoriteButton(context),
        ],
      ),
    );
  }

  Widget _buildGridCard(BuildContext context) {
    final subtitle = widget.item.type == VaultItemType.link
        ? (widget.item.domain ?? 'Saved link')
        : _formatDate(widget.item.createdAt);

    return SliSpotlightCard(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      padding: EdgeInsets.all(
        _isCompact ? SliTokens.spaceSm : SliTokens.spaceMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: _buildThumbnail(context, width: 160, height: 110),
                ),
                Positioned(top: 6, left: 6, child: _buildTypePill(context)),
                if (widget.item.collection.isNotEmpty &&
                    widget.item.collection != 'General')
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: _buildCollectionBadge(context),
                  ),
                if (widget.isSelectionMode)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Icon(
                      widget.isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: widget.isSelected
                          ? context.sli.primaryAccent
                          : Colors.white,
                      size: 24,
                    ),
                  )
                else
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _buildFavoriteButton(context),
                  ),
              ],
            ),
          ),
          const SizedBox(height: SliTokens.spaceSm),
          Text(
            widget.item.title,
            maxLines: _isCompact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontSize: _isCompact ? 13.5 : 14.5),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontSize: _isCompact ? 11.5 : 12),
                ),
              ),
              if (widget.item.description != null &&
                  widget.item.description!.isNotEmpty)
                Icon(
                  Icons.description_outlined,
                  size: 13,
                  color: context.sli.textSecondary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
