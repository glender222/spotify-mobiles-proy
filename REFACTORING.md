# Hoja de Ruta para la Refactorización a Arquitectura Limpia

El objetivo es migrar las funcionalidades pendientes a la Arquitectura Limpia para mejorar la mantenibilidad, escalabilidad y la capacidad de realizar pruebas.

---

### 🚧 Hoja de Ruta

**1. Refactorizar la Gestión de Descargas**
*   **Estado:** ¡COMPLETADO!
*   **Porqué:** Actualmente, el servicio `Downloader` (`lib/services/downloader.dart`) tiene una gran responsabilidad. Mezcla la lógica de negocio (gestión de colas, permisos) con el acceso a datos (descarga de archivos, escritura de metadatos), lo que lo hace complejo y difícil de probar.
*   **Cómo:**
    1.  **Capa de `Domain`:** Crear un `DownloadRepository` con la definición de las operaciones (ej. `downloadSong`, `getQueue`, `cancelDownload`). Luego, crear casos de uso como `DownloadSongUseCase`.
    2.  **Capa de `Data`:** Implementar el `DownloadRepository`, moviendo la lógica de descarga de bajo nivel a esta capa.
    3.  **Capa de `Presentation`:** Actualizar la UI relacionada con las descargas para que utilice los nuevos casos de uso en lugar de llamar directamente al `Downloader`.

**2. Refactorizar las Configuraciones y Preferencias**
*   **Estado:** ¡COMPLETADO!
*   **Porqué:** El `SettingsScreenController` (`lib/ui/screens/Settings/settings_screen_controller.dart`) interactúa directamente con `Hive` para leer y escribir todas las preferencias del usuario. Esto acopla fuertemente la pantalla de configuración con la implementación de la base de datos.
*   **Cómo:**
    1.  **Capa de `Domain`:** Definir un `SettingsRepository` con métodos para cada preferencia (ej. `getTheme`, `saveTheme`, `getStreamingQuality`). Crear casos de uso para cada operación.
    2.  **Capa de `Data`:** Implementar el repositorio, que será el único responsable de interactuar con `Hive`.
    3.  **Capa de `Presentation`:** Modificar el `SettingsScreenController` para que obtenga y guarde las configuraciones a través de los nuevos casos de uso.

**3. Refactorizar el Sistema de Recomendaciones**
*   **Estado:** ¡COMPLETADO!
*   **Porqué:** Como se menciona en `REFACTORING.md`, aunque la carga de recomendaciones en la pantalla de inicio ya usa un caso de uso, el servicio subyacente (`RecommendationService`) todavía tiene lógica que podría ser abstraída.
*   **Cómo:**
    1.  **Capa de `Domain`:** Asegurarse de que el `RecommendationRepository` (o el `HomeRepository` si se decide unificar) defina un contrato claro para obtener recomendaciones.
    2.  **Capa de `Data`:** Mover la lógica de `RecommendationService` a la implementación del repositorio, asegurando que las fuentes de datos estén completamente aisladas.
    3.  **Revisión Final:** Confirmar que ninguna parte de la UI dependa del `RecommendationService` directamente.

**4. (Opcional) Añadir Pruebas Unitarias**
*   **Estado:** PENDIENTE.
*   **Porqué:** Ahora que la lógica de negocio está aislada en casos de uso, es mucho más fácil crear pruebas unitarias para validar su comportamiento sin depender de la UI o de servicios externos.
*   **Cómo:** Crear archivos de prueba para los nuevos casos de uso (ej. `get_search_suggestions_usecase_test.dart`) para verificar que funcionan como se espera.

---

### ✅ Funcionalidades Completamente Modernizadas

1.  **Búsqueda:**
    *   **Estado:** ¡COMPLETADO!
    *   **Descripción:** Toda la funcionalidad relacionada con la búsqueda de música (sugerencias y resultados).

2.  **Gestión de Playlists:**
    *   **Estado:** ¡COMPLETADO!
    *   **Descripción:** Toda la lógica de las playlists, incluyendo visualización, guardado, edición y exportación.

3.  **Pantalla de Inicio:**
    *   **Estado:** ¡COMPLETADO!
    *   **Descripción:** Toda la lógica de negocio para la carga de contenido (local, de red, caché y "Quick Picks") ha sido refactorizada.
