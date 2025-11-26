import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Search/components/desktop_search_bar.dart';
import '/presentation/controllers/search/search_controller.dart'
    as app_controllers;
import '/ui/widgets/animated_screen_transition.dart';
import '../Library/library_combined.dart';
import '../../widgets/side_nav_bar.dart';
import '../Library/library.dart';
import '../Search/search_screen.dart';
import '../../../presentation/controllers/settings/settings_controller.dart';
import '/ui/player/player_controller.dart';
import '/models/playlist.dart';
import '/models/quick_picks.dart';
import '/ui/widgets/create_playlist_dialog.dart';
import '../../navigator.dart';
import '../../widgets/content_list_widget.dart';
import '../../widgets/quickpickswidget.dart';
import '../../widgets/shimmer_widgets/home_shimmer.dart';
import '../../../presentation/controllers/home/home_controller.dart';
import '../Settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    final homeController = Get.find<HomeController>();
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
        floatingActionButton: Obx(
          () => ((homeController.tabIndex.value == 0 &&
                          !GetPlatform.isDesktop) ||
                      homeController.tabIndex.value == 2) &&
                  settingsController.isBottomNavBarEnabled.isFalse
              ? Obx(
                  () => Padding(
                    padding: EdgeInsets.only(
                        bottom: playerController.playerPanelMinHeight.value >
                                Get.mediaQuery.padding.bottom
                            ? playerController.playerPanelMinHeight.value -
                                Get.mediaQuery.padding.bottom
                            : playerController.playerPanelMinHeight.value),
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: FittedBox(
                        child: FloatingActionButton(
                            focusElevation: 0,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14))),
                            elevation: 0,
                            onPressed: () async {
                              if (homeController.tabIndex.value == 2) {
                                showDialog(
                                    context: context,
                                    builder: (context) =>
                                        const CreateNRenamePlaylistPopup());
                              } else {
                                Get.toNamed(ScreenNavigationSetup.searchScreen,
                                    id: ScreenNavigationSetup.id);
                              }
                              // file:///data/user/0/com.example.harmonymusic/cache/libCachedImageData/
                              //file:///data/user/0/com.example.harmonymusic/cache/just_audio_cache/
                            },
                            child: Icon(homeController.tabIndex.value == 2
                                ? Icons.add
                                : Icons.search)),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        body: Obx(
          () => Row(
            children: <Widget>[
              // create a navigation rail
              settingsController.isBottomNavBarEnabled.isFalse
                  ? const SideNavBar()
                  : const SizedBox(
                      width: 0,
                    ),
              //const VerticalDivider(thickness: 1, width: 2),
              Expanded(
                child: Obx(() => AnimatedScreenTransition(
                    enabled: settingsController
                        .isTransitionAnimationDisabled.isFalse,
                    resverse: homeController.reverseAnimationtransiton,
                    horizontalTransition:
                        settingsController.isBottomNavBarEnabled.isTrue,
                    child: Center(
                      key: ValueKey<int>(homeController.tabIndex.value),
                      child: const Body(),
                    ))),
              ),
            ],
          ),
        ));
  }
}

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final settingsController = Get.find<SettingsController>();
    final size = MediaQuery.of(context).size;
    final topPadding = GetPlatform.isDesktop
        ? 85.0
        : context.isLandscape
            ? 50.0
            : size.height < 750
                ? 80.0
                : 85.0;
    final leftPadding =
        settingsController.isBottomNavBarEnabled.isTrue ? 20.0 : 5.0;
    if (homeController.tabIndex.value == 0) {
      return Padding(
        padding: EdgeInsets.only(left: leftPadding),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                // for Desktop search bar
                if (GetPlatform.isDesktop) {
                  final sscontroller =
                      Get.find<app_controllers.SearchController>();
                  if (sscontroller.focusNode.hasFocus) {
                    sscontroller.focusNode.unfocus();
                  }
                }
              },
              child: Obx(
                () => homeController.networkError.isTrue
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height - 180,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "home".tr,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "networkError1".tr,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 10),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .color,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: InkWell(
                                          onTap: () {
                                            homeController
                                                .loadContentFromNetwork();
                                          },
                                          child: Text(
                                            "retry".tr,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .canvasColor),
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                            )
                          ],
                        ),
                      )
                    : Obx(() {
                        if (!homeController.isContentFetched.value) {
                          return const HomeShimmer();
                        }
                        return ListView(
                          padding:
                              EdgeInsets.only(bottom: 200, top: topPadding),
                          children: [
                            Obx(() {
                              if (homeController.recentlyPlayed.isNotEmpty) {
                                return QuickPicksWidget(
                                  content: QuickPicks(
                                    homeController.recentlyPlayed,
                                    title: "Escuchado Recientemente",
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                            Obx(() {
                              if (homeController.recentPlaylists.isNotEmpty) {
                                return ContentListWidget(
                                  content: PlaylistContent(
                                    playlistList:
                                        homeController.recentPlaylists,
                                    title: "Tus Playlists Recientes",
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                            Obx(() {
                              if (homeController.recommendations.isNotEmpty) {
                                return QuickPicksWidget(
                                  content: QuickPicks(
                                    homeController.recommendations,
                                    title: "Recomendaciones",
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                            Obx(() {
                              if (homeController
                                  .quickPicks.value.songList.isNotEmpty) {
                                return QuickPicksWidget(
                                  content: homeController.quickPicks.value,
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                            Obx(() {
                              return Column(
                                children: homeController.middleContent
                                    .map((content) => ContentListWidget(
                                          content: content,
                                        ))
                                    .toList(),
                              );
                            }),
                            Obx(() {
                              return Column(
                                children: homeController.fixedContent
                                    .map((content) => ContentListWidget(
                                          content: content,
                                        ))
                                    .toList(),
                              );
                            }),
                          ],
                        );
                      }),
              ),
            ),
            if (GetPlatform.isDesktop)
              Align(
                alignment: Alignment.topCenter,
                child: LayoutBuilder(builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth > 800
                        ? 800
                        : constraints.maxWidth - 40,
                    child: const Padding(
                        padding: EdgeInsets.only(top: 15.0),
                        child: DesktopSearchBar()),
                  );
                }),
              )
          ],
        ),
      );
    } else if (homeController.tabIndex.value == 1) {
      return settingsController.isBottomNavBarEnabled.isTrue
          ? const SearchScreen()
          : const SongsLibraryWidget();
    } else if (homeController.tabIndex.value == 2) {
      return settingsController.isBottomNavBarEnabled.isTrue
          ? const CombinedLibrary()
          : const PlaylistNAlbumLibraryWidget(isAlbumContent: false);
    } else if (homeController.tabIndex.value == 3) {
      return settingsController.isBottomNavBarEnabled.isTrue
          ? const SettingsScreen(isBottomNavActive: true)
          : const PlaylistNAlbumLibraryWidget();
    } else if (homeController.tabIndex.value == 4) {
      return const LibraryArtistWidget();
    } else if (homeController.tabIndex.value == 5) {
      return const SettingsScreen();
    } else {
      return Center(
        child: Text("${homeController.tabIndex.value}"),
      );
    }
  }
}
