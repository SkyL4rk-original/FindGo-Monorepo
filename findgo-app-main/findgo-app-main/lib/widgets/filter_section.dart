import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../data_models/special.dart';
import '../main.dart';
import '../view_models/filter_vm.dart';
import '../view_models/theme_vm.dart';

class FilterSection extends StatefulWidget {
  final Function(String) onSearchSubmitted;
  final Function(DateTimeRange?) onCalendarFilter;
  final Function(SpecialType?) onTypeFilter;
  final Function(bool)? onLocationFilter;

  const FilterSection({
    Key? key,
    required this.onSearchSubmitted,
    required this.onCalendarFilter,
    required this.onTypeFilter,
    this.onLocationFilter,
  }) : super(key: key);

  @override
  _FilterSectionState createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  late ThemeViewModel _themeViewModel;

  DateTimeRange? _dateRange;
  bool _showLocationRangeSelector = false;
  double? _locationRange;

  @override
  void initState() {
    final _filterViewModel = context.read(filterVMProvider);
    _themeViewModel = context.read(themeVMProvider);

    // Do after build
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (widget.onLocationFilter != null) {
        _locationRange = await _filterViewModel.locationRange;
        if (_locationRange != null) {
          final _locationVM = context.read(locationVMProvider);
          await _locationVM.fetchCurrentPosition();
          widget.onLocationFilter!(_showLocationRangeSelector);
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      background: Consumer(
        builder: (context, watch, child) {
          watch(themeVMProvider);
          watch(specialsVMProvider);
          watch(storesVMProvider);
          final filterVM = watch(filterVMProvider);
          final locationVM = watch(locationVMProvider);

          return Column(
            children: [
              const SizedBox(height: kToolbarHeight + 30),

              /// SELECTION BUTTONS
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _specialTypeSelectButtonIcon(
                    specialType: SpecialType.brand,
                    label: "Specials",
                    icon: Icons.store,
                  ),
                  _specialTypeSelectButtonIcon(
                    specialType: SpecialType.event,
                    label: "Events",
                    icon: Icons.music_note,
                  ),
                  _specialTypeSelectButtonIcon(
                    specialType: SpecialType.discount,
                    label: "Discounts",
                    icon: Icons.money_sharp,
                  ),
                  _specialTypeSelectButtonIcon(
                    specialType: SpecialType.featured,
                    label: "Featured",
                    icon: Icons.star,
                  ),
                  // INFO: DATE RANGE BUTTON
                  Column(
                    children: [
                      TextButton(
                        onPressed: () async {
                          // FocusScope.of(context).unfocus();

                          // _onlyTodaySpecials = !_onlyTodaySpecials;
                          // updated = false;
                          // setState(() {});
                          if (_dateRange != null) {
                            _dateRange = null;
                          } else {
                            final now = DateTime.now();

                            _dateRange = await showDateRangePicker(
                              context: context,
                              initialEntryMode:
                                  DatePickerEntryMode.calendarOnly,
                              firstDate: DateTime(now.year - 1),
                              lastDate: DateTime(now.year + 5),
                              initialDateRange: DateTimeRange(
                                start: now,
                                end: DateTime(now.year, now.month, now.day + 1),
                              ),
                              builder: (context, child) {
                                return _themeViewModel.mode == ThemeMode.dark
                                    ? Theme(
                                        data: ThemeData.dark().copyWith(
                                          dialogBackgroundColor: Colors.white,
                                          primaryColor: kColorAccent,
                                          colorScheme: const ColorScheme.dark(
                                            primary: kColorAccent,
                                          ),
                                        ),
                                        child: child!,
                                      )
                                    : Theme(
                                        data: ThemeData.light().copyWith(
                                          primaryColor: kColorAccent,
                                          colorScheme: const ColorScheme.light(
                                            primary: kColorAccent,
                                          ),
                                        ),
                                        child: child!,
                                      );
                              },
                            );
                          }

                          // await _filterViewModel.filterSpecialList(
                          //     filterString: _filterString,
                          //     selectedSpecialType: _selectedSpecialType,
                          //     filterFollowing: widget.filterFollowing,
                          //     filterSaved: widget.filterSaved,
                          //     dateRange: _dateRange
                          // );
                          widget.onCalendarFilter(_dateRange);

                          setState(() {});
                        },
                        style: _dateRange != null
                            ? kButtonSpecialType
                            : kButtonSpecialTypeDeactivated,
                        // color: kColorAccent,
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: _themeViewModel.mode == ThemeMode.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      const Text(
                        "Calendar",
                        style: TextStyle(fontSize: 8.0),
                      )
                    ],
                  ),
                ],
              ),
              // INFO: SEARCH BAR
              const SizedBox(
                height: 8.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        elevation: 0,
                        color: Colors.grey.withAlpha(40),
                        child: SizedBox(
                          height: 40.0,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Search',
                                icon: Icon(
                                  Icons.search,
                                ),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (query) async {
                                _filterString = query.toLowerCase();

                                // await _filterViewModel.filterSpecialList(
                                //     filterString: _filterString,
                                //     selectedSpecialType: _selectedSpecialType,
                                //     filterFollowing: widget.filterFollowing,
                                //     filterSaved: widget.filterSaved,
                                //     dateRange: _dateRange
                                // );

                                widget.onSearchSubmitted(_filterString);
                                setState(() {});
                              },
                              onChanged: (query) async {
                                _filterString = query.toLowerCase();

                                // widget.onSearchSubmitted(_filterString);
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    // INFO: LOCATION BUTTON
                    if (widget.onLocationFilter != null)
                      Column(
                        children: [
                          TextButton(
                            onPressed: () async {
                              _locationRange = await filterVM.locationRange;

                              if (_locationRange != null) {
                                _locationRange = null;
                                filterVM.setLocationRange(_locationRange);
                                _showLocationRangeSelector = false;
                              } else {
                                // Check for current location
                                locationVM.context = context;
                                if (locationVM.latLng.isNil &&
                                    !await locationVM.fetchCurrentPosition()) {
                                  return;
                                }

                                _locationRange = _defaultLocationRange;
                                filterVM.setLocationRange(_locationRange);
                                _showLocationRangeSelector = true;
                              }
                              widget.onLocationFilter!(
                                _showLocationRangeSelector,
                              );
                              setState(() {});
                            },
                            style: _showLocationRangeSelector || _locationRange != null
                                ? kButtonSpecialType
                                : kButtonSpecialTypeDeactivated,
//                                 ? kButtonSpecialTypeDeactivated
//                                 : kButtonSpecialType,
                            // color: kColorAccent,
                            child: Icon(
                              Icons.location_pin,
                              color: _themeViewModel.mode == ThemeMode.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          Text(
                            _locationRange == null ? "Location" : "${_locationRange!.toInt()} km",
                            style: const TextStyle(fontSize: 8.0),
                          )
                        ],
                      ),
                  ],
                ),
              ),
              if (_showLocationRangeSelector && _locationRange != null)
                SizedBox(
                  height: 50.0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                          left: 16,
                          bottom: 0,
                          child: Text("${_minLocationRange.toInt()} km", style: const TextStyle(fontSize: 10.0),),),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape:
                              const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 28.0),
                          tickMarkShape: const RoundSliderTickMarkShape(),
                          valueIndicatorShape:
                              const PaddleSliderValueIndicatorShape(),
                          valueIndicatorTextStyle: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        child: Slider(
                          label: "${_locationRange!.toInt()} km",
                          value: _locationRange!,
                          min: _minLocationRange,
                          max: _maxLocationRange,
                          divisions: (_maxLocationRange - _minLocationRange) ~/ 5,
                          onChanged: (value) => setState(() {
                            _locationRange = value;
                            filterVM.setLocationRange(_locationRange);
                          }),
                          onChangeEnd: (value) async {
                            widget.onLocationFilter!(true);
                            await Future.delayed(const Duration(seconds: 2));
                            _showLocationRangeSelector = false;
                            widget.onLocationFilter!(false);
                            setState(() {});
                          },
                        ),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 0,
                        child: Text("${_maxLocationRange.toInt()} km", style: const TextStyle(fontSize: 10.0),),),
                    ],
                  ),
                ),

              const SizedBox(
                height: 12.0,
              ),
            ],
          );
        },
      ),
    );
  }

  final double _defaultLocationRange = 10.0;
  final double _minLocationRange = 5.0;
  final double _maxLocationRange = 50.0;

  String _filterString = "";
  SpecialType? _selectedSpecialType;
  final kButtonSpecialType = ElevatedButton.styleFrom(
    primary: kColorAccent,
    shape: const CircleBorder(side: BorderSide(color: kColorAccent)),
  );
  final kButtonSpecialTypeDeactivated = ElevatedButton.styleFrom(
    primary: Colors.grey.withAlpha(20),
    shape: const CircleBorder(side: BorderSide(color: Colors.grey)),
  );

  Widget _specialTypeSelectButtonIcon({
    required String label,
    required IconData icon,
    required SpecialType specialType,
  }) {
    return Column(
      children: [
        TextButton(
          onPressed: () async {
            FocusScope.of(context).unfocus();
            if (_selectedSpecialType == specialType) {
              _selectedSpecialType = null;
            } else {
              _selectedSpecialType = specialType;
            }

            widget.onTypeFilter(_selectedSpecialType);

            // await _filterViewModel.filterSpecialList(
            //     filterString: _filterString,
            //     selectedSpecialType: _selectedSpecialType,
            //     filterFollowing: widget.filterFollowing,
            //     filterSaved: widget.filterSaved,
            //     dateRange: _dateRange
            // );
            setState(() {});
          },
          style: _selectedSpecialType == specialType
              ? kButtonSpecialType
              : kButtonSpecialTypeDeactivated,
          // color: kColorAccent,
          child: Icon(
            icon,
            color: _themeViewModel.mode == ThemeMode.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 8.0),
        )
      ],
    );
  }
}
