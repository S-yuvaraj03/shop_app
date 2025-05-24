import 'package:flutter/material.dart';
import 'package:shop_app/models/shop.dart';
import 'package:shop_app/models/product.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shop_app/utils/constant/sizes.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class product_analytics extends StatelessWidget {
  final Shop shop;

  product_analytics({required this.shop});

  @override
  Widget build(BuildContext context) {
    int totalAvailable = shop.products.fold(0, (sum, product) => sum + (product.Available_count ?? 0));
    int totalSold = shop.products.fold(0, (sum, product) => sum + (product.lastlyUpdatedAvailableCount - (product.Available_count ?? 0)));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            _buildRoundChart(totalAvailable, totalSold),
            SizedBox(height: 20),
            buildAnimatedColumnChart(shop.products),
            SizedBox(height: 20),
            _buildSectionTitle('Fast-Selling Products'),
            _buildEnhancedProductTable(shop.products, context),
            SizedBox(height: 20),
            _buildSummary(totalAvailable, totalSold),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildRoundChart(int totalAvailable, int totalSold) {
    int totalProducts = totalAvailable + totalSold;
    double availablePercentage = (totalProducts > 0) ? (totalAvailable / totalProducts) * 100 : 0;
    double soldPercentage = (totalProducts > 0) ? (totalSold / totalProducts) * 100 : 0;

    return Column(
      children: [
        _buildSectionTitle('Inventory Overview'),
        SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: totalAvailable.toDouble(),
                  color: Colors.blue,
                  title: 'In Stock: ${totalAvailable} (${availablePercentage.toStringAsFixed(1)}%)',
                  titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                  showTitle: true,
                  titlePositionPercentageOffset: 2.2,
                ),
                PieChartSectionData(
                  value: totalSold.toDouble(),
                  color: Colors.red,
                  title: 'Sold: ${totalSold} (${soldPercentage.toStringAsFixed(1)}%)',
                  titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                  showTitle: true,
                  titlePositionPercentageOffset: 2.2,
                ),
              ],
              centerSpaceRadius: 40,
              sectionsSpace: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAnimatedColumnChart(List<Product> products) {
    return Column(
      children: [
        _buildSectionTitle('Sales Performance'),
        SizedBox(height: 10),
        SizedBox(
          height: 300,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 50,
              interval: 10,
              labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            series: <CartesianSeries<Product, String>>[
              ColumnSeries<Product, String>(
                dataSource: products,
                xValueMapper: (Product product, _) => product.product_name,
                yValueMapper: (Product product, _) =>
                    product.lastlyUpdatedAvailableCount - (product.Available_count ?? 0),
                name: 'Sales',
                pointColorMapper: (Product product, int index) =>
                    Colors.primaries[index % Colors.primaries.length],
                dataLabelSettings: DataLabelSettings(isVisible: true),
                animationDuration: 1200,
                width: 0.6,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ],
            tooltipBehavior: TooltipBehavior(enable: true),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedProductTable(List<Product> products, BuildContext context) {
    return Column(
      children: [
        _buildSectionTitle('Product Details'),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.blue[50]),
            border: TableBorder.all(color: Colors.grey.shade300),
            columns: [
              DataColumn(label: Text('Image')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Stock')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Total Sold')),
              DataColumn(label: Text('Profit')),
            ],
            rows: products.map((product) {
              int totalSold = product.lastlyUpdatedAvailableCount - (product.Available_count ?? 0);
              double profit = totalSold * product.product_offerprice;
              return DataRow(cells: [
                DataCell(Image.network(product.imageLink, width: 50, height: 50)),
                DataCell(Text(_limitWords(product.product_name, 3),
          style: TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(product.product_cateogory)),
                DataCell(Text('${product.Available_count}')),
                DataCell(Text('\$${product.product_offerprice}')),
                DataCell(Text('$totalSold')),
                DataCell(Text('\$${profit.toStringAsFixed(2)}')),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(int totalAvailable, int totalSold) {
    double totalProfit = shop.products.fold(0.0, (sum, product) {
      int soldCount = product.lastlyUpdatedAvailableCount - (product.Available_count ?? 0);
      return sum + (soldCount * product.product_offerprice);
    });

    return Container(
        width: double.infinity-10,
        child: Card(
          color: Colors.white,
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Summary', style: TextStyle(fontSize: TSizes.Lg, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Total Available Products: $totalAvailable', style: TextStyle(fontSize: TSizes.fontMd)),
                Text('Total Sold Products: $totalSold', style: TextStyle(fontSize: TSizes.fontMd)),
                Text('Total Profit: \$${totalProfit.toStringAsFixed(2)}', style: TextStyle(fontSize: TSizes.fontMd)),
                SizedBox(height: 10),
                Text('Note: The summary data is based on the latest data from the server.', style: TextStyle(fontSize: TSizes.fontSm, color: Colors.black54)),
              ],
            ),
          ),
        ),
    );
  }

  String _limitWords(String text, int maxWords) {
    List<String> words = text.split(' ');
    if (words.length > maxWords) {
      return words.take(maxWords).join(' ') + '...';
    }
    return text;
  }
}
