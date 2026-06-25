#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

// kguanoluisa, Ventana de guia con validaciones de entorno BIAR-15, variables v_pasos v_scroll y v_mensajeValidacion, 2026-06-25
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
    private string v_mensajeValidacion = string.Empty;

    [MenuItem("Tools/AR Samaritano/Guia de Instalacion")]
    public static void ShowWindow()
    {
        GetWindow<InstallGuideWindow>("Guia de Instalacion");
    }

    private void OnGUI()
    {
        GUILayout.Label("Guia de instalacion y configuracion del entorno (BIAR-15)", EditorStyles.boldLabel);
        EditorGUILayout.HelpBox("Valide el entorno antes de compilar para Android.", MessageType.Info);

        v_scroll = EditorGUILayout.BeginScrollView(v_scroll);
        for (int v_i = 0; v_i < v_pasos.Length; v_i++)
        {
            EditorGUILayout.LabelField($"Paso {v_i + 1}", v_pasos[v_i]);
        }
        EditorGUILayout.EndScrollView();

        if (GUILayout.Button("Validar entorno"))
        {
            v_mensajeValidacion = ValidarEntornoEditor();
        }

        if (!string.IsNullOrEmpty(v_mensajeValidacion))
        {
            MessageType v_tipo = v_mensajeValidacion.StartsWith("OK") ? MessageType.Info : MessageType.Warning;
            EditorGUILayout.HelpBox(v_mensajeValidacion, v_tipo);
        }
    }

    private static string ValidarEntornoEditor()
    {
        if (!Application.unityVersion.StartsWith("6000.5"))
        {
            return $"Advertencia: se recomienda Unity 6000.5.x. Detectado {Application.unityVersion}.";
        }

        return "OK: version de Unity compatible con BibliaAR.";
    }
}
#endif
