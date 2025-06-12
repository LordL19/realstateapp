import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:realestate_app/services/image_upload_service.dart';
import 'package:realestate_app/theme/theme.dart';
import 'package:realestate_app/utils/image_helper.dart';
import 'package:realestate_app/models/gallery_item.dart';
import 'package:realestate_app/widgets/publish_property/gallery_tile.dart';

class StepGallery extends StatefulWidget {
  final List<String> initialUrls;
  final ValueChanged<List<String>> onChanged;

  const StepGallery({
    super.key,
    required this.initialUrls,
    required this.onChanged,
  });

  @override
  State<StepGallery> createState() => _StepGalleryState();
}

class _StepGalleryState extends State<StepGallery> {
  final _upload = ImageUploadService();
  final List<GalleryItem> _items = [];
  bool _picking = false;
  static const _max = 10;

  @override
  void initState() {
    super.initState();
    // Carga inicial
    _items.addAll(widget.initialUrls.map(GalleryItem.network));
  }

  Future<void> _pick() async {
    if (_items.length >= _max) return;
    setState(() => _picking = true);

    final picked =
        await ImageHelper.pickImages(maxImages: _max - _items.length);
    for (final original in picked) {
      final img = await ImageHelper.compressFile(original);
      final item = GalleryItem.local(img ?? original);
      setState(() => _items.add(item));

      _upload.uploadImage(img ?? original).then((url) {
        if (url == null) {
          item.error = true;
        } else {
          item.remoteUrl = url;
        }
        setState(() {});
        _notifyParent();
      });
    }

    setState(() => _picking = false);
  }

  void _remove(int i) {
    setState(() => _items.removeAt(i));
    _notifyParent();
  }

  void _notifyParent() {
    widget.onChanged(_items
        .where((e) => e.remoteUrl != null)
        .map((e) => e.remoteUrl!)
        .toList());
  }

  void _preview(String url) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, anim, __) => FadeTransition(
          opacity: anim,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Center(
                child: Hero(tag: url, child: Image.network(url)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Construye la lista de widgets: tiles + botón “+”
    List<Widget> children = [
      for (int i = 0; i < _items.length; i++)
        GalleryTile(
          key: ValueKey(_items[i].key),
          item: _items[i],
          onRemove: () => _remove(i),
          onTap: _items[i].remoteUrl != null
              ? () => _preview(_items[i].remoteUrl!)
              : null,
        ),
      if (_items.length < _max)
        GestureDetector(
          key: const ValueKey('add'),
          onTap: _picking ? null : _pick,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _picking
                ? const Center(child: CircularProgressIndicator())
                : Icon(Icons.add,
                    size: 40, color: cs.primary.withValues(alpha: .8)),
          ),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl, AppSpacing.xs, AppSpacing.xxl, AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Sube y ordena tus fotos', style: tt.headlineSmall),
          const SizedBox(height: AppSpacing.m),
          ReorderableWrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                final w = children.removeAt(oldIndex);
                children.insert(newIndex, w);
                final item = _items.removeAt(oldIndex);
                _items.insert(newIndex, item);
              });
              _notifyParent();
            },
            children: children,
          ),
          if (_items.length >= _max)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s),
              child: Text('Máximo $_max imágenes',
                  style: tt.bodySmall?.copyWith(color: cs.error)),
            ),
        ],
      ),
    );
  }
}
