import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class HeroCarousel extends StatefulWidget {
  final List<String> photos;
  final String listedBy; // «Publicado por …»
  final VoidCallback? onBack;
  final VoidCallback? onShare;
  final ValueChanged<bool>? onFavToggle;
  final bool initiallyFav;
  final double height;

  const HeroCarousel({
    super.key,
    required this.photos,
    required this.listedBy,
    this.onBack,
    this.onShare,
    this.onFavToggle,
    this.initiallyFav = false,
    this.height = 300, // altura configurable
  });

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late bool fav = widget.initiallyFav;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    /* ---------- helpers ---------- */
    Widget _circularBtn(IconData icn, VoidCallback? onTap,
            {bool toggleFav = false}) =>
        Material(
          color: cs.primaryContainer,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                toggleFav && fav ? Icons.favorite : icn,
                color: cs.primary,
              ),
            ),
          ),
        );

    /* ---------- UI ---------- */
    return SliverToBoxAdapter(
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            /* ---- imágenes ---- */
            CarouselSlider.builder(
              itemCount: widget.photos.isEmpty ? 1 : widget.photos.length,
              itemBuilder: (_, i, __) => widget.photos.isEmpty
                  ? const ColoredBox(
                      color: Colors.black12,
                      child: Center(
                          child: Icon(Icons.house_outlined,
                              size: 100, color: Colors.white30)),
                    )
                  : Image.network(widget.photos[i],
                      fit: BoxFit.cover, width: double.infinity),
              options: CarouselOptions(
                height: widget.height,
                viewportFraction: 1,
                autoPlay: widget.photos.length > 1,
                enableInfiniteScroll: widget.photos.length > 1,
              ),
            ),

            /* ---- botones top ---- */
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circularBtn(Icons.arrow_back, widget.onBack),
                  Row(
                    children: [
                      _circularBtn(Icons.favorite_border, () {
                        setState(() => fav = !fav);
                        widget.onFavToggle?.call(fav);
                      }, toggleFav: true),
                      const SizedBox(width: 8),
                      _circularBtn(
                          Icons.share,
                          widget.onShare ??
                              () {
                                if (widget.photos.isNotEmpty) {
                                  Share.share(widget.photos.first);
                                }
                              }),
                    ],
                  ),
                ],
              ),
            ),

            /* ---- footer negro translucido ---- */
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Visto',
                          style: Theme.of(context).textTheme.labelMedium),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(widget.listedBy,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: Colors.white)),
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
