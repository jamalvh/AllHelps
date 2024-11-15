import 'package:allhelps/filter_model.dart';
import 'package:allhelps/search_model.dart';
import 'package:flutter/material.dart';

import 'search_bar_page.dart';

class Filters extends StatefulWidget {
  final Function activateSearch;
  final Function closeSearch;
  const Filters(
      {super.key, required this.activateSearch, required this.closeSearch});

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  FilterModel filterModel = FilterModel();
  SearchModel searchModel = SearchModel();

  Set<String> chosenSubfilters = {
    ''
  }; // Local variable to keep track of chosen sub filters for a set filter

  List<Widget> renderTopFilters() {
    List<Widget> topFilters = [];
    filterModel.filters.keys.toList().forEach((categoryName) {
      topFilters.add(renderTopFilter(
          categoryName, filterModel.getTopLevelImage(categoryName)));
    });

    return topFilters;
  }

  Widget renderTopFilter(categoryName, filename) {
    return Row(
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  chosenSubfilters = {''};
                  filterModel.setChosenFilter(categoryName);
                  // Conduct search
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Colors.black12, width: 1),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              child: Row(children: [
                FutureBuilder<bool>(
                  future: filterModel.assetExists(filename),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return snapshot.data == true
                          ? Image.asset(
                              filename,
                              width: 20,
                              height: 20,
                            )
                          : Container();
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  categoryName,
                  style: const TextStyle(fontSize: 14),
                ),
              ]),
            )),
      ],
    );
  }

  List<Widget> renderSubFilters(topCategory) {
    List<Widget> subFilters = [];
    subFilters
        .add(renderSubFilter('', filterModel.getSubLevelImage('Clear filter')));
    subFilters.add(
        renderSubFilter('Distance', filterModel.getSubLevelImage('Distance')));
    filterModel.filters[topCategory]?.forEach((subCategory) {
      subFilters.add(renderSubFilter(
          subCategory, filterModel.getSubLevelImage(subCategory)));
    });
    return subFilters;
  }

  Widget renderSubFilter(categoryName, filename) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              if (categoryName == '') {
                chosenSubfilters = {''};
              } else {
                if (chosenSubfilters.contains(categoryName)) {
                  chosenSubfilters.remove(categoryName);
                } else {
                  chosenSubfilters.add(categoryName);
                }
              }
            });
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                    color: chosenSubfilters.contains(categoryName)
                        ? Colors.indigo.shade300
                        : Colors.black12,
                    width: 1)),
            backgroundColor: chosenSubfilters.contains(categoryName)
                ? Colors.indigo.shade100
                : Colors.white,
          ),
          child: Row(children: [
            FutureBuilder<bool>(
              future: filterModel.assetExists(filename),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return snapshot.data == true
                      ? Image.asset(
                          filename,
                          width: 20,
                          height: 20,
                        )
                      : Container();
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              categoryName,
              style: const TextStyle(fontSize: 14),
            ),
          ]),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: SearchBarWidget(
              closeSearch: widget.closeSearch,
              activateSearch: widget.activateSearch,
            )),
            filterModel.getChosenFilter() == ""
                ? const SizedBox(
                    width: 10,
                  )
                : Container(),
            filterModel.getChosenFilter() == ""
                ? Container(
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                        color: Colors.indigo.shade400,
                        borderRadius: BorderRadius.circular(10)),
                    width: 0.15 * MediaQuery.of(context).size.width,
                    height: 0.075 * MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/help_page_assets/top_clear_filter.png',
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        const Text(
                          'Filter',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : Container()
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: searchModel.showResults
                  ? [Container()]
                  : filterModel.getChosenFilter() == ""
                      ? renderTopFilters()
                      : renderSubFilters(filterModel.getChosenFilter()),
            ))
      ],
    );
  }
}
