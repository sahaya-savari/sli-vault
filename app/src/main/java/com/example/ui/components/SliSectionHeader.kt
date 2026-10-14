package com.example.ui.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.MutedText
import com.example.ui.theme.PrimaryText
import com.example.ui.theme.SecondaryText
import com.example.ui.theme.SliSpacing

/**
 * Reusable Section Header inspired by Streak's section label architecture.
 * Features refined typographic hierarchy, uppercase tracked labeling,
 * optional descriptive subtitle, and flexible trailing action slot (e.g. "See all", counter, or button).
 */
@Composable
fun SliSectionHeader(
    title: String,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    isUppercase: Boolean = false,
    uppercase: Boolean = isUppercase,
    trailing: @Composable (() -> Unit)? = null
) {
    val shouldUppercase = isUppercase || uppercase
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = SliSpacing.xl, vertical = SliSpacing.sm),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(
            modifier = Modifier.weight(1f, fill = false)
        ) {
            Text(
                text = if (shouldUppercase) title.uppercase() else title,
                style = if (isUppercase) {
                    MaterialTheme.typography.labelMedium.copy(
                        letterSpacing = 1.1.sp,
                        fontWeight = FontWeight.Bold,
                        color = MutedText
                    )
                } else {
                    MaterialTheme.typography.titleLarge.copy(
                        fontWeight = FontWeight.Bold,
                        color = PrimaryText
                    )
                },
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            if (subtitle != null) {
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.bodySmall,
                    color = SecondaryText,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }

        if (trailing != null) {
            Spacer(modifier = Modifier.width(SliSpacing.md))
            trailing()
        }
    }
}

/**
 * Convenience section header with a standard "See all" or custom action button.
 */
@Composable
fun SliSectionHeaderWithAction(
    title: String,
    actionText: String,
    onActionClick: () -> Unit,
    modifier: Modifier = Modifier,
    subtitle: String? = null
) {
    SliSectionHeader(
        title = title,
        subtitle = subtitle,
        modifier = modifier,
        trailing = {
            TextButton(
                onClick = onActionClick,
                contentPadding = androidx.compose.foundation.layout.PaddingValues(horizontal = 8.dp, vertical = 4.dp)
            ) {
                Text(
                    text = actionText,
                    style = MaterialTheme.typography.labelLarge,
                    color = FieryOrange,
                    fontWeight = FontWeight.SemiBold
                )
            }
        }
    )
}
