import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/ui/screens/Artists/artist_screen_v2.dart';
import '/presentation/controllers/settings/settings_controller.dart';
import '../../widgets/animated_screen_transition.dart';
import '../../widgets/loader.dart';
import '../../widgets/separate_tab_item_widget.dart';
import '/ui/player/player_controller.dart';
import '/ui/widgets/image_widget.dart';
import 'package:share_plus/share_plus.dart';
import '../../navigator.dart';
import '../../widgets/snackbar.dart';
import '../../../presentation/controllers/artist/artist_controller.dart';

class ArtistScreen extends StatelessWidget {
  const ArtistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    final tag = key.hashCode.toString();
    // Controller is created by ArtistBinding
    final ArtistController artistController =
        Get.find<ArtistController>(tag: tag);
    return Scaffold(
      floatingActionButton: Obx(
        () => Padding(
          padding: EdgeInsets.only(
              bottom: playerController.playerPanelMinHeight.value),
          child: SizedBox(
            height: 60,
            width: 60,
            child: FittedBox(
              child: FloatingActionButton(
                  focusElevation: 0,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14))),
                  elevation: 0,
                  onPressed: () async {
                    final radioId = artistController.artist_.radioId;
                    if (radioId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(snackbar(
                          context, "radioNotAvailable".tr,
                          size: SanckBarSize.BIG));
                      return;
                    }
                    playerController.startRadio(null,
                        playlistid: artistController.artist_.radioId);
                  },
                  child: const Icon(Icons.sensors)),
            ),
          ),
        ),
      ),
      body: GetPlatform.isDesktop ||
              Get.find<SettingsController>().isBottomNavBarEnabled.value
          ? ArtistScreenBN(artistController: artistController, tag: tag)
          : Row(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: IntrinsicHeight(
                      child: Obx(
                        () => NavigationRail(
                          onDestinationSelected:
                              artistController.onDestinationSelected,
                          minWidth: 60,
                          destinations: [
                            "about".tr,
                            "songs".tr,
                            "videos".tr,
                            "albums".tr,
                            "singles".tr
                          ].map((e) => railDestination(e)).toList(),
                          leading: Column(
                            children: [
                              SizedBox(
                                height: context.isLandscape ? 20.0 : 45.0,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .color,
                                ),
                                onPressed: () {
                                  Get.nestedKey(ScreenNavigationSetup.id)!
                                      .currentState!
                                      .pop();
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                          labelType: NavigationRailLabelType.all,
                          selectedIndex:
                              artistController.navigationRailCurrentIndex.value,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => AnimatedScreenTransition(
                      enabled: Get.find<SettingsController>()
                          .isTransitionAnimationDisabled
                          .isFalse,
                      resverse: artistController.isTabTransitionReversed,
                      child: Center(
                        key: ValueKey<int>(
                            artistController.navigationRailCurrentIndex.value),
                        child: Body(tag: tag),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  NavigationRailDestination railDestination(String label) {
    return NavigationRailDestination(
      icon: const SizedBox.shrink(),
      label: RotatedBox(quarterTurns: -1, child: Text(label)),
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    super.key,
    required this.tag,
  });

  final String tag;

  @override
  Widget build(BuildContext context) {
    final ArtistController artistController =
        Get.find<ArtistController>(tag: tag);

    final tabIndex = artistController.navigationRailCurrentIndex.value;

    if (tabIndex == 0) {
      return Obx(() => artistController.isArtistContentFetched.isTrue
          ? AboutArtist(
              artistController: artistController,
            )
          : const Center(
              child: LoadingIndicator(),
            ));
    } else {
      final separatedContent = artistController.separatedContent;
      final currentTabName =
          ["About", "Songs", "Videos", "Albums", "Singles"][tabIndex];
      return Obx(() {
        if (artistController.isSeparatedArtistContentFetched.isFalse &&
            artistController.navigationRailCurrentIndex.value != 0) {
          return const Center(child: LoadingIndicator());
        }
        return SeparateTabItemWidget(
          artistControllerTag: tag,
          isResultWidget: false,
          items: separatedContent.containsKey(currentTabName)
              ? separatedContent[currentTabName]['results']
              : [],
          title: currentTabName,
          topPadding: context.isLandscape ? 50.0 : 80.0,
          scrollController: currentTabName == "Songs"
              ? artistController.songScrollController
              : currentTabName == "Videos"
                  ? artistController.videoScrollController
                  : currentTabName == "Albums"
                      ? artistController.albumScrollController
                      : currentTabName == "Singles"
                          ? artistController.singlesScrollController
                          : null,
        );
      });
    }
  }
}

class AboutArtist extends StatelessWidget {
  const AboutArtist(
      {super.key,
      required this.artistController,
      this.padding = const EdgeInsets.only(bottom: 90, top: 70)});
  final EdgeInsetsGeometry padding;
  final ArtistController artistController;

  @override
  Widget build(BuildContext context) {
    final artistData = artistController.artistData;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          padding: padding,
          child: artistController.isArtistContentFetched.value
              ? Column(
                  children: [
                    SizedBox(
                      height: 200,
                      width: 260,
                      child: Stack(
                        children: [
                          Center(
                            child: ImageWidget(
                              size: 200,
                              artist: artistController.artist_,
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Column(
                              children: [
                                InkWell(
                                    onTap: () {
                                      final bool add = artistController
                                          .isAddedToLibrary.isFalse;
                                      artistController
                                          .addNremoveFromLibrary(add: add)
                                          .then((value) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackbar(
                                                  context,
                                                  value
                                                      ? add
                                                          ? "artistBookmarkAddAlert"
                                                              .tr
                                                          : "artistBookmarkRemoveAlert"
                                                              .tr
                                                      : "operationFailed".tr,
                                                  size: SanckBarSize.MEDIUM));
                                        }
                                      });
                                    },
                                    child: Obx(
                                      () => artistController
                                              .isArtistContentFetched.isFalse
                                          ? const SizedBox.shrink()
                                          : Icon(artistController
                                                  .isAddedToLibrary.isFalse
                                              ? Icons.bookmark_add
                                              : Icons.bookmark_added),
                                    )),
                                IconButton(
                                    icon: const Icon(
                                      Icons.share,
                                      size: 20,
                                    ),
                                    splashRadius: 18,
                                    onPressed: () => Share.share(
                                        "https://music.youtube.com/channel/${artistController.artist_.browseId}")),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        artistController.artist_.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    (artistData.containsKey("description") &&
                            artistData["description"] != null)
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "\"${artistData["description"]}\"",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          )
                        : SizedBox(
                            height: 300,
                            child: Center(
                              child: Text(
                                "artistDesNotAvailable".tr,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
