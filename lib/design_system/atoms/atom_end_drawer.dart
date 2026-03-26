import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../../core/core.dart';
import '../../../../../design_system/atoms/atom_chip.dart';
import '../../../../../shared_widgets/custom_button.dart';
import 'atom_text_field.dart';

class AtomEndDrawer extends ConsumerWidget {
  const AtomEndDrawer({
    required this.textFilter,
    required this.thematicListFilter,
    required this.isDarkMode,
    required this.selectedList,
    this.showFilteredDate = true,
    this.scaffoldKey,
    this.startDate,
    this.endDate,
    this.onSelected,
    this.onApplyFilters,
    this.onClearFilters,
    super.key,
  });

  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String textFilter;
  final List<String> thematicListFilter;
  final bool isDarkMode;
  final List<bool> selectedList;
  final bool showFilteredDate;
  final TextEditingController? startDate;
  final TextEditingController? endDate;
  final Function(bool, int)? onSelected;
  final VoidCallback? onApplyFilters;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
        margin: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0),
        child: Drawer(
          width: Helpers.getResponsiveWidth(context) * .88,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    70.ph,
                    ListTile(
                      title: Text(
                        textFilter,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    46.ph,
                    ListTile(
                      title: Text(
                        'Thématiques',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      onTap: () {},
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 4,
                            runAlignment: WrapAlignment.center,
                            children: [
                              for (int i = 0; i < thematicListFilter.length; i++)
                                AtomChip(
                                  data: thematicListFilter[i],
                                  backgroundColor: isDarkMode ? surfaceDark : surfaceLight,
                                  selectedColor: isDarkMode ? primaryLight : primaryDark,
                                  borderColor: isDarkMode ? outlineVariantDark : outlineVariantLight,
                                  onSelected: (value) => onSelected?.call(value, i),
                                  isSelected: selectedList.length > i ? selectedList[i] : false,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    20.ph,
                    const Divider(),
                    20.ph,
                    if (showFilteredDate) ...[
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 28),
                        child: Text(
                          'Période',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      30.ph,
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AtomTextField(
                          fieldController: startDate,
                          isDarkMode: isDarkMode,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          onTap: () {
                            _showDatePicker(
                              context,
                              isDarkMode,
                              (selectedDate) {
                                startDate!.text = DateFormat('dd/MM/yyyy').format(selectedDate);
                              },
                              initialDate: _parseDate(startDate!.text),
                            );
                          },
                          readOnly: true,
                          addClearButton: true,
                          label: 'À partir de',
                          hintText: 'jj/mm/aaaa',
                          validator: false,
                          suffixIcon: SvgPicture.asset(
                            Assets.assetsImageCalendar,
                            colorFilter: ColorFilter.mode(
                              isDarkMode ? onPrimaryLight : onPrimaryDark,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      20.ph,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AtomTextField(
                          fieldController: endDate,
                          isDarkMode: isDarkMode,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          onTap: () {
                            _showDatePicker(
                              context,
                              isDarkMode,
                              (selectedDate) {
                                endDate!.text = DateFormat('dd/MM/yyyy').format(selectedDate);
                              },
                              initialDate: _parseDate(endDate!.text),
                            );
                          },
                          readOnly: true,
                          addClearButton: true,
                          label: "Jusqu'au",
                          hintText: 'jj/mm/aaaa',
                          validator: false,
                          suffixIcon: SvgPicture.asset(
                            Assets.assetsImageCalendar,
                            colorFilter: ColorFilter.mode(
                              isDarkMode ? onPrimaryLight : onPrimaryDark,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      20.ph,
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CustomButtons.elevatePrimary(
                        onPressed: () {
                          onApplyFilters?.call();
                          scaffoldKey?.currentState?.closeEndDrawer();
                        },
                        title: 'Appliquer les filtres',
                        borderRadius: 100,
                        buttonColor: isDarkMode ? primaryDark : primaryLight,
                        titleStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: isDarkMode ? onPrimaryDark : onPrimaryLight,
                            ),
                      ),
                    ),
                    20.ph,
                  ],
                ),
              ),
              Positioned(
                top: 50,
                right: 30,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircleAvatar(
                    backgroundColor: ref.watch(themeProvider).isDarkMode ? primaryLight : primaryDark,
                    child: IconButton(
                      onPressed: () => scaffoldKey?.currentState?.closeEndDrawer(),
                      icon: Icon(
                        Icons.close,
                        color: ref.watch(themeProvider).isDarkMode ? onSurfaceDark : onSurfaceLight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  DateTime? _parseDate(String dateText) {
    if (dateText.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy').parse(dateText);
    } catch (e) {
      return null;
    }
  }

  void _showDatePicker(
    BuildContext context,
    bool isDarkMode,
    Function(DateTime) onDateSelected, {
    DateTime? initialDate,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(9.0)),
        ),
        backgroundColor: isDarkMode ? onPrimaryDark : onPrimaryLight,
        elevation: 10,
        actionsPadding: EdgeInsets.zero,
        buttonPadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(27, 27, 27, 9),
        content: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9.0),
          ),
          child: SizedBox(
            width: 300,
            height: 300,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('fr')],
              locale: const Locale('fr'),
              home: SfDateRangePicker(
                controller: DateRangePickerController(),
                initialSelectedDate: initialDate ?? DateTime.now(),
                todayHighlightColor: isDarkMode ? primaryDark : primaryLight,
                selectionColor: isDarkMode ? primaryDark : primaryLight,
                showActionButtons: true,
                showNavigationArrow: true,
                headerStyle: DateRangePickerHeaderStyle(
                  textStyle: TextStyle(
                    color: isDarkMode ? onPrimaryLight : onPrimaryDark,
                  ),
                  backgroundColor: isDarkMode ? primaryLight : primaryDark,
                ),
                selectionTextStyle: TextStyle(
                  color: isDarkMode ? primaryLight : primaryDark,
                ),
                backgroundColor: isDarkMode ? onPrimaryDark : onPrimaryLight,
                monthCellStyle: DateRangePickerMonthCellStyle(
                  textStyle: TextStyle(
                    color: isDarkMode ? onPrimaryLight : onPrimaryDark,
                  ),
                ),
                monthViewSettings: DateRangePickerMonthViewSettings(
                  viewHeaderStyle: DateRangePickerViewHeaderStyle(
                    textStyle: TextStyle(
                      color: isDarkMode ? onPrimaryLight : onPrimaryDark,
                    ),
                  ),
                ),
                yearCellStyle: DateRangePickerYearCellStyle(
                  textStyle: TextStyle(
                    color: isDarkMode ? onPrimaryLight : onPrimaryDark,
                  ),
                ),
                onSelectionChanged: (dateRangePickerSelectionChangedArgs) {},
                cancelText: 'Annuler',
                confirmText: 'Ok',
                onCancel: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                onSubmit: (selectedDate) {
                  if (selectedDate != null) {
                    onDateSelected(DateTime.parse(selectedDate.toString()));
                  }
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
