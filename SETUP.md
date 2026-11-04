# FieldTech Móvil — Guía de ejecución y verificación

Laboratorio 15 · IF0009 Desarrollo de Software IV · UCR Recinto de Paraíso

## 1. Entorno utilizado

| Herramienta | Versión |
|---|---|
| Java (Temurin) | 25 LTS (el proyecto compila con `java.version=21`) |
| Maven | 3.9.16 |
| Spring Boot | 3.3.4 · H2 en memoria |
| Flutter / Dart | 3.47.7 / 3.13.5 |
| Emulador | Pixel 9 Pro · Android 37 |

## 2. Backend (`fieldtech-backend`)

```bash
cd fieldtech-backend
mvn spring-boot:run
```

- API: `http://localhost:8080/api/v1/incidencias`
- Consola H2: `http://localhost:8080/h2-console` (JDBC URL `jdbc:h2:mem:fieldtechdb`, usuario `sa`, sin contraseña)
- `schema.sql` y `data.sql` se ejecutan al arrancar y cargan 3 incidencias de ejemplo.

Prueba rápida desde la terminal:

```bash
curl http://localhost:8080/api/v1/incidencias
curl -X POST http://localhost:8080/api/v1/incidencias -F titulo="Prueba" -F descripcion="Desde curl" -F categoria=INFRAESTRUCTURA -F latitud=9.9322 -F longitud=-84.0795 -F tecnicoCodigo=TEC-CR-001 -F foto=@foto.jpg
```

Pruebas automáticas (3 pruebas de integración con MockMvc):

```bash
mvn test
```

## 3. App móvil (`fieldtech_mobile`)

1. Con el backend encendido, abra el emulador **Pixel 9 Pro**.
2. En el emulador abra **⋯ > Location**, escriba `9.9322` / `-84.0795` y pulse **Set Location** (el AVD no tiene GPS real).
3. Ejecute la app:

```bash
cd fieldtech_mobile
flutter run
```

La app usa `http://10.0.2.2:8080`, que en el emulador apunta al `localhost` de la PC. En un teléfono físico se debe cambiar por la IP de la PC en la misma red Wi-Fi.

Pruebas automáticas (6 pruebas con SQLite de escritorio, sin emulador):

```bash
flutter analyze
flutter test
```

## 4. Flujo de verificación manual (evidencias)

1. Pulse **Nueva Incidencia**, escriba un título, pulse **Obtener GPS** y acepte el permiso de ubicación.
2. Pulse el ícono de cámara, acepte el permiso y tome una foto.
3. Pulse **Guardar Localmente (Offline)**: la tarjeta aparece con la nube tachada y la etiqueta **Offline**.
4. Pulse el ícono de sincronizar (arriba a la derecha). Debe salir *"¡Sincronización exitosa! (1 registros enviados)."* y la tarjeta cambia a **En Servidor**.
5. Abra `http://localhost:8080/api/v1/incidencias` en el navegador: la incidencia aparece con `tecnicoCodigo` `TEC-CR-001`.
6. Reto: toque **Todas**, **Offline** y **Sincronizadas** en el filtro bajo el AppBar. La lista se recarga con `WHERE is_synced = ?`.

## 5. Problemas encontrados y solución

| Problema | Solución |
|---|---|
| `locationSettings` no existe en `geolocator 12.0.0` (error de compilación del código de la guía) | Se actualizó a `geolocator: ^13.0.0`, que sí incluye `LocationSettings` |
| Advertencias del linter: campo `_hardware` sin usar en la pantalla principal y `value` obsoleto en `DropdownButtonFormField` | Se quitó el campo sin uso y se cambió `value` por `initialValue` |
| `SocketException: Connection refused` desde el emulador | Usar `10.0.2.2` en lugar de `localhost` |
| `TimeoutException` al pulsar *Obtener GPS* | Fijar una ubicación en los controles extendidos del emulador (paso 3.2) |
