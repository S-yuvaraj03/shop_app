import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Updated to match the number of tabs
  }

  // Function to launch the map
  _launchMap(String address) async {
    final url = 'https://www.google.com/maps/search/?q=$address';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch map';
    }
  }

  // Function to launch the shop URL
  _launchShopUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch URL';
    }
  }

  // Function to make a call
  _launchCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not make a call';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TabBar for selecting Location and Phone
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.location_on), text: 'Location'),
                Tab(icon: Icon(Icons.phone), text: 'Phone'),
                Tab(icon: Icon(Icons.location_searching), text: 'Nearby'),
                Tab(icon: Icon(Icons.share), text: 'Share'),
              ],
            ),
            const SizedBox(height: 16),
            // TabBarView for displaying content based on selected tab
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Location Tab
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _launchMap('354X+QCC, I V, Tamil Nadu 600093'),
                          icon: const Icon(Icons.directions),
                          label: const Text("Open Location in Google Maps"),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Location Details",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text("354X+QCC, I V, Tamil Nadu 600093"),
                      ],
                    ),
                  ),
                  // Phone Tab
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _launchCall('1234567890'),
                          icon: const Icon(Icons.call),
                          label: const Text("Call Shop"),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Phone Details",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text("Phone: 123-456-7890"),
                        const SizedBox(height: 8),
                        const Text("Email: example@shop.com"),
                      ],
                    ),
                  ),
                  // Nearby Tab
                  const Center(
                    child: Text("Nearby information will be displayed here."),
                  ),
                  // Share Tab
                  const Center(
                    child: Text("Sharing options will be available here."),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
