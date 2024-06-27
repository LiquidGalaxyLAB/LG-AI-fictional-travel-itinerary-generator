import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lg_ai_travel_itinerary/ai_travel/config/theme/app_theme.dart';

import '../providers/connection_providers.dart';

class CustomDropdown extends ConsumerStatefulWidget {
  final List<String> elementList;

  const CustomDropdown({super.key, required this.elementList});

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends ConsumerState<CustomDropdown> {
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.elementList.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      onChanged: (String? newValue) {
        ref.read(currentAiModelSelected.notifier).state = newValue!;
        setState(() {
          dropdownValue = newValue!;
        });
      },
      items: widget.elementList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      elevation: 2,
      dropdownColor: AppColors.backgroundColor,
    );
  }
}
