import 'package:flutter/material.dart';

class ChartData {
  final String category;
  final int count;
  final double percentage;
  final Color color;

  ChartData({
    required this.category,
    required this.count,
    required this.percentage,
    required this.color,
  });
}

class StatusChartData {
  final String title;
  final List<ChartData> data;
  final int total;

  StatusChartData({
    required this.title,
    required this.data,
    required this.total,
  });
}

class ComparisonData {
  final String status;
  final int proctor;
  final int ac;
  final int hod;

  ComparisonData({
    required this.status,
    required this.proctor,
    required this.ac,
    required this.hod,
  });
}
