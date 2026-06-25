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
