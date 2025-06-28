import 'package:ksit_mobile/features/home/models/schedule_models.dart';

class ScheduleRequest {
  final Status status;
  final int pageNo;
  final int pageSize;

  const ScheduleRequest({
    this.status = Status.active,
    this.pageNo = 1,
    this.pageSize = 10,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'pageNo': pageNo,
      'pageSize': pageSize,
    };
  }
}
