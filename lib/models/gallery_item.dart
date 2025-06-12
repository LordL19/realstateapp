import 'package:image_picker/image_picker.dart';

class GalleryItem {
  final String? localPath; // mientras sube
  String? remoteUrl; // final
  bool error = false;

  String get key => remoteUrl ?? localPath!;

  GalleryItem.local(XFile f) : localPath = f.path;
  GalleryItem.network(String url)
      : remoteUrl = url,
        localPath = null;
}
