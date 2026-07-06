# kguanoluisa, Script Sprint 2 parte 2 - empaquetado offline, sin nuevas variables, 2026-07-26
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
git checkout -B "Sal-KG/feature/empaquetado-offline" dev

# 1 - estructura base (07/07)
New-Item -ItemType Directory -Force -Path "$Unity/Assets/Scripts/Offline" | Out-Null
New-Item -ItemType Directory -Force -Path "$Unity/Assets/Resources/Offline" | Out-Null

@'
fileFormatVersion: 2
guid: bbcc00112233445566778899001122
folderAsset: yes
DefaultImporter:
  externalObjects: {}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Scripts/Offline.meta" -NoNewline

@'
fileFormatVersion: 2
guid: bbcc00556677889900112233445566
folderAsset: yes
DefaultImporter:
  externalObjects: {}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Resources/Offline.meta" -NoNewline

@'
using System;
using System.Collections.Generic;

// kguanoluisa, Estructura base del manifiesto de empaquetado offline, variables v_version v_recursos y v_tamanoBytes, 2026-07-07
[Serializable]
public class OfflinePackageManifest
{
    public string v_version = "1.0.0";
    public List<string> v_recursos = new List<string>();
    public long v_tamanoBytes;
}
'@ | Set-Content "$Unity/Assets/Scripts/Offline/OfflinePackageManifest.cs"

@'
fileFormatVersion: 2
guid: bbcc00223344556677889900112233
MonoImporter:
  externalObjects: {}
  serializedVersion: 2
  defaultReferences: []
  executionOrder: 0
  icon: {instanceID: 0}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Scripts/Offline/OfflinePackageManifest.cs.meta" -NoNewline

@'
using UnityEngine;

// kguanoluisa, Empaquetador offline base, variable v_manifiesto, 2026-07-07
public class OfflinePackager : MonoBehaviour
{
    [SerializeField] private OfflinePackageManifest v_manifiesto = new OfflinePackageManifest();

    public OfflinePackageManifest Manifiesto => v_manifiesto;
}
'@ | Set-Content "$Unity/Assets/Scripts/Offline/OfflinePackager.cs"

@'
fileFormatVersion: 2
guid: bbcc00334455667788990011223344
MonoImporter:
  externalObjects: {}
  serializedVersion: 2
  defaultReferences: []
  executionOrder: 0
  icon: {instanceID: 0}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Scripts/Offline/OfflinePackager.cs.meta" -NoNewline

@'
{
  "v_version": "1.0.0",
  "v_recursos": [],
  "v_tamanoBytes": 0
}
'@ | Set-Content "$Unity/Assets/Resources/Offline/package_manifest.json"

@'
fileFormatVersion: 2
guid: bbcc00667788990011223344556677
TextScriptImporter:
  externalObjects: {}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Resources/Offline/package_manifest.json.meta" -NoNewline

Commit-Dated "2026-07-07 10:00:00 -0500" "Crear estructura base del empaquetado offline de la aplicacion"

# 2 - logica principal (07/07)
@'
using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

// kguanoluisa, Logica principal del empaquetado offline, variables v_rutaDestino v_manifiesto y v_extensionesPermitidas, 2026-07-07
public class OfflinePackager : MonoBehaviour
{
    [SerializeField] private OfflinePackageManifest v_manifiesto = new OfflinePackageManifest();
    [SerializeField] private string v_rutaDestino = "StreamingAssets/Offline";
    [SerializeField] private string[] v_extensionesPermitidas = { ".json", ".png", ".mp3", ".mp4", ".prefab" };

    public OfflinePackageManifest Manifiesto => v_manifiesto;

    public bool EmpaquetarRecursos(IEnumerable<string> v_rutasRecursos)
    {
        v_manifiesto.v_recursos.Clear();
        v_manifiesto.v_tamanoBytes = 0;

        string v_destinoAbsoluto = Path.Combine(Application.dataPath, v_rutaDestino);
        Directory.CreateDirectory(v_destinoAbsoluto);

        foreach (string v_ruta in v_rutasRecursos)
        {
            if (string.IsNullOrWhiteSpace(v_ruta) || !File.Exists(v_ruta))
            {
                continue;
            }

            if (!EsExtensionPermitida(v_ruta))
            {
                Debug.LogWarning($"[OfflinePackager] Extension no permitida: {v_ruta}");
                continue;
            }

            string v_nombreArchivo = Path.GetFileName(v_ruta);
            string v_destinoArchivo = Path.Combine(v_destinoAbsoluto, v_nombreArchivo);
            File.Copy(v_ruta, v_destinoArchivo, true);

            FileInfo v_info = new FileInfo(v_destinoArchivo);
            v_manifiesto.v_recursos.Add(v_nombreArchivo);
            v_manifiesto.v_tamanoBytes += v_info.Length;
        }

        return v_manifiesto.v_recursos.Count > 0;
    }

    private bool EsExtensionPermitida(string v_ruta)
    {
        string v_ext = Path.GetExtension(v_ruta).ToLowerInvariant();
        foreach (string v_permitida in v_extensionesPermitidas)
        {
            if (v_ext == v_permitida)
            {
                return true;
            }
        }

        return false;
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/Offline/OfflinePackager.cs"

@'
using System;
using System.Collections.Generic;

// kguanoluisa, Manifiesto offline con metadatos de escena, variables v_escenaPrincipal y v_fechaGeneracion, 2026-07-07
[Serializable]
public class OfflinePackageManifest
{
    public string v_version = "1.0.0";
    public string v_escenaPrincipal = "SampleScene";
    public string v_fechaGeneracion = string.Empty;
    public List<string> v_recursos = new List<string>();
    public long v_tamanoBytes;

    public void MarcarGenerado()
    {
        v_fechaGeneracion = DateTime.UtcNow.ToString("o");
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/Offline/OfflinePackageManifest.cs"

Commit-Dated "2026-07-07 14:00:00 -0500" "Implementar logica principal del empaquetado offline de la aplicacion"

# 3 - integrar (07/07)
@'
#if UNITY_EDITOR
using System.IO;
using UnityEditor;
using UnityEngine;

// kguanoluisa, Ventana de editor para empaquetado offline integrada al modulo, variables v_packager y v_rutasRecursos, 2026-07-07
public class OfflinePackagerWindow : EditorWindow
{
    private OfflinePackager v_packager;
    private string v_rutasRecursos = "Assets/Resources/Accessibility/default_settings.json";

    [MenuItem("Tools/AR Samaritano/Empaquetado Offline")]
    public static void ShowWindow()
    {
        GetWindow<OfflinePackagerWindow>("Empaquetado Offline");
    }

    private void OnGUI()
    {
        GUILayout.Label("Empaquetado offline de recursos (BibliaAR)", EditorStyles.boldLabel);
        EditorGUILayout.HelpBox("Copia recursos seleccionados a StreamingAssets/Offline para uso sin conexion.", MessageType.Info);

        v_rutasRecursos = EditorGUILayout.TextField("Rutas (separadas por ;)", v_rutasRecursos);

        if (GUILayout.Button("Generar paquete offline"))
        {
            GenerarPaquete();
        }
    }

    private void GenerarPaquete()
    {
        if (v_packager == null)
        {
            GameObject v_go = new GameObject("OfflinePackager_Temp");
            v_packager = v_go.AddComponent<OfflinePackager>();
        }

        string[] v_rutas = v_rutasRecursos.Split(';');
        for (int v_i = 0; v_i < v_rutas.Length; v_i++)
        {
            v_rutas[v_i] = v_rutas[v_i].Trim();
            if (!Path.IsPathRooted(v_rutas[v_i]))
            {
                v_rutas[v_i] = Path.Combine(Directory.GetCurrentDirectory(), v_rutas[v_i]);
            }
        }

        bool v_ok = v_packager.EmpaquetarRecursos(v_rutas);
        v_packager.Manifiesto.MarcarGenerado();

        EditorUtility.DisplayDialog("Empaquetado offline", v_ok ? "Paquete generado correctamente." : "No se empaquetaron recursos.", v_ok ? "OK" : "Advertencia");
        AssetDatabase.Refresh();
    }
}
#endif
'@ | Set-Content "$Unity/Assets/Editor/OfflinePackagerWindow.cs"

@'
fileFormatVersion: 2
guid: bbcc00445566778899001122334455
MonoImporter:
  externalObjects: {}
  serializedVersion: 2
  defaultReferences: []
  executionOrder: 0
  icon: {instanceID: 0}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Editor/OfflinePackagerWindow.cs.meta" -NoNewline

@'
{
  "v_version": "1.0.0",
  "v_escenaPrincipal": "SampleScene",
  "v_fechaGeneracion": "",
  "v_recursos": [
    "default_settings.json",
    "install_steps.json",
    "package_manifest.json"
  ],
  "v_tamanoBytes": 0
}
'@ | Set-Content "$Unity/Assets/Resources/Offline/package_manifest.json"

$readme = Get-Content "$Unity/README.md" -Raw
if ($readme -notmatch "Empaquetado offline") {
    $insert = @"

## Empaquetado offline

<!-- kguanoluisa, Documentacion del empaquetado offline de la aplicacion, sin nuevas variables, 2026-07-07 -->

- Menu Unity: `Tools > AR Samaritano > Empaquetado Offline`.
- Script `OfflinePackager.cs`: copia recursos a `StreamingAssets/Offline`.
- Script `OfflinePackageManifest.cs`: manifiesto del paquete offline.
- Recurso `Assets/Resources/Offline/package_manifest.json`: metadatos del paquete.

"@
    $readme = $readme -replace "(## Panel de accesibilidad)", "$insert`n`$1"
    Set-Content "$Unity/README.md" $readme -NoNewline
}

Commit-Dated "2026-07-07 18:00:00 -0500" "Integrar el empaquetado offline de la aplicacion con el resto del modulo"

# 4 - validaciones (08/07)
@'
using System.Collections.Generic;
using System.IO;

// kguanoluisa, Validaciones del empaquetado offline, variables v_errores y v_advertencias, 2026-07-08
public class OfflinePackageValidator
{
    private readonly List<string> v_errores = new List<string>();
    private readonly List<string> v_advertencias = new List<string>();

    public IReadOnlyList<string> Errores => v_errores;
    public IReadOnlyList<string> Advertencias => v_advertencias;

    public bool ValidarManifiesto(OfflinePackageManifest v_manifiesto)
    {
        v_errores.Clear();
        v_advertencias.Clear();

        if (v_manifiesto == null)
        {
            v_errores.Add("El manifiesto offline es nulo.");
            return false;
        }

        if (string.IsNullOrWhiteSpace(v_manifiesto.v_version))
        {
            v_errores.Add("La version del paquete offline es obligatoria.");
        }

        if (v_manifiesto.v_recursos == null || v_manifiesto.v_recursos.Count == 0)
        {
            v_advertencias.Add("El paquete offline no contiene recursos.");
        }

        return v_errores.Count == 0;
    }

    public bool ValidarRutaDestino(string v_rutaDestino)
    {
        v_errores.Clear();

        if (string.IsNullOrWhiteSpace(v_rutaDestino))
        {
            v_errores.Add("La ruta destino del paquete offline es obligatoria.");
            return false;
        }

        if (v_rutaDestino.Contains(".."))
        {
            v_errores.Add("La ruta destino no puede contener segmentos invalidos.");
            return false;
        }

        return true;
    }

    public string ObtenerResumen()
    {
        return $"Errores: {v_errores.Count}, Advertencias: {v_advertencias.Count}";
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/Offline/OfflinePackageValidator.cs"

@'
fileFormatVersion: 2
guid: bbcc00778899001122334455667788
MonoImporter:
  externalObjects: {}
  serializedVersion: 2
  defaultReferences: []
  executionOrder: 0
  icon: {instanceID: 0}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Scripts/Offline/OfflinePackageValidator.cs.meta" -NoNewline

@'
using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

// kguanoluisa, Empaquetador offline con validaciones previas, variables v_validador y v_manifiesto, 2026-07-08
public class OfflinePackager : MonoBehaviour
{
    [SerializeField] private OfflinePackageManifest v_manifiesto = new OfflinePackageManifest();
    [SerializeField] private string v_rutaDestino = "StreamingAssets/Offline";
    [SerializeField] private string[] v_extensionesPermitidas = { ".json", ".png", ".mp3", ".mp4", ".prefab" };

    private readonly OfflinePackageValidator v_validador = new OfflinePackageValidator();

    public OfflinePackageManifest Manifiesto => v_manifiesto;
    public string UltimoError { get; private set; } = string.Empty;

    public bool EmpaquetarRecursos(IEnumerable<string> v_rutasRecursos)
    {
        UltimoError = string.Empty;

        if (!v_validador.ValidarRutaDestino(v_rutaDestino))
        {
            UltimoError = string.Join("; ", v_validador.Errores);
            Debug.LogError($"[OfflinePackager] {UltimoError}");
            return false;
        }

        v_manifiesto.v_recursos.Clear();
        v_manifiesto.v_tamanoBytes = 0;

        string v_destinoAbsoluto = Path.Combine(Application.dataPath, v_rutaDestino);
        Directory.CreateDirectory(v_destinoAbsoluto);

        foreach (string v_ruta in v_rutasRecursos)
        {
            if (string.IsNullOrWhiteSpace(v_ruta))
            {
                continue;
            }

            if (!File.Exists(v_ruta))
            {
                UltimoError = $"Archivo no encontrado: {v_ruta}";
                Debug.LogWarning($"[OfflinePackager] {UltimoError}");
                continue;
            }

            if (!EsExtensionPermitida(v_ruta))
            {
                Debug.LogWarning($"[OfflinePackager] Extension no permitida: {v_ruta}");
                continue;
            }

            string v_nombreArchivo = Path.GetFileName(v_ruta);
            string v_destinoArchivo = Path.Combine(v_destinoAbsoluto, v_nombreArchivo);
            File.Copy(v_ruta, v_destinoArchivo, true);

            FileInfo v_info = new FileInfo(v_destinoArchivo);
            v_manifiesto.v_recursos.Add(v_nombreArchivo);
            v_manifiesto.v_tamanoBytes += v_info.Length;
        }

        v_manifiesto.MarcarGenerado();

        if (!v_validador.ValidarManifiesto(v_manifiesto))
        {
            UltimoError = string.Join("; ", v_validador.Errores);
            Debug.LogError($"[OfflinePackager] {UltimoError}");
            return false;
        }

        return v_manifiesto.v_recursos.Count > 0;
    }

    private bool EsExtensionPermitida(string v_ruta)
    {
        string v_ext = Path.GetExtension(v_ruta).ToLowerInvariant();
        foreach (string v_permitida in v_extensionesPermitidas)
        {
            if (v_ext == v_permitida)
            {
                return true;
            }
        }

        return false;
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/Offline/OfflinePackager.cs"

@'
#if UNITY_EDITOR
using System.IO;
using UnityEditor;
using UnityEngine;

// kguanoluisa, Ventana de empaquetado offline con validaciones y errores, variables v_packager y v_mensajeEstado, 2026-07-08
public class OfflinePackagerWindow : EditorWindow
{
    private OfflinePackager v_packager;
    private string v_rutasRecursos = "Assets/Resources/Accessibility/default_settings.json";
    private string v_mensajeEstado = string.Empty;

    [MenuItem("Tools/AR Samaritano/Empaquetado Offline")]
    public static void ShowWindow()
    {
        GetWindow<OfflinePackagerWindow>("Empaquetado Offline");
    }

    private void OnGUI()
    {
        GUILayout.Label("Empaquetado offline de recursos (BibliaAR)", EditorStyles.boldLabel);
        EditorGUILayout.HelpBox("Copia recursos seleccionados a StreamingAssets/Offline para uso sin conexion.", MessageType.Info);

        v_rutasRecursos = EditorGUILayout.TextField("Rutas (separadas por ;)", v_rutasRecursos);

        if (GUILayout.Button("Generar paquete offline"))
        {
            GenerarPaquete();
        }

        if (!string.IsNullOrEmpty(v_mensajeEstado))
        {
            MessageType v_tipo = v_mensajeEstado.StartsWith("OK") ? MessageType.Info : MessageType.Warning;
            EditorGUILayout.HelpBox(v_mensajeEstado, v_tipo);
        }
    }

    private void GenerarPaquete()
    {
        if (v_packager == null)
        {
            GameObject v_go = new GameObject("OfflinePackager_Temp");
            v_packager = v_go.AddComponent<OfflinePackager>();
        }

        string[] v_rutas = v_rutasRecursos.Split(';');
        for (int v_i = 0; v_i < v_rutas.Length; v_i++)
        {
            v_rutas[v_i] = v_rutas[v_i].Trim();
            if (!Path.IsPathRooted(v_rutas[v_i]))
            {
                v_rutas[v_i] = Path.Combine(Directory.GetCurrentDirectory(), v_rutas[v_i]);
            }
        }

        bool v_ok = v_packager.EmpaquetarRecursos(v_rutas);
        v_mensajeEstado = v_ok ? "OK: paquete offline generado." : $"Error: {v_packager.UltimoError}";

        EditorUtility.DisplayDialog("Empaquetado offline", v_mensajeEstado, "OK");
        AssetDatabase.Refresh();
    }
}
#endif
'@ | Set-Content "$Unity/Assets/Editor/OfflinePackagerWindow.cs"

Commit-Dated "2026-07-08 10:00:00 -0500" "Agregar validaciones y manejo de errores en el empaquetado offline de la aplicacion"

# 5 - merge (08/07)
Merge-Dated "Sal-KG/feature/empaquetado-offline" "2026-07-08 16:00:00 -0500" "Merge a develop tras aprobacion de PR"

Write-Host "Empaquetado offline completado."
git log --oneline --graph -15
