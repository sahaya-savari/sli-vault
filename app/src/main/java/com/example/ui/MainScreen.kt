package com.example.ui

import android.widget.Toast
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.compose.animation.togetherWith
import com.example.data.VaultItem
import com.example.ui.components.AtmosphereVariant
import com.example.ui.components.GlassAtmosphere
import com.example.ui.components.NavDestination
import com.example.ui.components.SliBottomNavBar
import com.example.ui.screens.AddItemSheet
import com.example.ui.screens.BrowseScreen
import com.example.ui.screens.CollectionsScreen
import com.example.ui.screens.FavoritesScreen
import com.example.ui.screens.HomeScreen
import com.example.ui.screens.ItemDetailScreen
import com.example.ui.screens.OnboardingScreen
import com.example.ui.screens.ProfileScreen
import com.example.ui.screens.SearchScreen
import com.example.ui.screens.SettingsScreen

private sealed interface AppScreenState {
    data object MainTabs : AppScreenState
    data object Onboarding : AppScreenState
    data class ItemDetail(val item: VaultItem) : AppScreenState
    data object Search : AppScreenState
    data object Settings : AppScreenState
    data object Profile : AppScreenState
}

@Composable
fun MainScreen(
    viewModel: VaultViewModel,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    var currentDestination by remember { mutableStateOf(NavDestination.HOME) }
    var isSearchActive by remember { mutableStateOf(false) }
    var isSettingsActive by remember { mutableStateOf(false) }
    var isProfileActive by remember { mutableStateOf(false) }
    var showOnboarding by remember { mutableStateOf(false) }

    val selectedItem by viewModel.selectedItem.collectAsStateWithLifecycle()
    val isAddSheetOpen by viewModel.isAddSheetOpen.collectAsStateWithLifecycle()
    val addInitialType by viewModel.addInitialType.collectAsStateWithLifecycle()
    val prefilledUrl by viewModel.prefilledUrl.collectAsStateWithLifecycle()
    val prefilledImageUri by viewModel.prefilledImageUri.collectAsStateWithLifecycle()
    val userMessage by viewModel.userMessage.collectAsStateWithLifecycle()

    val snackbarHostState = remember { SnackbarHostState() }

    // User feedback toasts/snackbars
    LaunchedEffect(userMessage) {
        userMessage?.let { msg ->
            Toast.makeText(context, msg, Toast.LENGTH_SHORT).show()
            viewModel.clearUserMessage()
        }
    }

    val currentScreenState: AppScreenState = when {
        showOnboarding -> AppScreenState.Onboarding
        selectedItem != null -> AppScreenState.ItemDetail(selectedItem!!)
        isSearchActive -> AppScreenState.Search
        isSettingsActive -> AppScreenState.Settings
        isProfileActive -> AppScreenState.Profile
        else -> AppScreenState.MainTabs
    }

    val atmosphereVariant = when (currentScreenState) {
        AppScreenState.Onboarding -> AtmosphereVariant.CINEMATIC
        is AppScreenState.ItemDetail -> AtmosphereVariant.FOCUS_IMMERSIVE
        AppScreenState.Search -> AtmosphereVariant.COSMIC_SUBTLE
        AppScreenState.Settings, AppScreenState.Profile -> AtmosphereVariant.SURFACE_ONLY
        AppScreenState.MainTabs -> AtmosphereVariant.ABSTRACT_FLOW
    }

    GlassAtmosphere(modifier = modifier, variant = atmosphereVariant) {
        Box(modifier = Modifier.fillMaxSize()) {
            androidx.compose.animation.AnimatedContent(
                targetState = currentScreenState,
                transitionSpec = {
                    (androidx.compose.animation.fadeIn(animationSpec = androidx.compose.animation.core.tween(200)) +
                            androidx.compose.animation.slideInVertically(animationSpec = androidx.compose.animation.core.tween(200)) { it / 30 })
                        .togetherWith(androidx.compose.animation.fadeOut(animationSpec = androidx.compose.animation.core.tween(150)))
                },
                label = "screen_transition"
            ) { screen ->
                when (screen) {
                    AppScreenState.Onboarding -> {
                        BackHandler { showOnboarding = false }
                        OnboardingScreen(onDismiss = { showOnboarding = false })
                    }

                    is AppScreenState.ItemDetail -> {
                        BackHandler { viewModel.selectItem(null) }
                        ItemDetailScreen(
                            item = screen.item,
                            viewModel = viewModel,
                            onBack = { viewModel.selectItem(null) }
                        )
                    }

                    AppScreenState.Search -> {
                        BackHandler { isSearchActive = false }
                        SearchScreen(
                            viewModel = viewModel,
                            onBack = { isSearchActive = false },
                            onOpenItemDetail = { item -> viewModel.selectItem(item) }
                        )
                    }

                    AppScreenState.Settings -> {
                        BackHandler { isSettingsActive = false }
                        SettingsScreen(
                            viewModel = viewModel,
                            onBack = { isSettingsActive = false },
                            onShowOnboarding = { showOnboarding = true },
                            onNavigateToProfile = {
                                isSettingsActive = false
                                isProfileActive = true
                            }
                        )
                    }

                    AppScreenState.Profile -> {
                        BackHandler { isProfileActive = false }
                        ProfileScreen(
                            viewModel = viewModel,
                            onBack = { isProfileActive = false }
                        )
                    }

                    AppScreenState.MainTabs -> {
                        Scaffold(
                            bottomBar = {
                                SliBottomNavBar(
                                    currentDestination = currentDestination,
                                    onNavigate = { dest ->
                                        currentDestination = dest
                                    },
                                    onOpenAdd = {
                                        viewModel.openAddSheet()
                                    }
                                )
                            },
                            snackbarHost = { SnackbarHost(snackbarHostState) },
                            containerColor = Color.Transparent
                        ) { innerPadding ->
                            Box(modifier = Modifier.padding(innerPadding)) {
                                androidx.compose.animation.AnimatedContent(
                                    targetState = currentDestination,
                                    transitionSpec = {
                                        androidx.compose.animation.fadeIn(animationSpec = androidx.compose.animation.core.tween(160))
                                            .togetherWith(androidx.compose.animation.fadeOut(animationSpec = androidx.compose.animation.core.tween(120)))
                                    },
                                    label = "tab_transition"
                                ) { targetDest ->
                                    when (targetDest) {
                                        NavDestination.HOME -> {
                                            HomeScreen(
                                                viewModel = viewModel,
                                                onNavigateToBrowse = { currentDestination = NavDestination.BROWSE },
                                                onNavigateToSearch = { isSearchActive = true },
                                                onNavigateToSettings = { isSettingsActive = true },
                                                onNavigateToProfile = { isProfileActive = true },
                                                onOpenItemDetail = { item -> viewModel.selectItem(item) }
                                            )
                                        }
                                        NavDestination.BROWSE -> {
                                            BrowseScreen(
                                                viewModel = viewModel,
                                                onOpenItemDetail = { item -> viewModel.selectItem(item) }
                                            )
                                        }
                                        NavDestination.FAVORITES -> {
                                            FavoritesScreen(
                                                viewModel = viewModel,
                                                onOpenItemDetail = { item -> viewModel.selectItem(item) }
                                            )
                                        }
                                        NavDestination.COLLECTIONS -> {
                                            CollectionsScreen(
                                                viewModel = viewModel,
                                                onSelectCollection = { collection ->
                                                    viewModel.setSelectedCollection(collection)
                                                    currentDestination = NavDestination.BROWSE
                                                }
                                            )
                                        }
                                        NavDestination.SETTINGS -> {
                                            SettingsScreen(
                                                viewModel = viewModel,
                                                onBack = { currentDestination = NavDestination.HOME },
                                                onShowOnboarding = { showOnboarding = true },
                                                onNavigateToProfile = { isProfileActive = true }
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

        // Add Item Sheet Modal
        if (isAddSheetOpen) {
            AddItemSheet(
                viewModel = viewModel,
                initialType = addInitialType,
                prefilledUrl = prefilledUrl,
                prefilledImageUri = prefilledImageUri,
                onDismiss = { viewModel.closeAddSheet() }
            )
        }
        }
    }
}
