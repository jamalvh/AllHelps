import 'package:allhelps/filter_model.dart';
import 'package:allhelps/helps.dart';
import 'package:flutter/material.dart';

Widget SearchOptions() {
  FilterModel filterModel = FilterModel();
  return Expanded(
      child: ListView.builder(
    itemBuilder: (context, index) {
      String filterOption = filterModel.filters.keys.toList().elementAt(index);
      String filename = filterModel.getTopLevelImage(filterOption);
      return ListTile(
        title: TextButton(
          onPressed: () {
            filterModel.chosenSubfilters = {''};
            filterModel.setChosenFilter(filterOption);
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
              filterOption,
              style: const TextStyle(fontSize: 14),
            ),
          ]),
        ),
      );
    },
    itemCount: filterModel.filters.keys.length,
  ));
}
