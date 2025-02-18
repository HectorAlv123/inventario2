// lib/services/excel_service.dart
import 'dart:io';

class ExcelService {
  /// Genera el archivo Excel en el directorio especificado.
  /// [fileBytes]: Contenido del archivo en bytes.
  /// [directory]: Directorio donde se guardará el archivo.
  static void generarArchivoExcel(List<int>? fileBytes, Directory? directory) {
    if (directory == null) {
      throw Exception("Directorio no disponible");
    }
    if (fileBytes == null) {
      throw Exception("No se proporcionaron bytes para el archivo Excel");
    }
    directory.createSync(recursive: true);
    String filePath = "${directory.path}/Inventario_Bodegas.xlsx";
    File(filePath)
      ..writeAsBytesSync(fileBytes);
  }
}
