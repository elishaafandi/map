import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movease/booking_LIst.dart';
import 'package:movease/chats_rentee.dart';
import 'package:movease/profile_page.dart';
import 'login_screen.dart';
import 'rentee_booking.dart';
import 'renter_page.dart';
import 'booking_status.dart';

class RenteePage extends StatefulWidget {
  final String username;

  RenteePage({required this.username});

  @override
  _RenteePageState createState() => _RenteePageState();
}

class _RenteePageState extends State<RenteePage> {
  int _selectedIndex = 0;

  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredVehicles = [];

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    try {
      final vehiclesSnapshot =
          await FirebaseFirestore.instance.collection('vehicles').get();

      final fetchedVehicles = vehiclesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['vehicle_name'] ?? 'Unnamed Vehicle',
          'type': data['vehicle_type'] ?? 'Unknown Type',
          'price': data['price_per_hour'] ?? 0,
          'plate_number': data['plate_number'] ?? 'N/A',
        };
      }).toList();

      setState(() {
        _vehicles = fetchedVehicles;
        _filteredVehicles = fetchedVehicles;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching vehicles: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

//bahagian search
  void _filterVehicles(String query) {
    setState(() {
      _filteredVehicles = _vehicles
          .where((vehicle) =>
              vehicle['name'].toLowerCase().contains(query.toLowerCase()) ||
              vehicle['type'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

// Helper method to get appropriate icon based on vehicle type
  IconData _getVehicleIcon(String type) {
    switch (type) {
      case 'cars':
        return Icons.directions_car;
      case 'bicycles':
        return Icons.pedal_bike;
      case 'motorcycles':
        return Icons.motorcycle;
      case 'scooter':
        return Icons.electric_scooter;
      default:
        return Icons.directions_car;
    }
  }

  // Pages for bottom navigation
  List<Widget> get _pages => [
        Column(
          children: [
            // Banner Section
            Container(
              height: 150,
              margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.yellow.shade700,
                    Colors.black87,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/renter.png', // Replace with your asset
                      fit: BoxFit.cover,
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Let others rent",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RenterPage(username: widget.username)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            "Renter",
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Categories Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategory("Car", Icons.directions_car),
                  _buildCategory("Motor", Icons.motorcycle),
                  _buildCategory("Bike", Icons.pedal_bike),
                  TextButton(
                    onPressed: () {
                      // Handle "Show All"
                    },
                    child: Text(
                      "Show All",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Vehicle Cards Section
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _vehicles.isEmpty
                      ? Center(child: Text("No vehicles available."))
                      : GridView.builder(
                          padding: EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _filteredVehicles.length,
                          itemBuilder: (context, index) {
                            final vehicle = _filteredVehicles[index];

                            return _buildVehicleCard(
                              name: vehicle['name'],
                              type: vehicle['type'],
                              price: vehicle['price']?.toString() ?? 'N/A',
                              onRent: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RenteeBook(vehicleId: vehicle['id']),
                                  ),
                                );
                              },
                              onView: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                        vehicle['name'] ?? 'Unnamed Vehicle'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            "Price: \$${vehicle['price'] ?? 'N/A'}/hour"),
                                        Text(
                                            "Plate: ${vehicle['plate_number'] ?? 'N/A'}"),
                                        Text(
                                            "Type: ${vehicle['type'] ?? 'N/A'}"),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Close"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
        BookingList(),
        BookingStatus(),
        Center(child: Text('Feedback', style: TextStyle(fontSize: 20))),
        NotificationsPage(),
        ProfilePage()
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        _fetchVehicles();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[600]),
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search for vehicles",
                    border: InputBorder.none,
                  ),
                  onChanged: _filterVehicles,
                ),
              ),
            ],
          ),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.black),
            onPressed: () {
              // Profile functionality here
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.yellow.shade700,
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Navigate to Home
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment_rounded),
              title: Text('Booking List'),
              onTap: () {
                // Navigate to Home
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt),
              title: Text('Booking Status'),
              onTap: () {
                // Navigate to Booking Status
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Feedback'),
              onTap: () {
                // Navigate to Feedback
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: 'Booking List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Booking Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCategory(String label, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.yellow.shade700,
          child: Icon(icon, color: Colors.black87),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard({
    required String name,
    String? type, // Add type parameter to determine the icon
    String price = 'N/A',
    required VoidCallback onRent,
    required VoidCallback onView,
  }) {
    // A helper function to return the appropriate icon based on type
    IconData _getVehicleIcon(String? type) {
      switch (type?.toLowerCase()) {
        case 'car':
          return Icons.directions_car;
        case 'bicycle':
          return Icons.directions_bike;
        case 'motorcycle':
          return Icons.motorcycle;
        case 'scooter':
          return Icons.electric_scooter;
        default:
          return Icons.help_outline; // Default icon if type is unknown
      }
    }

    return Card(
      color:
          Colors.yellow.shade700, // Set the background color of the Card here
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.yellow.shade700,
              child: Icon(
                _getVehicleIcon(type), // Use the helper method to get the icon
                size: 60,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Price: \$$price/hour",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: onRent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        "Rent",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: onView,
                      child: Text(
                        "View",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
