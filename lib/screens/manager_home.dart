import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../models/database_service.dart';

import '../models/models.dart';

import '../theme/app_theme.dart';

import '../theme/custom_components.dart';

import 'staff_management_screen.dart';

class ManagerHome extends StatefulWidget {

  final User? currentUser;

  const ManagerHome({Key? key, this.currentUser}) : super(key: key);

  @override

  State<ManagerHome> createState() => _ManagerHomeState();

}

class _ManagerHomeState extends State<ManagerHome>

    with TickerProviderStateMixin {

  final db = DatabaseService();

  late Future<HotelAnalytics> _analyticsFuture;

  late Future<List<Booking>> _recentBookingsFuture;

  late Future<List<Room>> _roomsFuture;

  late User manager;

  int selectedIndex = 0;

  // For room management

  String _selectedRoomFilter = 'All';

  bool _isLoadingRoomStatus = false;

  @override

  void initState() {

    super.initState();

    manager = widget.currentUser ??

        User(

          id: 'manager1',

          firstName: 'Manager',

          lastName: 'User',

          email: 'manager@example.com',

          password: 'password123',

          role: UserRole.manager,

        );

    _loadData();

  }

  void _loadData() {

    _analyticsFuture = db.getAnalytics();

    _recentBookingsFuture = Future.delayed(

      const Duration(milliseconds: 100),

      () => db.getAllBookings(),

    );

    _roomsFuture = db.getAllRooms();

    setState(() {});

  }

  Future<DateTime?> _showStatusDateTimePicker(

      BuildContext context, String status) async {

    DateTime? selectedDate;

    TimeOfDay? selectedTime;

    selectedDate = await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime.now(),

      lastDate: DateTime.now().add(const Duration(days: 365)),

      helpText: 'Until when is the room $status?',

    );

    if (selectedDate == null) return null;

    selectedTime = await showTimePicker(

      context: context,

      initialTime: TimeOfDay.now(),

      helpText: 'Until what time?',

    );

    if (selectedTime == null) return null;

    final selectedDateTime = DateTime(

      selectedDate.year,

      selectedDate.month,

      selectedDate.day,

      selectedTime.hour,

      selectedTime.minute,

    );

    if (selectedDateTime.isBefore(DateTime.now())) {

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(

            content: Text('⚠️ Please select a future date and time'),

            backgroundColor: AppTheme.warningOrange,

          ),

        );

      }

      return null;

    }

    return selectedDateTime;

  }

  void _showRoomManagementModal() {

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      backgroundColor: AppTheme.surfaceCard,

      shape: const RoundedRectangleBorder(

        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),

      ),

      builder: (context) {

        return StatefulBuilder(

          builder: (context, setModalState) {

            return FractionallySizedBox(

              heightFactor: 0.9,

              child: Column(

                children: [

                  // Header

                  Padding(

                    padding: const EdgeInsets.all(AppSpacing.lg),

                    child: Row(

                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [

                        Text(

                          'Room Management',

                          style: Theme.of(context)

                              .textTheme

                              .headlineSmall

                              ?.copyWith(

                                color: AppTheme.textPrimary,

                                fontWeight: FontWeight.w700,

                              ),

                        ),

                        IconButton(

                          icon: const Icon(Icons.close),

                          onPressed: () => Navigator.pop(context),

                          color: AppTheme.textPrimary,

                        ),

                      ],

                    ),

                  ),

                  const Divider(color: AppTheme.accentCyan, height: 1),

                  // Filter chips

                  Padding(

                    padding: const EdgeInsets.all(AppSpacing.lg),

                    child: Wrap(

                      spacing: AppSpacing.sm,

                      runSpacing: AppSpacing.sm,

                      children: [

                        _StatusFilterChip(

                          label: 'All',

                          isActive: _selectedRoomFilter == 'All',

                          onTap: () => setModalState(

                              () => _selectedRoomFilter = 'All'),

                        ),

                        _StatusFilterChip(

                          label: 'Available',

                          isActive: _selectedRoomFilter == 'available',

                          onTap: () => setModalState(

                              () => _selectedRoomFilter = 'available'),

                        ),

                        _StatusFilterChip(

                          label: 'Occupied',

                          isActive: _selectedRoomFilter == 'occupied',

                          onTap: () => setModalState(

                              () => _selectedRoomFilter = 'occupied'),

                        ),

                        _StatusFilterChip(

                          label: 'Maintenance',

                          isActive: _selectedRoomFilter == 'maintenance',

                          onTap: () => setModalState(

                              () => _selectedRoomFilter = 'maintenance'),

                        ),

                      ],

                    ),

                  ),

                  // Room list

                  Expanded(

                    child: FutureBuilder<List<Room>>(

                      future: _roomsFuture,

                      builder: (context, snapshot) {

                        if (snapshot.connectionState ==

                            ConnectionState.waiting) {

                          return Center(child: CyberLoader());

                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {

                          return Center(

                            child: Text(

                              'No rooms available',

                              style: TextStyle(

                                  color: AppTheme.textSecondary),

                            ),

                          );

                        }

                        List<Room> filteredRooms = snapshot.data!;

                        if (_selectedRoomFilter != 'All') {

                          filteredRooms = filteredRooms.where((room) {

                            String roomStatusStr =

                                room.status.toString().split('.').last;

                            String normalizedFilter =

                                _selectedRoomFilter.toLowerCase();

                            return roomStatusStr.toLowerCase() ==

                                normalizedFilter;

                          }).toList();

                        }

                        if (filteredRooms.isEmpty) {

                          return Center(

                            child: Text(

                              'No ${_selectedRoomFilter.toLowerCase()} rooms',

                              style: TextStyle(

                                  color: AppTheme.textSecondary),

                            ),

                          );

                        }

                        return ListView.separated(

                          padding: const EdgeInsets.all(AppSpacing.lg),

                          itemCount: filteredRooms.length,

                          separatorBuilder: (_, __) =>

                              const SizedBox(height: AppSpacing.lg),

                          itemBuilder: (context, index) {

                            final room = filteredRooms[index];

                            return _RoomManagementCard(

                              room: room,

                              isLoading: _isLoadingRoomStatus,

                              onStatusChange: (newStatus) async {

                                setModalState(

                                    () => _isLoadingRoomStatus = true);

                                try {

                                  if (newStatus == 'occupied' ||

                                      newStatus == 'maintenance') {

                                    final dateTime =

                                        await _showStatusDateTimePicker(

                                      context,

                                      newStatus,

                                    );

                                    if (dateTime == null) {

                                      setModalState(() =>

                                          _isLoadingRoomStatus = false);

                                      return;

                                    }

                                    if (!mounted) return;

                                    final roomStatusEnum =

                                        RoomStatus.values.firstWhere(

                                      (status) =>

                                          status.toString().split('.').last ==

                                          newStatus,

                                      orElse: () => RoomStatus.available,

                                    );

                                    // ✅ PASS the maintenanceUntil parameter

                                    await db.updateRoomStatus(

                                      room.id,

                                      roomStatusEnum,

                                      maintenanceUntil: dateTime,

                                    );

                                  } else {

                                    final roomStatusEnum =

                                        RoomStatus.values.firstWhere(

                                      (status) =>

                                          status.toString().split('.').last ==

                                          newStatus,

                                      orElse: () => RoomStatus.available,

                                    );

                                    await db.updateRoomStatus(

                                        room.id, roomStatusEnum);

                                  }

                                  if (mounted) {

                                    _loadData(); // ✅ Refresh the data

                                    setModalState(() =>

                                        _isLoadingRoomStatus = false);

                                    ScaffoldMessenger.of(context)

                                        .showSnackBar(

                                      SnackBar(

                                        content: Text(

                                            '✓ ${room.name} marked as $newStatus'),

                                        backgroundColor:

                                            AppTheme.successGreen,

                                      ),

                                    );

                                  }

                                } catch (e) {

                                  if (mounted) {

                                    setModalState(() =>

                                        _isLoadingRoomStatus = false);

                                    ScaffoldMessenger.of(context)

                                        .showSnackBar(

                                      SnackBar(

                                        content: Text('Error: $e'),

                                        backgroundColor: AppTheme.errorRed,

                                      ),

                                    );

                                  }

                                }

                              },

                            );

                          },

                        );

                      },

                    ),

                  ),

                ],

              ),

            );

          },

        );

      },

    );

  }

  Widget _buildDashboardTab() {

    return RefreshIndicator(

      onRefresh: () async {

        _loadData();

        await Future.delayed(const Duration(milliseconds: 500));

      },

      child: SingleChildScrollView(

        child: Column(

          children: [

            GradientHeader(

              title: 'Manager Dashboard',

              subtitle: 'Hotel Performance Overview',

            ),

            Padding(

              padding: const EdgeInsets.all(AppSpacing.lg),

              child: Column(

                children: [

                  // Analytics Cards

                  FutureBuilder<HotelAnalytics>(

                    future: _analyticsFuture,

                    builder: (context, snapshot) {

                      if (snapshot.connectionState ==

                          ConnectionState.waiting) {

                        return Column(

                          children: [

                            for (int i = 0; i < 4; i++)

                              Shimmer(

                                child: Container(

                                  height: 100,

                                  decoration: BoxDecoration(

                                    color: AppTheme.surfaceCard

                                        .withOpacity(0.5),

                                    borderRadius: AppRadius.lgRadius,

                                  ),

                                  margin: const EdgeInsets.only(

                                      bottom: AppSpacing.lg),

                                ),

                              ),

                          ],

                        );

                      }

                      if (!snapshot.hasData) {

                        return const SizedBox();

                      }

                      final analytics = snapshot.data!;

                      return Column(

                        children: [

                          Row(

                            children: [

                              Expanded(

                                child: _StatCard(

                                  label: 'Total Bookings',

                                  value: '${analytics.totalBookings}',

                                  icon: Icons.calendar_today_outlined,

                                  color: AppTheme.accentCyan,

                                ),

                              ),

                              const SizedBox(width: AppSpacing.lg),

                              Expanded(

                                child: _StatCard(

                                  label: 'Revenue (EGP)',

                                  value: '${analytics.totalRevenue}',

                                  icon: Icons.money_outlined,

                                  color: AppTheme.successGreen,

                                ),

                              ),

                            ],

                          ),

                          const SizedBox(height: AppSpacing.lg),

                          Row(

                            children: [

                              Expanded(

                                child: _StatCard(

                                  label: 'Occupancy Rate',

                                  value: '${analytics.occupancyRate}%',

                                  icon: Icons.hotel_outlined,

                                  color: AppTheme.accentGold,

                                ),

                              ),

                              const SizedBox(width: AppSpacing.lg),

                              Expanded(

                                child: _StatCard(

                                  label: 'Avg Rating',

                                  value: '${analytics.averageRating}/5',

                                  icon: Icons.star_outline,

                                  color: AppTheme.accentMagenta,

                                ),

                              ),

                            ],

                          ),

                        ],

                      );

                    },

                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Room Status Section

                  Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(

                        'Room Status Overview',

                        style: Theme.of(context)

                            .textTheme

                            .titleLarge

                            ?.copyWith(

                              color: AppTheme.textPrimary,

                            ),

                      ),

                      const SizedBox(height: AppSpacing.lg),

                      FutureBuilder<List<Room>>(

                        future: _roomsFuture,

                        builder: (context, snapshot) {

                          if (!snapshot.hasData) {

                            return CyberLoader();

                          }

                          final rooms = snapshot.data!;

                          final statusMap = <RoomStatus, int>{};

                          for (final room in rooms) {

                            statusMap[room.status] =

                                (statusMap[room.status] ?? 0) + 1;

                          }

                          return Column(

                            children: [

                              _RoomStatusChart(statusMap: statusMap),

                              const SizedBox(height: AppSpacing.lg),

                              Row(

                                mainAxisAlignment:

                                    MainAxisAlignment.spaceAround,

                                children: [

                                  _StatusLegend(

                                    status: 'Available',

                                    count: statusMap[RoomStatus.available] ??

                                        0,

                                    color: AppTheme.successGreen,

                                  ),

                                  _StatusLegend(

                                    status: 'Occupied',

                                    count: statusMap[RoomStatus.occupied] ?? 0,

                                    color: AppTheme.accentCyan,

                                  ),

                                  _StatusLegend(

                                    status: 'Booked',

                                    count: statusMap[RoomStatus.booked] ?? 0,

                                    color: AppTheme.errorRed,

                                  ),

                                  _StatusLegend(

                                    status: 'Maintenance',

                                    count:

                                        statusMap[RoomStatus.maintenance] ?? 0,

                                    color: AppTheme.warningOrange,

                                  ),

                                  _StatusLegend(

                                    status: 'Cleaning',

                                    count: statusMap[RoomStatus.cleaning] ?? 0,

                                    color: AppTheme.infoBlue,

                                  ),

                                ],

                              ),

                            ],

                          );

                        },

                      ),

                    ],

                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Recent Bookings Section

                  Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Row(

                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [

                          Text(

                            'Recent Bookings',

                            style: Theme.of(context)

                                .textTheme

                                .titleLarge

                                ?.copyWith(

                                  color: AppTheme.textPrimary,

                                ),

                          ),

                          Text(

                            'View All',

                            style: TextStyle(

                              color: AppTheme.accentCyan,

                              fontSize: 12,

                              fontWeight: FontWeight.w700,

                            ),

                          ),

                        ],

                      ),

                      const SizedBox(height: AppSpacing.lg),

                      FutureBuilder<List<Booking>>(

                        future: _recentBookingsFuture,

                        builder: (context, snapshot) {

                          if (!snapshot.hasData) {

                            return CyberLoader();

                          }

                          final bookings = snapshot.data!

                              .where((b) =>

                                  b.status == BookingStatus.confirmed)

                              .toList()

                              ..sort((a, b) =>

                                  b.createdAt.compareTo(a.createdAt));

                          final recentBookings = bookings.take(5).toList();

                          if (recentBookings.isEmpty) {

                            return Center(

                              child: Text(

                                'No recent bookings',

                                style: TextStyle(

                                  color: AppTheme.textSecondary,

                                ),

                              ),

                            );

                          }

                          return Column(

                            children: List.generate(

                              recentBookings.length,

                              (index) {

                                final booking = recentBookings[index];

                                return FutureBuilder<Room?>(

                                  future: db.getRoom(booking.roomId),

                                  builder: (context, roomSnapshot) {

                                    final room = roomSnapshot.data;

                                    return Padding(

                                      padding: EdgeInsets.only(

                                        bottom: index <

                                                recentBookings.length - 1

                                            ? AppSpacing.md

                                            : 0,

                                      ),

                                      child: _RecentBookingTile(

                                        booking: booking,

                                        room: room,

                                      ),

                                    );

                                  },

                                );

                              },

                            ),

                          );

                        },

                      ),

                    ],

                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Quick Actions

                  Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(

                        'Quick Actions',

                        style: Theme.of(context)

                            .textTheme

                            .titleLarge

                            ?.copyWith(

                              color: AppTheme.textPrimary,

                            ),

                      ),

                      const SizedBox(height: AppSpacing.lg),

                      Row(

                        children: [

                          Expanded(

                            child: _ActionButton(

                              icon: Icons.people_outline,

                              label: 'Manage Staff',

                              onTap: () {

                                Navigator.push(

                                  context,

                                  MaterialPageRoute(

                                    builder: (context) =>

                                        const StaffManagementScreen(),

                                  ),

                                );

                              },

                            ),

                          ),

                          const SizedBox(width: AppSpacing.lg),

                          Expanded(

                            child: _ActionButton(

                              icon: Icons.hotel_outlined,

                              label: 'Room Status',

                              onTap: _showRoomManagementModal,

                            ),

                          ),

                        ],

                      ),

                      const SizedBox(height: AppSpacing.lg),

                      Row(

                        children: [

                          Expanded(

                            child: _ActionButton(

                              icon: Icons.analytics_outlined,

                              label: 'Reports',

                              onTap: () {},

                            ),

                          ),

                          const SizedBox(width: AppSpacing.lg),

                          Expanded(

                            child: _ActionButton(

                              icon: Icons.settings_outlined,

                              label: 'Settings',

                              onTap: () {},

                            ),

                          ),

                        ],

                      ),

                    ],

                  ),

                ],

              ),

            ),

          ],

        ),

      ),

    );

  }

  Widget _buildAccountTab() {

    return SingleChildScrollView(

      child: Column(

        children: [

          GradientHeader(

            title: 'My Account',

            subtitle: 'Manage your profile',

          ),

          Padding(

            padding: const EdgeInsets.all(AppSpacing.lg),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // Profile Card

                Container(

                  padding: const EdgeInsets.all(AppSpacing.lg),

                  decoration: BoxDecoration(

                    color: AppTheme.surfaceCard.withOpacity(0.5),

                    borderRadius: AppRadius.lgRadius,

                    border: Border.all(

                      color: AppTheme.accentCyan.withOpacity(0.2),

                      width: 1.5,

                    ),

                  ),

                  child: Column(

                    children: [

                      Container(

                        width: 80,

                        height: 80,

                        decoration: BoxDecoration(

                          shape: BoxShape.circle,

                          gradient: AppTheme.cyberGradient,

                        ),

                        child: Center(

                          child: Text(

                            manager.firstName.isNotEmpty

                                ? manager.firstName[0].toUpperCase()

                                : '?',

                            style: const TextStyle(

                              color: AppTheme.textPrimary,

                              fontSize: 32,

                              fontWeight: FontWeight.w700,

                            ),

                          ),

                        ),

                      ),

                      const SizedBox(height: AppSpacing.lg),

                      Text(

                        '${manager.firstName} ${manager.lastName}',

                        style: const TextStyle(

                          color: AppTheme.textPrimary,

                          fontSize: 18,

                          fontWeight: FontWeight.w700,

                        ),

                      ),

                      const SizedBox(height: AppSpacing.sm),

                      Text(

                        manager.email,

                        style: const TextStyle(

                          color: AppTheme.textSecondary,

                          fontSize: 13,

                        ),

                      ),

                      const SizedBox(height: AppSpacing.md),

                      StatusBadge(

                        label: 'Manager',

                        status: 'manager',

                      ),

                    ],

                  ),

                ),

                const SizedBox(height: AppSpacing.xl),

                // Account Settings

                Text(

                  'Account Settings',

                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(

                        color: AppTheme.textPrimary,

                        fontWeight: FontWeight.w700,

                      ),

                ),

                const SizedBox(height: AppSpacing.lg),

                _SettingItem(

                  icon: Icons.email_outlined,

                  label: 'Email',

                  value: manager.email,

                ),

                const SizedBox(height: AppSpacing.lg),

                _SettingItem(

                  icon: Icons.security_outlined,

                  label: 'Account Type',

                  value: 'Hotel Manager',

                ),

                const SizedBox(height: AppSpacing.xl),

                // Preferences

                Text(

                  'Preferences',

                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(

                        color: AppTheme.textPrimary,

                        fontWeight: FontWeight.w700,

                      ),

                ),

                const SizedBox(height: AppSpacing.lg),

                _PreferenceToggle(

                  icon: Icons.notifications_outlined,

                  label: 'Push Notifications',

                  value: true,

                  onChanged: (value) {},

                ),

                const SizedBox(height: AppSpacing.lg),

                _PreferenceToggle(

                  icon: Icons.mail_outline,

                  label: 'Email Notifications',

                  value: true,

                  onChanged: (value) {},

                ),

                const SizedBox(height: AppSpacing.xl),

                // Sign Out

                SizedBox(

                  width: double.infinity,

                  child: ElevatedButton(

                    onPressed: () {

                      Navigator.of(context)

                          .pushNamedAndRemoveUntil('/', (route) => false);

                    },

                    style: ElevatedButton.styleFrom(

                      backgroundColor:

                          AppTheme.errorRed.withOpacity(0.2),

                      padding: const EdgeInsets.symmetric(

                          vertical: AppSpacing.md),

                      shape: RoundedRectangleBorder(

                        borderRadius: AppRadius.mdRadius,

                        side: BorderSide(

                          color: AppTheme.errorRed.withOpacity(0.5),

                          width: 1.5,

                        ),

                      ),

                    ),

                    child: Text(

                      'Sign Out',

                      style: TextStyle(

                        color: AppTheme.errorRed,

                        fontWeight: FontWeight.w700,

                        fontSize: 14,

                      ),

                    ),

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      body: IndexedStack(

        index: selectedIndex,

        children: [

          _buildDashboardTab(),

          _buildAccountTab(),

        ],

      ),

      bottomNavigationBar: Container(

        decoration: BoxDecoration(

          border: Border(

            top: BorderSide(

              color: AppTheme.accentCyan.withOpacity(0.2),

              width: 1,

            ),

          ),

        ),

        child: BottomNavigationBar(

          currentIndex: selectedIndex,

          onTap: (index) => setState(() => selectedIndex = index),

          type: BottomNavigationBarType.fixed,

          backgroundColor: AppTheme.surfaceCard,

          selectedItemColor: AppTheme.accentCyan,

          unselectedItemColor: AppTheme.textSecondary,

          items: const [

            BottomNavigationBarItem(

              icon: Icon(Icons.dashboard_outlined),

              label: 'Dashboard',

            ),

            BottomNavigationBarItem(

              icon: Icon(Icons.person_outlined),

              label: 'Account',

            ),

          ],

        ),

      ),

    );

  }

}

// Helper Widgets

class _StatCard extends StatelessWidget {

  final String label;

  final String value;

  final IconData icon;

  final Color color;

  const _StatCard({

    required this.label,

    required this.value,

    required this.icon,

    required this.color,

  });

  @override

  Widget build(BuildContext context) {

    return PremiumCard(

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Container(

            padding: const EdgeInsets.all(AppSpacing.md),

            decoration: BoxDecoration(

              color: color.withOpacity(0.15),

              borderRadius: AppRadius.mdRadius,

              border: Border.all(

                color: color.withOpacity(0.3),

                width: 1.5,

              ),

            ),

            child: Icon(icon, color: color, size: 24),

          ),

          const SizedBox(height: AppSpacing.lg),

          Text(

            value,

            style: Theme.of(context).textTheme.headlineSmall?.copyWith(

                  color: AppTheme.textPrimary,

                ),

          ),

          const SizedBox(height: AppSpacing.sm),

          Text(

            label,

            style: TextStyle(

              color: AppTheme.textSecondary,

              fontSize: 13,

            ),

          ),

        ],

      ),

    );

  }

}

class _RoomStatusChart extends StatelessWidget {

  final Map<RoomStatus, int> statusMap;

  const _RoomStatusChart({required this.statusMap});

  @override

  Widget build(BuildContext context) {

    final total = statusMap.values.fold<int>(0, (a, b) => a + b);

    return PremiumCard(

      child: Column(

        children: statusMap.entries.map((entry) {

          final percentage = total > 0

              ? (entry.value / total * 100).toStringAsFixed(1)

              : '0';

          final status = entry.key.toString().split('.').last;

          Color color = AppTheme.successGreen;

          switch (entry.key) {

            case RoomStatus.available:

              color = AppTheme.successGreen;

              break;

            case RoomStatus.occupied:

              color = AppTheme.accentCyan;

              break;

            case RoomStatus.booked:

              color = AppTheme.errorRed;

              break;

            case RoomStatus.maintenance:

              color = AppTheme.warningOrange;

              break;

            case RoomStatus.cleaning:

              color = AppTheme.infoBlue;

              break;

          }

          return Padding(

            padding: const EdgeInsets.only(bottom: AppSpacing.md),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Row(

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [

                    Text(

                      status,

                      style: TextStyle(

                        color: AppTheme.textSecondary,

                        fontSize: 13,

                        fontWeight: FontWeight.w600,

                      ),

                    ),

                    Text(

                      '${entry.value} (${percentage}%)',

                      style: TextStyle(

                        color: color,

                        fontSize: 13,

                        fontWeight: FontWeight.w700,

                      ),

                    ),

                  ],

                ),

                const SizedBox(height: AppSpacing.sm),

                ClipRRect(

                  borderRadius: AppRadius.smRadius,

                  child: LinearProgressIndicator(

                    value: entry.value / total,

                    minHeight: 8,

                    backgroundColor: color.withOpacity(0.15),

                    valueColor: AlwaysStoppedAnimation(color),

                  ),

                ),

              ],

            ),

          );

        }).toList(),

      ),

    );

  }

}

class _StatusLegend extends StatelessWidget {

  final String status;

  final int count;

  final Color color;

  const _StatusLegend({

    required this.status,

    required this.count,

    required this.color,

  });

  @override

  Widget build(BuildContext context) {

    return Column(

      children: [

        Container(

          width: 16,

          height: 16,

          decoration: BoxDecoration(

            color: color,

            borderRadius: BorderRadius.circular(4),

          ),

        ),

        const SizedBox(height: AppSpacing.sm),

        Text(

          '$count',

          style: const TextStyle(

            color: AppTheme.textPrimary,

            fontSize: 14,

            fontWeight: FontWeight.w700,

          ),

        ),

        const SizedBox(height: AppSpacing.xs),

        Text(

          status,

          style: const TextStyle(

            color: AppTheme.textSecondary,

            fontSize: 11,

          ),

          textAlign: TextAlign.center,

        ),

      ],

    );

  }

}

class _RecentBookingTile extends StatelessWidget {

  final Booking booking;

  final Room? room;

  const _RecentBookingTile({

    required this.booking,

    required this.room,

  });

  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(AppSpacing.md),

      decoration: BoxDecoration(

        color: AppTheme.surfaceCard.withOpacity(0.5),

        borderRadius: AppRadius.mdRadius,

        border: Border.all(

          color: AppTheme.accentCyan.withOpacity(0.1),

          width: 1,

        ),

      ),

      child: Row(

        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  room?.name ?? 'Unknown Room',

                  style: const TextStyle(

                    color: AppTheme.textPrimary,

                    fontSize: 13,

                    fontWeight: FontWeight.w700,

                  ),

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                ),

                const SizedBox(height: AppSpacing.xs),

                Text(

                  '${booking.checkIn.day}/${booking.checkIn.month} - ${booking.checkOut.day}/${booking.checkOut.month}',

                  style: TextStyle(

                    color: AppTheme.textSecondary,

                    fontSize: 12,

                  ),

                ),

              ],

            ),

          ),

          Text(

            'EGP ${booking.totalPrice.toStringAsFixed(0)}',

            style: const TextStyle(

              color: AppTheme.accentCyan,

              fontSize: 13,

              fontWeight: FontWeight.w700,

            ),

          ),

        ],

      ),

    );

  }

}

class _ActionButton extends StatelessWidget {

  final IconData icon;

  final String label;

  final VoidCallback onTap;

  const _ActionButton({

    required this.icon,

    required this.label,

    required this.onTap,

  });

  @override

  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        padding: const EdgeInsets.all(AppSpacing.lg),

        decoration: BoxDecoration(

          gradient: AppTheme.cyberGradient,

          borderRadius: AppRadius.lgRadius,

          border: Border.all(

            color: AppTheme.accentCyan.withOpacity(0.2),

            width: 1.5,

          ),

        ),

        child: Column(

          children: [

            Icon(icon, color: AppTheme.accentCyan, size: 28),

            const SizedBox(height: AppSpacing.md),

            Text(

              label,

              style: const TextStyle(

                color: AppTheme.textPrimary,

                fontSize: 13,

                fontWeight: FontWeight.w700,

              ),

              textAlign: TextAlign.center,

            ),

          ],

        ),

      ),

    );

  }

}

class _StatusFilterChip extends StatelessWidget {

  final String label;

  final bool isActive;

  final VoidCallback onTap;

  const _StatusFilterChip({

    required this.label,

    required this.isActive,

    required this.onTap,

  });

  @override

  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        padding: const EdgeInsets.symmetric(

          horizontal: AppSpacing.lg,

          vertical: AppSpacing.md,

        ),

        decoration: BoxDecoration(

          color: isActive

              ? AppTheme.accentCyan.withOpacity(0.2)

              : AppTheme.surfaceCard.withOpacity(0.3),

          borderRadius: BorderRadius.circular(AppRadius.full),

          border: Border.all(

            color: isActive

                ? AppTheme.accentCyan

                : AppTheme.accentCyan.withOpacity(0.2),

            width: 1.5,

          ),

        ),

        child: Text(

          label,

          style: TextStyle(

            color: isActive ? AppTheme.accentCyan : AppTheme.textSecondary,

            fontSize: 12,

            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,

          ),

        ),

      ),

    );

  }

}

class _RoomManagementCard extends StatelessWidget {

  final Room room;

  final bool isLoading;

  final Function(String) onStatusChange;

  const _RoomManagementCard({

    required this.room,

    required this.isLoading,

    required this.onStatusChange,

  });

  @override

  Widget build(BuildContext context) {

    final currentStatus = room.status.toString().split('.').last;

    return Container(

      padding: const EdgeInsets.all(AppSpacing.lg),

      decoration: BoxDecoration(

        color: AppTheme.surfaceCard.withOpacity(0.5),

        borderRadius: AppRadius.mdRadius,

        border: Border.all(

          color: AppTheme.accentCyan.withOpacity(0.2),

          width: 1.5,

        ),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              Text(

                room.name,

                style: const TextStyle(

                  color: AppTheme.textPrimary,

                  fontSize: 16,

                  fontWeight: FontWeight.w700,

                ),

              ),

              StatusBadge(

                label: currentStatus,

                status: currentStatus,

              ),

            ],

          ),

          const SizedBox(height: AppSpacing.md),

          Text(

            '${room.capacity} guests • EGP ${room.price.toStringAsFixed(0)}/night',

            style: TextStyle(

              color: AppTheme.textSecondary,

              fontSize: 12,

            ),

          ),

          const SizedBox(height: AppSpacing.lg),

          Row(

            children: [

              Expanded(

                child: _StatusButton(

                  label: 'Available',

                  isActive: currentStatus == 'available',

                  color: AppTheme.successGreen,

                  isLoading: isLoading,

                  onTap: () {

                    if (currentStatus != 'available') {

                      onStatusChange('available');

                    }

                  },

                ),

              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(

                child: _StatusButton(

                  label: 'Occupied',

                  isActive: currentStatus == 'occupied',

                  color: AppTheme.accentCyan,

                  isLoading: isLoading,

                  onTap: () {

                    if (currentStatus != 'occupied') {

                      onStatusChange('occupied');

                    }

                  },

                ),

              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(

                child: _StatusButton(

                  label: 'Maintenance',

                  isActive: currentStatus == 'maintenance',

                  color: AppTheme.warningOrange,

                  isLoading: isLoading,

                  onTap: () {

                    if (currentStatus != 'maintenance') {

                      onStatusChange('maintenance');

                    }

                  },

                ),

              ),

            ],

          ),

        ],

      ),

    );

  }

}

class _StatusButton extends StatefulWidget {

  final String label;

  final bool isActive;

  final Color color;

  final bool isLoading;

  final VoidCallback onTap;

  const _StatusButton({

    required this.label,

    required this.isActive,

    required this.color,

    required this.isLoading,

    required this.onTap,

  });

  @override

  State<_StatusButton> createState() => _StatusButtonState();

}

class _StatusButtonState extends State<_StatusButton> {

  bool _isHovered = false;

  @override

  Widget build(BuildContext context) {

    return MouseRegion(

      onEnter: (_) => setState(() => _isHovered = true),

      onExit: (_) => setState(() => _isHovered = false),

      child: GestureDetector(

        onTap: widget.isLoading ? null : widget.onTap,

        child: AnimatedContainer(

          duration: const Duration(milliseconds: 200),

          padding: const EdgeInsets.symmetric(

            horizontal: AppSpacing.sm,

            vertical: AppSpacing.md,

          ),

          decoration: BoxDecoration(

            color: widget.isLoading

                ? widget.color.withOpacity(0.1)

                : (_isHovered

                    ? widget.color.withOpacity(0.3)

                    : (widget.isActive

                        ? widget.color.withOpacity(0.2)

                        : AppTheme.surfaceCard.withOpacity(0.3))),

            borderRadius: AppRadius.smRadius,

            border: Border.all(

              color: widget.isLoading

                  ? widget.color.withOpacity(0.4)

                  : (_isHovered

                      ? widget.color.withOpacity(0.8)

                      : (widget.isActive

                          ? widget.color.withOpacity(0.6)

                          : widget.color.withOpacity(0.2))),

              width: 1.5,

            ),

          ),

          child: Center(

            child: widget.isLoading

                ? SizedBox(

                    width: 12,

                    height: 12,

                    child: CircularProgressIndicator(

                      strokeWidth: 1.5,

                      valueColor:

                          AlwaysStoppedAnimation(widget.color),

                    ),

                  )

                : Text(

                    widget.label,

                    textAlign: TextAlign.center,

                    style: TextStyle(

                      color: widget.isLoading

                          ? widget.color.withOpacity(0.6)

                          : (_isHovered

                              ? widget.color

                              : (widget.isActive

                                  ? widget.color

                                  : AppTheme.textSecondary)),

                      fontSize: 11,

                      fontWeight: widget.isLoading

                          ? FontWeight.w500

                          : (_isHovered

                              ? FontWeight.w700

                              : (widget.isActive

                                  ? FontWeight.w700

                                  : FontWeight.w500)),

                    ),

                  ),

          ),

        ),

      ),

    );

  }

}

class _SettingItem extends StatelessWidget {

  final IconData icon;

  final String label;

  final String value;

  const _SettingItem({

    required this.icon,

    required this.label,

    required this.value,

  });

  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.symmetric(

        horizontal: AppSpacing.lg,

        vertical: AppSpacing.md,

      ),

      decoration: BoxDecoration(

        color: AppTheme.surfaceCard.withOpacity(0.3),

        borderRadius: AppRadius.mdRadius,

        border: Border.all(

          color: AppTheme.accentCyan.withOpacity(0.1),

          width: 1,

        ),

      ),

      child: Row(

        children: [

          Icon(icon, color: AppTheme.accentCyan, size: 20),

          const SizedBox(width: AppSpacing.lg),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  label,

                  style: const TextStyle(

                    color: AppTheme.textSecondary,

                    fontSize: 12,

                    fontWeight: FontWeight.w500,

                  ),

                ),

                const SizedBox(height: AppSpacing.xs),

                Text(

                  value,

                  style: const TextStyle(

                    color: AppTheme.textPrimary,

                    fontSize: 13,

                    fontWeight: FontWeight.w600,

                  ),

                ),

              ],

            ),

          ),

          Icon(Icons.edit_outlined, color: AppTheme.textSecondary, size: 18),

        ],

      ),

    );

  }

}

class _PreferenceToggle extends StatefulWidget {

  final IconData icon;

  final String label;

  final bool value;

  final Function(bool) onChanged;

  const _PreferenceToggle({

    required this.icon,

    required this.label,

    required this.value,

    required this.onChanged,

  });

  @override

  State<_PreferenceToggle> createState() => _PreferenceToggleState();

}

class _PreferenceToggleState extends State<_PreferenceToggle> {

  late bool value;

  @override

  void initState() {

    super.initState();

    value = widget.value;

  }

  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.symmetric(

        horizontal: AppSpacing.lg,

        vertical: AppSpacing.md,

      ),

      decoration: BoxDecoration(

        color: AppTheme.surfaceCard.withOpacity(0.3),

        borderRadius: AppRadius.mdRadius,

        border: Border.all(

          color: AppTheme.accentCyan.withOpacity(0.1),

          width: 1,

        ),

      ),

      child: Row(

        children: [

          Icon(widget.icon, color: AppTheme.accentCyan, size: 20),

          const SizedBox(width: AppSpacing.lg),

          Expanded(

            child: Text(

              widget.label,

              style: const TextStyle(

                color: AppTheme.textPrimary,

                fontSize: 13,

                fontWeight: FontWeight.w600,

              ),

            ),

          ),

          Switch(

            value: value,

            onChanged: (v) {

              setState(() => value = v);

              widget.onChanged(v);

            },

            activeColor: AppTheme.accentCyan,

            inactiveThumbColor: AppTheme.textSecondary,

            inactiveTrackColor: AppTheme.surfaceCard,

          ),

        ],

      ),

    );

  }

}

// Shimmer Loading Widget

class Shimmer extends StatefulWidget {

  final Widget child;

  const Shimmer({required this.child});

  @override

  State<Shimmer> createState() => _ShimmerState();

}

class _ShimmerState extends State<Shimmer> with TickerProviderStateMixin {

  late AnimationController _controller;

  @override

  void initState() {

    super.initState();

    _controller = AnimationController(

      duration: const Duration(seconds: 2),

      vsync: this,

    )..repeat();

  }

  @override

  void dispose() {

    _controller.dispose();

    super.dispose();

  }

  @override

  Widget build(BuildContext context) {

    return FadeTransition(

      opacity: Tween(begin: 0.5, end: 1.0)

          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),

      child: widget.child,

    );

  }

}
