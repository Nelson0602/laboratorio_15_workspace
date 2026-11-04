// lib/models/sync_filter.dart
import 'package:flutter/material.dart';

// Opciones del filtro segmentado de incidencias con su texto e icono
enum SyncFilter {
  all('Todas', Icons.list_alt),
  pending('Offline', Icons.cloud_off),
  synced('Sincronizadas', Icons.cloud_done);

  const SyncFilter(this.label, this.icon);

  final String label;
  final IconData icon;
}
