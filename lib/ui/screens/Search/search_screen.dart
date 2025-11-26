import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'components/search_item.dart';
import '/presentation/controllers/settings/settings_controller.dart';
import '../../widgets/modified_text_field.dart';
import '/ui/navigator.dart';
import '../../../presentation/controllers/search/search_controller.dart'
    as app_controllers;

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = Get.put(app_controllers.SearchController());
    final settingsController = Get.find<SettingsController>();
    final topPadding = context.isLandscape ? 50.0 : 80.0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Obx(
        () => Row(
          children: [
            settingsController.isBottomNavBarEnabled.isFalse
                ? Container(
                    width: 60,
                    color:
                        Theme.of(context).navigationRailTheme.backgroundColor,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: topPadding),
                          child: IconButton(
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
                        ),
                      ],
                    ),
                  )
                : const SizedBox(
                    width: 15,
                  ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: topPadding, left: 5),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "search".tr,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ModifiedTextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: searchController.textInputController,
                      textInputAction: TextInputAction.search,
                      onChanged: searchController.onChanged,
                      onSubmitted: (val) {
                        if (val.contains("https://")) {
                          searchController.filterLinks(Uri.parse(val));
                          searchController.reset();
                          return;
                        }
                        Get.toNamed(ScreenNavigationSetup.searchResultScreen,
                            id: ScreenNavigationSetup.id, arguments: val);
                        searchController.addToHistryQueryList(val);
                      },
                      autofocus:
                          settingsController.isBottomNavBarEnabled.isFalse,
                      cursorColor: Theme.of(context).textTheme.bodySmall!.color,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 5),
                          focusColor: Colors.white,
                          hintText: "searchDes".tr,
                          suffix: IconButton(
                            onPressed: searchController.reset,
                            icon: const Icon(Icons.close),
                            splashRadius: 16,
                            iconSize: 19,
                          )),
                    ),
                    Expanded(
                      child: Obx(() {
                        final isEmpty =
                            searchController.suggestionList.isEmpty ||
                                searchController.textInputController.text == "";
                        final list = isEmpty
                            ? searchController.historyQuerylist.toList()
                            : searchController.suggestionList.toList();
                        return ListView(
                            padding: const EdgeInsets.only(top: 5, bottom: 400),
                            physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            children: searchController.urlPasted.isTrue
                                ? [
                                    InkWell(
                                      onTap: () {
                                        searchController.filterLinks(Uri.parse(
                                            searchController
                                                .textInputController.text));
                                        searchController.reset();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: SizedBox(
                                          width: double.maxFinite,
                                          height: 60,
                                          child: Center(
                                              child: Text(
                                            "urlSearchDes".tr,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          )),
                                        ),
                                      ),
                                    )
                                  ]
                                : list
                                    .map((item) => SearchItem(
                                        queryString: item,
                                        isHistoryString: isEmpty))
                                    .toList());
                      }),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
