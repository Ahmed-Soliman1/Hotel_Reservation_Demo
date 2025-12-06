import 'package:flutter/material.dart';
import '../models/database_service.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/custom_components.dart';
import 'edit_reservation.dart';

class BookingHistoryScreen extends StatefulWidget {
  final User? currentUser;

  const BookingHistoryScreen({this.currentUser});

  @override
  State createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State
    with TickerProviderStateMixin {
  final db = DatabaseService();
  late Future> _bookingsFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  void _loadBookings() {
    if (mounted && currentUser != null) {
      _bookingsFuture = db.getGuestBookings(currentUser!.id);
    } else {
      _bookingsFuture = db.getAllBookings();
    }
    setState(() {});
  }

  List _filterBookings(List bookings, int tabIndex) {
    switch (tabIndex) {
      case 0: // Upcoming
        return bookings
            .where((b) =>
                b.checkIn.isAfter(DateTime.now()) &&
                b.status != BookingStatus.cancelled)
            .toList();
      case 1: // Completed
        return bookings
            .where((b) =>
                b.checkOut.isBefore(DateTime.now()) &&
                b.status != BookingStatus.cancelled)
            .toList();
      case 2: // Cancelled
        return bookings
            .where((b) => b.status == BookingStatus.cancelled)
            .toList();
      default:
        return bookings;
    }
  }

  Future _cancelBooking(String bookingId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text(
          'Cancel Booking?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await db.cancelBooking(bookingId);
        _loadBookings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking cancelled successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future _editBooking(Booking booking) async {
    if (currentUser == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReservationScreen(
          booking: booking,
          currentUser: currentUser!,
        ),
      ),
    );

    if (result != null) {
      _loadBookings();
    }
  }

  get currentUser => widget.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: 'Booking History',
            subtitle: 'Manage your reservations',
          ),
          // Tabs
          Container(
            color: AppTheme.primaryDeep.withOpacity(0.5),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.accentCyan,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.accentCyan,
              indicatorWeight: 3,
              onTap: (_) => setState(() {}),
              tabs: const [
                Tab(
                  text: 'Upcoming',
                  icon: Icon(Icons.schedule_outlined),
                ),
                Tab(
                  text: 'Completed',
                  icon: Icon(Icons.check_circle_outlined),
                ),
                Tab(
                  text: 'Cancelled',
                  icon: Icon(Icons.cancel_outlined),
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: FutureBuilder>(
              future: _bookingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CyberLoader());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _EmptyState(
                    icon: Icons.calendar_today_outlined,
                    title: 'No Bookings',
                    description: 'You haven\'t made any bookings yet',
                  );
                }

                final filteredBookings =
                    _filterBookings(snapshot.data!, _tabController.index);

                if (filteredBookings.isEmpty) {
                  return _EmptyState(
                    icon: Icons.search_off,
                    title:
                        'No ${['Upcoming', 'Completed', 'Cancelled'][_tabController.index]} Bookings',
                    description:
                        'You don\'t have any ${['upcoming', 'completed', 'cancelled'][_tabController.index]} bookings',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: filteredBookings.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (context, index) {
                    final booking = filteredBookings[index];
                    return FutureBuilder(
                      future: db.getRoom(booking.roomId),
                      builder: (context, roomSnapshot) {
                        final room = roomSnapshot.data;
                        return _BookingCard(
                          booking: booking,
                          room: room,
                          onCancel: () => _cancelBooking(booking.id),
                          onEdit: () => _editBooking(booking),
                          canCancel: booking.status !=
                                  BookingStatus.cancelled &&
                              booking.checkIn.isAfter(DateTime.now()),
                          canEdit: booking.status ==
                                  BookingStatus.confirmed &&
                              booking.checkIn
                                  .isAfter(DateTime.now().add(Duration(days: 1))),
                        );
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final Room? room;
  final VoidCallback onCancel;
  final VoidCallback onEdit;
  final bool canCancel;
  final bool canEdit;

  const _BookingCard({
    required this.booking,
    required this.room,
    required this.onCancel,
    required this.onEdit,
    required this.canCancel,
    required this.canEdit,
  });

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppTheme.warningOrange;
      case BookingStatus.confirmed:
        return AppTheme.successGreen;
      case BookingStatus.checkedIn:
        return AppTheme.accentCyan;
      case BookingStatus.checkedOut:
        return AppTheme.textSecondary;
      case BookingStatus.cancelled:
        return AppTheme.errorRed;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.schedule_outlined;
      case BookingStatus.confirmed:
        return Icons.check_circle_outlined;
      case BookingStatus.checkedIn:
        return Icons.door_front_door_outlined;
      case BookingStatus.checkedOut:
        return Icons.exit_to_app_outlined;
      case BookingStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(booking.status);
    final statusIcon = _getStatusIcon(booking.status);
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room?.name ?? 'Unknown Room',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Booking ID: ${booking.id.substring(0, 8)}...',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: AppRadius.full,
                  border: Border.all(
                    color: statusColor.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      color: statusColor,
                      size: 14,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      booking.status.toString().split('.').last,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Dates Row
          Row(
            children: [
              Expanded(
                child: _DateInfo(
                  label: 'Check-In',
                  date: booking.checkIn,
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Icon(
                  Icons.arrow_forward_outlined,
                  color: AppTheme.textMuted,
                  size: 16,
                ),
              ),
              Expanded(
                child: _DateInfo(
                  label: 'Check-Out',
                  date: booking.checkOut,
                  icon: Icons.calendar_today_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Details Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nights',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${booking.numberOfNights}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guests',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${booking.numberOfGuests}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'EGP ${booking.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppTheme.accentCyan,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Action Buttons
          if (canEdit || canCancel) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                if (canEdit)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onEdit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentCyan.withOpacity(0.15),
                        foregroundColor: AppTheme.accentCyan,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.mdRadius,
                          side: BorderSide(
                            color: AppTheme.accentCyan.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text(
                        'Edit',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                if (canEdit && canCancel) const SizedBox(width: AppSpacing.lg),
                if (canCancel)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed.withOpacity(0.15),
                        foregroundColor: AppTheme.errorRed,
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
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DateInfo extends StatelessWidget {
  final String label;
  final DateTime date;
  final IconData icon;

  const _DateInfo({
    required this.label,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppTheme.accentCyan,
              size: 14,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.accentCyan.withOpacity(0.2),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
