import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movease/booking_request.dart';
import 'package:movease/chats_renter.dart';
import 'package:movease/profile_page.dart';
import 'package:movease/renter_status_tracker.dart';

import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_vehicle.dart';
import 'booking_status_renter.dart';
import 'edit_vehicle_page.dart';

class RenterPage extends StatefulWidget {
  final String username;

  RenterPage({required this.username});

  @override
  _RenterPageState createState() => _RenterPageState();
}

class _RenterPageState extends State<RenterPage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoading = true;

  static const primaryYellow = Color(0xFFFFD700);
  static const backgroundBlack = Color(0xFF121212);
  static const cardGrey = Color(0xFF1E1E1E);
  static const textGrey = Color(0xFFB3B3B3);

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userId = currentUser.uid;
        final vehiclesSnapshot = await FirebaseFirestore.instance
            .collection('vehicles')
            .where('user_id', isEqualTo: userId)
            .get();

        final fetchedVehicles = vehiclesSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['vehicle_name'] ?? 'Unnamed Vehicle',
            'type': data['vehicle_type'] ?? 'Unknown Type',
            'price': data['price_per_hour'] ?? 0,
          };
        }).toList();

        setState(() {
          _vehicles = fetchedVehicles;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching vehicles: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getVehicleImagePath(String vehicleName) {
    // Keep 'x70' as is, only lowercase the 'Proton' part
    String processedName = vehicleName;
    if (vehicleName.toLowerCase().contains('x70')) {
      processedName = 'proton x70'; // Exact match for your file name
    } else if (vehicleName.toLowerCase().contains('saga')) {
      processedName = 'proton saga'; // Exact match for your file name
    } else if (vehicleName.toLowerCase().contains('swift')) {
      processedName = 'suzuki swift'; // Exact match for your file name
    } else if (vehicleName.toLowerCase().contains('civic')) {
      processedName = 'honda civic'; // Exact match for your file name
    } else if (vehicleName.toLowerCase().contains('city')) {
      processedName = 'honda city'; // Exact match for your file name
    } else {
      processedName = 'default_vehicle';
    }

    final path = 'assets/images/$processedName.png';
    print('Attempting to load image from path: $path'); // Debug print
    return path;
  }

  List<Widget> get _pages => [
        _buildVehicleList(),
        Container(
            color: Colors.black, // Match your background color
            child: BookingRequest()),
        BookingStatusRenter(),
        Center(child: Text('Feedback', style: TextStyle(fontSize: 20))),
        RenterNotificationsPage(),
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

  Widget _buildVehicleList() {
    if (_isLoading) {
      return Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(primaryYellow),
      ));
    }

    return Container(
      color: backgroundBlack,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryYellow,
                foregroundColor: backgroundBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                elevation: 5,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Add Vehicle',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddVehiclePage()),
                ).then((_) => _fetchVehicles());
              },
            ),
          ),
          Expanded(
            child: _vehicles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 80,
                          color: primaryYellow.withOpacity(0.5),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No vehicles found',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = _vehicles[index];

                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: cardGrey,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: Image.asset(
                                _getVehicleImagePath(vehicle['name']),
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[900],
                                    child: Icon(
                                      Icons.directions_car,
                                      size: 80,
                                      color: primaryYellow.withOpacity(0.5),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        vehicle['name'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '\$${vehicle['price']}/hour',
                                        style: TextStyle(
                                          color: primaryYellow,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    vehicle['type'],
                                    style: TextStyle(
                                      color: textGrey,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Colors.white),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditVehiclePage(
                                                      vehicle: vehicle),
                                            ),
                                          ).then((_) => _fetchVehicles());
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red[400]),
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('vehicles')
                                              .doc(vehicle['id'])
                                              .delete();
                                          _fetchVehicles();
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBlack,
      appBar: AppBar(
        title: Text(
          'Welcome, ${widget.username}',
          style: TextStyle(color: primaryYellow),
        ),
        centerTitle: true,
        backgroundColor: cardGrey,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: primaryYellow),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: primaryYellow),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: cardGrey,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: backgroundBlack,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: primaryYellow,
                      child:
                          Icon(Icons.person, size: 40, color: backgroundBlack),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Hello, ${widget.username}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.history, 'View Rental History'),
              _buildDrawerItem(Icons.directions_car, 'View All Vehicles'),
              _buildDrawerItem(
                Icons.logout,
                'Logout',
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardGrey,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: cardGrey,
          selectedItemColor: primaryYellow,
          unselectedItemColor: textGrey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_list),
              label: 'View Rentals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt),
              label: 'Rental Status',
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
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: primaryYellow),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      onTap: onTap ?? () {},
    );
  }
}
