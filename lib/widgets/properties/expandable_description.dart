// expandable_description.dart – usa readmore o manual
import 'package:flutter/material.dart';

class ExpandableDescription extends StatefulWidget {
  final String text;
  const ExpandableDescription({super.key, required this.text});
  @override
  State createState() => _S();
}

class _S extends State<ExpandableDescription> {
  bool _expanded = false;
  @override
  Widget build(BuildContext c) {
    final t = Theme.of(c).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
          _expanded
              ? widget.text
              : '${widget.text.substring(0, widget.text.length.clamp(0, 120))}…',
          style: t.bodyMedium),
      TextButton(
          onPressed: () => setState(() => _expanded = !_expanded),
          child: Text(_expanded ? 'Show less' : 'Show more'))
    ]);
  }
}
