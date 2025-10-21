import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  // REEMPLAZA ESTOS VALORES CON LOS TUYOS DE CLOUDINARY
  static const String _cloudName = 'dv3dbwiqa';
  static const String _uploadPreset =
      'descubre_narino'; // Lo crearemos en Cloudinary

  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    _cloudName,
    _uploadPreset,
    cache: false,
  );

  /// Sube una imagen a Cloudinary
  /// [file] - Archivo de imagen a subir
  /// [folder] - Carpeta en Cloudinary (ej: 'events', 'users')
  /// Retorna la URL pública de la imagen
  Future<String> uploadImage({
    required File file,
    required String folder,
  }) async {
    try {
      // Subir imagen a Cloudinary
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      // Retornar URL segura de la imagen
      return response.secureUrl;
    } catch (e) {
      throw 'Error al subir imagen: $e';
    }
  }

  /// Elimina una imagen de Cloudinary
  /// [imageUrl] - URL completa de la imagen a eliminar
  /// Nota: La eliminación no es compatible con cloudinary_public. Debe usar la API de administración de Cloudinary.
  Future<void> deleteImage(String imageUrl) async {
    throw UnimplementedError(
        'La eliminación de imágenes no está soportada por cloudinary_public. Use la API de administración de Cloudinary.');
  }

  /// Obtiene una URL optimizada de la imagen
  /// [imageUrl] - URL original de la imagen
  /// [width] - Ancho deseado
  /// [height] - Alto deseado
  /// [quality] - Calidad (auto, best, good, eco, low)
  String getOptimizedUrl({
    required String imageUrl,
    int? width,
    int? height,
    String quality = 'auto',
  }) {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Buscar índice de 'upload'
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1) return imageUrl;

      // Construir transformaciones
      List<String> transformations = [];

      if (width != null) transformations.add('w_$width');
      if (height != null) transformations.add('h_$height');
      transformations.add('q_$quality');
      transformations.add('f_auto'); // Formato automático

      final transformationString = transformations.join(',');

      // Reconstruir URL con transformaciones
      final newPathSegments = List<String>.from(pathSegments);
      newPathSegments.insert(uploadIndex + 1, transformationString);

      return uri.replace(pathSegments: newPathSegments).toString();
    } catch (e) {
      // Si falla, retornar URL original
      return imageUrl;
    }
  }
}
