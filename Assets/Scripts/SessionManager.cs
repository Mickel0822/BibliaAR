// Autor: TNTE BAYAS CRISTIAN
using System;
using System.Collections;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// BIAR — Alerta de uso continuo de 20 minutos.
///
/// Monitorea el tiempo de sesión activa. Al cumplir <see cref="sessionAlertSeconds"/>
/// muestra un panel de alerta (visual + audible) con dos opciones:
///   • Continuar → oculta la alerta y reinicia el contador.
///   • Salir     → invoca <see cref="OnSessionExit"/> para que el controlador
///                 de historia vuelva a la pantalla inicial.
///
/// La duración de cada sesión se graba en PlayerPrefs bajo las claves
/// "LastSessionDuration" y "TotalSessionDuration".
///
/// Uso típico:
///   1. Añadir este componente al mismo GameObject que StoryFlowController.
///   2. Llamar a BeginSession() cuando el usuario inicia el relato.
///   3. Llamar a ResetSession() cuando el usuario cierra el quiz.
/// </summary>
public class SessionManager : MonoBehaviour
{
    // ─── PlayerPrefs Keys ────────────────────────────────────────────────────
    private const string KeyLastSession  = "LastSessionDuration";
    private const string KeyTotalSession = "TotalSessionDuration";

    // ─── Events ──────────────────────────────────────────────────────────────
    /// <summary>Se invoca cuando el usuario pulsa "Salir" en la alerta.</summary>
    public event Action OnSessionExit;

    // ─── Inspector ───────────────────────────────────────────────────────────
    [Header("Tiempo de sesión")]
    [Tooltip("Segundos de uso continuo antes de mostrar la alerta. Por defecto 1200 = 20 minutos.")]
    [SerializeField] private float sessionAlertSeconds = 30f;

    [Header("Audio")]
    [Tooltip("Clip de alerta. Si está vacío se genera un pitido sintético.")]
    [SerializeField] private AudioClip alertClip;

    // ─── Estado interno ───────────────────────────────────────────────────────
    private float elapsedSeconds;
    private bool  sessionActive;
    private bool  alertShown;

    // ─── UI de alerta ─────────────────────────────────────────────────────────
    private Canvas      alertCanvas;
    private GameObject  alertPanel;
    private AudioSource audioSource;

    // ─── Colores premium (dark mode) ──────────────────────────────────────────
    private static readonly Color32 ColBackground = new Color32(10,  10,  18,  220);
    private static readonly Color32 ColPanel      = new Color32(26,  26,  38,  245);
    private static readonly Color32 ColAccent     = new Color32(99,  102, 241, 255);   // indigo
    private static readonly Color32 ColSuccess    = new Color32(16,  185, 129, 255);   // emerald
    private static readonly Color32 ColDanger     = new Color32(239, 68,  68,  255);   // rose
    private static readonly Color32 ColWhite      = new Color32(255, 255, 255, 255);
    private static readonly Color32 ColMuted      = new Color32(160, 166, 178, 255);

    // ─────────────────────────────────────────────────────────────────────────
    #region Unity Lifecycle

    private void Awake()
    {
        audioSource = gameObject.AddComponent<AudioSource>();
        audioSource.playOnAwake = false;

        if (alertClip == null)
        {
            alertClip = GenerateSyntheticBeep();
        }

        audioSource.clip = alertClip;

        BuildAlertUi();
        alertPanel.SetActive(false);
    }

    private void Start()
    {
        // El contador NO arranca automáticamente: espera a que el relato comience.
        // BeginSession() es llamado desde StoryFlowController.PlayStory().
        sessionActive = false;
        Debug.Log("[SessionManager] Listo. Esperando inicio de sesión activa.");
    }

    private void Update()
    {
        if (!sessionActive || alertShown) return;

        elapsedSeconds += Time.deltaTime;

        if (elapsedSeconds >= sessionAlertSeconds)
        {
            ShowAlert();
        }
    }

    #endregion

    // ─────────────────────────────────────────────────────────────────────────
    #region Public API

    /// <summary>Inicia (o reanuda) el contador de sesión.</summary>
    public void BeginSession()
    {
        // Resetear el contador al (re)iniciar una sesión limpia
        elapsedSeconds = 0f;
        alertShown     = false;
        sessionActive  = true;
        Debug.Log("[SessionManager] Sesión activa. Alerta en: " + FormatTime(sessionAlertSeconds));
    }

    /// <summary>
    /// Guarda la duración de la sesión en PlayerPrefs y reinicia el contador.
    /// Llamar cuando el usuario cierra la sesión (p. ej. al terminar el quiz).
    /// </summary>
    public void ResetSession()
    {
        SaveSessionDuration();
        elapsedSeconds = 0f;
        sessionActive  = false;
        alertShown     = false;
        StopAlertAudio();   // <-- detener sonido inmediatamente
        HideAlert();
    }

    /// <summary>Devuelve la duración acumulada total de sesiones anteriores (en segundos).</summary>
    public static float GetTotalSessionDuration()
    {
        return PlayerPrefs.GetFloat(KeyTotalSession, 0f);
    }

    /// <summary>Devuelve la duración de la última sesión (en segundos).</summary>
    public static float GetLastSessionDuration()
    {
        return PlayerPrefs.GetFloat(KeyLastSession, 0f);
    }

    #endregion

    // ─────────────────────────────────────────────────────────────────────────
    #region Alert

    private void ShowAlert()
    {
        // Guardia: si ya está visible no volver a disparar
        if (alertShown) return;

        alertShown = true;
        SaveSessionDuration();

        alertPanel.SetActive(true);

        if (audioSource != null && alertClip != null)
        {
            audioSource.Stop();   // detener reproducción anterior si la hubiera
            audioSource.Play();
        }
    }

    private void HideAlert()
    {
        StopAlertAudio();
        if (alertPanel != null)
        {
            alertPanel.SetActive(false);
        }
    }

    private void StopAlertAudio()
    {
        if (audioSource != null && audioSource.isPlaying)
        {
            audioSource.Stop();
        }
    }

    private void OnContinuePressed()
    {
        // Ocultar panel y silenciar audio
        HideAlert();

        // Reiniciar el contador y reanudar la sesión limpiamente
        // (BeginSession resetea elapsedSeconds + alertShown + sessionActive)
        BeginSession();

        Debug.Log("[SessionManager] Usuario eligió Continuar. Contador reiniciado.");
    }

    private void OnExitPressed()
    {
        // 1. Ocultar la alerta y silenciar el audio de inmediato
        HideAlert();

        // 2. Detener el contador (pero NO llamar ResetSession todavía:
        //    OnSessionExitRequested en StoryFlowController cerrará el quiz
        //    y luego llamará ResetSession a través de OnQuizClosed)
        sessionActive  = false;
        alertShown     = false;
        SaveSessionDuration();
        elapsedSeconds = 0f;

        // 3. Notificar al controlador de historia para que cierre todo
        OnSessionExit?.Invoke();

        Debug.Log("[SessionManager] Usuario eligió Salir. Sesión terminada.");
    }

    #endregion

    // ─────────────────────────────────────────────────────────────────────────
    #region PlayerPrefs

    private void SaveSessionDuration()
    {
        PlayerPrefs.SetFloat(KeyLastSession, elapsedSeconds);

        float total = PlayerPrefs.GetFloat(KeyTotalSession, 0f) + elapsedSeconds;
        PlayerPrefs.SetFloat(KeyTotalSession, total);
        PlayerPrefs.Save();

        Debug.Log($"[SessionManager] Sesión guardada: {FormatTime(elapsedSeconds)} | Total acumulado: {FormatTime(total)}");
    }

    private static string FormatTime(float seconds)
    {
        int m = Mathf.FloorToInt(seconds / 60f);
        int s = Mathf.FloorToInt(seconds % 60f);
        return $"{m:D2}:{s:D2}";
    }

    #endregion

    // ─────────────────────────────────────────────────────────────────────────
    #region Synthetic Audio

    /// <summary>
    /// Genera un pitido sintético de dos tonos (sin necesidad de clip externo).
    /// </summary>
    private static AudioClip GenerateSyntheticBeep()
    {
        const int sampleRate  = 44100;
        const float duration  = 0.6f;
        int samples = Mathf.RoundToInt(sampleRate * duration);

        float[] data = new float[samples];

        for (int i = 0; i < samples; i++)
        {
            float t       = (float)i / sampleRate;
            float freq    = (t < 0.3f) ? 880f : 660f;           // La5 → Mi5
            float envelope = Mathf.Clamp01(Mathf.Sin(t / duration * Mathf.PI)); // fade in/out
            data[i] = Mathf.Sin(2f * Mathf.PI * freq * t) * envelope * 0.6f;
        }

        AudioClip clip = AudioClip.Create("AlertBeep", samples, 1, sampleRate, false);
        clip.SetData(data, 0);
        return clip;
    }

    #endregion

    // ─────────────────────────────────────────────────────────────────────────
    #region UI Builder

    private void BuildAlertUi()
    {
        // --- Canvas overlay ---
        GameObject canvasGo = new GameObject("SessionAlertCanvas", typeof(RectTransform));
        canvasGo.transform.SetParent(transform, false);

        alertCanvas = canvasGo.AddComponent<Canvas>();
        alertCanvas.renderMode   = RenderMode.ScreenSpaceOverlay;
        alertCanvas.sortingOrder = 100;   // Por encima del quiz (sortingOrder=50) y de todo lo demás

        CanvasScaler scaler = canvasGo.AddComponent<CanvasScaler>();
        scaler.uiScaleMode        = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        scaler.referenceResolution = new Vector2(1080, 1920);
        scaler.screenMatchMode    = CanvasScaler.ScreenMatchMode.MatchWidthOrHeight;
        scaler.matchWidthOrHeight = 0.5f;

        canvasGo.AddComponent<GraphicRaycaster>();

        // --- Panel principal (contiene fondo + contenido) ---
        // IMPORTANTE: el fondo oscuro va DENTRO del panel para que
        // SetActive(false) lo oculte junto con los botones.
        alertPanel = new GameObject("AlertPanel", typeof(RectTransform));
        alertPanel.transform.SetParent(canvasGo.transform, false);
        StretchFull(alertPanel.GetComponent<RectTransform>());

        // --- Fondo oscuro (hijo de alertPanel) ---
        GameObject bgGo = new GameObject("AlertBackground", typeof(RectTransform));
        bgGo.transform.SetParent(alertPanel.transform, false);
        Image bgImage   = bgGo.AddComponent<Image>();
        bgImage.color   = ColBackground;
        StretchFull(bgGo.GetComponent<RectTransform>());

        // --- Panel central de contenido ---
        GameObject contentPanel = new GameObject("AlertContent", typeof(RectTransform));
        contentPanel.transform.SetParent(alertPanel.transform, false);
        RectTransform panelRect = contentPanel.GetComponent<RectTransform>();
        panelRect.anchorMin = new Vector2(0.07f, 0.32f);
        panelRect.anchorMax = new Vector2(0.93f, 0.72f);
        panelRect.offsetMin = Vector2.zero;
        panelRect.offsetMax = Vector2.zero;

        Image panelBg = contentPanel.AddComponent<Image>();
        panelBg.color = ColPanel;

        // Reasignar la variable de referencia al contenedor de contenido
        // para que los hijos siguientes (título, cuerpo, botones) queden
        // bien anidados dentro del panel de contenido.
        Transform contentRoot = contentPanel.transform;

        // --- Icono / Título ---
        TextMeshProUGUI titleText = MakeText(contentRoot, "AlertTitle",
            "⚠  Descanso visual", 52, TextAlignmentOptions.Center, ColWhite);
        RectTransform titleRect = titleText.rectTransform;
        titleRect.anchorMin = new Vector2(0.05f, 0.70f);
        titleRect.anchorMax = new Vector2(0.95f, 0.95f);
        titleRect.offsetMin = titleRect.offsetMax = Vector2.zero;

        // --- Línea separadora ---
        GameObject line = new GameObject("Separator", typeof(RectTransform));
        line.transform.SetParent(contentRoot, false);
        Image lineImg   = line.AddComponent<Image>();
        lineImg.color   = ColAccent;
        RectTransform lineRect = line.GetComponent<RectTransform>();
        lineRect.anchorMin = new Vector2(0.08f, 0.67f);
        lineRect.anchorMax = new Vector2(0.92f, 0.675f);
        lineRect.offsetMin = lineRect.offsetMax = Vector2.zero;

        // --- Cuerpo del mensaje ---
        TextMeshProUGUI bodyText = MakeText(contentRoot, "AlertBody",
            "Llevas 20 minutos usando la aplicación.\n\nTu salud visual es importante.\nToma un descanso y descansa tus ojos.",
            32, TextAlignmentOptions.Center, ColMuted);
        RectTransform bodyRect = bodyText.rectTransform;
        bodyRect.anchorMin = new Vector2(0.06f, 0.30f);
        bodyRect.anchorMax = new Vector2(0.94f, 0.65f);
        bodyRect.offsetMin = bodyRect.offsetMax = Vector2.zero;

        // --- Botón Continuar ---
        Button continueBtn = MakeButton(contentRoot, "BtnContinue", "Continuar",
            new Vector2(0.06f, 0.06f), new Vector2(0.46f, 0.24f), ColSuccess);
        continueBtn.onClick.AddListener(OnContinuePressed);

        // --- Botón Salir ---
        Button exitBtn = MakeButton(contentRoot, "BtnExit", "Salir",
            new Vector2(0.54f, 0.06f), new Vector2(0.94f, 0.24f), ColDanger);
        exitBtn.onClick.AddListener(OnExitPressed);
    }

    // ─── Helpers de UI ────────────────────────────────────────────────────────

    private static TextMeshProUGUI MakeText(Transform parent, string name, string content,
        float fontSize, TextAlignmentOptions alignment, Color color)
    {
        GameObject go    = new GameObject(name, typeof(RectTransform));
        go.transform.SetParent(parent, false);
        TextMeshProUGUI tmp = go.AddComponent<TextMeshProUGUI>();
        tmp.text             = content;
        tmp.fontSize         = fontSize;
        tmp.alignment        = alignment;
        tmp.color            = color;
        tmp.textWrappingMode = TextWrappingModes.Normal;
        tmp.raycastTarget    = false;
        return tmp;
    }

    private static Button MakeButton(Transform parent, string name, string label,
        Vector2 anchorMin, Vector2 anchorMax, Color32 bgColor)
    {
        GameObject go = new GameObject(name, typeof(RectTransform));
        go.transform.SetParent(parent, false);

        RectTransform rect = go.GetComponent<RectTransform>();
        rect.anchorMin = anchorMin;
        rect.anchorMax = anchorMax;
        rect.offsetMin = rect.offsetMax = Vector2.zero;

        Image img  = go.AddComponent<Image>();
        img.color  = bgColor;

        Button btn = go.AddComponent<Button>();

        ColorBlock cb = btn.colors;
        Color hover   = (Color)bgColor * 1.2f;
        hover.a       = 1f;
        cb.highlightedColor = hover;
        cb.pressedColor     = (Color)bgColor * 0.7f;
        btn.colors          = cb;

        TextMeshProUGUI text = MakeText(go.transform, "Label", label, 34,
            TextAlignmentOptions.Center, Color.white);
        text.raycastTarget = true;

        RectTransform textRect = text.rectTransform;
        textRect.anchorMin     = Vector2.zero;
        textRect.anchorMax     = Vector2.one;
        textRect.offsetMin     = textRect.offsetMax = Vector2.zero;

        return btn;
    }

    private static void StretchFull(RectTransform rect)
    {
        rect.anchorMin = Vector2.zero;
        rect.anchorMax = Vector2.one;
        rect.offsetMin = rect.offsetMax = Vector2.zero;
    }

    #endregion
}
