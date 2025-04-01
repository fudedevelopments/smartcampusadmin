class AnalyticsData {
  final int totalCount;
  final StatusCounts proctorStatusCounts;
  final StatusCounts acStatusCounts;
  final StatusCounts hodStatusCounts;
  final int grantedCount;

  AnalyticsData({
    required this.totalCount,
    required this.proctorStatusCounts,
    required this.acStatusCounts,
    required this.hodStatusCounts,
    required this.grantedCount,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      totalCount: json['total_count'] ?? 0,
      proctorStatusCounts:
          StatusCounts.fromJson(json['proctor_status_counts'] ?? {}),
      acStatusCounts: StatusCounts.fromJson(json['ac_status_counts'] ?? {}),
      hodStatusCounts: StatusCounts.fromJson(json['hod_status_counts'] ?? {}),
      grantedCount: json['granted_count'] ?? 0,
    );
  }
}

class StatusCounts {
  final int pending;
  final int approved;
  final int rejected;

  StatusCounts({
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  factory StatusCounts.fromJson(Map<String, dynamic> json) {
    return StatusCounts(
      pending: json['PENDING'] ?? 0,
      approved: json['APPROVED'] ?? 0,
      rejected: json['REJECTED'] ?? 0,
    );
  }
}
