#if UNITY_EDITOR
using System.IO;
using UnityEditor;
using UnityEngine;

// kguanoluisa, Ventana de empaquetado offline con validaciones y errores, variables v_packager y v_mensajeEstado, 2026-07-08
public class OfflinePackagerWindow : EditorWindow
{
    private OfflinePackager v_packager;
    private string v_rutasRecursos = "Assets/Resources/Accessibility/default_settings.json";
    private string v_mensajeEstado = string.Empty;

    [MenuItem("Tools/AR Samaritano/Empaquetado Offline")]
    public static void ShowWindow()
    {
        GetWindow<OfflinePackagerWindow>("Empaquetado Offline");
    }

    private void OnGUI()
    {
        GUILayout.Label("Empaquetado offline de recursos (BibliaAR)", EditorStyles.boldLabel);
        EditorGUILayout.HelpBox("Copia recursos seleccionados a StreamingAssets/Offline para uso sin conexion.", MessageType.Info);

        v_rutasRecursos = EditorGUILayout.TextField("Rutas (separadas por ;)", v_rutasRecursos);

        if (GUILayout.Button("Generar paquete offline"))
        {
            GenerarPaquete();
        }

        if (!string.IsNullOrEmpty(v_mensajeEstado))
        {
            MessageType v_tipo = v_mensajeEstado.StartsWith("OK") ? MessageType.Info : MessageType.Warning;
            EditorGUILayout.HelpBox(v_mensajeEstado, v_tipo);
        }
    }

    private void GenerarPaquete()
    {
        if (v_packager == null)
        {
            GameObject v_go = new GameObject("OfflinePackager_Temp");
            v_packager = v_go.AddComponent<OfflinePackager>();
        }

        string[] v_rutas = v_rutasRecursos.Split(';');
        for (int v_i = 0; v_i < v_rutas.Length; v_i++)
        {
            v_rutas[v_i] = v_rutas[v_i].Trim();
            if (!Path.IsPathRooted(v_rutas[v_i]))
            {
                v_rutas[v_i] = Path.Combine(Directory.GetCurrentDirectory(), v_rutas[v_i]);
            }
        }

        bool v_ok = v_packager.EmpaquetarRecursos(v_rutas);
        v_mensajeEstado = v_ok ? "OK: paquete offline generado." : $"Error: {v_packager.UltimoError}";

        EditorUtility.DisplayDialog("Empaquetado offline", v_mensajeEstado, "OK");
        AssetDatabase.Refresh();
    }
}
#endif
