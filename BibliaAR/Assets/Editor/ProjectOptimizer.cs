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
