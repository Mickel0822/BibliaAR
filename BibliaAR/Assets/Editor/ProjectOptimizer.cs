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
