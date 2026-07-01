using System;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

[RequireComponent(typeof(ARTrackedImageManager))]
public class ImageTrackingController : MonoBehaviour
{
    public static event Action<ARTrackedImage> ImageDetected;
    public static event Action ImageLost;

    [Tooltip("If true, QR tracking state changes are printed in the console.")]
    [SerializeField] private bool logDebugInfo = true;

    [Tooltip("Prefab with the biblical AR scene. If empty, the ARTrackedImageManager tracked image prefab is reused as visual content.")]
    [SerializeField] private GameObject arContentPrefab;

    private ARTrackedImageManager trackedImageManager;
    private bool hasVisibleTrackedImage;
    private GameObject currentContent;

    private void Awake()
    {
        trackedImageManager = GetComponent<ARTrackedImageManager>();

        if (arContentPrefab == null && trackedImageManager.trackedImagePrefab != null)
        {
            arContentPrefab = trackedImageManager.trackedImagePrefab;
            trackedImageManager.trackedImagePrefab = null;
        }
    }

    private void OnEnable()
    {
        trackedImageManager.trackablesChanged.AddListener(OnTrackedImagesChanged);
    }

    private void OnDisable()
    {
        trackedImageManager.trackablesChanged.RemoveListener(OnTrackedImagesChanged);
    }

    private void OnTrackedImagesChanged(ARTrackablesChangedEventArgs<ARTrackedImage> args)
    {
        foreach (ARTrackedImage trackedImage in args.added)
        {
            ShowContentFor(trackedImage);
            NotifyDetected(trackedImage);
            Log($"QR detected: '{trackedImage.referenceImage.name}'. Showing AR scene.");
        }

        foreach (ARTrackedImage trackedImage in args.updated)
        {
            bool isVisible = trackedImage.trackingState == TrackingState.Tracking;

            if (isVisible)
            {
                ShowContentFor(trackedImage);
                NotifyDetected(trackedImage);
            }
            else
            {
                SetCurrentContentVisible(false);
                NotifyLost();
                Log($"QR '{trackedImage.referenceImage.name}' tracking is limited or lost. Hiding AR scene.");
            }
        }

        foreach (var removedImage in args.removed)
        {
            ARTrackedImage trackedImage = removedImage.Value;
            if (trackedImage == null)
            {
                continue;
            }

            SetCurrentContentVisible(false);
            NotifyLost();
            Log($"QR '{trackedImage.referenceImage.name}' removed. AR scene hidden.");
        }
    }

    private void ShowContentFor(ARTrackedImage trackedImage)
    {
        if (trackedImage == null)
        {
            return;
        }

        if (currentContent == null)
        {
            if (arContentPrefab == null)
            {
                Log("No AR content prefab is assigned.");
                return;
            }

            currentContent = Instantiate(arContentPrefab);
            currentContent.name = $"{arContentPrefab.name}_Runtime";
            Log($"Instantiated AR content '{currentContent.name}'.");
        }

        Transform contentTransform = currentContent.transform;
        contentTransform.SetParent(trackedImage.transform, false);
        contentTransform.localPosition = Vector3.zero;
        contentTransform.localRotation = Quaternion.identity;
        contentTransform.localScale = arContentPrefab.transform.localScale;

        SetCurrentContentVisible(true);
    }

    private void SetCurrentContentVisible(bool visible)
    {
        if (currentContent == null)
        {
            return;
        }

        currentContent.SetActive(visible);

        Renderer[] renderers = currentContent.GetComponentsInChildren<Renderer>(true);
        foreach (Renderer renderer in renderers)
        {
            renderer.enabled = visible;
        }

        Log($"AR content visible: {visible}. Renderers found: {renderers.Length}.");
    }

    private void NotifyDetected(ARTrackedImage trackedImage)
    {
        hasVisibleTrackedImage = true;
        ImageDetected?.Invoke(trackedImage);
    }

    private void NotifyLost()
    {
        if (!hasVisibleTrackedImage)
        {
            return;
        }

        hasVisibleTrackedImage = false;
        ImageLost?.Invoke();
    }

    private void Log(string message)
    {
        if (logDebugInfo)
        {
            Debug.Log($"[ImageTrackingController] {message}");
        }
    }
}
