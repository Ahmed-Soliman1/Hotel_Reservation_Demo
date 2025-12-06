import 'package:flutter/material.dart';

import '../models/database_service.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/custom_components.dart';
import 'rooms_browse.dart';
import 'edit_reservation.dart';

class GuestHome extends StatefulWidget {
  final User? currentUser;

  const GuestHome({Key? key, this.currentUser}) : super(key: key);

  @override
  State<GuestHome> createState() => _GuestHomeState();
}

class _GuestHomeState extends State<GuestHome> {
  final db = DatabaseService();
  late User _user;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _user = widget.currentUser ??
        User(
          id: 'guest1',
          firstName: 'Guest',
          lastName: 'User',
          email: 'guest@example.com',
          password: 'password123',
          role: UserRole.guest,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          RoomsBrowseScreen(currentUser: _user),
          _buildBookingHistoryTab(),
          _buildProfileTab(),
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
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          GradientHeader(
            title: 'Welcome!',
            subtitle: 'Your luxury hotel booking experience',
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Stats
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle,
                        label: 'Bookings',
                        value: '0',
                        color: AppTheme.accentCyan,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.star,
                        label: 'Rating',
                        value: '4.5',
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Featured Rooms
                Text(
                  'Featured Rooms',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FutureBuilder<List<Room>>(
                  future: db.getAllRooms(),
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

                    final rooms = snapshot.data!.take(3).toList();
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rooms.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        return _RoomPreviewCard(room: room);
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.search,
                        label: 'Search Rooms',
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.history,
                        label: 'My Bookings',
                        onTap: () => setState(() => _selectedIndex = 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.favorite,
                        label: 'Favorites',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.support_agent,
                        label: 'Support',
                        onTap: () {},
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

  Widget _buildBookingHistoryTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          GradientHeader(
            title: 'Booking History',
            subtitle: 'Manage your reservations',
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: FutureBuilder<List<Booking>>(
              future: db.getGuestBookings(_user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CyberLoader());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 64,
                            color: AppTheme.accentCyan.withOpacity(0.3),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'No bookings yet',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Start booking your next luxury stay',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (context, index) {
                    final booking = snapshot.data![index];
                    return _BookingCard(
                      booking: booking,
                      currentUser: _user,
                      onRefresh: () => setState(() {}),
                    );
                  },
                );
              },
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
            subtitle: 'Manage your account',
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
                        label: 'guest',
                        status: 'guest',
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
                  value: _user.email,
                ),
                const SizedBox(height: AppSpacing.lg),
                _SettingItem(
                  icon: Icons.security_outlined,
                  label: 'Account Type',
                  value: 'Premium Guest',
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
                    onPressed: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/',
                          (route) => false,
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorRed.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
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

// ============ HELPER WIDGETS ============

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
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
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
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomPreviewCard extends StatelessWidget {
  final Room room;

  const _RoomPreviewCard({required this.room});

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
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.cyberGradient,
              borderRadius: AppRadius.mdRadius,
            ),
            child: Center(
              child: Icon(
                Icons.hotel,
                color: AppTheme.accentCyan.withOpacity(0.3),
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: AppTheme.accentGold,
                      size: 14,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${room.rating}',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'EGP ${room.price.toStringAsFixed(0)}/night',
                  style: const TextStyle(
                    color: AppTheme.accentCyan,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_outlined,
            color: AppTheme.accentCyan,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final User currentUser;
  final VoidCallback onRefresh;

  const _BookingCard({
    required this.booking,
    required this.currentUser,
    required this.onRefresh,
  });

  String _getStatusString(BookingStatus status) {
    return status.toString().split('.').last;
  }

  double _calculateTotalCost(Booking booking) {
    return booking.totalPrice;
  }

  bool _canEdit() {
    final now = DateTime.now();
    final hoursUntilCheckIn = booking.checkIn.difference(now).inHours;
    return booking.status == BookingStatus.confirmed &&
        hoursUntilCheckIn > 24;
  }

  bool _canCancel() {
    return booking.status != BookingStatus.cancelled &&
        booking.checkIn.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final statusStr = _getStatusString(booking.status);
    final totalCost = _calculateTotalCost(booking);
    final canEdit = _canEdit();
    final canCancel = _canCancel();

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
          // Header with Booking ID and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking #${booking.id.substring(0, 8)}',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              StatusBadge(
                label: statusStr,
                status: statusStr,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Room Name and Guests Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Room',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      booking.roomName ?? 'Room ${booking.roomId}',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Guests',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        color: AppTheme.accentCyan,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${booking.numberOfGuests}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Check-in and Check-out Dates
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
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    booking.checkIn.toLocal().toString().split(' ')[0],
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_outlined,
                color: AppTheme.accentCyan,
                size: 16,
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
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    booking.checkOut.toLocal().toString().split(' ')[0],
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Total Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'EGP ${totalCost.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.accentCyan,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Action Buttons - Always Show Both Buttons
          Row(
            children: [
              // Edit Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: canEdit
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditReservationScreen(
                                booking: booking,
                                currentUser: currentUser,
                              ),
                            ),
                          ).then((updatedBooking) {
                            if (updatedBooking != null) {
                              onRefresh();
                            }
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canEdit
                        ? AppTheme.accentCyan.withOpacity(0.15)
                        : AppTheme.accentCyan.withOpacity(0.05),
                    foregroundColor: canEdit
                        ? AppTheme.accentCyan
                        : AppTheme.accentCyan.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdRadius,
                      side: BorderSide(
                        color: canEdit
                            ? AppTheme.accentCyan.withOpacity(0.5)
                            : AppTheme.accentCyan.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    disabledMouseCursor: SystemMouseCursors.forbidden,
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text(
                    'Edit',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Cancel Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: canCancel
                      ? () async {
                          final confirmed = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppTheme.surfaceCard,
                              title: const Text(
                                'Cancel Booking?',
                                style:
                                    TextStyle(color: AppTheme.textPrimary),
                              ),
                              content: const Text(
                                'Are you sure you want to cancel this booking? This action cannot be undone.',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text(
                                    'Yes, Cancel',
                                    style: TextStyle(
                                        color: AppTheme.errorRed),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirmed ?? false) {
                            try {
                              await DatabaseService()
                                  .cancelBooking(booking.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Booking cancelled successfully'),
                                    backgroundColor:
                                        AppTheme.successGreen,
                                  ),
                                );
                                onRefresh();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: AppTheme.errorRed,
                                  ),
                                );
                              }
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canCancel
                        ? AppTheme.errorRed.withOpacity(0.15)
                        : AppTheme.errorRed.withOpacity(0.05),
                    foregroundColor: canCancel
                        ? AppTheme.errorRed
                        : AppTheme.errorRed.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdRadius,
                      side: BorderSide(
                        color: canCancel
                            ? AppTheme.errorRed.withOpacity(0.5)
                            : AppTheme.errorRed.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    disabledMouseCursor: SystemMouseCursors.forbidden,
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text(
                    'Cancel',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
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

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
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
          color: AppTheme.accentCyan.withOpacity(0.1),
          borderRadius: AppRadius.mdRadius,
          border: Border.all(
            color: AppTheme.accentCyan.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.accentCyan, size: 24),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
          Icon(
            Icons.edit_outlined,
            color: AppTheme.textSecondary,
            size: 18,
          ),
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
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
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
            value: _value,
            onChanged: (value) {
              setState(() => _value = value);
              widget.onChanged(value);
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
