import 'package:allhelps/filter_model.dart';
import 'package:allhelps/helps.dart';
import 'package:flutter/material.dart';

class SearchOptions extends StatefulWidget {
  final List<String> searches;
  final Function(String) updateResults;
  const SearchOptions(
      {super.key, required this.searches, required this.updateResults});

  @override
  State<SearchOptions> createState() => _SearchOptionsState();
}

class _SearchOptionsState extends State<SearchOptions> {
  FilterModel filterModel = FilterModel();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.98,
        child: ListView.builder(
      itemBuilder: (context, index) {
        String filename =
            filterModel.getTopLevelImage(widget.searches.elementAt(index));
        return ListTile(
          title: TextButton(
            onPressed: () {
              filterModel.setChosenFilter(widget.searches.elementAt(index));
              widget.updateResults(filterModel.chosenFilter);
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return HelpsPage();
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
      itemCount: widget.searches.length,
    ));
  }
}

// Widget SearchOptionsWidget(List<String> searches) {
//   FilterModel filterModel = FilterModel();
//   return Expanded(
//       child: ListView.builder(
//     itemBuilder: (context, index) {
//       String filename = filterModel.getTopLevelImage(searches.elementAt(index));
//       return ListTile(
//         title: TextButton(
//           onPressed: () {
//             filterModel.setChosenFilter(searches.elementAt(index));

//             Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//               return const HelpsPage();
//             }));
//           },
//           child: Row(children: [
//             FutureBuilder<bool>(
//               future: filterModel.assetExists(filename),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   return snapshot.data == true
//                       ? Image.asset(
//                           filename,
//                           width: 20,
//                           height: 20,
//                         )
//                       : Container();
//                 } else {
//                   return const CircularProgressIndicator();
//                 }
//               },
//             ),
//             const SizedBox(
//               width: 10,
//             ),
//             Text(
//               filterModel.searches.elementAt(index),
//               style: const TextStyle(fontSize: 14),
//             ),
//           ]),
//         ),
//       );
//     },
//     itemCount: searches.length,
//   ));
// }