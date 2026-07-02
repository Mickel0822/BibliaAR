# BibliaAR

BibliaAR es una aplicacion movil de realidad aumentada hecha en Unity para presentar una escena biblica interactiva. El flujo actual permite escanear un codigo QR, cargar una escena 3D con personajes, reproducir una narracion con subtitulos y completar un quiz al final de la actividad.

El proyecto esta pensado para Android con ARCore. Para probar la experiencia AR real se debe usar un celular compatible con ARCore; el emulador no es una prueba confiable para camara y tracking AR.

## Requisitos

<!-- BIAR-14 | Desarrollador: Tnte Bayas Cristian | Subtarea: Documentar pasos de instalacion -->

- Unity `6000.5.0f1`.
- Android Build Support instalado desde Unity Hub.
- SDK, NDK y OpenJDK instalados desde Unity Hub.
- Git.
- Git LFS.
- Celular Android compatible con ARCore.

Instalar Git LFS una sola vez:

```powershell
git lfs install
```

## Como clonar el proyecto

```powershell
git clone https://github.com/Mickel0822/BibliaAR.git
cd BibliaAR
git lfs pull
```

Despues de eso, abrir la carpeta `BibliaAR` desde Unity Hub con Unity `6000.5.0f1`.

## Estructura importante

<!-- BIAR-12 | Desarrollador: Tnte Bayas Cristian | Subtarea: Crear estructura de carpetas (Scenes, Scripts, Prefabs, Models, Audio, UI, Resources, AR, Editor) -->

- `Assets/`: escenas, scripts, modelos, prefabs, texturas y recursos del proyecto.
- `Assets/AR/`: scripts relacionados con tracking AR.
- `Assets/Scripts/`: flujo de historia y quiz.
- `Assets/Prefabs/Escena1_Samaritano.prefab`: prefab principal con los personajes de la escena.
- `Assets/Scenes/SampleScene.unity`: escena principal actual.
- `Packages/manifest.json`: paquetes instalados.
- `ProjectSettings/`: configuracion del proyecto Unity.

## Flujo actual de la aplicacion

1. El usuario abre la app.
2. La app muestra una pantalla indicando que debe escanear el codigo QR.
3. Al detectar el QR, se carga la escena AR con personajes.
4. Se muestran los controles para iniciar el relato y activar/desactivar subtitulos.
5. Al iniciar el relato, se reproducen subtitulos y/o audio si hay audio asignado.
6. Al terminar el relato, aparece el quiz.
7. Al finalizar el quiz, el boton `Cerrar` devuelve al usuario al escaneo del QR.

## Scripts principales

- `ImageTrackingController.cs`: detecta el QR con `ARTrackedImageManager` e instancia el contenido AR.
- `StoryFlowController.cs`: controla el flujo de escaneo, narracion, subtitulos y quiz.
- `QuizManager.cs`: genera y controla la interfaz del quiz.
- `ARSceneSetupTool.cs`: herramienta de editor para configurar la escena AR.

## Como probar en Android

1. Abrir el proyecto en Unity.
2. Ir a `File > Build Profiles`.
3. Seleccionar `Android`.
4. Revisar que `SampleScene` este en la lista de escenas.
5. Conectar un celular Android por USB con depuracion USB activada.
6. Seleccionar el dispositivo en `Run Device`.
7. Usar `Build And Run`.
8. En el celular, apuntar la camara al QR usado por la libreria de imagenes del proyecto.

Si detecta el QR pero no aparecen personajes, revisar la consola de Unity. El script debe mostrar mensajes como:

```text
[ImageTrackingController] QR detected
[ImageTrackingController] Instantiated AR content
[ImageTrackingController] AR content visible: True
```

## Reglas para trabajar en equipo

Antes de empezar a trabajar:

```powershell
git pull
git lfs pull
```

Para subir cambios:

```powershell
git status
git add Assets Packages ProjectSettings .gitattributes .gitignore README.md
git commit -m "Descripcion corta del cambio"
git push
```

Eviten trabajar dos personas al mismo tiempo sobre la misma escena `.unity` o el mismo prefab grande `.prefab`, porque Unity guarda esos archivos como YAML y los conflictos pueden ser dificiles de resolver.

## No subir al repositorio

Estos archivos y carpetas son generados localmente y ya estan ignorados:

- `Library/`
- `Temp/`
- `Logs/`
- `UserSettings/`
- `Build/`
- `build/`
- `.vs/`
- `.vscode/`
- `*.csproj`
- `*.sln`
- `*.slnx`
- `*.apk`
- `*.aab`
- `Assets.zip`
- `UpgradeLog.htm`

Si necesitan compartir un APK, subanlo como release de GitHub o pasenlo aparte, no como archivo dentro del repositorio.

## Git LFS

Este proyecto usa Git LFS para archivos pesados como modelos, texturas, audio, videos, fuentes, PDFs y paquetes comprimidos. Si al abrir Unity faltan texturas/modelos o aparecen archivos muy pequeños de texto en lugar de binarios reales, ejecutar:

```powershell
git lfs pull
```

## Notas del proyecto

- El proyecto usa AR Foundation `6.5.0`, ARCore `6.5.0` y ARKit `6.5.0`.
- La prioridad actual es mantener estable el flujo QR -> escena AR -> narracion/subtitulos -> quiz -> volver a escanear.
- Para validar realidad aumentada, siempre probar en celular fisico.
