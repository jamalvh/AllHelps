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
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SizedBox(
            width: MediaQuery.of(context).size.width, 
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 375,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [  
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400], 
                          borderRadius: BorderRadius.circular(10), 
                        ),
                      ),
                    ),
                    const SizedBox(height: 16), 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Location Based on ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Distance',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Tooltip(
                          message:
                              'These are the nearest shelters based on your current location',
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Walking time',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildWalkingTimeButton(context, 5, isLeft: true),
                            _buildWalkingTimeButton(context, 20, isLeft: false),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildWalkingTimeButton(context, 30, isLeft: true),
                            _buildWalkingTimeButton(context, 60, isLeft: false),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                             backgroundColor: const Color.fromARGB(255, 224, 236, 248),
                              foregroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            icon: const Icon(Icons.cancel, color: Colors.deepPurple),
                            label: const Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 224, 236, 248),
                              foregroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            icon: const Icon(Icons.check_circle, color: Colors.deepPurple),
                            label: const Text('Apply', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildWalkingTimeButton(BuildContext context, double time, {bool isLeft = false}) {
  return Expanded(
    child: OutlinedButton(
      onPressed: () {
        widget.filterLocationsByWalkingTime(time);
        Navigator.of(context).pop();
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: isLeft ? const Radius.circular(50) : Radius.zero,
            bottomLeft: isLeft ? const Radius.circular(50) : Radius.zero,
            topRight: !isLeft ? const Radius.circular(50) : Radius.zero,
            bottomRight: !isLeft ? const Radius.circular(50) : Radius.zero,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 30),
      ),
      child: Text(
        time == 60.0 ? '60 mins +' : '< $time mins',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black, 
        ),
      ),
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
