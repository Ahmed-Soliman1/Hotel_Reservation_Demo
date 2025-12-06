import 'package:flutter/material.dart';
import '../models/room.dart';
import '../theme/app_theme.dart';
import 'package:hotel_reservation_demo/models/database_service.dart';
import '../theme/custom_components.dart';

class RoomDetailScreen extends StatefulWidget {
  final Room room;
  const RoomDetailScreen({required this.room});

  @override
  State createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  int selectedTabIndex = 0;
  
  final List<String> tabs = [
    "Overview",
    "Amenities",
    "Pricing",
    "Reviews",
  ];

  final List<Map<String, dynamic>> amenities = [
    {'icon': Icons.wifi, 'name': 'High-Speed WiFi', 'desc': 'Unlimited connectivity'},
    {'icon': Icons.kitchen, 'name': 'Kitchen', 'desc': 'Fully equipped kitchenette'},
    {'icon': Icons.pool, 'name': 'Private Pool', 'desc': 'Exclusive pool access'},
    {'icon': Icons.king_bed, 'name': 'King Bed', 'desc': 'Luxurious bedding'},
    {'icon': Icons.tv, 'name': 'Smart TV', 'desc': 'Premium streaming'},
    {'icon': Icons.spa, 'name': 'Jacuzzi', 'desc': 'In-room spa bath'},
  ];

  final List<Map<String, String>> reviews = [
    {
      'author': 'Sarah Johnson',
      'rating': '5.0',
      'date': '2 weeks ago',
      'comment': 'Absolutely stunning! The view is breathtaking and staff is incredibly helpful.',
    },
    {
      'author': 'Michael Chen',
      'rating': '4.8',
      'date': '1 month ago',
      'comment': 'Perfect honeymoon destination. Exceeded all expectations.',
    },
    {
      'author': 'Emma Williams',
      'rating': '5.0',
      'date': '6 weeks ago',
      'comment': 'Best vacation ever! Everything was perfect.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with Image
          Stack(
            children: [
              // Image
              Container(
                height: 280,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(widget.room.image),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppTheme.primaryDeep.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
              // Back Button
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.3),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppTheme.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Rating Badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppShadows.lg,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: AppTheme.primaryDeep,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${widget.room.rating}/5',
                        style: const TextStyle(
                          color: AppTheme.primaryDeep,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Room Info & Tabs
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Room Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.room.name,
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: AppTheme.accentCyan,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Kite Center Road, El Gouna, Hurghada, Egypt',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Tab Navigation
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard.withOpacity(0.5),
                      border: Border.all(
                        color: AppTheme.accentCyan.withOpacity(0.2),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(tabs.length, (idx) {
                          final isSelected = selectedTabIndex == idx;
                          return GestureDetector(
                            onTap: () => setState(() => selectedTabIndex = idx),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.md,
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.accentCyan.withOpacity(0.15)
                                    : Colors.transparent,
                                border: isSelected
                                    ? Border.all(
                                      color: AppTheme.accentCyan.withOpacity(0.5),
                                      width: 1.5,
                                    )
                                    : null,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                tabs[idx],
                                style: TextStyle(
                                  color: isSelected
                                      ? AppTheme.accentCyan
                                      : AppTheme.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Tab Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: _buildTabContent(),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),

          // Book Button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: GlowButton(
                label: 'Book Now - EGP ${widget.room.price.toStringAsFixed(0)}/night',
                icon: Icons.calendar_today_outlined,
                onPressed: () {
                  // Handle booking
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTabIndex) {
      case 0: // Overview
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionDivider(title: 'Room Overview'),
            PremiumCard(
              isGradient: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Luxurious accommodation with breathtaking ocean views',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InfoCard(
                        icon: Icons.square_foot,
                        label: 'Size',
                        value: '45 m²',
                      ),
                      _InfoCard(
                        icon: Icons.people_outline,
                        label: 'Guests',
                        value: '4 Max',
                      ),
                      _InfoCard(
                        icon: Icons.king_bed,
                        label: 'Beds',
                        value: '2 Beds',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );

      case 1: // Amenities
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionDivider(title: 'Amenities'),
            GridView.builder(
              itemCount: amenities.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.lg,
                mainAxisSpacing: AppSpacing.lg,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final amenity = amenities[index];
                return PremiumCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        amenity['icon'] as IconData,
                        color: AppTheme.accentCyan,
                        size: 28,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        amenity['name'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        amenity['desc'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );

      case 2: // Pricing
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionDivider(title: 'Pricing Details'),
            PremiumCard(
              isGradient: true,
              child: Column(
                children: [
                  _PricingRow(
                    label: 'Room Rate (1 night)',
                    price: 'EGP ${widget.room.price.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PricingRow(
                    label: 'Taxes & Fees',
                    price: 'EGP ${(widget.room.price * 0.14).toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(color: AppTheme.accentCyan),
                  const SizedBox(height: AppSpacing.lg),
                  _PricingRow(
                    label: 'Total (1 night)',
                    price: 'EGP ${(widget.room.price * 1.14).toStringAsFixed(0)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],
        );

      case 3: // Reviews
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionDivider(title: 'Guest Reviews'),
            ListView.separated(
              itemCount: reviews.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
              itemBuilder: (context, index) {
                final review = reviews[index];
                return PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            review['author']!,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          StarRating(
                            rating: double.parse(review['rating']!),
                            size: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        review['date']!,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        review['comment']!,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

// ============ HELPER WIDGETS ============

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard.withOpacity(0.6),
          border: Border.all(
            color: AppTheme.accentCyan.withOpacity(0.2),
            width: 1.5,
          ),
          borderRadius: AppRadius.mdRadius,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.accentCyan, size: 22),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingRow extends StatelessWidget {
  final String label;
  final String price;
  final bool isTotal;

  const _PricingRow({
    required this.label,
    required this.price,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? AppTheme.accentCyan : AppTheme.textSecondary,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            fontSize: isTotal ? 14 : 13,
          ),
        ),
        Text(
          price,
          style: TextStyle(
            color: isTotal ? AppTheme.accentGold : AppTheme.textPrimary,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            fontSize: isTotal ? 16 : 13,
          ),
        ),
      ],
    );
  }
}
