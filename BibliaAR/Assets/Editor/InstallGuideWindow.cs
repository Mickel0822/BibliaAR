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
