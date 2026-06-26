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
