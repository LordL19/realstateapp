import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/theme.dart';

class PriceBlock extends StatelessWidget {
  final double price;
  const PriceBlock({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$');

    // Stub de cuota mensual: 30 años, 7 % → (no preciso)
    final monthly = currency.format(price * 0.007 / 12);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl, AppSpacing.l, AppSpacing.xxl, AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(currency.format(price),
              style: tt.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xs),
          Text('Est. $monthly / mes', style: tt.labelLarge),
          const SizedBox(height: AppSpacing.m),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
            child: const Text('Get pre-approved'),
          ),
        ],
      ),
    );
  }
}
