import 'package:flutter/material.dart';
import 'package:shop_app/models/shop.dart';
import 'package:shop_app/screens/billingpage.dart';
import 'package:shop_app/screens/product_analytics.dart';
import 'package:shop_app/screens/product_maintenance_screen.dart';
import 'package:shop_app/screens/shopoverviewpage.dart';

class ShopDetailsScreen extends StatefulWidget {
  final Shop shop;

  const ShopDetailsScreen({required this.shop});

  @override
  _ShopDetailsScreenState createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final ValueNotifier<bool> _showHeader = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // Five tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: _showHeader,
                  builder: (context, showHeader, _) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: showHeader ? screenHeight * 0.4 : 0,
                      child: showHeader
                          ? Stack(
                              children: [
                                Container(
                                  height: screenHeight * 0.4,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: widget.shop.shopImageUrl != null &&
                                              widget.shop.shopImageUrl!.isNotEmpty
                                          ? NetworkImage(widget.shop.shopImageUrl!)
                                          : const AssetImage('assets/placeholder.png') as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: screenHeight * 0.25,
                                  left: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.search),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            decoration: InputDecoration(
                                              hintText: widget.shop.shopename.isNotEmpty
                                                  ? widget.shop.shopename
                                                  : 'Search',
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.mic, color: Colors.black87,),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : null,
                    );
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.blue,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        onTap: (index) {
                          _showHeader.value = index == 0;
                        },
                        tabs: const [
                          Tab(text: "Overview"),
                          Tab(text: "Products"),
                          Tab(text: "Analytics"),
                          Tab(text: "Sales"),
                          Tab(text: "Wallet"),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            const OverviewPage(),
                            ProductMaintenanceScreen(shopId: widget.shop.shopid),
                            product_analytics(shop: widget.shop),
                            BillingPage(allProducts: widget.shop.products),
                            const Center(child: Text("Wallet")),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: screenHeight * 0.4 - 30,
              right: 16,
              child: ValueListenableBuilder<bool>(
                valueListenable: _showHeader,
                builder: (context, showHeader, _) {
                  return GestureDetector(
                    onTap: () {
                      _showHeader.value = !showHeader;
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        showHeader ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
