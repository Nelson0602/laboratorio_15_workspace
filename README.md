# Laboratorio 15 · FieldTech Móvil

IF0009 Desarrollo de Software IV · UCR Recinto de Paraíso · II-2026
Estudiante: Nelson (c4i187)

Sistema de inspecciones técnicas en campo con arquitectura **Offline-First**, GPS, fotos y backend Spring Boot 3.

| Proyecto | Tecnología | Descripción |
|---|---|---|
| [`fieldtech-backend/`](fieldtech-backend) | Spring Boot 3.3.4 · Java 21 · H2 | API REST en capas (`domain`, `data`, `business`, `controller`) que recibe incidencias en `multipart/form-data` |
| [`fieldtech_mobile/`](fieldtech_mobile) | Flutter 3 · Dart 3 · sqflite | App móvil que guarda las incidencias en SQLite, captura GPS y fotos, y sincroniza con el backend |

La guía para ejecutar y probar todo está en [SETUP.md](SETUP.md).
