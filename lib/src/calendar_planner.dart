import 'package:calendar_planner/config/global_config.dart' as config;
import 'package:calendar_planner/src/calendar_planner_column.dart';
import 'package:calendar_planner/src/calendar_planner_filter.dart';
import 'package:calendar_planner/src/calendar_planner_style.dart';
import 'package:calendar_planner/src/calendar_planner_task.dart';
import 'package:calendar_planner/src/calendar_planner_title.dart';
import 'package:flutter/material.dart';

import 'calendar_planner_employee_card.dart';
import 'calendar_planner_time.dart';

class CalendarPlanner extends StatefulWidget {
  final int startHour;

  /// Time end at this hour, max value is 23
  final int endHour;

  /// Create days from here, each day is a TimePlannerTitle.
  ///
  /// you should create at least one day
  final List<CalendarPlannerTitle> headers;

  /// List of widgets on time planner
  final List<CalendarPlannerTask>? tasks;

  /// Style of time planner
  final CalendarPlannerStyle? style;

  /// When widget loaded scroll to current time with an animation. Default is true
  final bool? currentTimeAnimation;

  /// Whether time is displayed in 24 hour format or am/pm format in the time column on the left.
  final bool use24HourFormat;

  //Whether the time is displayed on the axis of the tim or on the center of the timeblock. Default is false.
  final bool setTimeOnAxis;

  const CalendarPlanner(
      {Key? key,
      required this.startHour,
      required this.endHour,
      required this.headers,
      this.tasks,
      this.style,
      this.use24HourFormat = false,
      this.setTimeOnAxis = false,
      this.currentTimeAnimation})
      : super(key: key);

  @override
  State<CalendarPlanner> createState() => _CalendarPlannerState();
}

class _CalendarPlannerState extends State<CalendarPlanner> {
  ScrollController mainHorizontalController = ScrollController();
  ScrollController mainVerticalController = ScrollController();
  ScrollController dayHorizontalController = ScrollController();
  ScrollController timeVerticalController = ScrollController();
  CalendarPlannerStyle style = CalendarPlannerStyle();
  List<CalendarPlannerTask> tasks = [];
  bool? isAnimated = true;

  /// check input value rules
  void _checkInputValue() {
    if (widget.startHour > widget.endHour) {
      throw FlutterError("Start hour should be lower than end hour");
    } else if (widget.startHour < 0) {
      throw FlutterError("Start hour should be larger than 0");
    } else if (widget.endHour > 23) {
      throw FlutterError("Start hour should be lower than 23");
    } else if (widget.headers.isEmpty) {
      throw FlutterError("header can't be empty");
    }
  }

  /// create local style
  void _convertToLocalStyle() {
    style.backgroundColor = widget.style?.backgroundColor;
    style.cellHeight = widget.style?.cellHeight ?? 80;
    style.cellWidth = widget.style?.cellWidth ?? 90;
    style.horizontalTaskPadding = widget.style?.horizontalTaskPadding ?? 0;
    style.borderRadius = widget.style?.borderRadius ??
        const BorderRadius.all(Radius.circular(8.0));
    style.dividerColor = widget.style?.dividerColor;
    style.showScrollBar = widget.style?.showScrollBar ?? false;
    style.interstitialOddColor = widget.style?.interstitialOddColor;
    style.interstitialEvenColor = widget.style?.interstitialEvenColor;
  }

  //Function to initial calendar view
  void _initData() {
    _checkInputValue();
    _convertToLocalStyle();
    config.horizontalTaskPadding = style.horizontalTaskPadding;
    config.cellHeight = style.cellHeight;
    config.cellWidth = style.cellWidth;
    config.totalHours = (widget.endHour - widget.startHour).toDouble();
    config.totalDays = widget.headers.length;
    config.startHour = widget.startHour;
    config.use24HourFormat = widget.use24HourFormat;
    config.setTimeOnAxis = widget.setTimeOnAxis;
    config.borderRadius = style.borderRadius;
    isAnimated = widget.currentTimeAnimation;
    tasks = widget.tasks ?? [];
  }

  @override
  void initState() {
    _initData();
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      int hour = DateTime.now().hour;
      if (isAnimated != null && isAnimated == true) {
        if (hour > widget.startHour) {
          double scrollOffset =
              (hour - widget.startHour) * config.cellHeight!.toDouble();
          mainVerticalController.animateTo(
            scrollOffset,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCirc,
          );
          timeVerticalController.animateTo(
            scrollOffset,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCirc,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < 1; i++)
          const CalendarPlannerEmployeeCard()
      ],
    );
  }

  String formattedTime(int hour) {
    /// this method formats the input hour into a time string
    /// modifing it as necessary based on the use24HourFormat flag .
    if (config.use24HourFormat) {
      // we use the hour as-is
      return hour.toString() + ':00';
    } else {
      // we format the time to use the am/pm scheme
      if (hour == 0) return "12:00 am";
      if (hour < 12) return "$hour:00 am";
      if (hour == 12) return "12:00 pm";
      return "${hour - 12}:00 pm";
    }
  }
}