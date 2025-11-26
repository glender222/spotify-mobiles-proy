import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/presentation/controllers/settings/settings_controller.dart';
import '/ui/widgets/piped_sync_widget.dart';
import '../../widgets/create_playlist_dialog.dart';
import 'library.dart';

class CombinedLibrary extends StatelessWidget {
  const CombinedLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    final settingscrnController = Get.find<SettingsController>();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 85,
          backgroundColor: Theme.of(context).canvasColor,
          elevation: 0,
          actions: [
            Obx(() => (settingscrnController.isLinkedWithPiped.isTrue)
                ? const PipedSyncWidget(
                    padding: EdgeInsets.only(right: 10, top: 50))
                : const SizedBox.shrink()),
            Padding(
              padding: const EdgeInsets.only(top: 50.0, right: 25),
              child: SizedBox(
                height: 40,
                width: 50,
                child: FittedBox(
                  child: FloatingActionButton.extended(
                      elevation: 0,
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const CreateNRenamePlaylistPopup());
                      },
                      label: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.add,
                          ),
                        ],
                      )),
                ),
              ),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            splashFactory: NoSplash.splashFactory,
            tabs: [
              Tab(text: "songs".tr),
              Tab(text: "playlists".tr),
              Tab(text: "albums".tr),
              Tab(text: "artists".tr),
            ],
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 60.0, left: 5),
            child: Text('library'.tr,
                style: Theme.of(context).textTheme.titleLarge),
          ),
        ),
        body: const TabBarView(
          children: [
            SongsLibraryWidget(
              isBottomNavActive: true,
            ),
            PlaylistNAlbumLibraryWidget(
                isAlbumContent: false, isBottomNavActive: true),
            PlaylistNAlbumLibraryWidget(isBottomNavActive: true),
            LibraryArtistWidget(isBottomNavActive: true),
          ],
        ),
      ),
    );
  }
}
