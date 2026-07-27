#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
using System.IO;

public class ProjectOptimizer
{
    [MenuItem("Tools/AR Samaritano/Optimizar Assets")]
    public static void OptimizeAssets()
    {
        string targetDir = Path.Combine(Application.dataPath, "Models/Scena1_Parabola");
        if (!Directory.Exists(targetDir))
        {
            Debug.LogWarning($"[ProjectOptimizer] El directorio no existe: {targetDir}");
            return;
        }

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
                        Debug.Log($"[ProjectOptimizer] Optimizando modelo FBX: {relativePath}");
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
                    
                    // Configurar tipo de textura
                    if (relativePath.ToLower().Contains("normal"))
                    {
                        if (importer.textureType != TextureImporterType.NormalMap)
                        {
                            importer.textureType = TextureImporterType.NormalMap;
                            changed = true;
                        }
                    }
                    else
                    {
                        if (importer.textureType != TextureImporterType.Default)
                        {
                            importer.textureType = TextureImporterType.Default;
                            changed = true;
                        }
                    }

                    // Obtener settings de Android
                    TextureImporterPlatformSettings androidSettings = importer.GetPlatformTextureSettings("Android");
                    if (androidSettings == null || !androidSettings.overridden || androidSettings.maxTextureSize != 1024 || androidSettings.textureCompression != TextureImporterCompression.Compressed)
                    {
                        androidSettings = new TextureImporterPlatformSettings();
                        androidSettings.name = "Android";
                        androidSettings.overridden = true;
                        androidSettings.maxTextureSize = 1024;
                        androidSettings.textureCompression = TextureImporterCompression.Compressed;
                        androidSettings.compressionQuality = (int)TextureCompressionQuality.Normal;
                        importer.SetPlatformTextureSettings(androidSettings);
                        changed = true;
                    }

                    if (changed)
                    {
                        Debug.Log($"[ProjectOptimizer] Optimizando textura: {relativePath}");
                        importer.SaveAndReimport();
                    }
                }
            }
        }
        
        AssetDatabase.SaveAssets();
    }

    [MenuItem("Tools/AR Samaritano/Optimizar y Compilar APK")]
    public static void BuildAndroid()
    {
        Debug.Log("[ProjectOptimizer] Iniciando optimización de assets...");
        OptimizeAssets();
        Debug.Log("[ProjectOptimizer] Optimización finalizada.");
        
        Debug.Log("[ProjectOptimizer] Configurando compilación de Android...");
        // Asegurar que la plataforma de compilación es Android
        if (EditorUserBuildSettings.activeBuildTarget != BuildTarget.Android)
        {
            Debug.Log("[ProjectOptimizer] Cambiando plataforma activa a Android...");
            EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.Android, BuildTarget.Android);
        }

        // Obtener escenas activas
        var scenesList = new System.Collections.Generic.List<string>();
        foreach (var scene in EditorBuildSettings.scenes)
        {
            if (scene.enabled)
            {
                scenesList.Add(scene.path);
            }
        }

        if (scenesList.Count == 0)
        {
            Debug.LogError("[ProjectOptimizer] No hay escenas activas en el Build Settings!");
            if (Application.isBatchMode) EditorApplication.Exit(1);
            return;
        }

        // Crear directorio de Builds
        string buildDirectory = "Builds";
        if (!Directory.Exists(buildDirectory))
        {
            Directory.CreateDirectory(buildDirectory);
        }

        string apkPath = Path.Combine(buildDirectory, "BibliaAR_v1.0.apk");
        Debug.Log($"[ProjectOptimizer] Compilando APK en: {apkPath}");

        BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions();
        buildPlayerOptions.scenes = scenesList.ToArray();
        buildPlayerOptions.locationPathName = apkPath;
        buildPlayerOptions.target = BuildTarget.Android;
        buildPlayerOptions.options = BuildOptions.None;

        var report = BuildPipeline.BuildPlayer(buildPlayerOptions);
        var summary = report.summary;

        if (summary.result == UnityEditor.Build.Reporting.BuildResult.Succeeded)
        {
            Debug.Log($"[ProjectOptimizer] Compilación exitosa! Tamaño: {summary.totalSize} bytes");
            EditorApplication.Exit(0);
        }
        else
        {
            Debug.LogError($"[ProjectOptimizer] Compilación fallida! Resultado: {summary.result}");
            EditorApplication.Exit(1);
        }
    }
}
#endif
