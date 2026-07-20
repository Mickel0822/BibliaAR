using System;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

/// <summary>
/// Centraliza el progreso local asociado a cada nino que usa la aplicacion.
/// La informacion se serializa como JSON dentro de <see cref="PlayerPrefs"/>,
/// por lo que no depende de una conexion a internet ni de un servicio remoto.
/// Ademas de conservar los perfiles, este componente construye la interfaz que
/// permite crearlos, seleccionarlos y consultar sus actividades finalizadas.
/// Cada registro conserva el nombre de la actividad, la fecha en formato UTC,
/// el resultado del cuestionario y el tiempo total empleado; de esta manera el
/// historial puede seguir siendo util cuando se abre la aplicacion otro dia.
/// </summary>
public class ChildProgressManager : MonoBehaviour
{
    public event Action ProfileChanged;

    [SerializeField] private string activityName = "El Buen Samaritano";

    // La clave incluye una version para poder migrar los datos con seguridad si
    // el formato del historial cambia en una futura actualizacion de la app.
    private const string StorageKey = "BibliAR.ChildProgress.v1";

    [Serializable]
    private class ProgressData
    {
        public List<ChildProfile> profiles = new List<ChildProfile>();
        public string selectedProfileId;
    }

    [Serializable]
    private class ChildProfile
    {
        public string id;
        public string displayName;
        public List<ActivityRecord> activities = new List<ActivityRecord>();
    }

    [Serializable]
    private class ActivityRecord
    {
        public string activityName;
        public string completedAtUtc;
        public int score;
        public int totalQuestions;
        public float durationSeconds;
    }

    private ProgressData progressData;
    private float activityStartedAt;
    private bool activityInProgress;

    private Canvas canvas;
    private GameObject modalRoot;
    private GameObject profilePanel;
    private GameObject historyPanel;
    private TextMeshProUGUI accessButtonText;
    private TextMeshProUGUI selectedProfileText;
    private TextMeshProUGUI historyTitleText;
    private TMP_InputField profileNameInput;
    private Transform profilesContainer;
    private Transform historyContainer;

    public bool HasSelectedProfile => GetSelectedProfile() != null;

    private void Awake()
    {
        LoadProgress();
        EnsureEventSystem();
        BuildUi();
        RefreshProfileUi();
        CloseProgressUi();
    }

    /// <summary>
    /// Inicia la medicion de la actividad solamente cuando existe un perfil
    /// activo. Si no se ha elegido un nino, abre el panel de perfiles y avisa al
    /// controlador del relato que no debe continuar: asi se evita guardar una
    /// actividad sin poder atribuirla a una persona concreta.
    /// </summary>
    public bool TryBeginActivity()
    {
        if (!HasSelectedProfile)
        {
            OpenProfilePanel();
            return false;
        }

        activityStartedAt = Time.realtimeSinceStartup;
        activityInProgress = true;
        return true;
    }

    /// <summary>
    /// Registra una actividad finalizada para el perfil seleccionado y persiste
    /// de inmediato todo el historial local. La duracion se calcula desde
    /// <see cref="TryBeginActivity"/> usando tiempo real, mientras que la fecha
    /// se guarda en UTC con formato ISO 8601 para que sea independiente de la
    /// configuracion regional del telefono y pueda mostrarse luego en hora local.
    /// </summary>
    public void CompleteActivity(int score, int totalQuestions)
    {
        ChildProfile selectedProfile = GetSelectedProfile();
        if (selectedProfile == null)
        {
            Debug.LogWarning("[ChildProgressManager] No child profile is selected.");
            return;
        }

        float duration = activityInProgress
            ? Mathf.Max(0f, Time.realtimeSinceStartup - activityStartedAt)
            : 0f;

        if (selectedProfile.activities == null)
        {
            selectedProfile.activities = new List<ActivityRecord>();
        }

        selectedProfile.activities.Add(new ActivityRecord
        {
            activityName = activityName,
            completedAtUtc = DateTime.UtcNow.ToString("O"),
            score = Mathf.Max(0, score),
            totalQuestions = Mathf.Max(0, totalQuestions),
            durationSeconds = duration
        });

        activityInProgress = false;
        SaveProgress();
        RefreshProfileUi();
    }

    public void OpenProfilePanel()
    {
        modalRoot.SetActive(true);
        profilePanel.SetActive(true);
        historyPanel.SetActive(false);
        RefreshProfileUi();
    }

    public void OpenHistoryPanel()
    {
        if (!HasSelectedProfile)
        {
            OpenProfilePanel();
            return;
        }

        modalRoot.SetActive(true);
        profilePanel.SetActive(false);
        historyPanel.SetActive(true);
        RefreshHistoryUi();
    }

    public void CloseProgressUi()
    {
        if (modalRoot != null)
        {
            modalRoot.SetActive(false);
        }
    }

    /// <summary>
    /// Devuelve el nombre visible del perfil activo para que otros componentes
    /// puedan mostrarlo sin conocer la estructura interna de los datos. Cuando
    /// no existe seleccion se devuelve una cadena vacia, evitando referencias
    /// nulas en los textos de estado del flujo narrativo.
    /// </summary>
    public string GetSelectedProfileName()
    {
        ChildProfile selectedProfile = GetSelectedProfile();
        return selectedProfile != null ? selectedProfile.displayName : string.Empty;
    }

    private void LoadProgress()
    {
        // PlayerPrefs puede no contener datos en la primera ejecucion o tras
        // borrar los datos de la aplicacion. En ambos casos se crea una coleccion
        // valida para que el resto de la interfaz pueda funcionar normalmente.
        string json = PlayerPrefs.GetString(StorageKey, string.Empty);
        progressData = string.IsNullOrEmpty(json)
            ? new ProgressData()
            : JsonUtility.FromJson<ProgressData>(json);

        if (progressData == null)
        {
            progressData = new ProgressData();
        }

        if (progressData.profiles == null)
        {
            progressData.profiles = new List<ChildProfile>();
        }
    }

    private void SaveProgress()
    {
        // Save fuerza la escritura antes de que el usuario cierre la app; esto
        // es importante porque el historial representa el avance ya completado.
        PlayerPrefs.SetString(StorageKey, JsonUtility.ToJson(progressData));
        PlayerPrefs.Save();
    }

    private ChildProfile GetSelectedProfile()
    {
        if (progressData == null || string.IsNullOrEmpty(progressData.selectedProfileId))
        {
            return null;
        }

        return progressData.profiles.Find(profile => profile.id == progressData.selectedProfileId);
    }

    private void CreateProfile()
    {
        string displayName = profileNameInput != null ? profileNameInput.text.Trim() : string.Empty;
        if (string.IsNullOrEmpty(displayName))
        {
            selectedProfileText.text = "Escribe el nombre del nino.";
            return;
        }

        if (progressData.profiles.Exists(profile =>
                string.Equals(profile.displayName, displayName, StringComparison.OrdinalIgnoreCase)))
        {
            selectedProfileText.text = "Ese perfil ya existe. Seleccionalo de la lista.";
            return;
        }

        ChildProfile profile = new ChildProfile
        {
            id = Guid.NewGuid().ToString("N"),
            displayName = displayName,
            activities = new List<ActivityRecord>()
        };

        progressData.profiles.Add(profile);
        progressData.selectedProfileId = profile.id;
        profileNameInput.text = string.Empty;
        SaveProgress();
        RefreshProfileUi();
        ProfileChanged?.Invoke();
    }

    private void SelectProfile(string profileId)
    {
        if (!progressData.profiles.Exists(profile => profile.id == profileId))
        {
            return;
        }

        progressData.selectedProfileId = profileId;
        SaveProgress();
        RefreshProfileUi();
        ProfileChanged?.Invoke();
    }

    private void BuildUi()
    {
        GameObject canvasObject = new GameObject("ProgressCanvas", typeof(RectTransform));
        canvasObject.transform.SetParent(transform, false);

        canvas = canvasObject.AddComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        canvas.sortingOrder = 60;
        CanvasScaler scaler = canvasObject.AddComponent<CanvasScaler>();
        scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        scaler.referenceResolution = new Vector2(1080, 1920);
        scaler.screenMatchMode = CanvasScaler.ScreenMatchMode.MatchWidthOrHeight;
        scaler.matchWidthOrHeight = 0.5f;
        canvasObject.AddComponent<GraphicRaycaster>();

        Button accessButton = CreateButton("ProfileAccessButton", "Perfil / Historial", canvasObject.transform);
        RectTransform accessRect = accessButton.GetComponent<RectTransform>();
        accessRect.anchorMin = new Vector2(0.64f, 0.91f);
        accessRect.anchorMax = new Vector2(0.96f, 0.97f);
        accessRect.offsetMin = Vector2.zero;
        accessRect.offsetMax = Vector2.zero;
        accessButton.onClick.AddListener(OpenProfilePanel);
        accessButtonText = accessButton.GetComponentInChildren<TextMeshProUGUI>();

        modalRoot = new GameObject("ProgressModal", typeof(RectTransform));
        modalRoot.transform.SetParent(canvasObject.transform, false);
        AttachStretch(modalRoot.GetComponent<RectTransform>(), canvasObject.transform, Vector2.zero, Vector2.zero);
        Image modalBackground = modalRoot.AddComponent<Image>();
        modalBackground.color = new Color(0.04f, 0.04f, 0.08f, 0.94f);

        profilePanel = CreatePanel("ProfilePanel", modalRoot.transform, new Vector2(0.07f, 0.12f), new Vector2(0.93f, 0.88f));
        BuildProfilePanel(profilePanel.transform);

        historyPanel = CreatePanel("HistoryPanel", modalRoot.transform, new Vector2(0.07f, 0.12f), new Vector2(0.93f, 0.88f));
        BuildHistoryPanel(historyPanel.transform);
    }

    private void BuildProfilePanel(Transform parent)
    {
        CreatePanelTitle(parent, "Perfil del nino");

        selectedProfileText = CreateText("SelectedProfile", "Selecciona o crea un perfil", 28, TextAlignmentOptions.Center);
        AttachStretch(selectedProfileText.rectTransform, parent, new Vector2(35f, 470f), new Vector2(-35f, -130f));

        profileNameInput = CreateInputField(parent, "Nombre del nino");
        RectTransform inputRect = profileNameInput.GetComponent<RectTransform>();
        inputRect.anchorMin = new Vector2(0.08f, 0.70f);
        inputRect.anchorMax = new Vector2(0.92f, 0.78f);
        inputRect.offsetMin = Vector2.zero;
        inputRect.offsetMax = Vector2.zero;

        Button createButton = CreateButton("CreateProfileButton", "Crear perfil", parent);
        SetAnchors(createButton.GetComponent<RectTransform>(), new Vector2(0.08f, 0.61f), new Vector2(0.92f, 0.68f));
        createButton.onClick.AddListener(CreateProfile);

        TextMeshProUGUI listTitle = CreateText("ProfilesTitle", "Perfiles disponibles", 25, TextAlignmentOptions.Left);
        AttachStretch(listTitle.rectTransform, parent, new Vector2(45f, 370f), new Vector2(-45f, -350f));

        GameObject profilesObject = new GameObject("ProfilesList", typeof(RectTransform));
        profilesObject.transform.SetParent(parent, false);
        profilesContainer = profilesObject.transform;
        SetAnchors(profilesObject.GetComponent<RectTransform>(), new Vector2(0.08f, 0.28f), new Vector2(0.92f, 0.52f));
        AddVerticalLayout(profilesObject, 12f);

        Button historyButton = CreateButton("HistoryButton", "Ver historial", parent);
        SetAnchors(historyButton.GetComponent<RectTransform>(), new Vector2(0.08f, 0.16f), new Vector2(0.48f, 0.24f));
        historyButton.onClick.AddListener(OpenHistoryPanel);

        Button closeButton = CreateButton("CloseProfileButton", "Cerrar", parent);
        SetAnchors(closeButton.GetComponent<RectTransform>(), new Vector2(0.54f, 0.16f), new Vector2(0.92f, 0.24f));
        closeButton.onClick.AddListener(CloseProgressUi);
    }

    private void BuildHistoryPanel(Transform parent)
    {
        historyTitleText = CreateText("HistoryTitle", "Historial", 31, TextAlignmentOptions.Center);
        AttachStretch(historyTitleText.rectTransform, parent, new Vector2(30f, 560f), new Vector2(-30f, -90f));

        GameObject historyObject = new GameObject("HistoryList", typeof(RectTransform));
        historyObject.transform.SetParent(parent, false);
        historyContainer = historyObject.transform;
        SetAnchors(historyObject.GetComponent<RectTransform>(), new Vector2(0.08f, 0.23f), new Vector2(0.92f, 0.77f));
        AddVerticalLayout(historyObject, 16f);

        Button backButton = CreateButton("BackToProfileButton", "Volver al perfil", parent);
        SetAnchors(backButton.GetComponent<RectTransform>(), new Vector2(0.08f, 0.11f), new Vector2(0.48f, 0.19f));
        backButton.onClick.AddListener(OpenProfilePanel);

        Button closeButton = CreateButton("CloseHistoryButton", "Cerrar", parent);
        SetAnchors(closeButton.GetComponent<RectTransform>(), new Vector2(0.54f, 0.11f), new Vector2(0.92f, 0.19f));
        closeButton.onClick.AddListener(CloseProgressUi);
    }

    private void RefreshProfileUi()
    {
        if (progressData == null || accessButtonText == null)
        {
            return;
        }

        ChildProfile selectedProfile = GetSelectedProfile();
        accessButtonText.text = selectedProfile == null
            ? "Perfil / Historial"
            : $"Perfil: {selectedProfile.displayName}";

        if (selectedProfileText != null)
        {
            selectedProfileText.text = selectedProfile == null
                ? "Selecciona o crea un perfil"
                : $"Perfil activo: {selectedProfile.displayName}";
        }

        if (profilesContainer == null)
        {
            return;
        }

        ClearChildren(profilesContainer);
        foreach (ChildProfile profile in progressData.profiles)
        {
            int activityCount = profile.activities != null ? profile.activities.Count : 0;
            Button profileButton = CreateButton(
                $"Profile_{profile.id}",
                $"{profile.displayName} ({activityCount} actividades)",
                profilesContainer);
            LayoutElement layout = profileButton.gameObject.AddComponent<LayoutElement>();
            layout.minHeight = 70f;
            string profileId = profile.id;
            profileButton.onClick.AddListener(() => SelectProfile(profileId));
        }
    }

    private void RefreshHistoryUi()
    {
        ChildProfile selectedProfile = GetSelectedProfile();
        if (selectedProfile == null || historyContainer == null)
        {
            return;
        }

        historyTitleText.text = $"Historial de {selectedProfile.displayName}";
        ClearChildren(historyContainer);

        if (selectedProfile.activities == null || selectedProfile.activities.Count == 0)
        {
            TextMeshProUGUI emptyText = CreateText("EmptyHistory", "Todavia no hay actividades completadas.", 26, TextAlignmentOptions.Center);
            emptyText.transform.SetParent(historyContainer, false);
            LayoutElement emptyLayout = emptyText.gameObject.AddComponent<LayoutElement>();
            emptyLayout.minHeight = 100f;
            return;
        }

        for (int i = selectedProfile.activities.Count - 1; i >= 0; i--)
        {
            ActivityRecord record = selectedProfile.activities[i];
            string date = FormatDate(record.completedAtUtc);
            string duration = FormatDuration(record.durationSeconds);
            TextMeshProUGUI recordText = CreateText(
                "ActivityRecord",
                $"{record.activityName}\n{date}\nResultado: {record.score}/{record.totalQuestions}   Duracion: {duration}",
                23,
                TextAlignmentOptions.Left);
            recordText.transform.SetParent(historyContainer, false);
            LayoutElement recordLayout = recordText.gameObject.AddComponent<LayoutElement>();
            recordLayout.minHeight = 105f;
        }
    }

    private static string FormatDate(string utcDate)
    {
        if (DateTime.TryParse(utcDate, null, System.Globalization.DateTimeStyles.RoundtripKind, out DateTime parsed))
        {
            return parsed.ToLocalTime().ToString("dd/MM/yyyy HH:mm");
        }

        return "Fecha no disponible";
    }

    private static string FormatDuration(float seconds)
    {
        int roundedSeconds = Mathf.Max(0, Mathf.RoundToInt(seconds));
        return $"{roundedSeconds / 60:00}:{roundedSeconds % 60:00}";
    }

    private static void ClearChildren(Transform parent)
    {
        for (int i = parent.childCount - 1; i >= 0; i--)
        {
            UnityEngine.Object.Destroy(parent.GetChild(i).gameObject);
        }
    }

    private static void AddVerticalLayout(GameObject target, float spacing)
    {
        VerticalLayoutGroup layout = target.AddComponent<VerticalLayoutGroup>();
        layout.spacing = spacing;
        layout.childAlignment = TextAnchor.UpperCenter;
        layout.childControlWidth = true;
        layout.childControlHeight = true;
        layout.childForceExpandWidth = true;
        layout.childForceExpandHeight = false;
    }

    private static GameObject CreatePanel(string objectName, Transform parent, Vector2 anchorMin, Vector2 anchorMax)
    {
        GameObject panel = new GameObject(objectName, typeof(RectTransform));
        panel.transform.SetParent(parent, false);
        SetAnchors(panel.GetComponent<RectTransform>(), anchorMin, anchorMax);
        Image image = panel.AddComponent<Image>();
        image.color = new Color32(30, 30, 42, 255);
        return panel;
    }

    private void CreatePanelTitle(Transform parent, string value)
    {
        TextMeshProUGUI title = CreateText("Title", value, 38, TextAlignmentOptions.Center);
        AttachStretch(title.rectTransform, parent, new Vector2(30f, 570f), new Vector2(-30f, -45f));
    }

    private static Button CreateButton(string objectName, string label, Transform parent)
    {
        GameObject buttonObject = new GameObject(objectName, typeof(RectTransform));
        buttonObject.transform.SetParent(parent, false);
        Image image = buttonObject.AddComponent<Image>();
        image.color = new Color32(65, 65, 88, 255);
        Button button = buttonObject.AddComponent<Button>();

        GameObject textObject = new GameObject("Text", typeof(RectTransform));
        textObject.transform.SetParent(buttonObject.transform, false);
        TextMeshProUGUI text = textObject.AddComponent<TextMeshProUGUI>();
        text.text = label;
        text.fontSize = 27f;
        text.alignment = TextAlignmentOptions.Center;
        text.color = Color.white;
        text.textWrappingMode = TextWrappingModes.Normal;
        text.raycastTarget = false;
        AttachStretch(text.rectTransform, buttonObject.transform, new Vector2(10f, 5f), new Vector2(-10f, -5f));
        return button;
    }

    private static TMP_InputField CreateInputField(Transform parent, string placeholder)
    {
        GameObject inputObject = new GameObject("ProfileNameInput", typeof(RectTransform));
        inputObject.transform.SetParent(parent, false);
        Image image = inputObject.AddComponent<Image>();
        image.color = new Color32(245, 245, 250, 255);
        TMP_InputField input = inputObject.AddComponent<TMP_InputField>();

        TextMeshProUGUI text = CreateText("Text", string.Empty, 27, TextAlignmentOptions.Left);
        text.color = new Color32(25, 25, 30, 255);
        AttachStretch(text.rectTransform, inputObject.transform, new Vector2(18f, 5f), new Vector2(-18f, -5f));
        input.textComponent = text;

        TextMeshProUGUI placeholderText = CreateText("Placeholder", placeholder, 27, TextAlignmentOptions.Left);
        placeholderText.color = new Color32(100, 100, 110, 255);
        AttachStretch(placeholderText.rectTransform, inputObject.transform, new Vector2(18f, 5f), new Vector2(-18f, -5f));
        input.placeholder = placeholderText;
        return input;
    }

    private static TextMeshProUGUI CreateText(string objectName, string value, float fontSize, TextAlignmentOptions alignment)
    {
        GameObject textObject = new GameObject(objectName, typeof(RectTransform));
        TextMeshProUGUI text = textObject.AddComponent<TextMeshProUGUI>();
        text.text = value;
        text.fontSize = fontSize;
        text.alignment = alignment;
        text.color = Color.white;
        text.textWrappingMode = TextWrappingModes.Normal;
        text.raycastTarget = false;

        TMP_FontAsset defaultFont = TMP_Settings.defaultFontAsset;
        if (defaultFont != null)
        {
            text.font = defaultFont;
        }

        return text;
    }

    private static void SetAnchors(RectTransform rect, Vector2 anchorMin, Vector2 anchorMax)
    {
        rect.anchorMin = anchorMin;
        rect.anchorMax = anchorMax;
        rect.offsetMin = Vector2.zero;
        rect.offsetMax = Vector2.zero;
    }

    private static void AttachStretch(RectTransform rect, Transform parent, Vector2 offsetMin, Vector2 offsetMax)
    {
        rect.SetParent(parent, false);
        rect.anchorMin = Vector2.zero;
        rect.anchorMax = Vector2.one;
        rect.offsetMin = offsetMin;
        rect.offsetMax = offsetMax;
    }

    private static void EnsureEventSystem()
    {
        EventSystem eventSystem = FindAnyObjectByType<EventSystem>();
        if (eventSystem == null)
        {
            GameObject eventSystemObject = new GameObject("EventSystem");
            eventSystem = eventSystemObject.AddComponent<EventSystem>();
#if ENABLE_INPUT_SYSTEM
            eventSystemObject.AddComponent<UnityEngine.InputSystem.UI.InputSystemUIInputModule>();
#else
            eventSystemObject.AddComponent<StandaloneInputModule>();
#endif
        }
#if ENABLE_INPUT_SYSTEM
        else if (eventSystem.GetComponent<StandaloneInputModule>() != null)
        {
            UnityEngine.Object.Destroy(eventSystem.GetComponent<StandaloneInputModule>());
            eventSystem.gameObject.AddComponent<UnityEngine.InputSystem.UI.InputSystemUIInputModule>();
        }
#endif
    }
}
