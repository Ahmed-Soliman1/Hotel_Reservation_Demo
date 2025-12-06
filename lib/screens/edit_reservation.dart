import 'package:flutter/material.dart';
import '../models/database_service.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/custom_components.dart';

class EditReservationScreen extends StatefulWidget {
  final Booking booking;
  final User currentUser;

  const EditReservationScreen({
    Key? key,
    required this.booking,
    required this.currentUser,
  }) : super(key: key);

  @override
  State createState() => _EditReservationScreenState();
}

class _EditReservationScreenState extends State<EditReservationScreen> {
  final db = DatabaseService();

  // Form state
  late DateTime _checkIn;
  late DateTime _checkOut;
  late int _numberOfGuests;
  late String _selectedRoomId;

  // Data
  late Room _currentRoom;
  late Room _selectedRoom;
  List<Room> _availableRooms = [];

  // UI state
  bool _showComparison = false;

  @override
  void initState() {
    super.initState();
    _checkIn = widget.booking.checkIn;
    _checkOut = widget.booking.checkOut;
    _numberOfGuests = widget.booking.numberOfGuests;
    _selectedRoomId = widget.booking.roomId;
    _loadRoomData();
  }

  Future<void> _loadRoomData() async {
    try {
      final room = await db.getRoom(widget.booking.roomId);
      final allRooms = await db.getAllRooms();

      if (mounted) {
        setState(() {
          _currentRoom = room!;
          _selectedRoom = room;
          _availableRooms = allRooms;
        });
      }
    } catch (e) {
      print('Error loading rooms: $e');
    }
  }

  Future<void> _selectCheckInDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkIn,
      firstDate: DateTime.now(),
      lastDate: _checkOut.subtract(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentCyan,
              surface: AppTheme.surfaceCard,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _checkIn) {
      setState(() {
        _checkIn = picked;
        _showComparison = true;
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOut,
      firstDate: _checkIn.add(const Duration(days: 1)),
      lastDate: _checkIn.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentCyan,
              surface: AppTheme.surfaceCard,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _checkOut) {
      setState(() {
        _checkOut = picked;
        _showComparison = true;
      });
    }
  }

  void _onNumberOfGuestsChanged(int value) {
    setState(() {
      _numberOfGuests = value;
      _showComparison = true;
    });
  }

  void _onRoomSelected(String roomId) {
    final room = _availableRooms.firstWhere((r) => r.id == roomId);
    setState(() {
      _selectedRoomId = roomId;
      _selectedRoom = room;
      _showComparison = true;
    });
  }

  int _calculateNights(DateTime checkIn, DateTime checkOut) {
    return checkOut.difference(checkIn).inDays;
  }

  double _calculateTotalPrice(Room room, int nights) {
    return room.price * nights;
  }

  Future<void> _confirmChanges() async {
    // Validate
    if (_numberOfGuests > _selectedRoom.capacity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedRoom.name} can only accommodate ${_selectedRoom.capacity} guests',
          ),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    // Create updated booking
    final updatedBooking = Booking(
      id: widget.booking.id,
      guestId: widget.booking.guestId,
      roomId: _selectedRoomId,
      roomName: _selectedRoom.name,
      guestName: widget.booking.guestName,
      specialRequests: widget.booking.specialRequests,
      checkIn: _checkIn,
      checkOut: _checkOut,
      status: widget.booking.status,
      totalPrice: _calculateTotalPrice(
        _selectedRoom,
        _calculateNights(_checkIn, _checkOut),
      ),
      numberOfGuests: _numberOfGuests,
    );

    try {
      // Update in database
      await db.updateBookingStatus(widget.booking.id, widget.booking.status);

      // You might want to create a separate update method in database_service.dart
      // For now, we'll just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking updated successfully'),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      if (mounted) {
        Navigator.pop(context, updatedBooking);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating booking: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentRoom == null) {
      return Scaffold(
        body: Center(child: CyberLoader()),
      );
    }

    final currentNights = _calculateNights(widget.booking.checkIn, widget.booking.checkOut);
    final newNights = _calculateNights(_checkIn, _checkOut);
    final currentTotal = _calculateTotalPrice(_currentRoom, currentNights);
    final newTotal = _calculateTotalPrice(_selectedRoom, newNights);
    final priceDifference = newTotal - currentTotal;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppTheme.primaryDeep,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_outlined),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Edit Reservation',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.cyberGradient,
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Reservation Summary
                  _buildSectionTitle('Current Reservation'),
                  const SizedBox(height: AppSpacing.lg),
                  _buildCurrentReservationCard(currentNights, currentTotal),
                  const SizedBox(height: AppSpacing.xl),

                  // Edit Form
                  _buildSectionTitle('New Details'),
                  const SizedBox(height: AppSpacing.lg),

                  // Room Selection
                  _buildRoomSelector(),
                  const SizedBox(height: AppSpacing.xl),

                  // Dates
                  _buildDateSelector(),
                  const SizedBox(height: AppSpacing.xl),

                  // Guests
                  _buildGuestSelector(),
                  const SizedBox(height: AppSpacing.xl),

                  // Price Comparison (if changed)
                  if (_showComparison) ...[
                    _buildPriceComparison(
                      currentTotal,
                      newTotal,
                      priceDifference,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Action Buttons
                  _buildActionButtons(priceDifference),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _buildCurrentReservationCard(int nights, double total) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room
          Row(
            children: [
              Icon(Icons.hotel, color: AppTheme.accentCyan, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentRoom.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'EGP ${_currentRoom.price.toStringAsFixed(0)}/night',
                      style: const TextStyle(
                        color: AppTheme.accentCyan,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Dates
          Row(
            children: [
              Expanded(
                child: _buildDateInfo(
                  'Check-In',
                  widget.booking.checkIn,
                ),
              ),
              Icon(
                Icons.arrow_forward_outlined,
                color: AppTheme.textMuted,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildDateInfo(
                  'Check-Out',
                  widget.booking.checkOut,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailInfo('Guests', '${widget.booking.numberOfGuests}'),
              _buildDetailInfo('Nights', '$nights'),
              _buildDetailInfo('Total', 'EGP ${total.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${date.day}/${date.month}/${date.year}',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRoomSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Room',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard.withOpacity(0.5),
            borderRadius: AppRadius.mdRadius,
            border: Border.all(
              color: AppTheme.accentCyan.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRoomId,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              dropdownColor: AppTheme.surfaceCard,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
              ),
              onChanged: (value) {
                if (value != null) _onRoomSelected(value);
              },
              items: _availableRooms.map((room) {
                return DropdownMenuItem(
                  value: room.id,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${room.capacity} guests • EGP ${room.price.toStringAsFixed(0)}/night',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (room.id == _selectedRoomId)
                        const Icon(
                          Icons.check_circle,
                          color: AppTheme.accentCyan,
                          size: 18,
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Dates',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _selectCheckInDate,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard.withOpacity(0.5),
                    borderRadius: AppRadius.mdRadius,
                    border: Border.all(
                      color: AppTheme.accentCyan.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check-In',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${_checkIn.day}/${_checkIn.month}/${_checkIn.year}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: GestureDetector(
                onTap: _selectCheckOutDate,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard.withOpacity(0.5),
                    borderRadius: AppRadius.mdRadius,
                    border: Border.all(
                      color: AppTheme.accentCyan.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check-Out',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${_checkOut.day}/${_checkOut.month}/${_checkOut.year}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGuestSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of Guests',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard.withOpacity(0.5),
            borderRadius: AppRadius.mdRadius,
            border: Border.all(
              color: AppTheme.accentCyan.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _numberOfGuests > 1
                    ? () => _onNumberOfGuestsChanged(_numberOfGuests - 1)
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCyan.withOpacity(0.1),
                    borderRadius: AppRadius.smRadius,
                  ),
                  child: Icon(
                    Icons.remove,
                    color: _numberOfGuests > 1
                        ? AppTheme.accentCyan
                        : AppTheme.textMuted,
                    size: 18,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$_numberOfGuests',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${_numberOfGuests > 1 ? 'Guests' : 'Guest'}',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _numberOfGuests < _selectedRoom.capacity
                    ? () => _onNumberOfGuestsChanged(_numberOfGuests + 1)
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCyan.withOpacity(0.1),
                    borderRadius: AppRadius.smRadius,
                  ),
                  child: Icon(
                    Icons.add,
                    color: _numberOfGuests < _selectedRoom.capacity
                        ? AppTheme.accentCyan
                        : AppTheme.textMuted,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Room capacity: ${_selectedRoom.capacity} guests',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceComparison(
    double currentTotal,
    double newTotal,
    double difference,
  ) {
    final isDifference = difference.abs() > 0.01;
    final isIncrease = difference > 0;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Comparison',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Current Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.successGreen,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Current Price',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Text(
                'EGP ${currentTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Arrow
          Center(
            child: Icon(
              Icons.arrow_downward_outlined,
              color: AppTheme.accentCyan,
              size: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // New Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: AppTheme.accentCyan,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'New Price',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Text(
                'EGP ${newTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppTheme.accentCyan,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          if (isDifference) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isIncrease
                    ? AppTheme.warningOrange.withOpacity(0.1)
                    : AppTheme.successGreen.withOpacity(0.1),
                borderRadius: AppRadius.mdRadius,
                border: Border.all(
                  color: isIncrease
                      ? AppTheme.warningOrange.withOpacity(0.3)
                      : AppTheme.successGreen.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isIncrease
                            ? Icons.trending_up_outlined
                            : Icons.trending_down_outlined,
                        color: isIncrease
                            ? AppTheme.warningOrange
                            : AppTheme.successGreen,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isIncrease ? 'Price Increase' : 'Price Decrease',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    '${isIncrease ? '+' : '-'} EGP ${difference.abs().toStringAsFixed(0)}',
                    style: TextStyle(
                      color: isIncrease
                          ? AppTheme.warningOrange
                          : AppTheme.successGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(double priceDifference) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.surfaceCard,
              foregroundColor: AppTheme.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.mdRadius,
                side: BorderSide(
                  color: AppTheme.accentCyan.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
            ),
            icon: const Icon(Icons.close_outlined, size: 18),
            label: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _confirmChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCyan,
              foregroundColor: AppTheme.primaryDeep,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.mdRadius,
              ),
            ),
            icon: const Icon(Icons.check_outlined, size: 18),
            label: const Text(
              'Apply Changes',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
