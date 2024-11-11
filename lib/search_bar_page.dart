import 'package:allhelps/filter_model.dart';
import 'package:flutter/material.dart';

Widget searchBarWidget(BuildContext context, Function onUpdate) {
  FilterModel filterModel = FilterModel();
  return SearchBar(
    leading: Padding(
      padding: const EdgeInsets.only(left: 10),
      child: filterModel.getChosenFilter() == ''
          ? Image.asset(
              'lib/help_page_assets/search.png',
              width: 24,
              height: 24,
            )
          : IconButton(
              onPressed: () {
                onUpdate();
              },
              icon: const Icon(Icons.arrow_back_ios)),
    ),
    hintText: 'I want to find ... ${filterModel.getChosenFilter()}',
    backgroundColor: const WidgetStatePropertyAll(Colors.white),
    side: const WidgetStatePropertyAll(BorderSide(color: Colors.black12)),
    shape: const WidgetStatePropertyAll(RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)))),
    elevation: const WidgetStatePropertyAll(0),
  );
}
