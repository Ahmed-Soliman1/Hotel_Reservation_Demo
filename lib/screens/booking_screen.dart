import 'package:flutter/material.dart';

import '../models/database_service.dart';

import '../models/models.dart';

import '../theme/app_theme.dart';

import '../theme/custom_components.dart';

class BookingScreen extends StatefulWidget {
  final Room room;
  final User? currentUser;

  const BookingScreen({
    required this.room,
    this.currentUser,
  });

  @override
  State createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with TickerProviderStateMixin {
  final db = DatabaseService();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _numberOfGuests = 1;
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeController.forward();
    _slideController.forward();
    // Set default dates
    _checkInDate = DateTime.now();
    _checkOutDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  int get numberOfNights =>
      _checkOutDate?.difference(_checkInDate ?? DateTime.now()).inDays ?? 1;

  double get totalPrice => widget.room.price * numberOfNights;

  Future _selectDate(BuildContext context, bool isCheckIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? (_checkInDate ?? DateTime.now())
          : (_checkOutDate ?? DateTime.now().add(const Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.accentCyan,
              onPrimary: AppTheme.primaryDeep,
              surface: AppTheme.surfaceCard,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate == null ||
              _checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutDate = _checkInDate!.add(const Duration(days: 1));
          }
        } else {
          if (picked.isAfter(_checkInDate ?? DateTime.now())) {
            _checkOutDate = picked;
          } else {
            _error = 'Check-out date must be after check-in date';
          }
        }
      });
    }
  }

  Future _confirmBooking() async {
    setState(() => _error = '');
    // Validation
    if (_checkInDate == null || _checkOutDate == null) {
      setState(() => _error = 'Please select check-in and check-out dates');
      return;
    }

    if (_numberOfGuests <= 0 || _numberOfGuests > widget.room.capacity) {
      setState(() =>
          _error = 'Number of guests must be between 1 and ${widget.room.capacity}');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // FIXED: Add roomName and guestName to booking
      final guestName = widget.currentUser != null
          ? '${widget.currentUser!.firstName} ${widget.currentUser!.lastName}'
          : 'Guest';

      final booking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        guestId: widget.currentUser?.id ?? 'guest_${DateTime.now().millisecondsSinceEpoch}',
        roomId: widget.room.id,
        roomName: widget.room.name, // FIXED: Added room name
        guestName: guestName, // FIXED: Added guest name
        checkIn: _checkInDate!,
        checkOut: _checkOutDate!,
        status: BookingStatus.confirmed, // FIXED: Set to confirmed instead of pending
        totalPrice: totalPrice,
        numberOfGuests: _numberOfGuests,
      );

      await db.createBooking(booking);

      if (mounted) {
        // Show confirmation dialog
        await showDialog(
          context: context,
          builder: (context) => BookingConfirmationDialog(
            booking: booking,
            room: widget.room,
            numberOfNights: numberOfNights,
          ),
        );

        Navigator.pop(context, booking);
      }
    } catch (e) {
      setState(() => _error = 'Booking failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: 'Book Room',
            subtitle: widget.room.name,
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeController,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      // Room Preview
                      PremiumCard(
                        child: Column(
                          children: [
                            // Room Image Placeholder
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                gradient: AppTheme.cyberGradient,
                                borderRadius: AppRadius.lgRadius,
                                border: Border.all(
                                  color: AppTheme.accentCyan.withOpacity(0.2),
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 60,
                                  color: AppTheme.accentCyan.withOpacity(0.3),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // Room Details
                            Text(
                              widget.room.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: AppTheme.accentGold,
                                  size: 18,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  '${widget.room.rating} · ${widget.room.capacity} guests',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // Amenities
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: widget.room.amenities
                                  .map((amenity) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.sm,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentCyan
                                              .withOpacity(0.1),
                                          borderRadius: AppRadius.smRadius,
                                          border: Border.all(
                                            color: AppTheme.accentCyan
                                                .withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          amenity,
                                          style: TextStyle(
                                            color: AppTheme.accentCyan,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Booking Details
                      PremiumCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Booking Details',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // Check-in Date
                            GestureDetector(
                              onTap: () => _selectDate(context, true),
                              child: DatePickerField(
                                label: 'Check-In',
                                date: _checkInDate,
                                icon: Icons.calendar_today,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // Check-out Date
                            GestureDetector(
                              onTap: () => _selectDate(context, false),
                              child: DatePickerField(
                                label: 'Check-Out',
                                date: _checkOutDate,
                                icon: Icons.calendar_today,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // Number of Guests
                            Text(
                              'Number of Guests',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceCard.withOpacity(0.5),
                                borderRadius: AppRadius.lgRadius,
                                border: Border.all(
                                  color: AppTheme.accentCyan.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    color: AppTheme.accentCyan,
                                    onPressed: _numberOfGuests > 1
                                        ? () =>
                                            setState(() => _numberOfGuests--)
                                        : null,
                                  ),
                                  Text(
                                    '$_numberOfGuests',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: AppTheme.textPrimary,
                                        ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    color: AppTheme.accentCyan,
                                    onPressed: _numberOfGuests <
                                            widget.room.capacity
                                        ? () =>
                                            setState(() => _numberOfGuests++)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Price Summary
                      PremiumCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Price per night',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'EGP ${widget.room.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Number of nights',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '$numberOfNights night${numberOfNights != 1 ? 's' : ''}',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              color: AppTheme.accentCyan.withOpacity(0.2),
                              height: AppSpacing.xl,
                              thickness: 1,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Price',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: AppTheme.textPrimary,
                                      ),
                                ),
                                Text(
                                  'EGP ${totalPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: AppTheme.accentCyan,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Error Message
                      if (_error.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed.withOpacity(0.15),
                            border: Border.all(
                              color: AppTheme.errorRed.withOpacity(0.5),
                              width: 1.5,
                            ),
                            borderRadius: AppRadius.lgRadius,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppTheme.errorRed,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  _error,
                                  style: TextStyle(
                                    color: AppTheme.errorRed,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xl),

                      // Confirm Button
                      SizedBox(
                        width: double.infinity,
                        child: GlowButton(
                          label: 'Confirm Booking',
                          icon: Icons.check_circle_outline,
                          isLoading: _isLoading,
                          onPressed: _confirmBooking,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widgets

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final IconData icon;

  const DatePickerField({
    required this.label,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard.withOpacity(0.5),
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: AppTheme.accentCyan.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentCyan),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
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
                Text(
                  date != null
                      ? '${date!.day}/${date!.month}/${date!.year}'
                      : 'Select date',
                  style: TextStyle(
                    color: date != null ? AppTheme.textPrimary : AppTheme.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_outlined,
            color: AppTheme.textMuted,
            size: 16,
          ),
        ],
      ),
    );
  }
}

class BookingConfirmationDialog extends StatelessWidget {
  final Booking booking;
  final Room room;
  final int numberOfNights;

  const BookingConfirmationDialog({
    required this.booking,
    required this.room,
    required this.numberOfNights,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.successGreen.withOpacity(0.15),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppTheme.successGreen,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Booking Confirmed!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Your reservation is now confirmed',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard.withOpacity(0.5),
                borderRadius: AppRadius.mdRadius,
              ),
              child: Column(
                children: [
                  _ConfirmationRow(
                    label: 'Room',
                    value: room.name,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ConfirmationRow(
                    label: 'Check-In',
                    value:
                        '${booking.checkIn.day}/${booking.checkIn.month}/${booking.checkIn.year}',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ConfirmationRow(
                    label: 'Check-Out',
                    value:
                        '${booking.checkOut.day}/${booking.checkOut.month}/${booking.checkOut.year}',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ConfirmationRow(
                    label: 'Total',
                    value: 'EGP ${booking.totalPrice.toStringAsFixed(2)}',
                    isHighlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCyan,
                  foregroundColor: AppTheme.primaryDeep,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.lgRadius,
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmationRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _ConfirmationRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? AppTheme.accentCyan : AppTheme.textPrimary,
            fontSize: isHighlight ? 14 : 13,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
