// lib/views/publish_property/steps/step_review.dart
import 'package:flutter/material.dart';
import 'package:realestate_app/models/review_mode.dart';
import 'package:realestate_app/theme/theme.dart';

class StepReview extends StatefulWidget {
  final ReviewData data;
  const StepReview({super.key, required this.data});

  @override
  State<StepReview> createState() => _StepReviewState();
}

class _StepReviewState extends State<StepReview> {
  int _tab = 0; // 0 = Info, 1 = Ubicación

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    /*── helper chip ──*/
    Chip _chip(IconData icn, String? txt) => Chip(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          avatar: Icon(icn, size: 16, color: cs.onPrimary),
          label: Text(txt ?? '—',
              style: tt.labelLarge?.copyWith(color: cs.onPrimary)),
          backgroundColor: cs.primary,
          side: BorderSide.none,
        );

    /*── bloque DESCRIPCIÓN + INFO ──*/
    Widget infoBody() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Info(label: 'Dirección', value: widget.data.address ?? '—'),
            _Info(label: 'Sup. construida', value: '${widget.data.built} m²'),
            const Divider(height: AppSpacing.xl),
            Text('Descripción',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.xs),
            Text(widget.data.desc, style: tt.bodyMedium),
          ],
        );

    /*── bloque MAPA ──*/
    Widget mapBody() {
      if (widget.data.latLng == null) {
        return Center(
            child: Text('No se estableció ubicación',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)));
      }
      final lat = widget.data.latLng!.latitude;
      final lng = widget.data.latLng!.longitude;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Ubicación aproximada',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.s),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/'
              '$lng,$lat,15,0/640x320'
              '?access_token=pk.eyJ1IjoiZGllZ29hcHYxMiIsImEiOiJjbWJzdGlwN2YwN3JhMmxxMHBpMTFvaW0wIn0.1GSG6G2_uKkDEqCnnnyxuQ',
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl, AppSpacing.xs, AppSpacing.xxl, AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /*── título ──*/
          Text('Revisa tu anuncio', style: tt.headlineSmall),
          const SizedBox(height: AppSpacing.l),

          /*── galería ──*/
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.data.photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s),
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(widget.data.photos[i],
                    width: 110, height: 110, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          const Divider(),

          /*── título + chips ──*/
          Text(widget.data.title,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.xs,
            children: [
              _chip(Icons.home_work_outlined, widget.data.type),
              _chip(Icons.sell_outlined, widget.data.txn),
              _chip(Icons.location_on_outlined,
                  '${widget.data.city}, ${widget.data.country}'),
            ],
          ),

          /*── métricas ──*/
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              _Metric(icon: Icons.attach_money, text: _fmtP(widget.data.price)),
              _Metric(icon: Icons.square_foot, text: '${widget.data.area} m²'),
              _Metric(
                  icon: Icons.bed_outlined, text: '${widget.data.beds} hab.'),
            ],
          ),

          /*── segmented control ──*/
          const SizedBox(height: AppSpacing.l),
          Align(
            alignment: Alignment.center,
            child: ToggleButtons(
              isSelected: [_tab == 0, _tab == 1],
              onPressed: (i) => setState(() => _tab = i),
              borderRadius: BorderRadius.circular(8),
              constraints: const BoxConstraints(minHeight: 36, minWidth: 120),
              selectedColor: cs.onPrimary,
              fillColor: cs.primary,
              color: cs.onSurface,
              children: const [
                Text('Información'),
                Text('Ubicación'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),

          /*── contenido dependiente ──*/
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _tab == 0 ? infoBody() : mapBody(),
          ),
        ],
      ),
    );
  }

  String _fmtP(double? v) => v == null ? '—' : '\$${v.toStringAsFixed(0)}';
}

/*── pequeños helpers visuales ─────────────────────────────*/
class _Info extends StatelessWidget {
  final String label, value;
  const _Info({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 130,
              child: Text(label,
                  style: tt.titleSmall!.copyWith(fontWeight: FontWeight.w600))),
          const SizedBox(width: AppSpacing.l),
          Expanded(child: Text(value, style: tt.bodyMedium)),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Metric({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.m),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(text,
              style: tt.labelLarge?.copyWith(color: cs.onPrimaryContainer)),
        ],
      ),
    );
  }
}
