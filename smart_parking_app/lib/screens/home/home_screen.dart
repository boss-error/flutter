import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/parking_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/ai_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/parking_spot_card.dart';
import '../../widgets/ai_insights_card.dart';
import '../../widgets/quick_actions_card.dart';
import '../../widgets/reservation_summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final parkingProvider = Provider.of<ParkingProvider>(context, listen: false);
    final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      await parkingProvider.initialize();
      await reservationProvider.loadUserReservations(authProvider.user!.uid);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildHomeTab(),
          _buildSearchTab(),
          _buildReservationsTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            // App Bar
            _buildSliverAppBar(),
            
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    _buildWelcomeSection(),
                    
                    const SizedBox(height: 20),
                    
                    // Quick Actions
                    const QuickActionsCard(),
                    
                    const SizedBox(height: 20),
                    
                    // Current Reservation
                    _buildCurrentReservation(),
                    
                    const SizedBox(height: 20),
                    
                    // AI Insights
                    const AIInsightsCard(),
                    
                    const SizedBox(height: 20),
                    
                    // Nearby Parking Spots
                    _buildNearbyParkingSpots(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Header
            _buildSearchHeader(),
            
            const SizedBox(height: 16),
            
            // Filters
            _buildFilters(),
            
            const SizedBox(height: 16),
            
            // Search Results
            Expanded(
              child: _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'My Reservations',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Reservation Summary
            const ReservationSummaryCard(),
            
            const SizedBox(height: 16),
            
            // Reservations List
            Expanded(
              child: _buildReservationsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),
            
            const SizedBox(height: 24),
            
            // Profile Options
            Expanded(
              child: _buildProfileOptions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      title: const Text(
        'Smart Parking',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // TODO: Navigate to notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {
            // TODO: Navigate to settings
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authProvider.displayName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find your perfect parking spot',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.local_parking,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentReservation() {
    return Consumer<ReservationProvider>(
      builder: (context, reservationProvider, child) {
        final activeReservation = reservationProvider.currentActiveReservation;
        final upcomingReservation = reservationProvider.nextUpcomingReservation;
        
        if (activeReservation == null && upcomingReservation == null) {
          return const SizedBox.shrink();
        }
        
        final reservation = activeReservation ?? upcomingReservation!;
        final isActive = activeReservation != null;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isActive ? Icons.local_parking : Icons.schedule,
                      color: isActive ? AppTheme.successColor : AppTheme.warningColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isActive ? 'Active Reservation' : 'Upcoming Reservation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Parking Spot: ${reservation.parkingSpotId}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Time: ${_formatDateTime(reservation.startTime)} - ${_formatDateTime(reservation.endTime)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${reservation.totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to reservation details
                      },
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNearbyParkingSpots() {
    return Consumer<ParkingProvider>(
      builder: (context, parkingProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Parking',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 1;
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    });
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: parkingProvider.nearbySpots.isEmpty
                  ? const Center(
                      child: Text('No nearby parking spots found'),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: parkingProvider.nearbySpots.take(5).length,
                      itemBuilder: (context, index) {
                        final spot = parkingProvider.nearbySpots[index];
                        return Container(
                          width: 280,
                          margin: const EdgeInsets.only(right: 12),
                          child: ParkingSpotCard(
                            spot: spot,
                            onTap: () {
                              parkingProvider.selectSpot(spot);
                              // TODO: Navigate to spot details
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find Parking',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search by location, address, or zone',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () {
                // TODO: Use current location
              },
            ),
          ),
          onChanged: (value) {
            // TODO: Implement search
          },
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Consumer<ParkingProvider>(
      builder: (context, parkingProvider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('Available'),
                selected: true,
                onSelected: (selected) {
                  // TODO: Filter by availability
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Indoor'),
                selected: parkingProvider.selectedType == ParkingSpotType.indoor,
                onSelected: (selected) {
                  parkingProvider.setFilterType(
                    selected ? ParkingSpotType.indoor : null,
                  );
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Covered'),
                selected: parkingProvider.selectedType == ParkingSpotType.covered,
                onSelected: (selected) {
                  parkingProvider.setFilterType(
                    selected ? ParkingSpotType.covered : null,
                  );
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Price < \$10'),
                selected: parkingProvider.maxPrice == 10.0,
                onSelected: (selected) {
                  parkingProvider.setMaxPrice(selected ? 10.0 : null);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return Consumer<ParkingProvider>(
      builder: (context, parkingProvider, child) {
        if (parkingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final spots = parkingProvider.availableSpots;
        
        if (spots.isEmpty) {
          return const Center(
            child: Text('No parking spots found'),
          );
        }
        
        return ListView.builder(
          itemCount: spots.length,
          itemBuilder: (context, index) {
            final spot = spots[index];
            return ParkingSpotCard(
              spot: spot,
              onTap: () {
                parkingProvider.selectSpot(spot);
                // TODO: Navigate to spot details
              },
            );
          },
        );
      },
    );
  }

  Widget _buildReservationsList() {
    return Consumer<ReservationProvider>(
      builder: (context, reservationProvider, child) {
        if (reservationProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final reservations = reservationProvider.reservations;
        
        if (reservations.isEmpty) {
          return const Center(
            child: Text('No reservations found'),
          );
        }
        
        return ListView.builder(
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            final reservation = reservations[index];
            return Card(
              child: ListTile(
                leading: Icon(
                  _getReservationIcon(reservation.status),
                  color: _getReservationColor(reservation.status),
                ),
                title: Text('Spot: ${reservation.parkingSpotId}'),
                subtitle: Text(
                  '${_formatDateTime(reservation.startTime)} - ${_formatDateTime(reservation.endTime)}',
                ),
                trailing: Text(
                  '\$${reservation.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  reservationProvider.selectReservation(reservation);
                  // TODO: Navigate to reservation details
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor,
                  backgroundImage: authProvider.profileImageUrl != null
                      ? NetworkImage(authProvider.profileImageUrl!)
                      : null,
                  child: authProvider.profileImageUrl == null
                      ? Text(
                          authProvider.displayName.isNotEmpty
                              ? authProvider.displayName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.userEmail,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // TODO: Navigate to edit profile
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileOptions() {
    return ListView(
      children: [
        _buildProfileOption(
          icon: Icons.history,
          title: 'Parking History',
          onTap: () {
            // TODO: Navigate to parking history
          },
        ),
        _buildProfileOption(
          icon: Icons.payment,
          title: 'Payment Methods',
          onTap: () {
            // TODO: Navigate to payment methods
          },
        ),
        _buildProfileOption(
          icon: Icons.notifications,
          title: 'Notifications',
          onTap: () {
            // TODO: Navigate to notifications settings
          },
        ),
        _buildProfileOption(
          icon: Icons.help,
          title: 'Help & Support',
          onTap: () {
            // TODO: Navigate to help
          },
        ),
        _buildProfileOption(
          icon: Icons.info,
          title: 'About',
          onTap: () {
            // TODO: Navigate to about
          },
        ),
        const Divider(),
        _buildProfileOption(
          icon: Icons.logout,
          title: 'Sign Out',
          onTap: () async {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            await authProvider.signOut();
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.errorColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.errorColor : null,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Reservations',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  Future<void> _refreshData() async {
    await _initializeData();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  IconData _getReservationIcon(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed:
        return Icons.check_circle;
      case ReservationStatus.active:
        return Icons.local_parking;
      case ReservationStatus.completed:
        return Icons.done;
      case ReservationStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.schedule;
    }
  }

  Color _getReservationColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed:
        return AppTheme.successColor;
      case ReservationStatus.active:
        return AppTheme.primaryColor;
      case ReservationStatus.completed:
        return AppTheme.successColor;
      case ReservationStatus.cancelled:
        return AppTheme.errorColor;
      default:
        return AppTheme.warningColor;
    }
  }
}
