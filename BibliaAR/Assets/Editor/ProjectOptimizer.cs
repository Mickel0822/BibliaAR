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
