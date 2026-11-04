import 'dart:io';

import 'package:fieldtech_mobile/data/database_helper.dart';
import 'package:fieldtech_mobile/models/sync_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Crea una fila de prueba con los mismos campos que guarda el formulario
Map<String, dynamic> buildRow(String title) {
  return {
    'titulo': title,
    'descripcion': 'Descripcion de prueba',
    'categoria': 'INFRAESTRUCTURA',
    'latitud': 9.9322,
    'longitud': -84.0795,
    'foto_path': null,
    'is_synced': 0,
    'fecha_creacion': DateTime.now().toIso8601String(),
  };
}

void main() {
  final db = DatabaseHelper.instance;

  setUpAll(() async {
    // SQLite de escritorio para correr las pruebas sin emulador
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final tempDir = Directory.systemTemp.createTempSync('fieldtech_db_test');
    await databaseFactory.setDatabasesPath(tempDir.path);

    // 3 incidencias: la segunda se marca como sincronizada
    await db.insertar(buildRow('Poste inclinado'));
    final syncedId = await db.insertar(buildRow('Caja averiada'));
    await db.insertar(buildRow('Antena desalineada'));
    await db.marcarSincronizado(syncedId);
  });

  test('All filter returns every incident, newest first', () async {
    final rows = await db.getByFilter(SyncFilter.all);

    expect(rows, hasLength(3));
    expect(rows.first['titulo'], 'Antena desalineada');
  });

  test('Pending filter returns only rows with is_synced = 0', () async {
    final rows = await db.getByFilter(SyncFilter.pending);

    expect(rows, hasLength(2));
    expect(rows.every((row) => row['is_synced'] == 0), isTrue);
  });

  test('Synced filter returns only rows with is_synced = 1', () async {
    final rows = await db.getByFilter(SyncFilter.synced);

    expect(rows, hasLength(1));
    expect(rows.single['titulo'], 'Caja averiada');
  });

  test('Pending queue used by SyncService matches the Offline filter', () async {
    final pending = await db.obtenerPendientes();

    expect(pending, hasLength(2));
  });
}
