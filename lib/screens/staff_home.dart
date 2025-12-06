import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../models/database_service.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/custom_components.dart';

// Staff Action Log Model
class StaffActionLog {
  final String id;
  final String staffId;
  final String staffName;
  final String action;
  final String roomId;
  final String roomName;
  final String details;
  final DateTime timestamp;

  StaffActionLog({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.action,
    required this.roomId,
    required this.roomName,
    required this.details,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'staffId': staffId,
        'staffName': staffName,
        'action': action,
        'roomId': roomId,
        'roomName': roomName,
        'details': details,
        'timestamp': timestamp.toIso8601String(),
      };

  static StaffActionLog fromJson(Map<String, dynamic> json) => StaffActionLog(
        id: json['id'],
        staffId: json['staffId'],
        staffName: json['staffName'],
        action: json['action'],
        roomId: json['roomId'],
        roomName: json['roomName'],
        details: json['details'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class StaffHome extends StatefulWidget {
  final User? currentUser;
  const StaffHome({Key? key, this.currentUser}) : super(key: key);

  @override
  State<StaffHome> createState() => _StaffHomeState();
}

class _StaffHomeState extends State<StaffHome> {
  final db = DatabaseService();
  late User _user;
  int _selectedIndex = 0;
  String _selectedFilter = 'All';
  late Timer _timeTimer;
  late Timer? _logoutTimer;
  DateTime _currentTime = DateTime.now();
  int _minutesUntilLogout = 0;
  bool _showLogoutWarning = false;
  bool _isLoadingCheckIn = false;
  bool _isLoadingRoomStatus = false;

  // Cache futures to prevent rebuilding
  late Future<List<Booking>> _bookingsFuture;
  late Future<List<Room>> _roomsFuture;

  // Shift end time (8 hours from now - you can customize this)
  late DateTime _shiftEndTime;

  @override
  void initState() {
    super.initState();
    _logoutTimer = null;
    _shiftEndTime = DateTime.now().add(Duration(hours: 8));

    // Initialize futures once
    _bookingsFuture = db.getAllBookings();
    _roomsFuture = db.getAllRooms();

    _user = widget.currentUser ??
        User(
          id: 'staff1',
          firstName: 'Staff',
          lastName: 'Member',
          email: 'staff@example.com',
          password: 'password123',
          role: UserRole.staff,
        );

    // Update current time every second
    _timeTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = getCurrentTime();
        _checkShiftEnd();
      });
    });
  }

  // Refresh data when needed
  void _refreshData() {
    setState(() {
      _bookingsFuture = db.getAllBookings();
      _roomsFuture = db.getAllRooms();
    });
  }

  // Check if shift has ended
  void _checkShiftEnd() {
    final timeUntilLogout = _shiftEndTime.difference(_currentTime).inMinutes;

    if (timeUntilLogout <= 0) {
      _logoutStaff();
    } else if (timeUntilLogout == 15) {
      setState(() {
        _showLogoutWarning = true;
        _minutesUntilLogout = 15;
      });

      if (_logoutTimer != null) {
        _logoutTimer!.cancel();
      }

      _logoutTimer = Timer.periodic(Duration(minutes: 1), (timer) {
        setState(() {
          _minutesUntilLogout--;
        });
        if (_minutesUntilLogout <= 0) {
          timer.cancel();
          _logoutStaff();
        }
      });
    }
  }

  void _logoutStaff() {
    _timeTimer.cancel();
    if (_logoutTimer != null) {
      _logoutTimer!.cancel();
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
    );
  }

  @override
  void dispose() {
    _timeTimer.cancel();
    if (_logoutTimer != null) {
      _logoutTimer!.cancel();
    }

    super.dispose();
  }

  Widget _buildTimeDisplay() {
    final timeFormat = DateFormat('HH:mm:ss');
    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.accentCyan.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeFormat.format(_currentTime),
                    style: const TextStyle(
                      color: AppTheme.accentCyan,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    dateFormat.format(_currentTime),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Shift Ends: ${DateFormat('HH:mm').format(_shiftEndTime)}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Cairo Time (UTC+2)',
                    style: TextStyle(
                      color: AppTheme.textSecondary.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutWarning() {
    if (!_showLogoutWarning) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.warningOrange.withOpacity(0.15),
        border: Border(
          top: BorderSide(
            color: AppTheme.warningOrange,
            width: 2,
          ),
          bottom: BorderSide(
            color: AppTheme.warningOrange.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_outlined,
            color: AppTheme.warningOrange,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shift Ending Soon',
                  style: TextStyle(
                    color: AppTheme.warningOrange,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'You will be logged out in $_minutesUntilLogout minute${_minutesUntilLogout != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: AppTheme.warningOrange.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    if (!_isLoadingCheckIn && !_isLoadingRoomStatus) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 120,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppTheme.accentCyan.withOpacity(0.2),
          borderRadius: AppRadius.mdRadius,
          border: Border.all(
            color: AppTheme.accentCyan,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(
                  AppTheme.accentCyan,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Loading...',
              style: TextStyle(
                color: AppTheme.accentCyan,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime getCurrentTime() {
    final now = DateTime.now();
    return now.add(const Duration(hours: 2));
  }

  Future<void> _logStaffAction({
    required String action,
    required String roomId,
    required String roomName,
    required String details,
  }) async {
    final log = StaffActionLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      staffId: _user.id,
      staffName: '${_user.firstName} ${_user.lastName}',
      action: action,
      roomId: roomId,
      roomName: roomName,
      details: details,
      timestamp: getCurrentTime(),
    );

    try {
      await db.saveStaffActionLog(log.toJson());
    } catch (e) {
      print('Error logging action: $e');
    }
  }

  Future<DateTime?> _showStatusDateTimePicker(
      BuildContext context, String status) async {
    final cairoNow = getCurrentTime();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    selectedDate = await showDatePicker(
      context: context,
      initialDate: cairoNow,
      firstDate: cairoNow,
      lastDate: cairoNow.add(Duration(days: 365)),
      helpText: 'Until when is the room $status?',
    );

    if (selectedDate == null) return null;

    selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(cairoNow),
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

    if (selectedDateTime.isBefore(cairoNow)) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildTimeDisplay(),
              _buildLogoutWarning(),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    _buildDashboardTab(),
                    _buildCheckInOutTab(),
                    _buildRoomManagementTab(),
                    _buildProfileTab(),
                  ],
                ),
              ),
            ],
          ),
          _buildLoadingIndicator(),
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
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.surfaceCard,
          selectedItemColor: AppTheme.accentCyan,
          unselectedItemColor: AppTheme.textSecondary,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Check In/Out'),
            BottomNavigationBarItem(
                icon: Icon(Icons.room_service), label: 'Rooms'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          GradientHeader(
            title: 'Dashboard',
            subtitle: 'Staff Management Center',
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.hotel,
                        label: 'Occupied',
                        value: '12',
                        color: AppTheme.accentCyan,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle,
                        label: 'Available',
                        value: '8',
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
                        icon: Icons.build,
                        label: 'Maintenance',
                        value: '2',
                        color: AppTheme.warningOrange,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.calendar_today,
                        label: 'Check-ins',
                        value: '3',
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  "Today's Check-Ins",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FutureBuilder<List<Booking>>(
                  future: _bookingsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CyberLoader());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No bookings today',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      );
                    }

                    final todayBookings = snapshot.data!
.where((b) =>
  b.status != BookingStatus.cancelled &&
  b.checkIn.year == _currentTime.year &&
  b.checkIn.month == _currentTime.month &&
  b.checkIn.day == _currentTime.day)

                        .toList();

                    if (todayBookings.isEmpty) {
                      return Center(
                        child: Text(
                          'No check-ins scheduled',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todayBookings.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, index) {
                        final booking = todayBookings[index];
                        return _CheckInCard(
                          booking: booking,
                          onCheckIn: () async {
                            setState(() => _isLoadingCheckIn = true);
                            try {
                              await db.updateBookingStatus(
                                booking.id,
                                BookingStatus.checkedIn,
                              );
                              await db.updateRoomStatus(
                                booking.roomId,
                                RoomStatus.occupied,
                              );
                              final room = await db.getRoom(booking.roomId);
                              await _logStaffAction(
                                action: 'check_in',
                                roomId: booking.roomId,
                                roomName: room?.name ?? 'Unknown Room',
                                details:
                                    'Guest checked in - Room moved to OCCUPIED',
                              );

                              if (mounted) {
                                _refreshData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        '✓ Guest checked in successfully! Room marked as OCCUPIED'),
                                    backgroundColor: AppTheme.successGreen,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: AppTheme.errorRed,
                                  ),
                                );
                              }
                            } finally {
                              setState(() => _isLoadingCheckIn = false);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInOutTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          GradientHeader(
            title: 'Check In/Out',
            subtitle: 'Manage guest arrivals & departures',
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<List<Booking>>(
                  future: _bookingsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CyberLoader());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No bookings',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      );
                    }

                    final pendingBookings = snapshot.data!
                        .where((b) =>
                            (b.status == BookingStatus.confirmed ||
                                b.status == BookingStatus.checkedIn) &&
                            ((b.checkIn.year == _currentTime.year &&
                                    b.checkIn.month == _currentTime.month &&
                                    b.checkIn.day == _currentTime.day) ||
                                (b.checkOut.isAfter(_currentTime) &&
                                    b.checkIn.isBefore(_currentTime))))
                        .toList();

                    if (pendingBookings.isEmpty) {
                      return Center(
                        child: Text(
                          'No pending bookings',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pendingBookings.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, index) {
                        final booking = pendingBookings[index];
                        return _CheckInOutCard(
                          booking: booking,
                          currentTime: _currentTime,
                          onCheckIn: () async {
                            if (_currentTime.isBefore(booking.checkIn)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '⏰ Check-in not allowed before ${DateFormat('MMM dd, HH:mm').format(booking.checkIn)}'),
                                  backgroundColor: AppTheme.warningOrange,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                              return;
                            }

                            setState(() => _isLoadingCheckIn = true);
                            try {
                              await db.updateBookingStatus(
                                booking.id,
                                BookingStatus.checkedIn,
                              );
                              await db.updateRoomStatus(
                                booking.roomId,
                                RoomStatus.occupied,
                              );
                              final room = await db.getRoom(booking.roomId);
                              await _logStaffAction(
                                action: 'check_in',
                                roomId: booking.roomId,
                                roomName: room?.name ?? 'Unknown Room',
                                details:
                                    'Guest checked in - Room moved to OCCUPIED',
                              );

                              if (mounted) {
                                _refreshData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        '✓ Guest checked in successfully - Room marked as OCCUPIED'),
                                    backgroundColor: AppTheme.successGreen,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: AppTheme.errorRed,
                                  ),
                                );
                              }
                            } finally {
                              setState(() => _isLoadingCheckIn = false);
                            }
                          },
                          onCheckOut: () async {
                            setState(() => _isLoadingCheckIn = true);
                            try {
                              await db.updateBookingStatus(
                                booking.id,
                                BookingStatus.checkedOut,
                              );
                              await db.updateRoomStatus(
                                booking.roomId,
                                RoomStatus.maintenance,
                              );
                              final room = await db.getRoom(booking.roomId);
                              await _logStaffAction(
                                action: 'check_out',
                                roomId: booking.roomId,
                                roomName: room?.name ?? 'Unknown Room',
                                details:
                                    'Guest checked out - Room moved to MAINTENANCE for cleaning',
                              );

                              if (mounted) {
                                _refreshData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        '✓ Guest checked out successfully - Room moved to MAINTENANCE'),
                                    backgroundColor: AppTheme.successGreen,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: AppTheme.errorRed,
                                  ),
                                );
                              }
                            } finally {
                              setState(() => _isLoadingCheckIn = false);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomManagementTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          GradientHeader(
            title: 'Room Management',
            subtitle: 'Update availability & status',
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Status',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _StatusFilterChip(
                      label: 'All',
                      isActive: _selectedFilter == 'All',
                      onTap: () => setState(() => _selectedFilter = 'All'),
                    ),
                    _StatusFilterChip(
                      label: 'Available',
                      isActive: _selectedFilter == 'available',
                      onTap: () =>
                          setState(() => _selectedFilter = 'available'),
                    ),
                    _StatusFilterChip(
                      label: 'Occupied',
                      isActive: _selectedFilter == 'occupied',
                      onTap: () =>
                          setState(() => _selectedFilter = 'occupied'),
                    ),
                    _StatusFilterChip(
                      label: 'Maintenance',
                      isActive: _selectedFilter == 'maintenance',
                      onTap: () =>
                          setState(() => _selectedFilter = 'maintenance'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                FutureBuilder<List<Room>>(
                  future: _roomsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CyberLoader());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No rooms available',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      );
                    }

                    List<Room> filteredRooms = snapshot.data!;

                    if (_selectedFilter != 'All') {
                      filteredRooms = filteredRooms.where((room) {
                        String roomStatusStr =
                            room.status.toString().split('.').last;
                        String normalizedFilter = _selectedFilter.toLowerCase();
                        return roomStatusStr.toLowerCase() == normalizedFilter;
                      }).toList();
                    }

                    if (filteredRooms.isEmpty) {
                      return Center(
                        child: Text(
                          'No ${_selectedFilter.toLowerCase()} rooms',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredRooms.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, index) {
                        final room = filteredRooms[index];
                        return _RoomManagementCard(
                          room: room,
                          onStatusChange: (newStatus) async {
                            setState(() => _isLoadingRoomStatus = true);
                            try {
                              if (newStatus == 'occupied' ||
                                  newStatus == 'maintenance') {
                                final dateTime =
                                    await _showStatusDateTimePicker(
                                  context,
                                  newStatus,
                                );

                                if (dateTime == null) {
                                  setState(
                                      () => _isLoadingRoomStatus = false);
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

                                // ✅ PASS the maintenanceUntil date
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
                                  room.id,
                                  roomStatusEnum,
                                );
                              }

                              await _logStaffAction(
                                action: 'room_status_change',
                                roomId: room.id,
                                roomName: room.name,
                                details:
                                    'Room status changed from ${room.status.toString().split('.').last.toUpperCase()} to ${newStatus.toUpperCase()}',
                              );

                              if (mounted) {
                                _refreshData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '✓ ${room.name} marked as $newStatus'),
                                    backgroundColor: AppTheme.successGreen,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Error updating room: $e'),
                                    backgroundColor: AppTheme.errorRed,
                                  ),
                                );
                              }
                            } finally {
                              setState(() => _isLoadingRoomStatus = false);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          GradientHeader(
            title: 'My Profile',
            subtitle: 'Staff account information',
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            _user.firstName.substring(0, 1).toUpperCase(),
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
                        '${_user.firstName} ${_user.lastName}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _user.email,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      StatusBadge(
                        label: 'staff',
                        status: 'staff',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Staff Information',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SettingItem(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: _user.email,
                ),
                const SizedBox(height: AppSpacing.lg),
                _SettingItem(
                  icon: Icons.badge_outlined,
                  label: 'Role',
                  value: 'Front Desk Staff',
                ),
                const SizedBox(height: AppSpacing.lg),
                _SettingItem(
                  icon: Icons.schedule,
                  label: 'Shift',
                  value: '08:00 AM - 04:00 PM',
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Permissions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _PermissionItem(
                  icon: Icons.login,
                  label: 'Check-in/Check-out',
                  isGranted: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                _PermissionItem(
                  icon: Icons.room_service,
                  label: 'Room Status Management',
                  isGranted: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                _PermissionItem(
                  icon: Icons.settings,
                  label: 'Settings Management',
                  isGranted: false,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
                      '/',
                      (route) => false,
                    ),
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
}

// Widget classes
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onCheckIn;

  const _CheckInCard({
    required this.booking,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.roomName ?? 'Unknown Room',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      booking.guestName ?? 'Guest',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: 'pending',
                status: 'pending',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Check-in: ${booking.checkIn.toLocal().toString().split(' ')[0]}',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          if (booking.specialRequests != null &&
              booking.specialRequests!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.1),
                borderRadius: AppRadius.smRadius,
                border: Border.all(
                  color: AppTheme.accentGold.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sticky_note_2,
                    size: 14,
                    color: AppTheme.accentGold,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      booking.specialRequests!,
                      style: TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCheckIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdRadius,
                  side: BorderSide(
                    color: AppTheme.successGreen.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
              ),
              child: Text(
                'Check In Now',
                style: TextStyle(
                  color: AppTheme.successGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInOutCard extends StatelessWidget {
  final Booking booking;
  final DateTime currentTime;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  const _CheckInOutCard({
    required this.booking,
    required this.currentTime,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue =
        currentTime.isAfter(booking.checkIn.add(Duration(days: 1)));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard.withOpacity(0.5),
        borderRadius: AppRadius.mdRadius,
        border: Border.all(
          color: isOverdue ? AppTheme.errorRed : AppTheme.accentCyan,
          width: isOverdue ? 2 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.roomName ?? 'Unknown Room',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      booking.guestName ?? 'Guest',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: booking.status.toString().split('.').last,
                status: booking.status.toString().split('.').last,
              ),
            ],
          ),
          if (isOverdue) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.1),
                borderRadius: AppRadius.smRadius,
                border: Border.all(
                  color: AppTheme.errorRed.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    size: 16,
                    color: AppTheme.errorRed,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '⚠️ OVERDUE: Contact guest - Check-in was on ${DateFormat('MMM dd').format(booking.checkIn)}',
                      style: TextStyle(
                        color: AppTheme.errorRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Check-in',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    booking.checkIn.toLocal().toString().split(' ')[0],
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Check-out',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    booking.checkOut.toLocal().toString().split(' ')[0],
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (booking.specialRequests != null &&
              booking.specialRequests!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.1),
                borderRadius: AppRadius.smRadius,
                border: Border.all(
                  color: AppTheme.accentGold.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sticky_note_2,
                    size: 14,
                    color: AppTheme.accentGold,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      booking.specialRequests!,
                      style: TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      booking.status == BookingStatus.confirmed ? onCheckIn : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdRadius,
                      side: BorderSide(
                        color: AppTheme.successGreen.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Text(
                    'Check In',
                    style: TextStyle(
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: ElevatedButton(
                  onPressed: booking.status == BookingStatus.checkedIn
                      ? onCheckOut
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorRed.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdRadius,
                      side: BorderSide(
                        color: AppTheme.errorRed.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Text(
                    'Check Out',
                    style: TextStyle(
                      color: AppTheme.errorRed,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoomManagementCard extends StatelessWidget {
  final Room room;
  final Function(String) onStatusChange;

  const _RoomManagementCard({
    required this.room,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final currentStatus = room.status.toString().split('.').last;

    // Display maintenance end time if available
    String? endTimeText;
    if (room.maintenanceUntil != null) {
      endTimeText =
          'Until: ${DateFormat('MMM dd, HH:mm').format(room.maintenanceUntil!)}';
    } else if (currentStatus == 'occupied' || currentStatus == 'maintenance') {
      endTimeText = 'Until: 2:00 PM Today';
    }

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
          if (endTimeText != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: (currentStatus == 'occupied'
                        ? AppTheme.accentCyan
                        : AppTheme.warningOrange)
                    .withOpacity(0.1),
                borderRadius: AppRadius.smRadius,
                border: Border.all(
                  color: (currentStatus == 'occupied'
                          ? AppTheme.accentCyan
                          : AppTheme.warningOrange)
                      .withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: currentStatus == 'occupied'
                        ? AppTheme.accentCyan
                        : AppTheme.warningOrange,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      endTimeText,
                      style: TextStyle(
                        color: currentStatus == 'occupied'
                            ? AppTheme.accentCyan
                            : AppTheme.warningOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatusButton(
                  label: 'Available',
                  isActive: currentStatus == 'available',
                  color: AppTheme.successGreen,
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
                  label: 'Maintenance',
                  isActive: currentStatus == 'maintenance',
                  color: AppTheme.warningOrange,
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
  final VoidCallback onTap;

  const _StatusButton({
    required this.label,
    required this.isActive,
    required this.color,
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
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color.withOpacity(0.3)
                : (widget.isActive
                    ? widget.color.withOpacity(0.2)
                    : AppTheme.surfaceCard.withOpacity(0.3)),
            borderRadius: AppRadius.smRadius,
            border: Border.all(
              color: _isHovered
                  ? widget.color.withOpacity(0.8)
                  : (widget.isActive
                      ? widget.color.withOpacity(0.6)
                      : widget.color.withOpacity(0.2)),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isHovered
                    ? widget.color
                    : (widget.isActive
                        ? widget.color
                        : AppTheme.textSecondary),
                fontSize: 11,
                fontWeight: _isHovered
                    ? FontWeight.w700
                    : (widget.isActive ? FontWeight.w700 : FontWeight.w500),
              ),
            ),
          ),
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
        ],
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isGranted;

  const _PermissionItem({
    required this.icon,
    required this.label,
    required this.isGranted,
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
          color: (isGranted ? AppTheme.successGreen : AppTheme.errorRed)
              .withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isGranted ? AppTheme.successGreen : AppTheme.errorRed,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            isGranted ? Icons.check_circle : Icons.cancel,
            color: isGranted ? AppTheme.successGreen : AppTheme.errorRed,
            size: 20,
          ),
        ],
      ),
    );
  }
}
