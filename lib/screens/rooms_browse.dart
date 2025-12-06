import 'package:flutter/material.dart';
import '../models/database_service.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/custom_components.dart';
import 'booking_screen.dart';

class RoomsBrowseScreen extends StatefulWidget {
  final User? currentUser;

  const RoomsBrowseScreen({this.currentUser});

  @override
  State createState() => _RoomsBrowseScreenState();
}

class _RoomsBrowseScreenState extends State<RoomsBrowseScreen> {
  final db = DatabaseService();
  late Future<List<Room>> _roomsFuture;

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _numberOfGuests = 1;
  String? _selectedZone;
  RangeValues _priceRange = const RangeValues(0, 300);
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _checkInDate = DateTime.now();
    _checkOutDate = DateTime.now().add(const Duration(days: 1));
    _loadRooms();
  }

  void _loadRooms() {
    _roomsFuture = db.searchRooms(
      checkIn: _checkInDate ?? DateTime.now(),
      checkOut: _checkOutDate ?? DateTime.now().add(const Duration(days: 1)),
      guests: _numberOfGuests,
      zoneId: _selectedZone,
      maxPrice: _priceRange.end,
    );
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
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
          }
        }
      });
      _loadRooms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            title: 'Find Your Room',
            subtitle: 'Discover luxury accommodations',
          ),
          // Search Filters
          Container(
            color: AppTheme.primaryDeep.withOpacity(0.5),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Quick Filters Row
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, true),
                        child: _FilterChip(
                          icon: Icons.calendar_today,
                          label: 'Check-In',
                          value: _checkInDate != null
                              ? '${_checkInDate!.day}/${_checkInDate!.month}'
                              : 'Select',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, false),
                        child: _FilterChip(
                          icon: Icons.calendar_today,
                          label: 'Check-Out',
                          value: _checkOutDate != null
                              ? '${_checkOutDate!.day}/${_checkOutDate!.month}'
                              : 'Select',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    GestureDetector(
                      onTap: () => setState(() => _showFilters = !_showFilters),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppTheme.accentCyan.withOpacity(0.15),
                          borderRadius: AppRadius.mdRadius,
                          border: Border.all(
                            color: AppTheme.accentCyan.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          _showFilters
                              ? Icons.filter_list_off
                              : Icons.filter_list,
                          color: AppTheme.accentCyan,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                // Expanded Filters
                if (_showFilters) ...[
                  const SizedBox(height: AppSpacing.lg),
                  // Guests
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Number of Guests',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard.withOpacity(0.5),
                          borderRadius: AppRadius.mdRadius,
                          border: Border.all(
                            color: AppTheme.accentCyan.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              color: AppTheme.accentCyan,
                              onPressed: _numberOfGuests > 1
                                  ? () {
                                      setState(() => _numberOfGuests--);
                                      _loadRooms();
                                    }
                                  : null,
                            ),
                            Text(
                              '$_numberOfGuests',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              color: AppTheme.accentCyan,
                              onPressed: () {
                                setState(() => _numberOfGuests++);
                                _loadRooms();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Price Range
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Price Range',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'EGP ${_priceRange.start.toStringAsFixed(0)} - ${_priceRange.end.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppTheme.accentCyan,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 300,
                        activeColor: AppTheme.accentCyan,
                        inactiveColor: AppTheme.accentCyan.withOpacity(0.2),
                        onChanged: (values) {
                          setState(() => _priceRange = values);
                          _loadRooms();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Zone Filter
                  FutureBuilder<List<Zone>>(
                    future: db.getAllZones(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Zone',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              _ZoneChip(
                                label: 'All',
                                isSelected: _selectedZone == null,
                                onTap: () {
                                  setState(() => _selectedZone = null);
                                  _loadRooms();
                                },
                              ),
                              ...snapshot.data!.map((zone) => _ZoneChip(
                                label: zone.name,
                                isSelected: _selectedZone == zone.id,
                                onTap: () {
                                  setState(() => _selectedZone = zone.id);
                                  _loadRooms();
                                },
                              )),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          // Rooms List
          Expanded(
            child: FutureBuilder<List<Room>>(
              future: _roomsFuture,
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.accentCyan.withOpacity(0.3),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'No rooms available',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 2 : 1,
                    crossAxisSpacing: AppSpacing.lg,
                    mainAxisSpacing: AppSpacing.lg,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final room = snapshot.data![index];
                    return _RoomCard(
                      room: room,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingScreen(
                              room: room,
                              currentUser: widget.currentUser,
                            ),
                          ),
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
}

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentCyan.withOpacity(0.1),
        borderRadius: AppRadius.mdRadius,
        border: Border.all(
          color: AppTheme.accentCyan.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.accentCyan, size: 16),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ZoneChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentCyan.withOpacity(0.2)
              : AppTheme.surfaceCard.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentCyan.withOpacity(0.6)
                : AppTheme.accentCyan.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.accentCyan : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;

  const _RoomCard({
    required this.room,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: AppTheme.accentCyan.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentCyan.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.cyberGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.lg),
                    topRight: Radius.circular(AppRadius.lg),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.accentCyan.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: AppTheme.accentCyan.withOpacity(0.2),
                      ),
                    ),
                    // Status Badge
                    Positioned(
                      top: AppSpacing.md,
                      right: AppSpacing.md,
                      child: StatusBadge(
                        label: room.status.toString().split('.').last,
                        status: room.status.toString().split('.').last,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Room Details
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Room Name
                    Text(
                      room.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Rating and Capacity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppTheme.accentGold,
                              size: 14,
                            ),
                            const SizedBox(width: AppSpacing.xs),
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
                        Row(
                          children: [
                            const Icon(
                              Icons.people_outline,
                              color: AppTheme.accentCyan,
                              size: 14,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${room.capacity}',
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
                    // Price
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
            ),
          ],
        ),
      ),
    );
  }
}
