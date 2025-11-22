import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/ui/screens/Artists/artist_screen.dart' show AboutArtist;
import '../../navigator.dart';
import '../../widgets/loader.dart';
import '../../widgets/separate_tab_item_widget.dart';
import '../../../presentation/controllers/artist/artist_controller.dart';

class ArtistScreenBN extends StatelessWidget {
  const ArtistScreenBN(
      {super.key, required this.artistController, required this.tag});
  final ArtistController artistController;
  final String tag;
  @override
  Widget build(BuildContext context) {
    final separatedContent = artistController.separatedContent;
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 85,
          backgroundColor: Theme.of(context).canvasColor,
          leading: Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: IconButton(
                onPressed: () {
                  Get.nestedKey(ScreenNavigationSetup.id)!.currentState!.pop();
                },
                icon: const Icon(Icons.arrow_back_ios_new)),
          ),
          elevation: 0,
          bottom: TabBar(
            splashFactory: NoSplash.splashFactory,
            enableFeedback: true,
            isScrollable: true,
            controller: artistController.tabController!,
            onTap: artistController.onDestinationSelected,
            tabs:
                ["about".tr, "songs".tr, "videos".tr, "albums".tr, "singles".tr]
                    .map((e) => Tab(
                          text: e,
                        ))
                    .toList(),
          ),
          title: Obx(
            () => artistController.isArtistContentFetched.isTrue
                ? Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: Text(artistController.artist_.name,
                        style: Theme.of(context).textTheme.titleLarge),
                  )
                : const SizedBox.shrink(),
          )),
      body: Obx(
        () => TabBarView(
          controller: artistController.tabController,
          children: artistController.isArtistContentFetched.isFalse
              ? List.generate(
                  5,
                  (index) => const Center(
                        child: LoadingIndicator(),
                      ))
              : [
                  AboutArtist(
                    artistController: artistController,
                    padding: const EdgeInsets.only(
                        top: 10, left: 15, right: 5, bottom: 200),
                  ),
                  ...["Songs", "Videos", "Albums", "Singles"].map(
                    (item) {
                      if (artistController
                              .isSeparatedArtistContentFetched.isFalse &&
                          artistController.navigationRailCurrentIndex.value !=
                              0) {
                        return const Center(child: LoadingIndicator());
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 5),
                        child: SeparateTabItemWidget(
                          artistControllerTag: tag,
                          hideTitle: true,
                          isResultWidget: false,
                          items: separatedContent.containsKey(item)
                              ? separatedContent[item]['results']
                              : [],
                          title: item,
                          scrollController: item == "Songs"
                              ? artistController.songScrollController
                              : item == "Videos"
                                  ? artistController.videoScrollController
                                  : item == "Albums"
                                      ? artistController.albumScrollController
                                      : item == "Singles"
                                          ? artistController
                                              .singlesScrollController
                                          : null,
                        ),
                      );
                    },
                  )
                ],
        ),
      ),
    );
  }
}
