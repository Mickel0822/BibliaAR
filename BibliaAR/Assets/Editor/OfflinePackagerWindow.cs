#if UNITY_EDITOR
using System.IO;
using UnityEditor;
using UnityEngine;

// kguanoluisa, Ventana de editor para empaquetado offline integrada al modulo, variables v_packager y v_rutasRecursos, 2026-07-07
public class OfflinePackagerWindow : EditorWindow
{
    private OfflinePackager v_packager;
    private string v_rutasRecursos = "Assets/Resources/Accessibility/default_settings.json";

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
        v_packager.Manifiesto.MarcarGenerado();

        EditorUtility.DisplayDialog("Empaquetado offline", v_ok ? "Paquete generado correctamente." : "No se empaquetaron recursos.", v_ok ? "OK" : "Advertencia");
        AssetDatabase.Refresh();
    }
}
#endif
