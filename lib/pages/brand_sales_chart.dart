import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class BrandSalesChartPage extends StatefulWidget {
  const BrandSalesChartPage({Key? key}) : super(key: key);

  @override
  State<BrandSalesChartPage> createState() => _BrandSalesChartPageState();
}

class _BrandSalesChartPageState extends State<BrandSalesChartPage> {
  List<String> brands = [];
  Map<String, List<int>> salesData = {};
  bool isLoading = false;
  String? errorMsg;

  final List<Color> colorList = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    fetchSalesFromAsset();
  }

  Future<void> fetchSalesFromAsset() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final String jsonString = await rootBundle.loadString('assets/laptop_sales.json');
      final List<dynamic> data = json.decode(jsonString);
      Map<String, List<int>> temp = {};
      List<String> tempBrands = [];
      for (final item in data) {
        final brand = item['brand'] as String;
        final sales = List<int>.from(item['sales']);
        temp[brand] = sales;
        tempBrands.add(brand);
      }
      setState(() {
        salesData = temp;
        brands = tempBrands;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = 'Gagal membaca data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF008FE5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.only(top: 36, left: 20, right: 20, bottom: 18),
            child: const SafeArea(
              child: Text(
                'Statistik Penjualan Brand',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ScaleOnTap(
                onTap: null,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  elevation: 7,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Penjualan Laptop per Brand',
                          style: TextStyle(
                            color: Color(0xFF008FE5),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: _buildChart(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final months = ['Des', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei'];
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : errorMsg != null
            ? Center(child: Text(errorMsg!, style: const TextStyle(color: Colors.red)))
            : salesData.isEmpty
                ? const Center(child: Text('Tidak ada data penjualan', style: TextStyle(color: Colors.white70)))
                : LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: 5,
                      minY: 0,
                      maxY: salesData.values.expand((e) => e).reduce((a, b) => a > b ? a : b) + 20,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 20,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.white.withOpacity(0.1),
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: Colors.white.withOpacity(0.1),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= months.length) return const SizedBox();
                              return Text(
                                months[idx],
                                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14),
                              );
                            },
                            interval: 1,
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: List.generate(brands.length, (i) {
                        final brand = brands[i];
                        final sales = salesData[brand]!;
                        return LineChartBarData(
                          spots: List.generate(sales.length, (j) => FlSpot(j.toDouble(), sales[j].toDouble())),
                          isCurved: true,
                          color: colorList[i % colorList.length],
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: colorList[i % colorList.length],
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: colorList[i % colorList.length].withOpacity(0.12),
                          ),
                        );
                      }),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.black87,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final brand = brands[spot.barIndex];
                              return LineTooltipItem(
                                '$brand\n${months[spot.x.toInt()]}: ${spot.y.toInt()}',
                                TextStyle(
                                  color: colorList[spot.barIndex % colorList.length],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  );
  }
}

class ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const ScaleOnTap({Key? key, required this.child, this.onTap}) : super(key: key);

  @override
  State<ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<ScaleOnTap> {
  double _scale = 1.0;

  void _onTapDown(_) => setState(() => _scale = 0.96);
  void _onTapUp(_) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
} 