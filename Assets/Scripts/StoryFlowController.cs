using System.Collections;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;

// kguanoluisa, Controlador del flujo narrativo AR: escaneo QR, subtitulos y quiz del Buen Samaritano, sin nuevas variables, 2026-07-21
// nayarbP, Controlador del flujo narrativo AR: escaneo QR, subtitulos y quiz del Buen Samaritano, sin nuevas variables, 2026-07-21
public class StoryFlowController : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private QuizManager quizManager;
    [SerializeField] private AudioSource narrationAudio;

    [Header("AR Flow")]
    [SerializeField] private bool waitForQrDetection = true;

    [Header("Narration")]
    [SerializeField] private bool showSubtitles = true;
    [SerializeField] private float fallbackSecondsPerSubtitle = 4f;
    [TextArea(2, 4)]
    [SerializeField] private string[] subtitles =
    {
        "Un viajero iba por el camino de Jerusalen a Jerico cuando fue atacado por ladrones.",
        "Lo dejaron herido y solo. Varias personas pasaron, pero no se detuvieron a ayudarlo.",
        "Finalmente, un samaritano se acerco, curo sus heridas y lo llevo a un lugar seguro.",
        "Esta historia nos ensena que debemos ayudar a quienes lo necesitan, sin importar quienes sean."
    };

    private Canvas canvas;
    private GameObject scanPanel;
    private GameObject scanReticle;
    private GameObject successPanel;
    private GameObject controlsPanel;
    private GameObject subtitlePanel;
    private Button playButton;
    private Button subtitlesButton;
    private TextMeshProUGUI scanTitleText;
    private TextMeshProUGUI scanBodyText;
    private TextMeshProUGUI subtitleText;
    private TextMeshProUGUI subtitlesButtonText;
    private Coroutine storyRoutine;
    private Coroutine successRoutine;
    private bool qrDetected;
    private bool storyStarted;
    private bool quizStarted;

    // kguanoluisa, Prepara referencias, UI y estado inicial del flujo narrativo AR, sin nuevas variables, 2026-07-01
    // nayarbP, Prepara referencias, UI y estado inicial del flujo narrativo AR, sin nuevas variables, 2026-07-01
    private void Awake()
    {
        if (quizManager == null)
        {
            quizManager = FindAnyObjectByType<QuizManager>();
        }

        EnsureEventSystem();
        BuildUi();
        ShowInitialState();
    }

    private void OnEnable()
    {
        // kguanoluisa, Suscribe eventos de deteccion QR y cierre del quiz para coordinar la experiencia, sin nuevas variables, 2026-07-21
        // nayarbP, Suscribe eventos de deteccion QR y cierre del quiz para coordinar la experiencia, sin nuevas variables, 2026-07-21
        ImageTrackingController.ImageDetected += OnQrDetected;
        ImageTrackingController.ImageLost += OnQrLost;

        if (quizManager != null)
        {
            quizManager.QuizClosed += OnQuizClosed;
        }
    }

    private void OnDisable()
    {
        ImageTrackingController.ImageDetected -= OnQrDetected;
        ImageTrackingController.ImageLost -= OnQrLost;

        if (quizManager != null)
        {
            quizManager.QuizClosed -= OnQuizClosed;
        }
    }

    // kguanoluisa, Valida deteccion QR antes de iniciar la corrutina del relato biblico, sin nuevas variables, 2026-07-01
    // nayarbP, Valida deteccion QR antes de iniciar la corrutina del relato biblico, sin nuevas variables, 2026-07-01
    public void PlayStory()
    {
        if (waitForQrDetection && !qrDetected)
        {
            ShowScanningState("Buscando codigo QR", "Apunta la camara al marcador para iniciar la experiencia.");
            return;
        }

        if (storyRoutine != null)
        {
            StopCoroutine(storyRoutine);
        }

        storyRoutine = StartCoroutine(StoryRoutine());
    }

    public void ToggleSubtitles()
    {
        showSubtitles = !showSubtitles;
        subtitlesButtonText.text = showSubtitles ? "Subtitulos: ON" : "Subtitulos: OFF";

        if (!showSubtitles)
        {
            SetSubtitleVisible(false);
        }
    }

    // kguanoluisa, Reacciona al evento de deteccion QR para iniciar la transicion a controles, sin nuevas variables, 2026-07-10
    // nayarbP, Reacciona al evento de deteccion QR para iniciar la transicion a controles, sin nuevas variables, 2026-07-10
    private void OnQrDetected(ARTrackedImage trackedImage)
    {
        if (qrDetected && !storyStarted && !quizStarted)
        {
            return;
        }

        qrDetected = true;

        if (storyStarted || quizStarted)
        {
            return;
        }

        if (successRoutine != null)
        {
            StopCoroutine(successRoutine);
        }

        successRoutine = StartCoroutine(ShowQrDetectedThenControls());
    }

    private void OnQrLost()
    {
        qrDetected = false;

        if (storyStarted || quizStarted)
        {
            return;
        }

        if (successRoutine != null)
        {
            StopCoroutine(successRoutine);
            successRoutine = null;
        }

        ShowScanningState("Manten el QR visible", "Acerca el marcador y evita reflejos o movimiento brusco.");
    }

    // kguanoluisa, Restablece la pantalla inicial cuando el usuario cierra el quiz, sin nuevas variables, 2026-07-21
    // nayarbP, Restablece la pantalla inicial cuando el usuario cierra el quiz, sin nuevas variables, 2026-07-21
    private void OnQuizClosed()
    {
        qrDetected = false;
        storyStarted = false;
        quizStarted = false;

        if (successRoutine != null)
        {
            StopCoroutine(successRoutine);
            successRoutine = null;
        }

        if (storyRoutine != null)
        {
            StopCoroutine(storyRoutine);
            storyRoutine = null;
        }

        if (narrationAudio != null)
        {
            narrationAudio.Stop();
        }

        ShowInitialState();
    }

    // kguanoluisa, Inicia la narracion con subtitulos sincronizados y luego lanza el quiz, sin nuevas variables, 2026-07-21
    // nayarbP, Inicia la narracion con subtitulos sincronizados y luego lanza el quiz, sin nuevas variables, 2026-07-21
    private IEnumerator StoryRoutine()
    {
        storyStarted = true;
        SetScanVisible(false);
        SetSuccessVisible(false);
        SetControlsVisible(false);

        if (narrationAudio != null && narrationAudio.clip != null)
        {
            narrationAudio.Stop();
            narrationAudio.Play();
        }

        int lineCount = subtitles != null ? subtitles.Length : 0;
        float totalDuration = GetNarrationDuration(lineCount);
        float lineDuration = lineCount > 0 ? totalDuration / lineCount : totalDuration;

        for (int i = 0; i < lineCount; i++)
        {
            if (showSubtitles)
            {
                subtitleText.text = subtitles[i];
                SetSubtitleVisible(true);
            }

            yield return new WaitForSeconds(lineDuration);
        }

        if (narrationAudio != null && narrationAudio.isPlaying)
        {
            while (narrationAudio.isPlaying)
            {
                yield return null;
            }
        }

        SetSubtitleVisible(false);
        StartQuiz();
        storyRoutine = null;
    }

    // kguanoluisa, Transiciona del relato al quiz ocultando paneles de la experiencia AR, sin nuevas variables, 2026-07-14
    // nayarbP, Transiciona del relato al quiz ocultando paneles de la experiencia AR, sin nuevas variables, 2026-07-14
    private void StartQuiz()
    {
        quizStarted = true;
        SetScanVisible(false);
        SetSuccessVisible(false);
        SetControlsVisible(false);

        if (quizManager != null)
        {
            quizManager.BeginQuiz();
        }
        else
        {
            Debug.LogWarning("[StoryFlowController] No QuizManager assigned.");
        }
    }

    // kguanoluisa, Muestra confirmacion de QR detectado antes de habilitar los controles de reproduccion, sin nuevas variables, 2026-07-21
    // nayarbP, Muestra confirmacion de QR detectado antes de habilitar los controles de reproduccion, sin nuevas variables, 2026-07-21
    private IEnumerator ShowQrDetectedThenControls()
    {
        SetScanVisible(false);
        SetControlsVisible(false);
        SetSuccessVisible(true);

        yield return new WaitForSeconds(1.1f);

        SetSuccessVisible(false);
        SetControlsVisible(true);
        successRoutine = null;
    }

    private void ShowInitialState()
    {
        SetSubtitleVisible(false);
        SetSuccessVisible(false);
        SetControlsVisible(!waitForQrDetection);

        if (waitForQrDetection)
        {
            ShowScanningState("Escanea el codigo QR", "Apunta la camara al marcador. Cuando se detecte, apareceran los controles.");
        }
        else
        {
            SetScanVisible(false);
        }
    }

    private void ShowScanningState(string title, string body)
    {
        scanTitleText.text = title;
        scanBodyText.text = body;
        SetScanVisible(true);
        SetSuccessVisible(false);
        SetControlsVisible(false);
        SetSubtitleVisible(false);
    }

    // kguanoluisa, Calcula la duracion total de narracion segun el audio o subtitulos configurados, sin nuevas variables, 2026-07-14
    // nayarbP, Calcula la duracion total de narracion segun el audio o subtitulos configurados, sin nuevas variables, 2026-07-14
    private float GetNarrationDuration(int lineCount)
    {
        if (narrationAudio != null && narrationAudio.clip != null)
        {
            return Mathf.Max(narrationAudio.clip.length, 1f);
        }

        return Mathf.Max(lineCount * fallbackSecondsPerSubtitle, 1f);
    }

    // kguanoluisa, Construye dinamicamente los paneles de escaneo, controles y subtitulos, sin nuevas variables, 2026-07-10
    // nayarbP, Construye dinamicamente los paneles de escaneo, controles y subtitulos, sin nuevas variables, 2026-07-10
    private void BuildUi()
    {
        GameObject canvasGo = new GameObject("StoryFlowCanvas", typeof(RectTransform));
        canvasGo.transform.SetParent(transform, false);

        canvas = canvasGo.AddComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        canvas.sortingOrder = 20;

        CanvasScaler scaler = canvasGo.AddComponent<CanvasScaler>();
        scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        scaler.referenceResolution = new Vector2(1080, 1920);
        scaler.screenMatchMode = CanvasScaler.ScreenMatchMode.MatchWidthOrHeight;
        scaler.matchWidthOrHeight = 0.5f;

        canvasGo.AddComponent<GraphicRaycaster>();

        BuildScanPanel(canvasGo.transform);
        BuildSuccessPanel(canvasGo.transform);
        BuildControlsPanel(canvasGo.transform);
        BuildSubtitlePanel(canvasGo.transform);
    }

    private void BuildScanPanel(Transform parent)
    {
        scanPanel = new GameObject("ScanPanel", typeof(RectTransform));
        scanPanel.transform.SetParent(parent, false);

        RectTransform panelRect = scanPanel.GetComponent<RectTransform>();
        panelRect.anchorMin = new Vector2(0.07f, 0.06f);
        panelRect.anchorMax = new Vector2(0.93f, 0.25f);
        panelRect.offsetMin = Vector2.zero;
        panelRect.offsetMax = Vector2.zero;

        Image background = scanPanel.AddComponent<Image>();
        background.color = new Color(0f, 0f, 0f, 0.72f);
        background.raycastTarget = false;

        scanTitleText = CreateText("Title", "Escanea el codigo QR", 38, TextAlignmentOptions.Center);
        AttachStretch(scanTitleText.rectTransform, scanPanel.transform, new Vector2(24f, 96f), new Vector2(-24f, -16f));

        scanBodyText = CreateText("Body", "Apunta la camara al marcador para iniciar.", 27, TextAlignmentOptions.Center);
        AttachStretch(scanBodyText.rectTransform, scanPanel.transform, new Vector2(24f, 18f), new Vector2(-24f, -82f));

        scanReticle = new GameObject("ScanReticle", typeof(RectTransform));
        scanReticle.transform.SetParent(parent, false);
        RectTransform reticleRect = scanReticle.GetComponent<RectTransform>();
        reticleRect.anchorMin = new Vector2(0.28f, 0.34f);
        reticleRect.anchorMax = new Vector2(0.72f, 0.68f);
        reticleRect.offsetMin = Vector2.zero;
        reticleRect.offsetMax = Vector2.zero;

        Image reticleImage = scanReticle.AddComponent<Image>();
        reticleImage.color = new Color(1f, 1f, 1f, 0.12f);
        reticleImage.raycastTarget = false;
    }

    private void BuildSuccessPanel(Transform parent)
    {
        successPanel = new GameObject("QrDetectedPanel", typeof(RectTransform));
        successPanel.transform.SetParent(parent, false);

        RectTransform rect = successPanel.GetComponent<RectTransform>();
        rect.anchorMin = new Vector2(0.12f, 0.41f);
        rect.anchorMax = new Vector2(0.88f, 0.55f);
        rect.offsetMin = Vector2.zero;
        rect.offsetMax = Vector2.zero;

        Image background = successPanel.AddComponent<Image>();
        background.color = new Color32(16, 185, 129, 235);
        background.raycastTarget = false;

        TextMeshProUGUI text = CreateText("Text", "QR detectado\nEscena cargada", 34, TextAlignmentOptions.Center);
        AttachStretch(text.rectTransform, successPanel.transform, Vector2.zero, Vector2.zero);
    }

    private void BuildControlsPanel(Transform parent)
    {
        controlsPanel = new GameObject("StoryControls", typeof(RectTransform));
        controlsPanel.transform.SetParent(parent, false);

        RectTransform controlsRect = controlsPanel.GetComponent<RectTransform>();
        controlsRect.anchorMin = new Vector2(0.06f, 0.04f);
        controlsRect.anchorMax = new Vector2(0.94f, 0.12f);
        controlsRect.offsetMin = Vector2.zero;
        controlsRect.offsetMax = Vector2.zero;

        playButton = CreateButton("PlayButton", "Iniciar relato", controlsPanel.transform, new Vector2(0f, 0f), new Vector2(0.48f, 1f));
        playButton.onClick.AddListener(PlayStory);

        subtitlesButton = CreateButton("SubtitlesButton", "Subtitulos: ON", controlsPanel.transform, new Vector2(0.54f, 0f), new Vector2(1f, 1f));
        subtitlesButton.onClick.AddListener(ToggleSubtitles);
        subtitlesButtonText = subtitlesButton.GetComponentInChildren<TextMeshProUGUI>();
    }

    private void BuildSubtitlePanel(Transform parent)
    {
        subtitlePanel = new GameObject("SubtitlePanel", typeof(RectTransform));
        subtitlePanel.transform.SetParent(parent, false);

        RectTransform subtitlePanelRect = subtitlePanel.GetComponent<RectTransform>();
        subtitlePanelRect.anchorMin = new Vector2(0.07f, 0.12f);
        subtitlePanelRect.anchorMax = new Vector2(0.93f, 0.25f);
        subtitlePanelRect.offsetMin = Vector2.zero;
        subtitlePanelRect.offsetMax = Vector2.zero;

        Image subtitleBackground = subtitlePanel.AddComponent<Image>();
        subtitleBackground.color = new Color(0f, 0f, 0f, 0.72f);
        subtitleBackground.raycastTarget = false;

        subtitleText = CreateText("SubtitleText", "", 32, TextAlignmentOptions.Center);
        AttachStretch(subtitleText.rectTransform, subtitlePanel.transform, new Vector2(24f, 16f), new Vector2(-24f, -16f));
    }

    private Button CreateButton(string objectName, string label, Transform parent, Vector2 anchorMin, Vector2 anchorMax)
    {
        GameObject buttonGo = new GameObject(objectName, typeof(RectTransform));
        buttonGo.transform.SetParent(parent, false);

        RectTransform rect = buttonGo.GetComponent<RectTransform>();
        rect.anchorMin = anchorMin;
        rect.anchorMax = anchorMax;
        rect.offsetMin = Vector2.zero;
        rect.offsetMax = Vector2.zero;

        Image image = buttonGo.AddComponent<Image>();
        image.color = new Color32(30, 30, 40, 235);

        Button button = buttonGo.AddComponent<Button>();

        TextMeshProUGUI text = CreateText("Text", label, 30, TextAlignmentOptions.Center);
        AttachStretch(text.rectTransform, buttonGo.transform, Vector2.zero, Vector2.zero);

        return button;
    }

    private TextMeshProUGUI CreateText(string objectName, string value, float fontSize, TextAlignmentOptions alignment)
    {
        GameObject textGo = new GameObject(objectName, typeof(RectTransform));
        TextMeshProUGUI text = textGo.AddComponent<TextMeshProUGUI>();
        text.text = value;
        text.fontSize = fontSize;
        text.alignment = alignment;
        text.color = Color.white;
        text.textWrappingMode = TextWrappingModes.Normal;
        text.raycastTarget = false;
        return text;
    }

    private static void AttachStretch(RectTransform rect, Transform parent, Vector2 offsetMin, Vector2 offsetMax)
    {
        rect.SetParent(parent, false);
        rect.anchorMin = Vector2.zero;
        rect.anchorMax = Vector2.one;
        rect.offsetMin = offsetMin;
        rect.offsetMax = offsetMax;
    }

    private void SetScanVisible(bool visible)
    {
        if (scanPanel != null)
        {
            scanPanel.SetActive(visible);
        }

        if (scanReticle != null)
        {
            scanReticle.SetActive(visible);
        }
    }

    private void SetSuccessVisible(bool visible)
    {
        if (successPanel != null)
        {
            successPanel.SetActive(visible);
        }
    }

    private void SetSubtitleVisible(bool visible)
    {
        if (subtitlePanel != null)
        {
            subtitlePanel.SetActive(visible);
        }
    }

    private void SetControlsVisible(bool visible)
    {
        if (controlsPanel != null)
        {
            controlsPanel.SetActive(visible);
        }
    }

    private static void EnsureEventSystem()
    {
        if (FindAnyObjectByType<EventSystem>() != null)
        {
            return;
        }

        GameObject eventSystemGo = new GameObject("EventSystem");
        eventSystemGo.AddComponent<EventSystem>();

#if ENABLE_INPUT_SYSTEM
        eventSystemGo.AddComponent<UnityEngine.InputSystem.UI.InputSystemUIInputModule>();
#else
        eventSystemGo.AddComponent<StandaloneInputModule>();
#endif
    }
}
