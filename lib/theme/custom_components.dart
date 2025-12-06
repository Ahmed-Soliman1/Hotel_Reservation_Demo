import 'package:flutter/material.dart';
import 'app_theme.dart';

// ============ CUSTOM BUTTON COMPONENTS ============

/// Futuristic primary button with glow effect
class GlowButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const GlowButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  State createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.lgRadius,
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentCyan
                    .withOpacity(0.3 * _glowAnimation.value),
                blurRadius: 20 * _glowAnimation.value,
                spreadRadius: 2 * _glowAnimation.value,
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: widget.isLoading ? null : widget.onPressed,
            icon: widget.isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        AppTheme.primaryDeep,
                      ),
                    ),
                  )
                : (widget.icon != null ? Icon(widget.icon) : null),
            label: Text(widget.label),
          ),
        );
      },
    );
  }
}

/// Glass-morphism button for secondary actions
class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isOutline;

  const GlassButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isOutline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: GlassMorphismDecoration.glass(opacity: 0.05),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.lgRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: AppTheme.accentCyan),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============ CUSTOM INPUT COMPONENTS ============

/// Futuristic text input with glow
class GlowTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const GlowTextField({
    required this.label,
    this.hint,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
  });

  @override
  State createState() => _GlowTextFieldState();
}

class _GlowTextFieldState extends State<GlowTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgRadius,
        boxShadow: _isFocused ? AppShadows.glow : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        onChanged: widget.onChanged,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: AppTheme.accentCyan)
              : null,
          suffixIcon: widget.suffixIcon != null
              ? Icon(widget.suffixIcon, color: AppTheme.textSecondary)
              : null,
          fillColor: AppTheme.surfaceCard.withOpacity(_isFocused ? 0.8 : 0.6),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: AppRadius.lgRadius,
            borderSide: BorderSide(
              color: _isFocused
                  ? AppTheme.accentCyan
                  : AppTheme.accentCyan.withOpacity(0.2),
              width: _isFocused ? 2 : 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.lgRadius,
            borderSide: BorderSide(
              color: AppTheme.accentCyan.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.lgRadius,
            borderSide: const BorderSide(
              color: AppTheme.accentCyan,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

// ============ CARD COMPONENTS ============

/// Premium card with gradient border and shadow
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final bool isGradient;

  const PremiumCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.isGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: isGradient
            ? GlassMorphismDecoration.gradientCard()
            : GlassMorphismDecoration.card(),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Header section with gradient background
class GradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const GradientHeader({
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.luxuryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ============ BADGE & STATUS COMPONENTS ============

/// Futuristic status badge
class StatusBadge extends StatelessWidget {
  final String label;
  final String status; // 'available', 'booked', 'maintenance', 'pending'
  final IconData? icon;

  const StatusBadge({
    required this.label,
    required this.status,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusColors[status] ?? AppTheme.accentCyan;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ RATING COMPONENT ============

/// Animated star rating display
class StarRating extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;

  const StarRating({
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < maxRating; i++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              i < rating.floor()
                  ? Icons.star
                  : (i < rating)
                      ? Icons.star_half
                      : Icons.star_outline,
              color: AppTheme.accentGold,
              size: size,
            ),
          ),
        const SizedBox(width: 6),
        Text(
          '${rating.toStringAsFixed(1)}/5',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ============ LOADING INDICATOR ============

/// Cyber-style loading indicator
class CyberLoader extends StatefulWidget {
  final double size;

  const CyberLoader({this.size = 50});

  @override
  State createState() => _CyberLoaderState();
}

class _CyberLoaderState extends State<CyberLoader>
    with SingleTickerProviderStateMixin {
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
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.accentCyan.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.accentCyan,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============ ROOM CARD ============

/// Premium room card with image and details
class RoomCard extends StatelessWidget {
  final String name;
  final String image;
  final double price;
  final double rating;
  final String status;
  final VoidCallback onTap;

  const RoomCard({
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PremiumCard(
        isGradient: true,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 12,
                      right: 12,
                      child: StatusBadge(
                        label: status,
                        status: status,
                        icon: Icons.check_circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        StarRating(rating: rating, size: 14),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'EGP ${price.toStringAsFixed(0)}/night',
                          style: const TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppTheme.accentCyan,
                        ),
                      ],
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

// ============ SECTION DIVIDER ============

class SectionDivider extends StatelessWidget {
  final String title;

  const SectionDivider({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.accentCyan,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
