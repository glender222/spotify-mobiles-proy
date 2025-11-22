import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Search/components/desktop_search_bar.dart';
import '/ui/screens/Search/search_screen_controller.dart';
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
    final HomeController HomeController =
        Get.find<HomeController>();
    final SettingsController SettingsController =
        Get.find<SettingsController>();

    return Scaffold(
        floatingActionButton: Obx(
          () => ((HomeController.tabIndex.value == 0 &&
                          !GetPlatform.isDesktop) ||
                      HomeController.tabIndex.value == 2) &&
                  SettingsController.isBottomNavBarEnabled.isFalse
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
                              if (HomeController.tabIndex.value == 2) {
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
                            child: Icon(HomeController.tabIndex.value == 2
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
              SettingsController.isBottomNavBarEnabled.isFalse
                  ? const SideNavBar()
                  : const SizedBox(
                      width: 0,
                    ),
              //const VerticalDivider(thickness: 1, width: 2),
              Expanded(
                child: Obx(() => AnimatedScreenTransition(
                    enabled: SettingsController
                        .isTransitionAnimationDisabled.isFalse,
                    resverse: HomeController.reverseAnimationtransiton,
                    horizontalTransition:
                        SettingsController.isBottomNavBarEnabled.isTrue,
                    child: Center(
                      key: ValueKey<int>(HomeController.tabIndex.value),
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
    final HomeController = Get.find<HomeController>();
    final SettingsController = Get.find<SettingsController>();
    final size = MediaQuery.of(context).size;
    final topPadding = GetPlatform.isDesktop
        ? 85.0
        : context.isLandscape
            ? 50.0
            : size.height < 750
                ? 80.0
                : 85.0;
    final leftPadding =
        SettingsController.isBottomNavBarEnabled.isTrue ? 20.0 : 5.0;
    if (HomeController.tabIndex.value == 0) {
      return Padding(
        padding: EdgeInsets.only(left: leftPadding),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                // for Desktop search bar
                if (GetPlatform.isDesktop) {
                  final sscontroller = Get.find<SearchScreenController>();
                  if (sscontroller.focusNode.hasFocus) {
                    sscontroller.focusNode.unfocus();
                  }
                }
              },
              child: Obx(
                () => HomeController.networkError.isTrue
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
                                            HomeController
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
                        if (!HomeController.isContentFetched.value) {
                          return const HomeShimmer();
                        }
                        return ListView(
                          padding:
                              EdgeInsets.only(bottom: 200, top: topPadding),
                          children: [
                            Obx(() {
                              if (HomeController
                                  .recentlyPlayed.isNotEmpty) {
                                return QuickPicksWidget(
                                  content: QuickPicks(
                                    HomeController.recentlyPlayed,
                                    title: "Escuchado Recientemente",
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                            Obx(() {
                              if (HomeController
                                  .recentPlaylists.isNotEmpty) {
                                return ContentListWidget(
                                  content: PlaylistContent(
                                    playlistList:
                                        HomeController.recentPlaylists,
                                    title: "Tus Playlists Recientes",
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                            Obx(() {
                              if (HomeController
                                  .recommendations.isNotEmpty) {
                                return QuickPicksWidget(
                                  content: QuickPicks(
                                    HomeController.recommendations,
                                    title: "Recomendaciones",
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                            Obx(() {
                              if (HomeController
                                  .quickPicks.value.songList.isNotEmpty) {
                                return QuickPicksWidget(
                                  content: HomeController.quickPicks.value,
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                            Obx(() {
                              return Column(
                                children: HomeController.middleContent
                                    .map((content) => ContentListWidget(
                                          content: content,
                                        ))
                                    .toList(),
                              );
                            }),
                            Obx(() {
                              return Column(
                                children: HomeController.fixedContent
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
    } else if (HomeController.tabIndex.value == 1) {
      return SettingsController.isBottomNavBarEnabled.isTrue
          ? const SearchScreen()
          : const SongsLibraryWidget();
    } else if (HomeController.tabIndex.value == 2) {
      return SettingsController.isBottomNavBarEnabled.isTrue
          ? const CombinedLibrary()
          : const PlaylistNAlbumLibraryWidget(isAlbumContent: false);
    } else if (HomeController.tabIndex.value == 3) {
      return SettingsController.isBottomNavBarEnabled.isTrue
          ? const SettingsScreen(isBottomNavActive: true)
          : const PlaylistNAlbumLibraryWidget();
    } else if (HomeController.tabIndex.value == 4) {
      return const LibraryArtistWidget();
    } else if (HomeController.tabIndex.value == 5) {
      return const SettingsScreen();
    } else {
      return Center(
        child: Text("${HomeController.tabIndex.value}"),
      );
    }
  }
}
