#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

/// <summary>
/// Responsable: Teniente.
/// Automatiza la configuración base de la escena AR:
///   1) Crea el GameObject "AR Session" si no existe.
///   2) Agrega/configura el componente ARTrackedImageManager sobre el objeto
///      que tengas seleccionado en la Jerarquía (normalmente tu "XR Origin"
///      o "AR Session Origin").
///   3) Asigna la Reference Image Library (QR) y el prefab de la escena
///      (EscenaSamaritano: Samaritano + Hombre Herido + Asno).
///
/// Uso: Tools > AR Samaritano > Configurar Escena AR
/// Pasos previos manuales (Editor GUI, no automatizables sin los assets):
///   - Tener instalado AR Foundation + Google ARCore XR Plugin.
///   - Tener creado el GameObject "XR Origin (AR)" (GameObject > XR > XR Origin (AR)).
///   - Tener creada la Reference Image Library con la imagen del QR
///     (Assets > Create > XR > Reference Image Library), con el ancho físico
///     real del QR impreso configurado en metros.
///   - Tener el prefab "EscenaSamaritano" armado con los 3 personajes.
/// </summary>
public class ARSceneSetupTool : EditorWindow
{
    private XRReferenceImageLibrary referenceLibrary;
    private GameObject arContentPrefab;

    [MenuItem("Tools/AR Samaritano/Configurar Escena AR")]
    public static void ShowWindow()
    {
        GetWindow<ARSceneSetupTool>("Configurar Escena AR");
    }

    private void OnGUI()
    {
        GUILayout.Label("Configuración de la escena AR (Teniente)", EditorStyles.boldLabel);

        EditorGUILayout.HelpBox(
            "1) Selecciona en la Jerarquía tu objeto 'XR Origin' (o 'AR Session Origin').\n" +
            "2) Asigna abajo la Reference Image Library del QR y el prefab de la escena.\n" +
            "3) Presiona 'Aplicar configuración'.",
            MessageType.Info);

        referenceLibrary = (XRReferenceImageLibrary)EditorGUILayout.ObjectField(
            "Reference Image Library (QR)", referenceLibrary, typeof(XRReferenceImageLibrary), false);

        arContentPrefab = (GameObject)EditorGUILayout.ObjectField(
            "Prefab escena (personajes)", arContentPrefab, typeof(GameObject), false);

        EditorGUILayout.Space();

        GameObject seleccionado = Selection.activeGameObject;
        EditorGUILayout.LabelField("Objeto seleccionado:", seleccionado != null ? seleccionado.name : "(ninguno)");

        EditorGUILayout.Space();

        if (GUILayout.Button("Aplicar configuración"))
        {
            Apply(seleccionado);
        }
    }

    private void Apply(GameObject target)
    {
        // 1) Asegurar AR Session.
        ARSession session = FindAnyObjectByType<ARSession>();
        if (session == null)
        {
            GameObject sessionGO = new GameObject("AR Session");
            sessionGO.AddComponent<ARSession>();
            Debug.Log("[ARSceneSetupTool] AR Session creada.");
        }

        // 2) Validar selección del XR Origin / AR Session Origin.
        if (target == null)
        {
            EditorUtility.DisplayDialog("Selecciona un objeto",
                "Selecciona en la Jerarquía el GameObject 'XR Origin' (o 'AR Session Origin') " +
                "donde se agregará el ARTrackedImageManager, y vuelve a presionar el botón.", "OK");
            return;
        }

        // 3) Agregar/obtener ARTrackedImageManager y agregar también el controlador de tracking.
        ARTrackedImageManager manager = target.GetComponent<ARTrackedImageManager>();
        if (manager == null)
        {
            manager = target.AddComponent<ARTrackedImageManager>();
            Debug.Log($"[ARSceneSetupTool] ARTrackedImageManager agregado en '{target.name}'.");
        }

        ImageTrackingController imageTrackingController = target.GetComponent<ImageTrackingController>();
        if (imageTrackingController == null)
        {
            imageTrackingController = target.AddComponent<ImageTrackingController>();
            Debug.Log($"[ARSceneSetupTool] ImageTrackingController agregado en '{target.name}'.");
        }

        // 4) Asignar librería y prefab si se proporcionaron.
        if (referenceLibrary != null)
        {
            manager.referenceLibrary = referenceLibrary;
        }
        if (arContentPrefab != null)
        {
            SerializedObject controllerObject = new SerializedObject(imageTrackingController);
            controllerObject.FindProperty("arContentPrefab").objectReferenceValue = arContentPrefab;
            controllerObject.ApplyModifiedProperties();
        }
        manager.trackedImagePrefab = null;
        manager.requestedMaxNumberOfMovingImages = 1;

        EditorUtility.SetDirty(imageTrackingController);
        EditorUtility.SetDirty(manager);
        EditorUtility.SetDirty(target);
        EditorUtility.DisplayDialog("Listo", $"ARTrackedImageManager configurado en '{target.name}'.", "OK");
    }
}
#endif
