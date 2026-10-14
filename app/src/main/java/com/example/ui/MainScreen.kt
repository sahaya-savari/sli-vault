package com.example.ui

import android.widget.Toast
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.navigationBarsPadding
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
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.compose.collectAsStateWithLifecycle
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
import com.example.ui.screens.SearchScreen
import com.example.ui.screens.SettingsScreen
import androidx.compose.ui.graphics.Color

@Composable
fun MainScreen(
    viewModel: VaultViewModel,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    var currentDestination by remember { mutableStateOf(NavDestination.HOME) }
    var isSearchActive by remember { mutableStateOf(false) }
    var isSettingsActive by remember { mutableStateOf(false) }
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

    GlassAtmosphere(modifier = modifier) {
        Box(modifier = Modifier.fillMaxSize()) {
            when {
            showOnboarding -> {
                BackHandler { showOnboarding = false }
                OnboardingScreen(onDismiss = { showOnboarding = false })
            }

            selectedItem != null -> {
                BackHandler { viewModel.selectItem(null) }
                ItemDetailScreen(
                    item = selectedItem!!,
                    viewModel = viewModel,
                    onBack = { viewModel.selectItem(null) }
                )
            }

            isSearchActive -> {
                BackHandler { isSearchActive = false }
                SearchScreen(
                    viewModel = viewModel,
                    onBack = { isSearchActive = false },
                    onOpenItemDetail = { item -> viewModel.selectItem(item) }
                )
            }

            isSettingsActive -> {
                BackHandler { isSettingsActive = false }
                SettingsScreen(
                    viewModel = viewModel,
                    onBack = { isSettingsActive = false },
                    onShowOnboarding = { showOnboarding = true }
                )
            }

            else -> {
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
                        when (currentDestination) {
                            NavDestination.HOME -> {
                                HomeScreen(
                                    viewModel = viewModel,
                                    onNavigateToBrowse = { currentDestination = NavDestination.BROWSE },
                                    onNavigateToSearch = { isSearchActive = true },
                                    onNavigateToSettings = { isSettingsActive = true },
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
                                    onShowOnboarding = { showOnboarding = true }
                                )
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
