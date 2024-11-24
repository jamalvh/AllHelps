import 'package:allhelps/filter_model.dart';
import 'package:allhelps/search_model.dart';
import 'package:flutter/material.dart';

import 'search_bar_page.dart';

class Filters extends StatefulWidget {
  final Function closeSearch;
  final Function activateSearch;
  final Function(String) updateSearch;
  final Function(String) updateResults;
  final Function(double) filterLocationsByWalkingTime;

  const Filters({
    super.key,
    required this.closeSearch,
    required this.activateSearch,
    required this.updateSearch,
    required this.updateResults,
    required this.filterLocationsByWalkingTime,
  });

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  FilterModel filterModel = FilterModel();
  SearchModel searchModel = SearchModel();

  Set<String> chosenSubfilters = {
    ''
  }; // Local variable to keep track of chosen subfilters for a set filter

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
                widget.updateResults(categoryName); // Conduct search
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
            child: Row(
              children: [
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
                      return Container();
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> renderSubFilters(topCategory) {
    List<Widget> subFilters = [];
    subFilters
        .add(renderSubFilter('', filterModel.getSubLevelImage('Clear filter')));
    subFilters.add(renderSubFilter(
        'Distance', filterModel.getSubLevelImage('Distance')));
    filterModel.filters[topCategory]?.forEach((subCategory) {
      subFilters.add(renderSubFilter(
          subCategory, filterModel.getSubLevelImage(subCategory)));
    });
    return subFilters;
  }

  Widget renderSubFilter(categoryName, filename) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          if (categoryName == 'Distance') {
            _showDistanceModal(context);
          } else {
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
          }
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: chosenSubfilters.contains(categoryName)
                  ? Colors.indigo.shade300
                  : Colors.black12,
              width: 1,
            ),
          ),
          backgroundColor: chosenSubfilters.contains(categoryName)
              ? Colors.indigo.shade100
              : Colors.white,
        ),
        child: Row(
          children: [
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
          ],
        ),
      ),
    );
  }

  void _showDistanceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Location Based on Distance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Walking time',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildWalkingTimeButton(context, 5),
                  _buildWalkingTimeButton(context, 20),
                  _buildWalkingTimeButton(context, 30),
                  _buildWalkingTimeButton(context, 60),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.cancel, color: Colors.blue),
                    label: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text(
                      'Apply',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalkingTimeButton(BuildContext context, double time) {
    return OutlinedButton(
      onPressed: () {
        widget.filterLocationsByWalkingTime(time);
        Navigator.of(context).pop();
      },



      
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Text(
        '< $time mins',
        style: const TextStyle(fontSize: 14),
      ),
    );
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
                updateSearch: widget.updateSearch,
                updateResults: widget.updateResults,
              ),
            ),
            filterModel.getChosenFilter() == ""
                ? const SizedBox(width: 10)
                : Container(),
            filterModel.getChosenFilter() == ""
                ? Container(
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                : Container(),
          ],
        ),
        const SizedBox(height: 10),
        searchModel.showResults
            ? Container()
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filterModel.getChosenFilter() == ""
                      ? renderTopFilters()
                      : renderSubFilters(filterModel.getChosenFilter()),
                ),
              ),
      ],
    );
  }
}
