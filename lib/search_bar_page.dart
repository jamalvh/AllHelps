import 'package:allhelps/filter_model.dart';
import 'package:allhelps/search_model.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final Function onUpdate;
  final Function updateSearch;
  const SearchBarWidget(
      {super.key, required this.onUpdate, required this.updateSearch});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  FilterModel filterModel = FilterModel();
  SearchModel searchModel = SearchModel();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SearchBar(
          onTap: () {
            print('tapped');
            widget.updateSearch();
            print(searchModel.showResults);
          },
          onTapOutside: (event) {
            setState(() {
              searchModel.showResults = false;
            });
          },
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
                      widget.onUpdate();
                    },
                    icon: const Icon(Icons.arrow_back_ios)),
          ),
          hintText: 'I want to find ... ${filterModel.getChosenFilter()}',
          backgroundColor: const WidgetStatePropertyAll(Colors.white),
          side: const WidgetStatePropertyAll(BorderSide(color: Colors.black12)),
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)))),
          elevation: const WidgetStatePropertyAll(0),
        ),
        searchModel.showResults
            ? Expanded(child: ListView.builder(itemBuilder: (context, index) {
                return ListTile(
                  title: Text(index.toString()),
                );
              }))
            : Container(),
      ],
    );
  }
}
