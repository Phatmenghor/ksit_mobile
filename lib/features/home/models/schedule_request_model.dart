import 'package:ksit_mobile/features/home/models/schedule_models.dart';

class ScheduleRequest {
  final int academyYear;
  final Semester semester;
  final DayOfWeek? dayOfWeek;
  final Status status;
  final int pageNo;
  final int pageSize;

  const ScheduleRequest({
    required this.academyYear,
    required this.semester,
    this.dayOfWeek,
    this.status = Status.active,
    this.pageNo = 1,
    this.pageSize = 10,
  });

  Map<String, dynamic> toJson() {
    return {
      'academyYear': academyYear,
      'semester': semester.name,
      if (dayOfWeek != null) 'dayOfWeek': dayOfWeek!.name,
      'status': status.name,
      'pageNo': pageNo,
      'pageSize': pageSize,
    };
  }
}
