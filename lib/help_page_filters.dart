import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Filters extends StatefulWidget {
  const Filters({super.key});

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  final Map<String, List<String>> filters = {
    "Food": ["Meal", "Pantry"],
    "Support": ["Abuse", "Family", "Financial"],
    "Medical": ["General", "Mental", "Treatment"],
    "Shelter": ["Residence", "Cooling", "Hygiene", "Housing"],
    "Resources": ["Essentials", "Legals", "Job", "Education"],
  };

  String chosenFilter = "";
  Set<String> chosenSubfilters = {''};
  List<Widget> subFilters = [];

  bool isSelected = false;

  String getTopLevelImage(String topCategory) {
    String url = 'lib/help_page_assets/${topCategory.toLowerCase()}.png';
    return url;
  }

  String getSubLevelImage(String subCategory) {
    String formattedFileName = subCategory.replaceAll(' ', '_');
    String url = 'lib/help_page_assets/${formattedFileName.toLowerCase()}.png';
    return url;
  }

  List<Widget> renderTopFilters() {
    List<Widget> topFilters = [];
    filters.keys.toList().forEach((categoryName) {
      topFilters
          .add(renderTopFilter(categoryName, getTopLevelImage(categoryName)));
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
                  chosenFilter = categoryName;
                });
              },
              child: Row(children: [
                FutureBuilder<bool>(
                  future: assetExists(filename),
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
    subFilters.add(renderSubFilter('', getSubLevelImage('Clear filter')));
    subFilters.add(renderSubFilter('Distance', getSubLevelImage('Distance')));
    filters[topCategory]?.forEach((subCategory) {
      subFilters
          .add(renderSubFilter(subCategory, getSubLevelImage(subCategory)));
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
                chosenFilter = '';
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
              backgroundColor: chosenSubfilters.contains(categoryName)
                  ? Colors.purpleAccent
                  : Colors.white),
          child: Row(children: [
            FutureBuilder<bool>(
              future: assetExists(filename),
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
        ));
  }

  void handleSubfilter(String subFilter) {
    if (subFilter == '') {
      setState(() {
        chosenSubfilters = {};
        chosenFilter = "";
      });
    } else {
      setState(() {
        chosenSubfilters.add(subFilter);
      });
    }

    setState(() {
      isSelected = !isSelected;
    });
  }

  Future<bool> assetExists(String path) async {
    try {
      // Attempt to load the asset
      await rootBundle.load(path);
      return true; // Asset exists
    } catch (e) {
      return false; // Asset doesn't exist
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        children: chosenFilter == ""
            ? renderTopFilters()
            : renderSubFilters(chosenFilter));
  }
}
