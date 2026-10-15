import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/vault_controller.dart';
import '../../domain/vault_item.dart';
import '../assets/sli_assets.dart';
import '../theme/sli_theme.dart';
import 'sli_spotlight_card.dart';
import 'sli_svg.dart';

class VaultItemCard extends StatelessWidget {
  final VaultItem item;
  final VaultController controller;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final bool isGrid;

  const VaultItemCard({
    super.key,
    required this.item,
    required this.controller,
    required this.onTap,
    required this.onToggleFavorite,
    this.isGrid = false,
  });

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

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return _buildGridCard(context);
    }
    return _buildListCard(context);
  }

  Widget _buildThumbnail(
    BuildContext context, {
    required double width,
    required double height,
  }) {
    if (item.type == VaultItemType.link) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.sli.charcoal,
          borderRadius: BorderRadius.circular(SliTokens.radiusMd),
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

    return FutureBuilder<File?>(
      future: controller.resolveImageFile(item.localImageId),
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(SliTokens.radiusMd),
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
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.sli.charcoal,
        borderRadius: BorderRadius.circular(SliTokens.radiusMd),
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

  Widget _buildTypePill(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.sli.charcoal,
        borderRadius: BorderRadius.circular(SliTokens.radiusSm),
        border: Border.all(color: context.sli.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliIcon(item.type.iconAsset, size: 12, color: context.sli.amberText),
          SizedBox(width: 4),
          Text(
            item.type.label,
            style: TextStyle(
              color: context.sli.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
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
        tooltip: item.isFavorite ? 'Remove from favorites' : 'Add to favorites',
        onPressed: onToggleFavorite,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: SliIcon(
            item.isFavorite
                ? SliAssets.actionFavoriteFilled
                : SliAssets.actionFavoriteOutline,
            key: ValueKey<bool>(item.isFavorite),
            size: 20,
            color: item.isFavorite
                ? SliTokens.coral
                : context.sli.textSecondary,
            semanticLabel: item.isFavorite
                ? 'Unfavorite ${item.title}'
                : 'Favorite ${item.title}',
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    final subtitle = item.type == VaultItemType.link
        ? (item.domain ?? item.url ?? 'Saved link')
        : _formatDate(item.createdAt);

    return SliSpotlightCard(
      onTap: onTap,
      padding: EdgeInsets.all(SliTokens.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThumbnail(context, width: 72, height: 72),
          SizedBox(width: SliTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildTypePill(context),
                    SizedBox(width: SliTokens.spaceSm),
                    Expanded(
                      child: Text(
                        _formatDate(item.createdAt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.sli.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (item.tags.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: item.tags.take(3).map((t) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.sli.charcoal,
                          borderRadius: BorderRadius.circular(
                            SliTokens.radiusPill,
                          ),
                          border: Border.all(color: context.sli.border),
                        ),
                        child: Text(
                          '#$t',
                          style: TextStyle(
                            color: context.sli.amberText,
                            fontSize: 11,
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
          _buildFavoriteButton(context),
        ],
      ),
    );
  }

  Widget _buildGridCard(BuildContext context) {
    final subtitle = item.type == VaultItemType.link
        ? (item.domain ?? 'Saved link')
        : _formatDate(item.createdAt);

    return SliSpotlightCard(
      onTap: onTap,
      padding: EdgeInsets.all(SliTokens.spaceMd),
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
                Positioned(
                  top: 0,
                  right: 0,
                  child: _buildFavoriteButton(context),
                ),
              ],
            ),
          ),
          SizedBox(height: SliTokens.spaceSm),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
