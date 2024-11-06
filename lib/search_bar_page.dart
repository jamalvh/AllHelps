import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    return const SearchBar(
      leading: Icon(Icons.search),
      hintText: 'I want to find ...',
      backgroundColor: WidgetStatePropertyAll(Colors.white),
      side: WidgetStatePropertyAll(BorderSide(color: Colors.black12)),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)))),
      elevation: WidgetStatePropertyAll(0),
    );
  }
}
