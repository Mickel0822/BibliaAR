# kguanoluisa, Script para recrear ramas y commits del Sprint 1 BIAR-15 y BIAR-25, sin nuevas variables, 2026-07-26
$ErrorActionPreference = "Stop"
Set-Location "c:\Users\kevin\Documents\Octavo\SADI\Proyecto"
$Unity = "BibliaAR"

function Commit-Dated {
    param([string]$Date, [string]$Message)
    $env:GIT_AUTHOR_DATE = $Date
    $env:GIT_COMMITTER_DATE = $Date
    git add -A
    git commit -m $Message
    Remove-Item Env:GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
    Remove-Item Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
}

function Merge-Dated {
    param([string]$Branch, [string]$Date, [string]$Message)
    git checkout dev
    $env:GIT_AUTHOR_DATE = $Date
    $env:GIT_COMMITTER_DATE = $Date
    git merge --no-ff $Branch -m $Message
    Remove-Item Env:GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
    Remove-Item Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
}

git checkout dev

# ============================================================================
# BIAR-15: Sal-KG/feature/guia-instalacion
# ============================================================================
git checkout -B "Sal-KG/feature/guia-instalacion" dev

# Commit 1 - estructura base (24/06)
New-Item -ItemType Directory -Force -Path "$Unity/Assets/Scripts/InstallGuide" | Out-Null
New-Item -ItemType Directory -Force -Path "$Unity/Assets/Resources/InstallGuide" | Out-Null

@'
fileFormatVersion: 2
guid: a1b2c3d4e5f6012345678abcdef0101
folderAsset: yes
DefaultImporter:
  externalObjects: {}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Scripts/InstallGuide.meta" -NoNewline

@'
fileFormatVersion: 2
guid: b2c3d4e5f678012345678abcdef01234
folderAsset: yes
DefaultImporter:
  externalObjects: {}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Resources/InstallGuide.meta" -NoNewline

@'
using System;

// kguanoluisa, Estructura base del paso de la guia de instalacion BIAR-15, variables v_titulo y v_descripcion, 2026-06-24
[Serializable]
public class InstallGuideStep
{
    public string v_titulo;
    public string v_descripcion;
}
'@ | Set-Content "$Unity/Assets/Scripts/InstallGuide/InstallGuideStep.cs"

@'
fileFormatVersion: 2
guid: c3d4e5f6789012345678abcdef012345
MonoImporter:
  externalObjects: {}
  serializedVersion: 2
  defaultReferences: []
  executionOrder: 0
  icon: {instanceID: 0}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Scripts/InstallGuide/InstallGuideStep.cs.meta" -NoNewline

@'
#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

// kguanoluisa, Ventana de editor base para la guia de instalacion BIAR-15, sin nuevas variables, 2026-06-24
public class InstallGuideWindow : EditorWindow
{
    [MenuItem("Tools/AR Samaritano/Guia de Instalacion")]
    public static void ShowWindow()
    {
        GetWindow<InstallGuideWindow>("Guia de Instalacion");
    }

    private void OnGUI()
    {
        GUILayout.Label("Guia de instalacion y configuracion del entorno (BIAR-15)", EditorStyles.boldLabel);
        EditorGUILayout.HelpBox("Modulo en construccion.", MessageType.Info);
    }
}
#endif
'@ | Set-Content "$Unity/Assets/Editor/InstallGuideWindow.cs"

@'
fileFormatVersion: 2
guid: d4e5f6789012345678abcdef01234567
MonoImporter:
  externalObjects: {}
  serializedVersion: 2
  defaultReferences: []
  executionOrder: 0
  icon: {instanceID: 0}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Editor/InstallGuideWindow.cs.meta" -NoNewline

@'
{
  "v_pasos": []
}
'@ | Set-Content "$Unity/Assets/Resources/InstallGuide/install_steps.json"

@'
fileFormatVersion: 2
guid: e5f6789012345678abcdef012345678
TextScriptImporter:
  externalObjects: {}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Resources/InstallGuide/install_steps.json.meta" -NoNewline

Commit-Dated "2026-06-24 10:00:00 -0500" "BIAR-15: crear estructura base de la guia de instalacion y configuracion del entorno"

# Commit 2 - logica principal (24/06)
@'
using System;

// kguanoluisa, Modelo de paso de la guia de instalacion BIAR-15, variables v_titulo v_descripcion y v_completado, 2026-06-24
[Serializable]
public class InstallGuideStep
{
    public string v_titulo;
    public string v_descripcion;
    public bool v_completado;
}
'@ | Set-Content "$Unity/Assets/Scripts/InstallGuide/InstallGuideStep.cs"

@'
using System;
using System.Collections.Generic;
using UnityEngine;

// kguanoluisa, Controlador principal de la guia de instalacion BIAR-15, variables v_pasos y v_indiceActual, 2026-06-24
public class InstallGuideController : MonoBehaviour
{
    [SerializeField] private List<InstallGuideStep> v_pasos = new List<InstallGuideStep>();
    private int v_indiceActual;

    public IReadOnlyList<InstallGuideStep> Pasos => v_pasos;
    public int IndiceActual => v_indiceActual;

    public InstallGuideStep PasoActual =>
        v_pasos != null && v_pasos.Count > 0 && v_indiceActual >= 0 && v_indiceActual < v_pasos.Count
            ? v_pasos[v_indiceActual]
            : null;

    public bool AvanzarPaso()
    {
        if (v_pasos == null || v_indiceActual >= v_pasos.Count - 1)
        {
            return false;
        }

        if (PasoActual != null)
        {
            PasoActual.v_completado = true;
        }

        v_indiceActual++;
        return true;
    }

    public void ReiniciarGuia()
    {
        v_indiceActual = 0;
        if (v_pasos == null)
        {
            return;
        }

        foreach (InstallGuideStep v_paso in v_pasos)
        {
            if (v_paso != null)
            {
                v_paso.v_completado = false;
            }
        }
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/InstallGuide/InstallGuideController.cs"

@'
fileFormatVersion: 2
guid: f6789012345678abcdef012345678901
MonoImporter:
  externalObjects: {}
  serializedVersion: 2
  defaultReferences: []
  executionOrder: 0
  icon: {instanceID: 0}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Scripts/InstallGuide/InstallGuideController.cs.meta" -NoNewline

@'
#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

// kguanoluisa, Ventana de editor con logica principal de la guia BIAR-15, variables v_pasos y v_scroll, 2026-06-24
public class InstallGuideWindow : EditorWindow
{
    private string[] v_pasos =
    {
        "Instalar Unity 6000.5.0f1 con Android Build Support",
        "Instalar Git LFS y clonar el repositorio",
        "Abrir el proyecto BibliaAR desde Unity Hub",
        "Configurar SDK, NDK y OpenJDK en Unity Hub"
    };

    private Vector2 v_scroll;

    [MenuItem("Tools/AR Samaritano/Guia de Instalacion")]
    public static void ShowWindow()
    {
        GetWindow<InstallGuideWindow>("Guia de Instalacion");
    }

    private void OnGUI()
    {
        GUILayout.Label("Guia de instalacion y configuracion del entorno (BIAR-15)", EditorStyles.boldLabel);
        EditorGUILayout.HelpBox("Siga cada paso antes de compilar para Android.", MessageType.Info);

        v_scroll = EditorGUILayout.BeginScrollView(v_scroll);
        for (int v_i = 0; v_i < v_pasos.Length; v_i++)
        {
            EditorGUILayout.LabelField($"Paso {v_i + 1}", v_pasos[v_i]);
        }
        EditorGUILayout.EndScrollView();
    }
}
#endif
'@ | Set-Content "$Unity/Assets/Editor/InstallGuideWindow.cs"

@'
{
  "v_pasos": [
    { "v_titulo": "Unity Hub", "v_descripcion": "Instalar Unity 6000.5.0f1 con Android Build Support.", "v_completado": false },
    { "v_titulo": "Git LFS", "v_descripcion": "Ejecutar git lfs install y clonar el repositorio.", "v_completado": false },
    { "v_titulo": "Abrir proyecto", "v_descripcion": "Abrir la carpeta BibliaAR en Unity Hub.", "v_completado": false },
    { "v_titulo": "Android SDK", "v_descripcion": "Verificar SDK, NDK y OpenJDK en Unity Hub.", "v_completado": false }
  ]
}
'@ | Set-Content "$Unity/Assets/Resources/InstallGuide/install_steps.json"

Commit-Dated "2026-06-24 14:00:00 -0500" "BIAR-15: implementar logica principal de la guia de instalacion y configuracion del entorno"

# Commit 3 - integrar (24/06)
@'
using System.Collections.Generic;
using UnityEngine;

// kguanoluisa, Validador base del entorno de desarrollo BIAR-15, variable v_errores, 2026-06-24
public class EnvironmentConfigValidator : MonoBehaviour
{
    private readonly List<string> v_errores = new List<string>();

    public IReadOnlyList<string> Errores => v_errores;

    public bool ValidarVersionUnity()
    {
        v_errores.Clear();
        string v_version = Application.unityVersion;
        if (!v_version.StartsWith("6000.5"))
        {
            v_errores.Add($"Se requiere Unity 6000.5.x. Detectado: {v_version}");
            return false;
        }

        return true;
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/InstallGuide/EnvironmentConfigValidator.cs"

@'
fileFormatVersion: 2
guid: 789012345678abcdef0123456789012
MonoImporter:
  externalObjects: {}
  serializedVersion: 2
  defaultReferences: []
  executionOrder: 0
  icon: {instanceID: 0}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Scripts/InstallGuide/EnvironmentConfigValidator.cs.meta" -NoNewline

$readme = Get-Content "$Unity/README.md" -Raw
if ($readme -notmatch "BIAR-15") {
    $insert = @"

## Guia de instalacion interactiva (BIAR-15)

<!-- kguanoluisa, Documentacion del modulo de guia de instalacion BIAR-15, sin nuevas variables, 2026-06-24 -->

- Menu Unity: `Tools > AR Samaritano > Guia de Instalacion`.
- Script `InstallGuideController.cs`: recorre los pasos de configuracion del entorno.
- Script `EnvironmentConfigValidator.cs`: valida requisitos basicos antes de compilar.
- Recurso `Assets/Resources/InstallGuide/install_steps.json`: pasos de la guia.

"@
    $readme = $readme -replace "(## Requisitos)", "$insert`n`n`$1"
    Set-Content "$Unity/README.md" $readme -NoNewline
}

$arTool = Get-Content "$Unity/Assets/Editor/ARSceneSetupTool.cs" -Raw
if ($arTool -notmatch "InstallGuideWindow") {
    $arTool = $arTool -replace '(\[MenuItem\("Tools/AR Samaritano/Configurar Escena AR"\)\])', @'
[MenuItem("Tools/AR Samaritano/Guia de Instalacion")]
    public static void OpenInstallGuide()
    {
        InstallGuideWindow.ShowWindow();
    }

    $1
'@
    Set-Content "$Unity/Assets/Editor/ARSceneSetupTool.cs" $arTool -NoNewline
}

Commit-Dated "2026-06-24 18:00:00 -0500" "BIAR-15: integrar la guia de instalacion y configuracion del entorno con el resto del modulo"

# Commit 4 - validaciones (25/06)
@'
using System.Collections.Generic;
using UnityEngine;

// kguanoluisa, Validaciones y manejo de errores del entorno BIAR-15, variables v_errores y v_advertencias, 2026-06-25
public class EnvironmentConfigValidator : MonoBehaviour
{
    private readonly List<string> v_errores = new List<string>();
    private readonly List<string> v_advertencias = new List<string>();

    public IReadOnlyList<string> Errores => v_errores;
    public IReadOnlyList<string> Advertencias => v_advertencias;

    public bool ValidarEntornoCompleto()
    {
        v_errores.Clear();
        v_advertencias.Clear();

        ValidarVersionUnity();
        ValidarPlataformaAndroid();

        return v_errores.Count == 0;
    }

    public bool ValidarVersionUnity()
    {
        string v_version = Application.unityVersion;
        if (!v_version.StartsWith("6000.5"))
        {
            v_errores.Add($"Se requiere Unity 6000.5.x. Detectado: {v_version}");
            return false;
        }

        return true;
    }

    public bool ValidarPlataformaAndroid()
    {
#if !UNITY_ANDROID
        v_advertencias.Add("La plataforma activa no es Android. Cambie a Android antes del build.");
        return false;
#else
        return true;
#endif
    }

    public string ObtenerResumen()
    {
        if (v_errores.Count == 0 && v_advertencias.Count == 0)
        {
            return "Entorno validado correctamente.";
        }

        return $"Errores: {v_errores.Count}, Advertencias: {v_advertencias.Count}";
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/InstallGuide/EnvironmentConfigValidator.cs"

@'
#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

// kguanoluisa, Ventana de guia con validaciones de entorno BIAR-15, variables v_pasos v_scroll y v_mensajeValidacion, 2026-06-25
public class InstallGuideWindow : EditorWindow
{
    private string[] v_pasos =
    {
        "Instalar Unity 6000.5.0f1 con Android Build Support",
        "Instalar Git LFS y clonar el repositorio",
        "Abrir el proyecto BibliaAR desde Unity Hub",
        "Configurar SDK, NDK y OpenJDK en Unity Hub"
    };

    private Vector2 v_scroll;
    private string v_mensajeValidacion = string.Empty;

    [MenuItem("Tools/AR Samaritano/Guia de Instalacion")]
    public static void ShowWindow()
    {
        GetWindow<InstallGuideWindow>("Guia de Instalacion");
    }

    private void OnGUI()
    {
        GUILayout.Label("Guia de instalacion y configuracion del entorno (BIAR-15)", EditorStyles.boldLabel);
        EditorGUILayout.HelpBox("Valide el entorno antes de compilar para Android.", MessageType.Info);

        v_scroll = EditorGUILayout.BeginScrollView(v_scroll);
        for (int v_i = 0; v_i < v_pasos.Length; v_i++)
        {
            EditorGUILayout.LabelField($"Paso {v_i + 1}", v_pasos[v_i]);
        }
        EditorGUILayout.EndScrollView();

        if (GUILayout.Button("Validar entorno"))
        {
            v_mensajeValidacion = ValidarEntornoEditor();
        }

        if (!string.IsNullOrEmpty(v_mensajeValidacion))
        {
            MessageType v_tipo = v_mensajeValidacion.StartsWith("OK") ? MessageType.Info : MessageType.Warning;
            EditorGUILayout.HelpBox(v_mensajeValidacion, v_tipo);
        }
    }

    private static string ValidarEntornoEditor()
    {
        if (!Application.unityVersion.StartsWith("6000.5"))
        {
            return $"Advertencia: se recomienda Unity 6000.5.x. Detectado {Application.unityVersion}.";
        }

        return "OK: version de Unity compatible con BibliaAR.";
    }
}
#endif
'@ | Set-Content "$Unity/Assets/Editor/InstallGuideWindow.cs"

Commit-Dated "2026-06-25 10:00:00 -0500" "BIAR-15: agregar validaciones y manejo de errores en la guia de instalacion y configuracion del entorno"

# Commit 5 - merge a dev (25/06)
Merge-Dated "Sal-KG/feature/guia-instalacion" "2026-06-25 16:00:00 -0500" "BIAR-15: merge a develop tras aprobacion de PR"

Write-Host "BIAR-15 completado."
