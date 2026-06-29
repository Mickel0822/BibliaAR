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
