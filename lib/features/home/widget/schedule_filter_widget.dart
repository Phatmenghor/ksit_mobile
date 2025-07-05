// lib/features/home/widget/schedule_filter_widget.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ksit_mobile/core/constants/app_colors.dart';

// Import the new utils
import '../../../core/utils/enums_utils.dart';
import '../../../core/utils/ui_utils.dart';

class ScheduleFilterWidget extends StatelessWidget {
  final List<int> availableYears;
  final int selectedYear;
  final List<Semester> availableSemesters;
  final Semester? selectedSemester;
  final Function(int) onYearChanged;
  final Function(Semester) onSemesterChanged;
  final VoidCallback? onSemesterCleared;
  final VoidCallback? onClearFilters;

  const ScheduleFilterWidget({
    super.key,
    required this.availableYears,
    required this.selectedYear,
    required this.availableSemesters,
    required this.selectedSemester,
    required this.onYearChanged,
    required this.onSemesterChanged,
    this.onSemesterCleared,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Academy Year Filter
          Expanded(
            child: _buildFilterCard(
              title: '',
              value: _getYearDisplayText(),
              icon: Icons.filter_alt_rounded,
              hasSelection: selectedYear != 0,
              onTap: () => _showYearPicker(context),
              onClear: selectedYear != 0 ? () => onYearChanged(0) : null,
            ),
          ),

          const SizedBox(width: 12),

          // Semester Filter
          Expanded(
            child: _buildFilterCard(
              title: '',
              value: _getSemesterDisplayText(),
              icon: Icons.filter_alt_rounded,
              hasSelection: selectedSemester != null,
              onTap: () => _showSemesterPicker(context),
              onClear: selectedSemester != null ? onSemesterCleared : null,
            ),
          ),
        ],
      ),
    );
  }

  String _getYearDisplayText() {
    if (selectedYear == 0) {
      return 'All Academy';
    }
    return selectedYear.toString();
  }

  String _getSemesterDisplayText() {
    if (selectedSemester == null) {
      return 'All Semester';
    }
    return selectedSemester!.displayName;
  }

  Widget _buildFilterCard({
    required String title,
    required String value,
    required IconData icon,
    required bool hasSelection,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            if (hasSelection && onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.clear,
                  size: 16,
                  color: AppColors.error,
                ),
              )
            else
              const Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  void _showYearPicker(BuildContext context) {
    // Use UIUtils for bottom sheet
    UIUtils.showCustomBottomSheet(
      height: 300,
      child: YearPickerWidget(
        availableYears: availableYears,
        selectedYear: selectedYear,
        onYearSelected: onYearChanged,
      ),
    );
  }

  void _showSemesterPicker(BuildContext context) {
    // Use UIUtils for bottom sheet
    UIUtils.showCustomBottomSheet(
      height: 300,
      child: SemesterPickerWidget(
        availableSemesters: availableSemesters,
        selectedSemester: selectedSemester,
        onSemesterSelected: onSemesterChanged,
        onSemesterCleared: onSemesterCleared,
      ),
    );
  }
}

// Year Picker Component
class YearPickerWidget extends StatefulWidget {
  final List<int> availableYears;
  final int selectedYear;
  final Function(int) onYearSelected;

  const YearPickerWidget({
    super.key,
    required this.availableYears,
    required this.selectedYear,
    required this.onYearSelected,
  });

  @override
  State<YearPickerWidget> createState() => _YearPickerWidgetState();
}

class _YearPickerWidgetState extends State<YearPickerWidget> {
  late int tempSelectedYear;
  late FixedExtentScrollController scrollController;

  @override
  void initState() {
    super.initState();
    tempSelectedYear = widget.selectedYear;

    // Add "All Academy" option at the beginning
    final allYears = [0, ...widget.availableYears];
    final initialIndex = allYears.indexOf(tempSelectedYear);
    scrollController = FixedExtentScrollController(
        initialItem: initialIndex >= 0 ? initialIndex : 0);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allYears = [0, ...widget.availableYears];

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
              const Text(
                'Select Academy Year',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.onYearSelected(tempSelectedYear);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Picker
        Expanded(
          child: CupertinoPicker(
            scrollController: scrollController,
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              tempSelectedYear = allYears[index];
            },
            children: allYears.map((year) {
              return Center(
                child: Text(
                  year == 0 ? 'All Academy' : year.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// Semester Picker Component
class SemesterPickerWidget extends StatefulWidget {
  final List<Semester> availableSemesters;
  final Semester? selectedSemester;
  final Function(Semester) onSemesterSelected;
  final VoidCallback? onSemesterCleared;

  const SemesterPickerWidget({
    super.key,
    required this.availableSemesters,
    required this.selectedSemester,
    required this.onSemesterSelected,
    this.onSemesterCleared,
  });

  @override
  State<SemesterPickerWidget> createState() => _SemesterPickerWidgetState();
}

class _SemesterPickerWidgetState extends State<SemesterPickerWidget> {
  late Semester? tempSelectedSemester;
  late FixedExtentScrollController scrollController;

  @override
  void initState() {
    super.initState();
    tempSelectedSemester = widget.selectedSemester;

    // Find the correct initial index
    int initialIndex = 0; // Default to "All Semester"
    if (widget.selectedSemester != null) {
      // Find the index of the selected semester (add 1 because null is at index 0)
      final semesterIndex =
          widget.availableSemesters.indexOf(widget.selectedSemester!);
      if (semesterIndex >= 0) {
        initialIndex =
            semesterIndex + 1; // +1 because "All Semester" (null) is at index 0
      }
    }

    scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allSemesters = <Semester?>[null, ...widget.availableSemesters];

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
              const Text(
                'Select Semester',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  if (tempSelectedSemester != null) {
                    widget.onSemesterSelected(tempSelectedSemester!);
                  } else {
                    // Clear semester selection
                    widget.onSemesterCleared?.call();
                  }
                  Navigator.pop(context);
                },
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Picker
        Expanded(
          child: CupertinoPicker(
            scrollController: scrollController,
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              tempSelectedSemester = allSemesters[index];
            },
            children: allSemesters.map((semester) {
              return Center(
                child: Text(
                  semester == null ? 'All Semester' : semester.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
