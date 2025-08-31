import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class FavouriteRow extends StatefulWidget {
  final Map<String, dynamic> pObj;                 // productID, productName, imageURL, finalPrice, category
  final VoidCallback onPressed;                    // (optional) add-to-cart or open details
  final bool isFavorite;
  final Future<void> Function() onFavoriteToggle;  // async toggle fav/unfav

  const FavouriteRow({
    super.key,
    required this.pObj,
    required this.onPressed,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<FavouriteRow> createState() => _FavouriteRowState();
}

class _FavouriteRowState extends State<FavouriteRow> {
  late bool _isFavoriteLocal;

  @override
  void initState() {
    super.initState();
    _isFavoriteLocal = widget.isFavorite;
  }

  @override
  void didUpdateWidget(covariant FavouriteRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _isFavoriteLocal = widget.isFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double finalPrice =
    (widget.pObj["finalPrice"] is num) ? (widget.pObj["finalPrice"] as num).toDouble() : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onPressed, // tap whole card (optional)
          child: Container(
            constraints: const BoxConstraints(minHeight: 88),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              // soft background tint so it matches your theme
              color: const Color(0xFFF6EEF2),
            ),
            child: Row(
              children: [
                // image
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 64,
                    height: 64,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Image.network(
                        widget.pObj["imageURL"] ?? '',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // text + chips
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // name
                      Text(
                        widget.pObj["productName"] ?? "Unnamed",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // chips row
                      Row(
                        children: [
                          // category chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.green.shade100),
                            ),
                            child: Text(
                              widget.pObj["category"] ?? "General",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // price pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Text(
                              "\$${finalPrice.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: TColor.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // heart button (floating circle)
                _HeartButton(
                  isActive: _isFavoriteLocal,
                  onToggle: () async {
                    await widget.onFavoriteToggle();
                    if (mounted) {
                      setState(() => _isFavoriteLocal = !_isFavoriteLocal);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeartButton extends StatelessWidget {
  final bool isActive;
  final Future<void> Function() onToggle;

  const _HeartButton({required this.isActive, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Icon(
              isActive ? Icons.favorite : Icons.favorite_border,
              key: ValueKey<bool>(isActive),
              color: isActive ? Colors.red : Colors.black45,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
