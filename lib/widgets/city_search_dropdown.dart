import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class CitySearchDropdown extends StatelessWidget {
  final String currentValue;
  final Function(String?) onChanged;
  final List<String> cities;

  const CitySearchDropdown({
    Key? key,
    required this.currentValue,
    required this.onChanged,
    required this.cities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      popupProps: const PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search city...",
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ),
      items: (filter, infiniteScrollProps) => cities,
      selectedItem: currentValue,
      onChanged: onChanged,
      decoratorProps: const DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: 'Default City',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      ),
    );
  }
}
