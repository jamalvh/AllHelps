class FilterModel {
  // Singleton model
  static final FilterModel _instance = FilterModel._internal();
  FilterModel._internal();

  factory FilterModel() {
    return _instance;
  }

  final Map<String, List<String>> filters = {
    "Food": ["Meal", "Pantry"],
    "Support": ["Abuse", "Family", "Financial"],
    "Medical": ["General", "Mental", "Treatment"],
    "Shelter": ["Residence", "Cooling", "Hygiene", "Housing"],
    "Resources": ["Essentials", "Legals", "Job", "Education"],
  };

  String chosenFilter = "";
  Set<String> chosenSubfilters = {''};

  void setChosenFilter(String newFilter) {
    chosenFilter = newFilter;
  }

  String getChosenFilter() {
    return chosenFilter;
  }

  String getTopLevelImage(String topCategory) {
    String url = 'lib/help_page_assets/${topCategory.toLowerCase()}.png';
    return url;
  }

  String getSubLevelImage(String subCategory) {
    String formattedFileName = subCategory.replaceAll(' ', '_');
    String url = 'lib/help_page_assets/${formattedFileName.toLowerCase()}.png';
    return url;
  }
}
