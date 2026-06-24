#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

// kguanoluisa, Ventana de editor base para la guia de instalacion BIAR-15, sin nuevas variables, 2026-06-24
public class InstallGuideWindow : EditorWindow
{
    [MenuItem("Tools/AR Samaritano/Guia de Instalacion")]
    public static void ShowWindow()
    {
        GetWindow<InstallGuideWindow>("Guia de Instalacion");
    }

    private void OnGUI()
    {
        GUILayout.Label("Guia de instalacion y configuracion del entorno (BIAR-15)", EditorStyles.boldLabel);
        EditorGUILayout.HelpBox("Modulo en construccion.", MessageType.Info);
    }
}
#endif
