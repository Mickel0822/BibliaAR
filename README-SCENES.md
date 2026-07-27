# Estructura Extensible para Escenas Bíblicas

La aplicación ha sido actualizada para soportar múltiples escenas bíblicas mediante una arquitectura orientada a datos (Data-Driven) utilizando **ScriptableObjects**. Esto significa que puedes agregar nuevas escenas sin necesidad de modificar el código principal.

## ¿Cómo agregar una nueva escena?

1. **Crear el Asset de la Escena (ScriptableObject):**
   - En el menú superior de Unity, ve a `Assets > Create > BibliaAR > Biblical Scene Data` (o haz clic derecho en la ventana Project, `Create > BibliaAR > Biblical Scene Data`).
   - Nombra el archivo con el nombre de tu escena (por ejemplo, `Scene_ArcaNoe`).

2. **Configurar el Asset:**
   - Selecciona el archivo creado. En el Inspector verás la configuración de la escena.
   - **Scene Id / Name:** Completa la información básica.
   - **Scene Prefab:** Arrastra el modelo 3D o Prefab que contiene el escenario y los personajes.
   - **Full Narration Audio:** (Opcional) Si la narración completa de la escena es un solo archivo de audio, colócalo aquí.

3. **Agregar las Fases de la Historia (Phases):**
   - En la sección `Phases`, añade un nuevo elemento pulsando el botón `+`.
   - Por cada fase (o párrafo de la historia), configura:
     - **Subtitle Text:** El texto que aparecerá en pantalla.
     - **Duration:** Cuánto durará esta fase en segundos (útil para la temporización).
     - **Phase Audio:** (Opcional) Si el audio está troceado, coloca aquí el audio específico de esta fase.
     - **Pictogram / Lse Video:** Configura el sprite del pictograma y el video de Lengua de Señas.
     - **Animation State Name:** El nombre del *Trigger* que se activará en el `Animator` de los personajes en esta fase (por ejemplo: `"Walk"`, `"Pray"`, etc.).

4. **Configurar la Escena en Unity:**
   - En tu escena principal de Unity (donde esté el controlador AR), asegúrate de tener un GameObject con el script `SceneDataLoader`.
   - Arrastra el Asset (`ScriptableObject`) que acabas de crear a la variable **Scene Data** del `SceneDataLoader`.

¡Listo! `StoryFlowController` detectará automáticamente el `SceneDataLoader` y utilizará la configuración, audios, tiempos y subtítulos de tu nuevo archivo, enviando los comandos de animación al modelo 3D sin modificar una sola línea de código.

## Nota de Compatibilidad
El sistema cuenta con un modo de compatibilidad (Modo Legado). Si a `SceneDataLoader` no se le asigna ningún `Scene Data` (o si se desactiva), la aplicación seguirá reproduciendo la secuencia hardcodeada original de "El Buen Samaritano".
