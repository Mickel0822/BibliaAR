using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

/// <summary>
/// Responsable: Teniente.
/// Controla la visualización de los personajes en Realidad Aumentada según el
/// estado de seguimiento del código QR (ARTrackedImageManager).
///
/// Requiere que el GameObject que tiene este script también tenga el
/// componente ARTrackedImageManager, con:
///   - referenceLibrary = librería que contiene la imagen del QR.
///   - trackedImagePrefab = prefab "EscenaSamaritano" (Samaritano, HombreHerido, Asno).
/// </summary>
[RequireComponent(typeof(ARTrackedImageManager))]
public class ImageTrackingController : MonoBehaviour
{
    [Tooltip("Si es true, se imprime en consola cada cambio de estado del QR (útil para depurar en el equipo de Teniente).")]
    [SerializeField] private bool logDebugInfo = true;

    private ARTrackedImageManager trackedImageManager;

    private void Awake()
    {
        trackedImageManager = GetComponent<ARTrackedImageManager>();
    }

    private void OnEnable()
    {
        trackedImageManager.trackedImagesChanged += OnTrackedImagesChanged;
    }

    private void OnDisable()
    {
        trackedImageManager.trackedImagesChanged -= OnTrackedImagesChanged;
    }

    private void OnTrackedImagesChanged(ARTrackedImagesChangedEventArgs args)
    {
        // QR detectado por primera vez: AR Foundation ya instanció el prefab
        // (trackedImagePrefab) como hijo de este ARTrackedImage.
        foreach (ARTrackedImage trackedImage in args.added)
        {
            trackedImage.gameObject.SetActive(true);
            Log($"QR detectado: '{trackedImage.referenceImage.name}'. Mostrando escena.");
        }

        // QR sigue siendo trackeado en este frame: mostrar/ocultar según calidad del tracking.
        foreach (ARTrackedImage trackedImage in args.updated)
        {
            bool esVisible = trackedImage.trackingState == TrackingState.Tracking;
            trackedImage.gameObject.SetActive(esVisible);

            if (!esVisible)
            {
                Log($"QR '{trackedImage.referenceImage.name}' con tracking limitado/perdido. Ocultando escena.");
            }
        }

        // QR removido de la sesión AR.
        foreach (ARTrackedImage trackedImage in args.removed)
        {
            trackedImage.gameObject.SetActive(false);
            Log($"QR '{trackedImage.referenceImage.name}' removido. Escena ocultada.");
        }
    }

    private void Log(string mensaje)
    {
        if (logDebugInfo)
        {
            Debug.Log($"[ImageTrackingController] {mensaje}");
        }
    }
}
