import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'analytics_model.dart';
import 'analytics_service.dart';
import 'chart_data.dart';
import 'components/date_header.dart';
import 'components/summary_cards.dart';
import 'components/pie_chart_section.dart';
import 'components/month_picker.dart';
import 'monthly_report_page.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  late DateTime _selectedDate;
  bool _isLoading = true;
  AnalyticsData? _analyticsData;
  final AnalyticsService _analyticsService = AnalyticsService();
  String? _errorMessage;
  final List<StatusChartData> _statusCharts = [];
  final List<ComparisonData> _comparisonData = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _fetchAnalyticsData();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAnalyticsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _analyticsService.fetchAnalyticsData(
        month: _selectedDate.month,
        year: _selectedDate.year,
      );
      setState(() {
        _analyticsData = data;
        _isLoading = false;
        _prepareChartData();
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _prepareChartData() {
    if (_analyticsData == null) return;

    _statusCharts.clear();
    _comparisonData.clear();

    _statusCharts.add(_createStatusChartData(
        'Proctor Status',
        _analyticsData!.proctorStatusCounts,
        [Colors.orange.shade400, Colors.green.shade400, Colors.red.shade400]));

    _statusCharts.add(_createStatusChartData(
        'AC Status',
        _analyticsData!.acStatusCounts,
        [Colors.orange.shade400, Colors.green.shade400, Colors.red.shade400]));

    _statusCharts.add(_createStatusChartData(
        'HOD Status',
        _analyticsData!.hodStatusCounts,
        [Colors.orange.shade400, Colors.green.shade400, Colors.red.shade400]));

    // Prepare comparison data
    _comparisonData.add(ComparisonData(
      status: 'Pending',
      proctor: _analyticsData!.proctorStatusCounts.pending,
      ac: _analyticsData!.acStatusCounts.pending,
      hod: _analyticsData!.hodStatusCounts.pending,
    ));

    _comparisonData.add(ComparisonData(
      status: 'Approved',
      proctor: _analyticsData!.proctorStatusCounts.approved,
      ac: _analyticsData!.acStatusCounts.approved,
      hod: _analyticsData!.hodStatusCounts.approved,
    ));

    _comparisonData.add(ComparisonData(
      status: 'Rejected',
      proctor: _analyticsData!.proctorStatusCounts.rejected,
      ac: _analyticsData!.acStatusCounts.rejected,
      hod: _analyticsData!.hodStatusCounts.rejected,
    ));
  }

  StatusChartData _createStatusChartData(
      String title, StatusCounts counts, List<Color> colors) {
    final total = counts.pending + counts.approved + counts.rejected;

    final List<ChartData> data = [];

    if (counts.pending > 0) {
      data.add(ChartData(
        category: 'Pending',
        count: counts.pending,
        percentage: total > 0 ? (counts.pending / total) * 100 : 0,
        color: colors[0],
      ));
    }

    if (counts.approved > 0) {
      data.add(ChartData(
        category: 'Approved',
        count: counts.approved,
        percentage: total > 0 ? (counts.approved / total) * 100 : 0,
        color: colors[1],
      ));
    }

    if (counts.rejected > 0) {
      data.add(ChartData(
        category: 'Rejected',
        count: counts.rejected,
        percentage: total > 0 ? (counts.rejected / total) * 100 : 0,
        color: colors[2],
      ));
    }

    return StatusChartData(
      title: title,
      data: data,
      total: total,
    );
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return MonthPicker(
          selectedDate: _selectedDate,
          onDateSelected: (year, month) {
            setState(() {
              _selectedDate = DateTime(year, month);
            });
            _fetchAnalyticsData();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'On Duty Analytics',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _showMonthPicker,
            tooltip: 'Select Month and Year',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAnalyticsData,
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Analytics Dashboard',
            ),
            Tab(
              icon: Icon(Icons.description),
              text: 'Monthly Reports',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnalyticsBody(),
          const MonthlyReportPage(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $_errorMessage',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchAnalyticsData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_analyticsData == null) {
      return Center(
        child: Text(
          'No data available',
          style: GoogleFonts.poppins(
            fontSize: 16,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DateHeader(
            selectedDate: _selectedDate,
            onChangePressed: _showMonthPicker,
          ),
          const SizedBox(height: 24),
          SummaryCards(analyticsData: _analyticsData!),
          const SizedBox(height: 24),
          PieChartSection(statusCharts: _statusCharts),
        ],
      ),
    );
  }
}
