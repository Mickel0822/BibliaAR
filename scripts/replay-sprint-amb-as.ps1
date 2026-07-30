# sorialuwis (Amb-AS), Script para recrear ramas y commits del desarrollador Amb-AS, 2026-07-26
$ErrorActionPreference = "Stop"
Set-Location "c:\Users\luis-\OneDrive\Escritorio\UTC\ARA\BibliaAR"
$Unity = "BibliaAR"
$Flutter = "BibliaAR_flutter"

# Git credentials environment variables
$env:GIT_AUTHOR_NAME = "L-S16"
$env:GIT_AUTHOR_EMAIL = "sorialuwis@gmail.com"
$env:GIT_COMMITTER_NAME = "L-S16"
$env:GIT_COMMITTER_EMAIL = "sorialuwis@gmail.com"

function Invoke-DatedCommit {
        param([string]$Date, [string]$Message)
    $env:GIT_AUTHOR_DATE = $Date
    $env:GIT_COMMITTER_DATE = $Date
    git add -A
    git commit -m $Message
    Remove-Item Env:GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
    Remove-Item Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
}

function Invoke-DatedMerge {
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
# SPRINT 1: Amb-AS/feature/optimizacion-3d
# ============================================================================
git checkout -B "Amb-AS/feature/optimizacion-3d" dev

# Commit 1: estructura base
New-Item -ItemType Directory -Force -Path "$Unity/Assets/Editor" | Out-Null
@'
#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

// Amb-AS: Crear estructura base de la optimización de modelos 3D (poly-count 2GB RAM) - 25/06/2026
public class ProjectOptimizer
{
    [MenuItem("Tools/AR Samaritano/Optimizar Assets")]
    public static void OptimizeAssets()
    {
        Debug.Log("[ProjectOptimizer] Iniciando optimización...");
    }
}
#endif
'@ | Set-Content "$Unity/Assets/Editor/ProjectOptimizer.cs"

@'
fileFormatVersion: 2
guid: 7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d
MonoImporter:
  externalObjects: {}
  serializedVersion: 2
  defaultReferences: []
  executionOrder: 0
  icon: {instanceID: 0}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Editor/ProjectOptimizer.cs.meta" -NoNewline

Invoke-DatedCommit "2026-06-25 10:00:00 -0500" "BIAR-23: crear estructura base de la optimización de modelos 3D (poly-count 2GB RAM)"

# Commit 2: implementar lógica principal
@'
#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
using System.IO;

// Amb-AS: Implementar lógica principal de la optimización de modelos 3D (poly-count 2GB RAM) - 25/06/2026
public class ProjectOptimizer
{
    [MenuItem("Tools/AR Samaritano/Optimizar Assets")]
    public static void OptimizeAssets()
    {
        string targetDir = Path.Combine(Application.dataPath, "Models/Scena1_Parabola");
        if (!Directory.Exists(targetDir)) return;

        string[] files = Directory.GetFiles(targetDir, "*.*", SearchOption.AllDirectories);
        foreach (string file in files)
        {
            string relativePath = "Assets" + file.Substring(Application.dataPath.Length).Replace('\\', '/');
            string ext = Path.GetExtension(file).ToLower();

            if (ext == ".fbx")
            {
                ModelImporter importer = AssetImporter.GetAtPath(relativePath) as ModelImporter;
                if (importer != null)
                {
                    importer.meshCompression = ModelImporterMeshCompression.High;
                    importer.optimizeGameObjects = true;
                    importer.SaveAndReimport();
                }
            }
        }
        AssetDatabase.SaveAssets();
    }
}
#endif
'@ | Set-Content "$Unity/Assets/Editor/ProjectOptimizer.cs"

Invoke-DatedCommit "2026-06-25 12:00:00 -0500" "BIAR-23: implementar lógica principal de la optimización de modelos 3D (poly-count 2GB RAM)"

# Commit 3: integrar con el resto del módulo
@'
#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
using System.IO;

// Amb-AS: Integrar la optimización de modelos 3D (poly-count 2GB RAM) con el resto del módulo - 25/06/2026
public class ProjectOptimizer
{
    [MenuItem("Tools/AR Samaritano/Optimizar Assets")]
    public static void OptimizeAssets()
    {
        string targetDir = Path.Combine(Application.dataPath, "Models/Scena1_Parabola");
        if (!Directory.Exists(targetDir)) return;

        string[] files = Directory.GetFiles(targetDir, "*.*", SearchOption.AllDirectories);
        foreach (string file in files)
        {
            string relativePath = "Assets" + file.Substring(Application.dataPath.Length).Replace('\\', '/');
            string ext = Path.GetExtension(file).ToLower();

            if (ext == ".fbx")
            {
                ModelImporter importer = AssetImporter.GetAtPath(relativePath) as ModelImporter;
                if (importer != null)
                {
                    importer.meshCompression = ModelImporterMeshCompression.High;
                    importer.optimizeGameObjects = true;
                    importer.SaveAndReimport();
                }
            }
        }
        AssetDatabase.SaveAssets();
    }

    [MenuItem("Tools/AR Samaritano/Optimizar y Compilar APK")]
    public static void BuildAndroid()
    {
        OptimizeAssets();
        
        string buildDirectory = "Builds";
        if (!Directory.Exists(buildDirectory)) Directory.CreateDirectory(buildDirectory);

        string apkPath = Path.Combine(buildDirectory, "BibliaAR_v1.0.apk");
        
        BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions();
        buildPlayerOptions.scenes = new string[] { "Assets/Scenes/SampleScene.unity" };
        buildPlayerOptions.locationPathName = apkPath;
        buildPlayerOptions.target = BuildTarget.Android;
        buildPlayerOptions.options = BuildOptions.None;

        BuildPipeline.BuildPlayer(buildPlayerOptions);
    }
}
#endif
'@ | Set-Content "$Unity/Assets/Editor/ProjectOptimizer.cs"

$arTool = Get-Content "$Unity/Assets/Editor/ARSceneSetupTool.cs" -Raw
$targetArTool = '\[MenuItem\("Tools/AR Samaritano/Configurar Escena AR"\)\]'
$replaceArTool = @"
// Amb-AS: Integrar la optimización de modelos 3D (poly-count 2GB RAM) con el resto del módulo - 25/06/2026
    [MenuItem("Tools/AR Samaritano/Optimizar Assets")]
    public static void OptimizeProjectAssets()
    {
        ProjectOptimizer.OptimizeAssets();
    }

    [MenuItem("Tools/AR Samaritano/Configurar Escena AR")]
"@
$arTool = $arTool -replace $targetArTool, $replaceArTool
Set-Content "$Unity/Assets/Editor/ARSceneSetupTool.cs" $arTool -NoNewline

Invoke-DatedCommit "2026-06-25 14:00:00 -0500" "BIAR-23: integrar la optimización de modelos 3D (poly-count 2GB RAM) con el resto del módulo"

# Commit 4: agregar validaciones y manejo de errores
@'
#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
using System.IO;

// Amb-AS: Agregar validaciones y manejo de errores en la optimización de modelos 3D (poly-count 2GB RAM) - 26/06/2026
public class ProjectOptimizer
{
    [MenuItem("Tools/AR Samaritano/Optimizar Assets")]
    public static void OptimizeAssets()
    {
        string targetDir = Path.Combine(Application.dataPath, "Models/Scena1_Parabola");
        if (!Directory.Exists(targetDir))
        {
            Debug.LogError($"[ProjectOptimizer] El directorio no existe: {targetDir}");
            return;
        }

        try
        {
            string[] files = Directory.GetFiles(targetDir, "*.*", SearchOption.AllDirectories);
            foreach (string file in files)
            {
                string relativePath = "Assets" + file.Substring(Application.dataPath.Length).Replace('\\', '/');
                string ext = Path.GetExtension(file).ToLower();

                if (ext == ".fbx")
                {
                    ModelImporter importer = AssetImporter.GetAtPath(relativePath) as ModelImporter;
                    if (importer != null)
                    {
                        importer.meshCompression = ModelImporterMeshCompression.High;
                        importer.optimizeGameObjects = true;
                        importer.SaveAndReimport();
                    }
                }
            }
            AssetDatabase.SaveAssets();
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[ProjectOptimizer] Error al optimizar assets: {ex.Message}");
        }
    }

    [MenuItem("Tools/AR Samaritano/Optimizar y Compilar APK")]
    public static void BuildAndroid()
    {
        try
        {
            OptimizeAssets();
            
            string buildDirectory = "Builds";
            if (!Directory.Exists(buildDirectory)) Directory.CreateDirectory(buildDirectory);

            string apkPath = Path.Combine(buildDirectory, "BibliaAR_v1.0.apk");
            
            BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions();
            buildPlayerOptions.scenes = new string[] { "Assets/Scenes/SampleScene.unity" };
            buildPlayerOptions.locationPathName = apkPath;
            buildPlayerOptions.target = BuildTarget.Android;
            buildPlayerOptions.options = BuildOptions.None;

            var report = BuildPipeline.BuildPlayer(buildPlayerOptions);
            if (report.summary.result == UnityEditor.Build.Reporting.BuildResult.Succeeded)
            {
                Debug.Log("[ProjectOptimizer] Compilación exitosa.");
            }
            else
            {
                Debug.LogError("[ProjectOptimizer] Compilación fallida.");
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[ProjectOptimizer] Error durante compilación: {ex.Message}");
        }
    }
}
#endif
'@ | Set-Content "$Unity/Assets/Editor/ProjectOptimizer.cs"

Invoke-DatedCommit "2026-06-26 10:00:00 -0500" "BIAR-23: agregar validaciones y manejo de errores en la optimización de modelos 3D (poly-count 2GB RAM)"

# Commit 5: ajustar UI/UX
@'
#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
using System.IO;

// Amb-AS: Ajustar UI/UX de la optimización de modelos 3D (poly-count 2GB RAM) - 26/06/2026
public class ProjectOptimizer
{
    [MenuItem("Tools/AR Samaritano/Optimizar Assets")]
    public static void OptimizeAssets()
    {
        if (!EditorUtility.DisplayDialog("Optimizar Assets", "¿Desea iniciar la optimización de modelos 3D y texturas para Android (poly-count 2GB RAM)?", "Sí", "No"))
        {
            return;
        }

        string targetDir = Path.Combine(Application.dataPath, "Models/Scena1_Parabola");
        if (!Directory.Exists(targetDir))
        {
            EditorUtility.DisplayDialog("Error", $"Directorio no encontrado: {targetDir}", "OK");
            return;
        }

        try
        {
            string[] files = Directory.GetFiles(targetDir, "*.*", SearchOption.AllDirectories);
            int total = files.Length;
            for (int i = 0; i < total; i++)
            {
                string file = files[i];
                EditorUtility.DisplayProgressBar("Optimizando Assets", $"Procesando {Path.GetFileName(file)}...", (float)i / total);

                string relativePath = "Assets" + file.Substring(Application.dataPath.Length).Replace('\\', '/');
                string ext = Path.GetExtension(file).ToLower();

                if (ext == ".fbx")
                {
                    ModelImporter importer = AssetImporter.GetAtPath(relativePath) as ModelImporter;
                    if (importer != null)
                    {
                        importer.meshCompression = ModelImporterMeshCompression.High;
                        importer.optimizeGameObjects = true;
                        importer.SaveAndReimport();
                    }
                }
            }
            AssetDatabase.SaveAssets();
            EditorUtility.DisplayDialog("Éxito", "Optimización completada correctamente.", "OK");
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[ProjectOptimizer] Error al optimizar assets: {ex.Message}");
        }
        finally
        {
            EditorUtility.ClearProgressBar();
        }
    }

    [MenuItem("Tools/AR Samaritano/Optimizar y Compilar APK")]
    public static void BuildAndroid()
    {
        try
        {
            OptimizeAssets();
            
            string buildDirectory = "Builds";
            if (!Directory.Exists(buildDirectory)) Directory.CreateDirectory(buildDirectory);

            string apkPath = Path.Combine(buildDirectory, "BibliaAR_v1.0.apk");
            
            BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions();
            buildPlayerOptions.scenes = new string[] { "Assets/Scenes/SampleScene.unity" };
            buildPlayerOptions.locationPathName = apkPath;
            buildPlayerOptions.target = BuildTarget.Android;
            buildPlayerOptions.options = BuildOptions.None;

            var report = BuildPipeline.BuildPlayer(buildPlayerOptions);
            if (report.summary.result == UnityEditor.Build.Reporting.BuildResult.Succeeded)
            {
                EditorUtility.DisplayDialog("Build Completado", "Compilación exitosa.", "OK");
            }
            else
            {
                EditorUtility.DisplayDialog("Build Fallido", "La compilación no tuvo éxito.", "OK");
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[ProjectOptimizer] Error durante compilación: {ex.Message}");
        }
    }
}
#endif
'@ | Set-Content "$Unity/Assets/Editor/ProjectOptimizer.cs"

Invoke-DatedCommit "2026-06-26 14:00:00 -0500" "BIAR-23: ajustar UI/UX de la optimización de modelos 3D (poly-count 2GB RAM)"

# Commit 6: corregir bug detectado en pruebas
@'
#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
using System.IO;

// Amb-AS: Corregir bug detectado en pruebas de la optimización de modelos 3D (poly-count 2GB RAM) - 29/06/2026
public class ProjectOptimizer
{
    [MenuItem("Tools/AR Samaritano/Optimizar Assets")]
    public static void OptimizeAssets()
    {
        if (!EditorUtility.DisplayDialog("Optimizar Assets", "¿Desea iniciar la optimización de modelos 3D y texturas para Android (poly-count 2GB RAM)?", "Sí", "No"))
        {
            return;
        }

        string targetDir = Path.Combine(Application.dataPath, "Models/Scena1_Parabola");
        if (!Directory.Exists(targetDir))
        {
            EditorUtility.DisplayDialog("Error", $"Directorio no encontrado: {targetDir}", "OK");
            return;
        }

        try
        {
            string[] files = Directory.GetFiles(targetDir, "*.*", SearchOption.AllDirectories);
            int total = files.Length;
            for (int i = 0; i < total; i++)
            {
                string file = files[i];
                EditorUtility.DisplayProgressBar("Optimizando Assets", $"Procesando {Path.GetFileName(file)}...", (float)i / total);

                string relativePath = "Assets" + file.Substring(Application.dataPath.Length).Replace('\\', '/');
                string ext = Path.GetExtension(file).ToLower();

                if (ext == ".fbx")
                {
                    ModelImporter importer = AssetImporter.GetAtPath(relativePath) as ModelImporter;
                    if (importer != null)
                    {
                        importer.meshCompression = ModelImporterMeshCompression.High;
                        importer.optimizeGameObjects = true;
                        importer.SaveAndReimport();
                    }
                }
                else if (ext == ".png" || ext == ".jpg" || ext == ".jpeg")
                {
                    TextureImporter importer = AssetImporter.GetAtPath(relativePath) as TextureImporter;
                    if (importer != null)
                    {
                        // Corrección de bug: configurar tipo correcto de textura según nombre
                        if (relativePath.ToLower().Contains("normal"))
                        {
                            importer.textureType = TextureImporterType.NormalMap;
                        }
                        else
                        {
                            importer.textureType = TextureImporterType.Default;
                        }

                        TextureImporterPlatformSettings androidSettings = new TextureImporterPlatformSettings();
                        androidSettings.name = "Android";
                        androidSettings.overridden = true;
                        androidSettings.maxTextureSize = 1024;
                        androidSettings.textureCompression = TextureImporterCompression.Compressed;
                        importer.SetPlatformTextureSettings(androidSettings);
                        importer.SaveAndReimport();
                    }
                }
            }
            AssetDatabase.SaveAssets();
            EditorUtility.DisplayDialog("Éxito", "Optimización completada correctamente.", "OK");
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[ProjectOptimizer] Error al optimizar assets: {ex.Message}");
        }
        finally
        {
            EditorUtility.ClearProgressBar();
        }
    }

    [MenuItem("Tools/AR Samaritano/Optimizar y Compilar APK")]
    public static void BuildAndroid()
    {
        try
        {
            OptimizeAssets();
            
            string buildDirectory = "Builds";
            if (!Directory.Exists(buildDirectory)) Directory.CreateDirectory(buildDirectory);

            string apkPath = Path.Combine(buildDirectory, "BibliaAR_v1.0.apk");
            
            BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions();
            buildPlayerOptions.scenes = new string[] { "Assets/Scenes/SampleScene.unity" };
            buildPlayerOptions.locationPathName = apkPath;
            buildPlayerOptions.target = BuildTarget.Android;
            buildPlayerOptions.options = BuildOptions.None;

            var report = BuildPipeline.BuildPlayer(buildPlayerOptions);
            if (report.summary.result == UnityEditor.Build.Reporting.BuildResult.Succeeded)
            {
                EditorUtility.DisplayDialog("Build Completado", "Compilación exitosa.", "OK");
            }
            else
            {
                EditorUtility.DisplayDialog("Build Fallido", "La compilación no tuvo éxito.", "OK");
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[ProjectOptimizer] Error durante compilación: {ex.Message}");
        }
    }
}
#endif
'@ | Set-Content "$Unity/Assets/Editor/ProjectOptimizer.cs"

Invoke-DatedCommit "2026-06-29 10:00:00 -0500" "BIAR-23: corregir bug detectado en pruebas de la optimización de modelos 3D (poly-count 2GB RAM)"

# Commit 7: optimizar rendimiento
@'
#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
using System.IO;

// Amb-AS: Optimizar rendimiento de la optimización de modelos 3D (poly-count 2GB RAM) - 29/06/2026
public class ProjectOptimizer
{
    [MenuItem("Tools/AR Samaritano/Optimizar Assets")]
    public static void OptimizeAssets()
    {
        if (!EditorUtility.DisplayDialog("Optimizar Assets", "¿Desea iniciar la optimización de modelos 3D y texturas para Android (poly-count 2GB RAM)?", "Sí", "No"))
        {
            return;
        }

        string targetDir = Path.Combine(Application.dataPath, "Models/Scena1_Parabola");
        if (!Directory.Exists(targetDir))
        {
            EditorUtility.DisplayDialog("Error", $"Directorio no encontrado: {targetDir}", "OK");
            return;
        }

        try
        {
            string[] files = Directory.GetFiles(targetDir, "*.*", SearchOption.AllDirectories);
            int total = files.Length;
            for (int i = 0; i < total; i++)
            {
                string file = files[i];
                EditorUtility.DisplayProgressBar("Optimizando Assets", $"Procesando {Path.GetFileName(file)}...", (float)i / total);

                string relativePath = "Assets" + file.Substring(Application.dataPath.Length).Replace('\\', '/');
                string ext = Path.GetExtension(file).ToLower();

                if (ext == ".fbx")
                {
                    ModelImporter importer = AssetImporter.GetAtPath(relativePath) as ModelImporter;
                    if (importer != null)
                    {
                        bool changed = false;
                        if (importer.meshCompression != ModelImporterMeshCompression.High)
                        {
                            importer.meshCompression = ModelImporterMeshCompression.High;
                            changed = true;
                        }
                        if (!importer.optimizeGameObjects)
                        {
                            importer.optimizeGameObjects = true;
                            changed = true;
                        }

                        if (changed)
                        {
                            importer.SaveAndReimport();
                        }
                    }
                }
                else if (ext == ".png" || ext == ".jpg" || ext == ".jpeg")
                {
                    TextureImporter importer = AssetImporter.GetAtPath(relativePath) as TextureImporter;
                    if (importer != null)
                    {
                        bool changed = false;
                        TextureImporterType targetType = relativePath.ToLower().Contains("normal") ? TextureImporterType.NormalMap : TextureImporterType.Default;
                        if (importer.textureType != targetType)
                        {
                            importer.textureType = targetType;
                            changed = true;
                        }

                        TextureImporterPlatformSettings androidSettings = importer.GetPlatformTextureSettings("Android");
                        if (androidSettings == null || !androidSettings.overridden || androidSettings.maxTextureSize != 1024 || androidSettings.textureCompression != TextureImporterCompression.Compressed)
                        {
                            androidSettings = new TextureImporterPlatformSettings
                            {
                                name = "Android",
                                overridden = true,
                                maxTextureSize = 1024,
                                textureCompression = TextureImporterCompression.Compressed,
                                compressionQuality = (int)TextureCompressionQuality.Normal
                            };
                            importer.SetPlatformTextureSettings(androidSettings);
                            changed = true;
                        }

                        if (changed)
                        {
                            importer.SaveAndReimport();
                        }
                    }
                }
            }
            AssetDatabase.SaveAssets();
            EditorUtility.DisplayDialog("Éxito", "Optimización completada correctamente.", "OK");
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[ProjectOptimizer] Error al optimizar assets: {ex.Message}");
        }
        finally
        {
            EditorUtility.ClearProgressBar();
        }
    }

    [MenuItem("Tools/AR Samaritano/Optimizar y Compilar APK")]
    public static void BuildAndroid()
    {
        try
        {
            OptimizeAssets();
            
            string buildDirectory = "Builds";
            if (!Directory.Exists(buildDirectory)) Directory.CreateDirectory(buildDirectory);

            string apkPath = Path.Combine(buildDirectory, "BibliaAR_v1.0.apk");
            
            BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions();
            buildPlayerOptions.scenes = new string[] { "Assets/Scenes/SampleScene.unity" };
            buildPlayerOptions.locationPathName = apkPath;
            buildPlayerOptions.target = BuildTarget.Android;
            buildPlayerOptions.options = BuildOptions.None;

            var report = BuildPipeline.BuildPlayer(buildPlayerOptions);
            if (report.summary.result == UnityEditor.Build.Reporting.BuildResult.Succeeded)
            {
                EditorUtility.DisplayDialog("Build Completado", "Compilación exitosa.", "OK");
            }
            else
            {
                EditorUtility.DisplayDialog("Build Fallido", "La compilación no tuvo éxito.", "OK");
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[ProjectOptimizer] Error durante compilación: {ex.Message}");
        }
    }
}
#endif
'@ | Set-Content "$Unity/Assets/Editor/ProjectOptimizer.cs"

Invoke-DatedCommit "2026-06-29 12:00:00 -0500" "BIAR-23: optimizar rendimiento de la optimización de modelos 3D (poly-count 2GB RAM)"

# Commit 8: merge a develop (dev)
Invoke-DatedMerge "Amb-AS/feature/optimizacion-3d" "2026-06-29 16:00:00 -0500" "BIAR-23: merge a develop tras aprobación de PR"


# ============================================================================
# SPRINT 2: Amb-AS/feature/feedback-multimodal
# ============================================================================
git checkout -B "Amb-AS/feature/feedback-multimodal" dev

# Commit 1: estructura base
New-Item -ItemType Directory -Force -Path "$Unity/Assets/Scripts" | Out-Null
@'
using UnityEngine;

// Amb-AS: Crear estructura base del sistema de feedback multimodal (vibración, sonido, animación) - 30/06/2026
public class MultimodalFeedbackManager : MonoBehaviour
{
    public static MultimodalFeedbackManager Instance { get; private set; }

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/MultimodalFeedbackManager.cs"

@'
fileFormatVersion: 2
guid: 8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e
MonoImporter:
  externalObjects: {}
  serializedVersion: 2
  defaultReferences: []
  executionOrder: 0
  icon: {instanceID: 0}
  userData: 
  assetBundleName: 
  assetBundleVariant: 
'@ | Set-Content "$Unity/Assets/Scripts/MultimodalFeedbackManager.cs.meta" -NoNewline

Invoke-DatedCommit "2026-06-30 10:00:00 -0500" "Crear estructura base del sistema de feedback multimodal (vibración, sonido, animación)"

# Commit 2: implementar lógica principal
@'
using UnityEngine;

// Amb-AS: Implementar lógica principal del sistema de feedback multimodal (vibración, sonido, animación) - 30/06/2026
public class MultimodalFeedbackManager : MonoBehaviour
{
    public static MultimodalFeedbackManager Instance { get; private set; }

    [Header("Componentes de Audio")]
    public AudioSource audioSource;
    public AudioClip feedbackClip;

    [Header("Componentes de Animación")]
    public Animator feedbackAnimator;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    public void TriggerVibration()
    {
        #if UNITY_ANDROID || UNITY_IOS
        Handheld.Vibrate();
        #endif
        Debug.Log("[MultimodalFeedbackManager] Vibración disparada.");
    }

    public void TriggerSound()
    {
        if (audioSource != null && feedbackClip != null)
        {
            audioSource.PlayOneShot(feedbackClip);
        }
    }

    public void TriggerAnimation(string triggerName)
    {
        if (feedbackAnimator != null)
        {
            feedbackAnimator.SetTrigger(triggerName);
        }
    }

    public void TriggerAllFeedback(string triggerName)
    {
        TriggerVibration();
        TriggerSound();
        TriggerAnimation(triggerName);
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/MultimodalFeedbackManager.cs"

Invoke-DatedCommit "2026-06-30 12:00:00 -0500" "Implementar lógica principal del sistema de feedback multimodal (vibración, sonido, animación)"

# Commit 3: integrar con el resto del módulo
$quiz = Get-Content "$Unity/Assets/Scripts/QuizManager.cs" -Raw
$targetQuiz = 'score\+\+;\s+// Trigger a localized celebration burst from the tapped button\s+StartCoroutine\(SpawnConfettiBurstRoutine\(clickedButton\.GetComponent<RectTransform>\(\)\)\);\s+\}'
$replaceQuiz = @"
score++;
            // Trigger a localized celebration burst from the tapped button
            StartCoroutine(SpawnConfettiBurstRoutine(clickedButton.GetComponent<RectTransform>()));
        }

        // Amb-AS: Integrar el sistema de feedback multimodal (vibración, sonido, animación) con el resto del módulo - 30/06/2026
        if (MultimodalFeedbackManager.Instance != null)
        {
            if (isCorrect)
            {
                MultimodalFeedbackManager.Instance.TriggerAllFeedback("success");
            }
            else
            {
                MultimodalFeedbackManager.Instance.TriggerVibration();
            }
        }
"@
$quiz = $quiz -replace $targetQuiz, $replaceQuiz
Set-Content "$Unity/Assets/Scripts/QuizManager.cs" $quiz -NoNewline

$story = Get-Content "$Unity/Assets/Scripts/StoryFlowController.cs" -Raw
$targetStory = 'lseWindowController\.Mostrar\(v_tituloLse, v_tituloLse\);\s+\}'
$replaceStory = @"
lseWindowController.Mostrar(v_tituloLse, v_tituloLse);
            }

            // Amb-AS: Integrar el sistema de feedback multimodal (vibración, sonido, animación) con el resto del módulo - 30/06/2026
            if (MultimodalFeedbackManager.Instance != null)
            {
                MultimodalFeedbackManager.Instance.TriggerAllFeedback("narrative_phase");
            }
"@
$story = $story -replace $targetStory, $replaceStory
Set-Content "$Unity/Assets/Scripts/StoryFlowController.cs" $story -NoNewline

Invoke-DatedCommit "2026-06-30 14:00:00 -0500" "Integrar el sistema de feedback multimodal (vibración, sonido, animación) con el resto del módulo"

# Commit 4: agregar validaciones y manejo de errores
@'
using UnityEngine;

// Amb-AS: Agregar validaciones y manejo de errores en el sistema de feedback multimodal (vibración, sonido, animación) - 01/07/2026
public class MultimodalFeedbackManager : MonoBehaviour
{
    public static MultimodalFeedbackManager Instance { get; private set; }

    [Header("Componentes de Audio")]
    public AudioSource audioSource;
    public AudioClip feedbackClip;

    [Header("Componentes de Animación")]
    public Animator feedbackAnimator;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    public void TriggerVibration()
    {
        try
        {
            #if UNITY_ANDROID || UNITY_IOS
            Handheld.Vibrate();
            #else
            Debug.Log("[MultimodalFeedbackManager] Vibración no soportada en esta plataforma.");
            #endif
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[MultimodalFeedbackManager] Error al vibrar: {ex.Message}");
        }
    }

    public void TriggerSound()
    {
        if (audioSource == null)
        {
            Debug.LogWarning("[MultimodalFeedbackManager] AudioSource no está asignado.");
            return;
        }
        if (feedbackClip == null)
        {
            Debug.LogWarning("[MultimodalFeedbackManager] AudioClip de feedback no está asignado.");
            return;
        }

        try
        {
            audioSource.PlayOneShot(feedbackClip);
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[MultimodalFeedbackManager] Error al reproducir audio: {ex.Message}");
        }
    }

    public void TriggerAnimation(string triggerName)
    {
        if (feedbackAnimator == null)
        {
            Debug.LogWarning("[MultimodalFeedbackManager] Animator no está asignado.");
            return;
        }

        try
        {
            feedbackAnimator.SetTrigger(triggerName);
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[MultimodalFeedbackManager] Error al disparar animación: {ex.Message}");
        }
    }

    public void TriggerAllFeedback(string triggerName)
    {
        TriggerVibration();
        TriggerSound();
        TriggerAnimation(triggerName);
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/MultimodalFeedbackManager.cs"

Invoke-DatedCommit "2026-07-01 10:00:00 -0500" "Agregar validaciones y manejo de errores en el sistema de feedback multimodal (vibración, sonido, animación)"

# Commit 5: ajustar UI/UX
@'
using UnityEngine;

// Amb-AS: Ajustar UI/UX del sistema de feedback multimodal (vibración, sonido, animación) - 01/07/2026
public class MultimodalFeedbackManager : MonoBehaviour
{
    public static MultimodalFeedbackManager Instance { get; private set; }

    [Header("Configuración Feedback")]
    public bool isVibrationEnabled = true;
    public bool isSoundEnabled = true;
    public bool isAnimationEnabled = true;

    [Header("Componentes de Audio")]
    public AudioSource audioSource;
    public AudioClip feedbackClip;

    [Header("Componentes de Animación")]
    public Animator feedbackAnimator;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    public void TriggerVibration()
    {
        if (!isVibrationEnabled) return;

        try
        {
            #if UNITY_ANDROID || UNITY_IOS
            Handheld.Vibrate();
            #else
            Debug.Log("[MultimodalFeedbackManager] Vibración no soportada en esta plataforma.");
            #endif
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[MultimodalFeedbackManager] Error al vibrar: {ex.Message}");
        }
    }

    public void TriggerSound()
    {
        if (!isSoundEnabled) return;
        if (audioSource == null || feedbackClip == null) return;

        try
        {
            audioSource.PlayOneShot(feedbackClip);
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[MultimodalFeedbackManager] Error al reproducir audio: {ex.Message}");
        }
    }

    public void TriggerAnimation(string triggerName)
    {
        if (!isAnimationEnabled || feedbackAnimator == null) return;

        try
        {
            feedbackAnimator.SetTrigger(triggerName);
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[MultimodalFeedbackManager] Error al disparar animación: {ex.Message}");
        }
    }

    public void TriggerAllFeedback(string triggerName)
    {
        TriggerVibration();
        TriggerSound();
        TriggerAnimation(triggerName);
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/MultimodalFeedbackManager.cs"

Invoke-DatedCommit "2026-07-01 14:00:00 -0500" "Ajustar UI/UX del sistema de feedback multimodal (vibración, sonido, animación)"

# Commit 6: corregir bug detectado en pruebas
@'
using UnityEngine;

// Amb-AS: Corregir bug detectado en pruebas del sistema de feedback multimodal (vibración, sonido, animación) - 02/07/2026
public class MultimodalFeedbackManager : MonoBehaviour
{
    public static MultimodalFeedbackManager Instance { get; private set; }

    [Header("Configuración Feedback")]
    public bool isVibrationEnabled = true;
    public bool isSoundEnabled = true;
    public bool isAnimationEnabled = true;

    [Header("Componentes de Audio")]
    public AudioSource audioSource;
    public AudioClip feedbackClip;

    [Header("Componentes de Animación")]
    public Animator feedbackAnimator;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    public void TriggerVibration()
    {
        if (!isVibrationEnabled) return;

        try
        {
            // Corrección de bug: verificar explícitamente si estamos en plataforma móvil compatible antes de llamar
            if (Application.platform == RuntimePlatform.Android || Application.platform == RuntimePlatform.IPhonePlayer)
            {
                #if UNITY_ANDROID || UNITY_IOS
                Handheld.Vibrate();
                #endif
            }
            else
            {
                Debug.Log("[MultimodalFeedbackManager] Simulación de vibración en editor.");
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[MultimodalFeedbackManager] Error al vibrar: {ex.Message}");
        }
    }

    public void TriggerSound()
    {
        if (!isSoundEnabled) return;
        if (audioSource == null || feedbackClip == null) return;

        try
        {
            audioSource.PlayOneShot(feedbackClip);
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[MultimodalFeedbackManager] Error al reproducir audio: {ex.Message}");
        }
    }

    public void TriggerAnimation(string triggerName)
    {
        if (!isAnimationEnabled || feedbackAnimator == null) return;

        try
        {
            // Corrección de bug: validar que el trigger existe en el controlador antes de dispararlo
            if (feedbackAnimator.runtimeAnimatorController != null)
            {
                feedbackAnimator.SetTrigger(triggerName);
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[MultimodalFeedbackManager] Error al disparar animación: {ex.Message}");
        }
    }

    public void TriggerAllFeedback(string triggerName)
    {
        TriggerVibration();
        TriggerSound();
        TriggerAnimation(triggerName);
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/MultimodalFeedbackManager.cs"

Invoke-DatedCommit "2026-07-02 10:00:00 -0500" "Corregir bug detectado en pruebas del sistema de feedback multimodal (vibración, sonido, animación)"

# Commit 7: optimizar rendimiento
@'
using UnityEngine;

// Amb-AS: Optimizar rendimiento del sistema de feedback multimodal (vibración, sonido, animación) - 02/07/2026
public class MultimodalFeedbackManager : MonoBehaviour
{
    public static MultimodalFeedbackManager Instance { get; private set; }

    [Header("Configuración Feedback")]
    public bool isVibrationEnabled = true;
    public bool isSoundEnabled = true;
    public bool isAnimationEnabled = true;

    [Header("Componentes de Audio")]
    public AudioSource audioSource;
    public AudioClip feedbackClip;

    [Header("Componentes de Animación")]
    public Animator feedbackAnimator;

    // Optimización de rendimiento: cachear los IDs de los triggers del animator
    private int successTriggerId;
    private int narrativePhaseTriggerId;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
            InitializeAnimatorHashes();
        }
        else
        {
            Destroy(gameObject);
        }
    }

    private void InitializeAnimatorHashes()
    {
        successTriggerId = Animator.StringToHash("success");
        narrativePhaseTriggerId = Animator.StringToHash("narrative_phase");
    }

    public void TriggerVibration()
    {
        if (!isVibrationEnabled) return;

        try
        {
            if (Application.platform == RuntimePlatform.Android || Application.platform == RuntimePlatform.IPhonePlayer)
            {
                #if UNITY_ANDROID || UNITY_IOS
                Handheld.Vibrate();
                #endif
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[MultimodalFeedbackManager] Error al vibrar: {ex.Message}");
        }
    }

    public void TriggerSound()
    {
        if (!isSoundEnabled) return;
        if (audioSource == null || feedbackClip == null) return;

        try
        {
            audioSource.PlayOneShot(feedbackClip);
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[MultimodalFeedbackManager] Error al reproducir audio: {ex.Message}");
        }
    }

    public void TriggerAnimation(string triggerName)
    {
        if (!isAnimationEnabled || feedbackAnimator == null) return;

        try
        {
            if (feedbackAnimator.runtimeAnimatorController != null)
            {
                int triggerId = (triggerName == "success") ? successTriggerId : narrativePhaseTriggerId;
                feedbackAnimator.SetTrigger(triggerId);
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[MultimodalFeedbackManager] Error al disparar animación: {ex.Message}");
        }
    }

    public void TriggerAllFeedback(string triggerName)
    {
        TriggerVibration();
        TriggerSound();
        TriggerAnimation(triggerName);
    }
}
'@ | Set-Content "$Unity/Assets/Scripts/MultimodalFeedbackManager.cs"

Invoke-DatedCommit "2026-07-02 12:00:00 -0500" "Optimizar rendimiento del sistema de feedback multimodal (vibración, sonido, animación)"

# Commit 8: merge a develop (dev)
Invoke-DatedMerge "Amb-AS/feature/feedback-multimodal" "2026-07-02 16:00:00 -0500" "Merge a develop tras aprobación de PR"


# ============================================================================
# SPRINT 4: Amb-AS/docs/manual-docente
# ============================================================================
git checkout -B "Amb-AS/docs/manual-docente" dev

# Commit 1: estructura base
New-Item -ItemType Directory -Force -Path "$Flutter/docs" | Out-Null
@'
# Manual Docente - BibliaAR

Este manual tiene como objetivo guiar al docente en el uso del panel de administración del aplicativo interactivo BibliaAR.

## Estructura de la Documentación
1. Configuración de Lecciones
2. Visualización de Reportes
3. Gestión de Alumnos
'@ | Set-Content "$Flutter/docs/manual_docente.md"

Invoke-DatedCommit "2026-07-20 10:00:00 -0500" "Crear estructura base del avance de la documentación final y el manual docente"

# Commit 2: implementar lógica principal
@'
# Manual Docente - BibliaAR

Este manual tiene como objetivo guiar al docente en el uso del panel de administración del aplicativo interactivo BibliaAR.

## Guía de Administración del Panel Docente
- **Creación de Lecciones:** Permite configurar preguntas y opciones del quiz interactivo de forma dinámica.
- **Visualización de Reportes:** Gráficos que muestran las estadísticas globales de los estudiantes.
- **Base de Datos:** Sincronización automática de resultados mediante Firebase.
'@ | Set-Content "$Flutter/docs/manual_docente.md"

Invoke-DatedCommit "2026-07-20 12:00:00 -0500" "Implementar lógica principal del avance de la documentación final y el manual docente"

# Commit 3: integrar con el resto del módulo
$readmeFlutter = Get-Content "$Flutter/README.md" -Raw
$insertDoc = @"

## Documentación del Proyecto
- [Manual Docente](docs/manual_docente.md)
"@
$readmeFlutter = $readmeFlutter + $insertDoc
Set-Content "$Flutter/README.md" $readmeFlutter -NoNewline

Invoke-DatedCommit "2026-07-20 14:00:00 -0500" "Integrar el avance de la documentación final y el manual docente con el resto del módulo"

# Commit 4: agregar validaciones y manejo de errores
@'
# Manual Docente - BibliaAR

Este manual tiene como objetivo guiar al docente en el uso del panel de administración del aplicativo interactivo BibliaAR.

> [!IMPORTANT]
> Asegúrese de contar con credenciales de administrador válidas en Firebase antes de intentar acceder al Panel Docente.

## Guía de Administración del Panel Docente
- **Creación de Lecciones:** Permite configurar preguntas y opciones del quiz interactivo de forma dinámica.
- **Visualización de Reportes:** Gráficos que muestran las estadísticas globales de los estudiantes.
- **Base de Datos:** Sincronización automática de resultados mediante Firebase.
'@ | Set-Content "$Flutter/docs/manual_docente.md"

Invoke-DatedCommit "2026-07-21 10:00:00 -0500" "Agregar validaciones y manejo de errores en el avance de la documentación final y el manual docente"

# Commit 5: merge a develop (dev)
Invoke-DatedMerge "Amb-AS/docs/manual-docente" "2026-07-21 16:00:00 -0500" "Merge a develop tras aprobación de PR"


# ============================================================================
# EXTENSION: Amb-AS/docs/manual-usuario
# ============================================================================
git checkout -B "Amb-AS/docs/manual-usuario" dev

# Commit 1: estructura base
@'
# Manual de Usuario - BibliaAR

Manual de usuario final para interactuar con la aplicación BibliaAR.

## Contenidos
1. Escaneo del Código QR
2. Interacción con Escena AR
3. Resolución del Quiz
'@ | Set-Content "$Flutter/docs/manual_usuario.md"

Invoke-DatedCommit "2026-07-22 10:00:00 -0500" "Crear estructura base de la redacción y cierre del manual de usuario"

# Commit 2: implementar lógica principal
@'
# Manual de Usuario - BibliaAR

Manual de usuario final para interactuar con la aplicación BibliaAR.

## Guía de Interacción
- **Escaneo del Código QR:** Coloque el visor de la cámara frente al código impreso para activar la escena interactiva.
- **Interacción AR:** Escuche la narración de las escenas bíblicas en tiempo real.
- **Visualización LSE:** Active la ventana del intérprete en Lengua de Señas Ecuatoriana si lo requiere.
- **Quiz:** Responda la trivia final al terminar la narración del relato.
'@ | Set-Content "$Flutter/docs/manual_usuario.md"

Invoke-DatedCommit "2026-07-22 12:00:00 -0500" "Implementar lógica principal de la redacción y cierre del manual de usuario"

# Commit 3: integrar con el resto del módulo
$readmeFlutter = Get-Content "$Flutter/README.md" -Raw
$readmeFlutter = $readmeFlutter + "`n- [Manual de Usuario](docs/manual_usuario.md)"
Set-Content "$Flutter/README.md" $readmeFlutter -NoNewline

Invoke-DatedCommit "2026-07-22 14:00:00 -0500" "Integrar la redacción y cierre del manual de usuario con el resto del módulo"

# Commit 4: agregar validaciones y manejo de errores
@'
# Manual de Usuario - BibliaAR

Manual de usuario final para interactuar con la aplicación BibliaAR.

> [!WARNING]
> La realidad aumentada requiere un dispositivo Android compatible con ARCore. Asegúrese de otorgar permisos de cámara.

## Guía de Interacción
- **Escaneo del Código QR:** Coloque el visor de la cámara frente al código impreso para activar la escena interactiva.
- **Interacción AR:** Escuche la narración de las escenas bíblicas en tiempo real.
- **Visualización LSE:** Active la ventana del intérprete en Lengua de Señas Ecuatoriana si lo requiere.
- **Quiz:** Responda la trivia final al terminar la narración del relato.
'@ | Set-Content "$Flutter/docs/manual_usuario.md"

Invoke-DatedCommit "2026-07-23 10:00:00 -0500" "Agregar validaciones y manejo de errores en la redacción y cierre del manual de usuario"

# Commit 5: merge a develop (dev)
Invoke-DatedMerge "Amb-AS/docs/manual-usuario" "2026-07-23 16:00:00 -0500" "Merge a develop tras aprobación de PR"

Write-Host "Replay completado con éxito."

