import 'package:allhelps/filter_model.dart';
import 'package:allhelps/helps.dart';
import 'package:flutter/material.dart';

class SearchOptions extends StatefulWidget {
  final List<String> searches;
  const SearchOptions({super.key, required this.searches});

  @override
  State<SearchOptions> createState() => _SearchOptionsState();
}

class _SearchOptionsState extends State<SearchOptions> {
  @override
  Widget build(BuildContext context) {
    return SearchOptionsWidget(widget.searches);
  }
}

Widget SearchOptionsWidget(List<String> searches) {
  FilterModel filterModel = FilterModel();
  return Expanded(
      child: ListView.builder(
    itemBuilder: (context, index) {
      String filename = filterModel.getTopLevelImage(searches.elementAt(index));
      return ListTile(
        title: TextButton(
          onPressed: () {
            filterModel.setChosenFilter(searches.elementAt(index));
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const HelpsPage();
            }));
          },
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
              filterModel.searches.elementAt(index),
              style: const TextStyle(fontSize: 14),
            ),
          ]),
        ),
      );
    },
    itemCount: searches.length,
  ));
}
