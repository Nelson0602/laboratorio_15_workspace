import 'dart:io';

import 'package:fieldtech_mobile/data/database_helper.dart';
import 'package:fieldtech_mobile/main.dart';
import 'package:fieldtech_mobile/models/sync_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Busca la opcion dentro del filtro (las tarjetas tambien dicen "Offline")
Finder filterOption(String label) {
  return find.descendant(
    of: find.byType(SegmentedButton<SyncFilter>),
    matching: find.text(label),
  );
}

// Espera a que SQLite responda y luego redibuja la pantalla
Future<void> waitForDatabase(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    // SQLite de escritorio para correr las pruebas sin emulador
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final tempDir = Directory.systemTemp.createTempSync('fieldtech_ui_test');
    await databaseFactory.setDatabasesPath(tempDir.path);
  });

  // El formulario no guarda si falta el titulo o el GPS
  testWidgets('Form shows validation message when title and GPS are missing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NuevaIncidenciaModal(onGuardado: () {}),
        ),
      ),
    );

    await tester.tap(find.text('Guardar Localmente (Offline)'));
    await tester.pump();

    expect(
      find.text('Debe ingresar un título y capturar las coordenadas GPS.'),
      findsOneWidget,
    );
  });

  // La lista cambia al tocar cada opcion del filtro segmentado
  testWidgets('Segmented filter refreshes the list from SQLite',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final db = DatabaseHelper.instance;
      await db.insertar({
        'titulo': 'Poste pendiente',
        'descripcion': 'Sin enviar',
        'categoria': 'INFRAESTRUCTURA',
        'latitud': 9.85,
        'longitud': -83.87,
        'is_synced': 0,
        'fecha_creacion': DateTime.now().toIso8601String(),
      });
      final syncedId = await db.insertar({
        'titulo': 'Antena enviada',
        'descripcion': 'Ya en el servidor',
        'categoria': 'TORRE_RADIO',
        'latitud': 9.84,
        'longitud': -83.86,
        'is_synced': 0,
        'fecha_creacion': DateTime.now().toIso8601String(),
      });
      await db.marcarSincronizado(syncedId);
    });

    await tester.pumpWidget(const FieldTechApp());
    await waitForDatabase(tester);

    // Todas
    expect(find.text('Poste pendiente'), findsOneWidget);
    expect(find.text('Antena enviada'), findsOneWidget);

    // Offline (Pendientes)
    await tester.tap(filterOption('Offline'));
    await waitForDatabase(tester);
    expect(find.text('Poste pendiente'), findsOneWidget);
    expect(find.text('Antena enviada'), findsNothing);

    // Sincronizadas
    await tester.tap(filterOption('Sincronizadas'));
    await waitForDatabase(tester);
    expect(find.text('Poste pendiente'), findsNothing);
    expect(find.text('Antena enviada'), findsOneWidget);
  });
}
