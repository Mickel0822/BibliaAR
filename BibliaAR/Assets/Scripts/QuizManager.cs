using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using TMPro;
using Action = System.Action;

public class QuizManager : MonoBehaviour
{
    public event Action QuizClosed;

    [System.Serializable]
    public class Question
    {
        public string questionText;
        public string[] options;
        public int correctAnswerIndex;
    }

    private List<Question> questionPool = new List<Question>();
    private List<Question> questions = new List<Question>();
    private int currentQuestionIndex = 0;
    private int score = 0;
    private bool isTransitioning = false;
    [SerializeField] private bool startAutomatically = false;
    private bool uiInitialized = false;
    private GameObject canvasRoot;

    // UI References generated at runtime
    private Canvas canvas;
    private RectTransform quizPanel;
    private RectTransform resultPanel;
    private TextMeshProUGUI progressText;
    private TextMeshProUGUI questionText;
    private List<Button> optionButtons = new List<Button>();
    private List<TextMeshProUGUI> optionTexts = new List<TextMeshProUGUI>();
    private List<Image> starImages = new List<Image>();
    
    // Generated UI assets to prevent memory leaks
    private Sprite starSprite;
    private Sprite cardSprite;
    private List<GameObject> activeConfetti = new List<GameObject>();
    
    // Result UI References
    private TextMeshProUGUI resultTitleText;
    private TextMeshProUGUI resultBodyText;
    private Button closeButton;

    // Premium Color Palette (Sleek Dark Mode)
    private Color colorBackground = new Color32(18, 18, 22, 255);       // Slate Black (#121216)
    private Color colorCard = new Color32(30, 30, 40, 255);             // Dark Grey (#1E1E28)
    private Color colorTextWhite = new Color32(255, 255, 255, 255);     // Pure White (#FFFFFF)
    private Color colorTextMuted = new Color32(160, 166, 178, 255);     // Muted Blue-Grey (#A0A6B2)
    private Color colorAccent = new Color32(99, 102, 241, 255);         // Indigo Accent (#6366F1)
    private Color colorSuccess = new Color32(16, 185, 129, 255);        // Emerald Green (#10B981)
    private Color colorError = new Color32(239, 68, 68, 255);           // Rose Red (#EF4444)
    private Color colorButtonNormal = new Color32(45, 45, 58, 255);     // Card Button Slate (#2D2D3A)

    private void Awake()
    {
        InitializeQuestions();
        if (startAutomatically)
        {
            BeginQuiz();
        }
    }

    public void BeginQuiz()
    {
        if (!uiInitialized)
        {
            SetupUI();
            uiInitialized = true;
        }

        score = 0;
        currentQuestionIndex = 0;
        isTransitioning = false;
        ClearConfetti();

        if (canvasRoot != null)
        {
            canvasRoot.SetActive(true);
        }

        resultPanel.gameObject.SetActive(false);
        quizPanel.gameObject.SetActive(true);
        SelectRandomQuestions();
        ShowQuestion(0);
    }

    public void HideQuiz()
    {
        ClearConfetti();

        if (canvasRoot != null)
        {
            canvasRoot.SetActive(false);
        }
    }

    private void OnDestroy()
    {
        // Clean up generated assets to prevent memory leaks
        if (starSprite != null)
        {
            if (starSprite.texture != null)
            {
                Destroy(starSprite.texture);
            }
            Destroy(starSprite);
        }

        if (cardSprite != null)
        {
            if (cardSprite.texture != null)
            {
                Destroy(cardSprite.texture);
            }
            Destroy(cardSprite);
        }
    }

    private void InitializeQuestions()
    {
        // Question 1
        questionPool.Add(new Question
        {
            questionText = "¿Quién se detuvo a ayudar al hombre herido en el camino de Jerusalén a Jericó?",
            options = new string[] { "Un sacerdote", "Un levita", "Un samaritano" },
            correctAnswerIndex = 2
        });

        // Question 2
        questionPool.Add(new Question
        {
            questionText = "¿Qué hizo el samaritano por el hombre herido?",
            options = new string[] { 
                "Ignorarlo y seguir de largo", 
                "Curar sus heridas, llevarlo en su asno y pagar por su hospedaje", 
                "Llamar a los guardias para que lo rescataran" 
            },
            correctAnswerIndex = 1
        });

        // Question 3
        questionPool.Add(new Question
        {
            questionText = "¿Cuál es la principal enseñanza de la parábola del Buen Samaritano?",
            options = new string[] { 
                "Que debemos ayudar a quienes lo necesitan, sin importar quiénes sean", 
                "Que los caminos antiguos eran muy peligrosos", 
                "Que no debemos viajar solos por la noche" 
            },
            correctAnswerIndex = 0
        });

        // Question 4
        questionPool.Add(new Question
        {
            questionText = "¿Qué hicieron el sacerdote y el levita al ver al hombre herido en el camino?",
            options = new string[] { 
                "Se acercaron rápidamente para curarlo", 
                "Pasaron por el otro lado de la calle y continuaron de largo", 
                "Buscaron a los guardias del templo para ayudar" 
            },
            correctAnswerIndex = 1
        });

        // Question 5
        questionPool.Add(new Question
        {
            questionText = "¿A qué lugar llevó el samaritano al hombre herido para cuidarlo con más calma?",
            options = new string[] { 
                "A su propia casa familiar", 
                "A un hospital de la gran ciudad", 
                "A un alojamiento (un mesón) y pagó por su estadía" 
            },
            correctAnswerIndex = 2
        });

        // Question 6
        questionPool.Add(new Question
        {
            questionText = "¿Quién le hizo a Jesús la pregunta '¿quién es mi prójimo?' desencadenando la parábola?",
            options = new string[] { 
                "Un doctor de la ley (un intérprete de la ley)", 
                "Uno de sus doce apóstoles", 
                "Un cobrador de impuestos del imperio romano" 
            },
            correctAnswerIndex = 0
        });
    }

    // Selects 3 random unique questions from the pool of 6 questions
    private void SelectRandomQuestions()
    {
        questions.Clear();
        List<Question> poolCopy = new List<Question>(questionPool);

        for (int i = 0; i < 3; i++)
        {
            if (poolCopy.Count == 0) break;
            int randomIndex = Random.Range(0, poolCopy.Count);
            questions.Add(poolCopy[randomIndex]);
            poolCopy.RemoveAt(randomIndex); // Avoid selecting duplicates in the same round
        }
    }

    // Procedural Star Sprite Generator (creates a clean anti-aliased 5-point star vector sprite)
    private Sprite CreateStarSprite()
    {
        int size = 128;
        Texture2D tex = new Texture2D(size, size, TextureFormat.RGBA32, false);
        Vector2 center = new Vector2(size / 2f, size / 2f);
        
        // Vertices logic: 10 points (5 outer, 5 inner)
        Vector2[] vertices = GetStarVertices(center, 5, 55f, 22f);

        for (int y = 0; y < size; y++)
        {
            for (int x = 0; x < size; x++)
            {
                // Super-sampling 2x2 for smooth edges
                float insideCount = 0f;
                Vector2[] subOffsets = new Vector2[] {
                    new Vector2(0.25f, 0.25f),
                    new Vector2(0.25f, 0.75f),
                    new Vector2(0.75f, 0.25f),
                    new Vector2(0.75f, 0.75f)
                };

                foreach (var offset in subOffsets)
                {
                    Vector2 p = new Vector2(x + offset.x, y + offset.y);
                    if (IsPointInStarPoly(p, center, vertices))
                    {
                        insideCount += 0.25f;
                    }
                }

                if (insideCount > 0f)
                {
                    tex.SetPixel(x, y, new Color(1f, 1f, 1f, insideCount));
                }
                else
                {
                    tex.SetPixel(x, y, new Color(0f, 0f, 0f, 0f));
                }
            }
        }

        tex.Apply();
        return Sprite.Create(tex, new Rect(0, 0, size, size), new Vector2(0.5f, 0.5f));
    }

    private Vector2[] GetStarVertices(Vector2 center, int points, float outerRadius, float innerRadius)
    {
        int numVertices = points * 2;
        Vector2[] vertices = new Vector2[numVertices];
        float angleStep = 360f / numVertices;
        float startAngle = -90f; // Align first vertex pointing straight up

        for (int i = 0; i < numVertices; i++)
        {
            float angle = (startAngle + i * angleStep) * Mathf.Deg2Rad;
            float r = (i % 2 == 0) ? outerRadius : innerRadius;
            vertices[i] = center + new Vector2(Mathf.Cos(angle), Mathf.Sin(angle)) * r;
        }
        return vertices;
    }

    private bool IsPointInStarPoly(Vector2 p, Vector2 center, Vector2[] vertices)
    {
        for (int i = 0; i < 10; i++)
        {
            if (IsPointInTriangle(p, center, vertices[i], vertices[(i + 1) % 10]))
            {
                return true;
            }
        }
        return false;
    }

    private bool IsPointInTriangle(Vector2 p, Vector2 a, Vector2 b, Vector2 c)
    {
        float d1 = Sign(p, a, b);
        float d2 = Sign(p, b, c);
        float d3 = Sign(p, c, a);

        bool has_neg = (d1 < 0) || (d2 < 0) || (d3 < 0);
        bool has_pos = (d1 > 0) || (d2 > 0) || (d3 > 0);

        return !(has_neg && has_pos);
    }

    private float Sign(Vector2 p1, Vector2 p2, Vector2 p3)
    {
        return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
    }

    // Procedural Rounded Rectangle Sprite Generator (anti-aliased corners, ready for 9-slice resizing)
    private Sprite CreateRoundedRectSprite(int size, float radius)
    {
        Texture2D tex = new Texture2D(size, size, TextureFormat.RGBA32, false);
        float r = radius;
        float limitLower = r;
        float limitUpper = size - r;

        for (int y = 0; y < size; y++)
        {
            for (int x = 0; x < size; x++)
            {
                // Super-sampling 2x2 for smooth round edges
                float insideCount = 0f;
                Vector2[] subOffsets = new Vector2[] {
                    new Vector2(0.25f, 0.25f),
                    new Vector2(0.25f, 0.75f),
                    new Vector2(0.75f, 0.25f),
                    new Vector2(0.75f, 0.75f)
                };

                foreach (var offset in subOffsets)
                {
                    float px = x + offset.x;
                    float py = y + offset.y;

                    if (IsPointInRoundedRect(px, py, size, r, limitLower, limitUpper))
                    {
                        insideCount += 0.25f;
                    }
                }

                if (insideCount > 0f)
                {
                    tex.SetPixel(x, y, new Color(1f, 1f, 1f, insideCount));
                }
                else
                {
                    tex.SetPixel(x, y, new Color(0f, 0f, 0f, 0f));
                }
            }
        }

        tex.Apply();
        
        // Setup 9-slice border borders so corners don't deform on stretching
        Vector4 border = new Vector4(r, r, r, r);
        return Sprite.Create(tex, new Rect(0, 0, size, size), new Vector2(0.5f, 0.5f), 100f, 0, SpriteMeshType.Tight, border);
    }

    private bool IsPointInRoundedRect(float x, float y, float size, float r, float limitLower, float limitUpper)
    {
        // Inside main vertical or horizontal rectangles
        if (x >= limitLower && x <= limitUpper) return true;
        if (y >= limitLower && y <= limitUpper) return true;

        // Inside one of the 4 corners
        if (x < limitLower && y < limitLower)
        {
            return Vector2.Distance(new Vector2(x, y), new Vector2(limitLower, limitLower)) <= r;
        }
        if (x > limitUpper && y < limitLower)
        {
            return Vector2.Distance(new Vector2(x, y), new Vector2(limitUpper, limitLower)) <= r;
        }
        if (x < limitLower && y > limitUpper)
        {
            return Vector2.Distance(new Vector2(x, y), new Vector2(limitLower, limitUpper)) <= r;
        }
        if (x > limitUpper && y > limitUpper)
        {
            return Vector2.Distance(new Vector2(x, y), new Vector2(limitUpper, limitUpper)) <= r;
        }

        return false;
    }

    // Helper to programmatically create TMPro text objects with RectTransform and default fonts
    private TextMeshProUGUI CreateTextObject(string name, Transform parent, string initialText, float fontSize, TextAlignmentOptions alignment, Color color)
    {
        GameObject go = new GameObject(name, typeof(RectTransform));
        go.transform.SetParent(parent, false);
        
        TextMeshProUGUI textComponent = go.AddComponent<TextMeshProUGUI>();
        textComponent.text = initialText;
        textComponent.fontSize = fontSize;
        textComponent.alignment = alignment;
        textComponent.color = color;
        textComponent.textWrappingMode = TextWrappingModes.Normal;
        
        // Force assignment of TMPro default font
        TMP_FontAsset defaultFont = TMP_Settings.defaultFontAsset;
        if (defaultFont == null)
        {
            // Fallback load from standard TMPro path inside Resources
            defaultFont = Resources.Load<TMP_FontAsset>("Fonts & Materials/LiberationSans SDF");
        }
        
        if (defaultFont != null)
        {
            textComponent.font = defaultFont;
        }
        else
        {
            Debug.LogWarning("TextMeshPro default font not found. Please click 'Window > TextMeshPro > Import TMP Essential Resources' in Unity.");
        }
        
        return textComponent;
    }

    private void SetupUI()
    {
        // 1. Ensure EventSystem exists and is compatible with the active Input System
        EventSystem existingEventSystem = FindAnyObjectByType<EventSystem>();
        if (existingEventSystem == null)
        {
            GameObject eventSystemGo = new GameObject("EventSystem");
            existingEventSystem = eventSystemGo.AddComponent<EventSystem>();
#if ENABLE_INPUT_SYSTEM
            eventSystemGo.AddComponent<UnityEngine.InputSystem.UI.InputSystemUIInputModule>();
#else
            eventSystemGo.AddComponent<StandaloneInputModule>();
#endif
        }
        else
        {
            // If an EventSystem already exists in the scene, check for Input System compatibility
#if ENABLE_INPUT_SYSTEM
            StandaloneInputModule oldModule = existingEventSystem.GetComponent<StandaloneInputModule>();
            if (oldModule != null)
            {
                Destroy(oldModule);
                existingEventSystem.gameObject.AddComponent<UnityEngine.InputSystem.UI.InputSystemUIInputModule>();
            }
#endif
        }

        // 2. Generate Rounded Corner Sprite (9-slicable)
        cardSprite = CreateRoundedRectSprite(128, 28f);

        // 3. Create Canvas GameObject
        GameObject canvasGo = new GameObject("QuizCanvas");
        canvasRoot = canvasGo;
        canvas = canvasGo.AddComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        canvas.sortingOrder = 50;
        
        CanvasScaler scaler = canvasGo.AddComponent<CanvasScaler>();
        scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        scaler.referenceResolution = new Vector2(1080, 1920); // Mobile vertical standard
        scaler.screenMatchMode = CanvasScaler.ScreenMatchMode.MatchWidthOrHeight;
        scaler.matchWidthOrHeight = 0.5f;

        canvasGo.AddComponent<GraphicRaycaster>();

        // 4. Create Fullscreen Background
        GameObject bgGo = new GameObject("Background", typeof(RectTransform));
        bgGo.transform.SetParent(canvasGo.transform, false);
        Image bgImg = bgGo.AddComponent<Image>();
        bgImg.color = colorBackground;
        RectTransform bgRect = bgGo.GetComponent<RectTransform>();
        bgRect.anchorMin = Vector2.zero;
        bgRect.anchorMax = Vector2.one;
        bgRect.sizeDelta = Vector2.zero;

        // 5. Create Main Quiz Panel (Rounded Card container)
        GameObject quizPanelGo = new GameObject("QuizPanel", typeof(RectTransform));
        quizPanelGo.transform.SetParent(canvasGo.transform, false);
        quizPanel = quizPanelGo.GetComponent<RectTransform>();
        quizPanel.anchorMin = new Vector2(0.5f, 0.5f);
        quizPanel.anchorMax = new Vector2(0.5f, 0.5f);
        quizPanel.pivot = new Vector2(0.5f, 0.5f);
        quizPanel.sizeDelta = new Vector2(900, 1400); // Card aspect ratio
        
        Image quizPanelImg = quizPanelGo.AddComponent<Image>();
        quizPanelImg.sprite = cardSprite;
        quizPanelImg.type = Image.Type.Sliced;
        quizPanelImg.color = colorCard;

        // 6. Add Header / Progress Text
        progressText = CreateTextObject("ProgressText", quizPanel, "Pregunta 1 de 3", 32, TextAlignmentOptions.Center, colorTextMuted);
        RectTransform progressRect = progressText.GetComponent<RectTransform>();
        progressRect.anchorMin = new Vector2(0.1f, 0.9f);
        progressRect.anchorMax = new Vector2(0.9f, 0.95f);
        progressRect.sizeDelta = Vector2.zero;

        // 7. Add Question Text
        questionText = CreateTextObject("QuestionText", quizPanel, "¿Pregunta?", 46, TextAlignmentOptions.Center, colorTextWhite);
        RectTransform questionRect = questionText.GetComponent<RectTransform>();
        questionRect.anchorMin = new Vector2(0.08f, 0.65f);
        questionRect.anchorMax = new Vector2(0.92f, 0.88f);
        questionRect.sizeDelta = Vector2.zero;

        // 8. Add Vertical Layout Group for Buttons
        GameObject optionsContainerGo = new GameObject("OptionsContainer", typeof(RectTransform));
        optionsContainerGo.transform.SetParent(quizPanel, false);
        RectTransform optionsContainerRect = optionsContainerGo.GetComponent<RectTransform>();
        optionsContainerRect.anchorMin = new Vector2(0.08f, 0.1f);
        optionsContainerRect.anchorMax = new Vector2(0.92f, 0.6f);
        optionsContainerRect.sizeDelta = Vector2.zero;

        VerticalLayoutGroup layoutGroup = optionsContainerGo.AddComponent<VerticalLayoutGroup>();
        layoutGroup.spacing = 40f;
        layoutGroup.childAlignment = TextAnchor.MiddleCenter;
        layoutGroup.childControlHeight = true;
        layoutGroup.childControlWidth = true;
        layoutGroup.childForceExpandHeight = false;
        layoutGroup.childForceExpandWidth = true;

        // Create 3 Rounded Option Buttons dynamically
        for (int i = 0; i < 3; i++)
        {
            int index = i;
            GameObject buttonGo = new GameObject($"OptionButton_{i}", typeof(RectTransform));
            buttonGo.transform.SetParent(optionsContainerRect, false);
            
            // Add UI components with rounded sliced sprite
            Image btnImg = buttonGo.AddComponent<Image>();
            btnImg.sprite = cardSprite;
            btnImg.type = Image.Type.Sliced;
            btnImg.color = colorButtonNormal;
            
            Button btn = buttonGo.AddComponent<Button>();
            
            // Add Button Text using helper
            TextMeshProUGUI btnText = CreateTextObject("Text", buttonGo.transform, $"Opción {i + 1}", 36, TextAlignmentOptions.Center, colorTextWhite);

            // Padding for text inside button
            RectTransform textRect = btnText.GetComponent<RectTransform>();
            textRect.anchorMin = Vector2.zero;
            textRect.anchorMax = Vector2.one;
            textRect.sizeDelta = new Vector2(-40, -40); // Inner margin padding

            // Layout Element to give it height
            LayoutElement layoutEl = buttonGo.AddComponent<LayoutElement>();
            layoutEl.preferredHeight = 160f; // Tall enough for mobile touch targets

            // Register Click Event
            btn.onClick.AddListener(() => OnOptionClicked(index, btn));
            
            // Add Premium Hover and Feedback effects
            buttonGo.AddComponent<QuizButtonEffects>().Initialize(colorButtonNormal, colorAccent);

            optionButtons.Add(btn);
            optionTexts.Add(btnText);
        }

        // 9. Setup Result Panel (Rounded Card container, Initially Inactive)
        GameObject resultPanelGo = new GameObject("ResultPanel", typeof(RectTransform));
        resultPanelGo.transform.SetParent(canvasGo.transform, false);
        resultPanel = resultPanelGo.GetComponent<RectTransform>();
        resultPanel.anchorMin = new Vector2(0.5f, 0.5f);
        resultPanel.anchorMax = new Vector2(0.5f, 0.5f);
        resultPanel.pivot = new Vector2(0.5f, 0.5f);
        resultPanel.sizeDelta = new Vector2(900, 1400);

        Image resultPanelImg = resultPanelGo.AddComponent<Image>();
        resultPanelImg.sprite = cardSprite;
        resultPanelImg.type = Image.Type.Sliced;
        resultPanelImg.color = colorCard;

        // 10. Setup Stars Container
        GameObject starsGo = new GameObject("StarsContainer", typeof(RectTransform));
        starsGo.transform.SetParent(resultPanel, false);
        RectTransform starsRect = starsGo.GetComponent<RectTransform>();
        starsRect.anchorMin = new Vector2(0.1f, 0.65f);
        starsRect.anchorMax = new Vector2(0.9f, 0.82f);
        starsRect.sizeDelta = Vector2.zero;

        HorizontalLayoutGroup starsLayout = starsGo.AddComponent<HorizontalLayoutGroup>();
        starsLayout.spacing = 50f;
        starsLayout.childAlignment = TextAnchor.MiddleCenter;
        starsLayout.childControlHeight = false; // Prevent layout group from forcing vertical stretching
        starsLayout.childControlWidth = false;
        starsLayout.childForceExpandHeight = false;
        starsLayout.childForceExpandWidth = false;

        // Generate procedural Star Sprite
        starSprite = CreateStarSprite();

        for (int i = 0; i < 3; i++)
        {
            GameObject starGo = new GameObject($"Star_{i}", typeof(RectTransform));
            starGo.transform.SetParent(starsGo.transform, false);
            
            RectTransform starRectTrans = starGo.GetComponent<RectTransform>();
            starRectTrans.sizeDelta = new Vector2(130f, 130f); // Force perfect square bounds
            
            Image starImg = starGo.AddComponent<Image>();
            starImg.sprite = starSprite;
            starImg.color = colorTextMuted; // Set initial color
            starImg.preserveAspect = true;  // Keep 1:1 ratio
            
            starGo.transform.localScale = Vector3.zero; // Animate in on results
            starImages.Add(starImg);
        }

        // Congratulations Title Text
        resultTitleText = CreateTextObject("ResultTitle", resultPanel, "¡Felicitaciones!", 58, TextAlignmentOptions.Center, new Color32(251, 191, 36, 255));
        RectTransform rTitleRect = resultTitleText.GetComponent<RectTransform>();
        rTitleRect.anchorMin = new Vector2(0.1f, 0.48f);
        rTitleRect.anchorMax = new Vector2(0.9f, 0.62f);
        rTitleRect.sizeDelta = Vector2.zero;

        // Congratulations Body Text
        resultBodyText = CreateTextObject("ResultBody", resultPanel, "", 38, TextAlignmentOptions.Center, colorTextWhite);
        RectTransform rBodyRect = resultBodyText.GetComponent<RectTransform>();
        rBodyRect.anchorMin = new Vector2(0.08f, 0.22f);
        rBodyRect.anchorMax = new Vector2(0.92f, 0.46f);
        rBodyRect.sizeDelta = Vector2.zero;

        // Close / Final Button (Rounded Accent Button)
        GameObject closeGo = new GameObject("CloseButton", typeof(RectTransform));
        closeGo.transform.SetParent(resultPanel, false);
        Image closeImg = closeGo.AddComponent<Image>();
        closeImg.sprite = cardSprite;
        closeImg.type = Image.Type.Sliced;
        closeImg.color = colorAccent;
        
        closeButton = closeGo.AddComponent<Button>();
        
        // Button Text
        TextMeshProUGUI closeText = CreateTextObject("Text", closeGo.transform, "Cerrar", 38, TextAlignmentOptions.Center, colorTextWhite);
        RectTransform rTextRect = closeText.GetComponent<RectTransform>();
        rTextRect.anchorMin = Vector2.zero;
        rTextRect.anchorMax = Vector2.one;
        rTextRect.sizeDelta = Vector2.zero;

        RectTransform closeRect = closeGo.GetComponent<RectTransform>();
        closeRect.anchorMin = new Vector2(0.15f, 0.08f);
        closeRect.anchorMax = new Vector2(0.85f, 0.18f);
        closeRect.sizeDelta = Vector2.zero;

        closeButton.onClick.AddListener(CloseQuiz);
        closeGo.AddComponent<QuizButtonEffects>().Initialize(colorAccent, new Color32(79, 70, 229, 255));

        // Hide result panel at start
        resultPanel.gameObject.SetActive(false);
    }

    private void ShowQuestion(int index)
    {
        if (index < 0 || index >= questions.Count) return;

        isTransitioning = false;
        currentQuestionIndex = index;
        Question q = questions[index];

        progressText.text = $"Pregunta {index + 1} de {questions.Count}";
        questionText.text = q.questionText;

        // Reset and set button texts
        for (int i = 0; i < optionButtons.Count; i++)
        {
            optionButtons[i].interactable = true;
            optionButtons[i].GetComponent<Image>().color = colorButtonNormal;
            
            if (i < q.options.Length)
            {
                optionButtons[i].gameObject.SetActive(true);
                optionTexts[i].text = q.options[i];
            }
            else
            {
                optionButtons[i].gameObject.SetActive(false);
            }
        }

        // Animate question fade in
        StartCoroutine(FadeInPanel(quizPanel, 0.2f));
    }

    private void OnOptionClicked(int selectedIndex, Button clickedButton)
    {
        if (isTransitioning) return;
        isTransitioning = true;

        Question currentQuestion = questions[currentQuestionIndex];
        bool isCorrect = (selectedIndex == currentQuestion.correctAnswerIndex);
        if (isCorrect)
        {
            score++;
            // Trigger a localized celebration burst from the tapped button
            StartCoroutine(SpawnConfettiBurstRoutine(clickedButton.GetComponent<RectTransform>()));
        }

        // Disable interaction during feedback
        foreach (Button btn in optionButtons)
        {
            btn.interactable = false;
        }

        StartCoroutine(AnimateFeedback(isCorrect, clickedButton));
    }

    private IEnumerator AnimateFeedback(bool isCorrect, Button clickedButton)
    {
        Image btnImg = clickedButton.GetComponent<Image>();
        
        if (isCorrect)
        {
            btnImg.color = colorSuccess;
            
            // Pop effect
            Vector3 origScale = clickedButton.transform.localScale;
            float timer = 0f;
            while (timer < 0.2f)
            {
                timer += Time.deltaTime;
                clickedButton.transform.localScale = origScale * (1f + Mathf.Sin(timer * Mathf.PI / 0.2f) * 0.1f);
                yield return null;
            }
            clickedButton.transform.localScale = origScale;
        }
        else
        {
            btnImg.color = colorError;
            
            // Show the correct answer as well in Green
            int correctIdx = questions[currentQuestionIndex].correctAnswerIndex;
            optionButtons[correctIdx].GetComponent<Image>().color = colorSuccess;

            // Shake card animation
            Vector3 originalPos = quizPanel.localPosition;
            float elapsed = 0f;
            float duration = 0.4f;
            float magnitude = 15f;

            while (elapsed < duration)
            {
                float x = Random.Range(-1f, 1f) * magnitude;
                quizPanel.localPosition = new Vector3(originalPos.x + x, originalPos.y, originalPos.z);
                elapsed += Time.deltaTime;
                yield return null;
            }
            quizPanel.localPosition = originalPos;
        }

        yield return new WaitForSeconds(1.2f);

        // Next Question or End Screen
        if (currentQuestionIndex + 1 < questions.Count)
        {
            ShowQuestion(currentQuestionIndex + 1);
        }
        else
        {
            ShowResultScreen();
        }
    }

    private void ShowResultScreen()
    {
        ClearConfetti();
        quizPanel.gameObject.SetActive(false);
        resultPanel.gameObject.SetActive(true);

        // Dynamically update congratulatory text based on the user's score
        if (score == questions.Count)
        {
            resultTitleText.text = "¡Excelente!";
            resultTitleText.color = new Color32(251, 191, 36, 255); // Amber Gold
            resultBodyText.text = "Has contestado todas las preguntas correctamente y completado la actividad sobre el Buen Samaritano con éxito.";
        }
        else
        {
            resultTitleText.text = "Actividad Completada";
            resultTitleText.color = colorTextWhite;
            
            if (score == 0)
            {
                resultBodyText.text = "No has acertado ninguna respuesta en esta ocasión.\n\n¡No te preocupes! Vuelve a leer la historia e inténtalo de nuevo.";
            }
            else
            {
                resultBodyText.text = $"Has finalizado la actividad con {score} de {questions.Count} respuestas correctas.\n\n¡Puedes volver a intentarlo para conseguir una puntuación perfecta!";
            }
        }
        
        // Pop result panel and run animations
        StartCoroutine(FadeInPanel(resultPanel, 0.35f));
        StartCoroutine(AnimateResultScreen(score));
    }

    private void CloseQuiz()
    {
        HideQuiz();
        QuizClosed?.Invoke();
    }

    private void ClearConfetti()
    {
        foreach (GameObject c in activeConfetti)
        {
            if (c != null) Destroy(c);
        }
        activeConfetti.Clear();
    }

    private IEnumerator AnimateResultScreen(int finalScore)
    {
        // 1. Reset all stars
        for (int i = 0; i < starImages.Count; i++)
        {
            starImages[i].transform.localScale = Vector3.zero;
            
            // Color stars: gold for correct, dark/muted for incorrect
            if (i < finalScore)
            {
                starImages[i].color = new Color32(251, 191, 36, 255); // Gold
            }
            else
            {
                starImages[i].color = new Color32(75, 85, 99, 255); // Dark Slate Grey (#4B5563)
            }
        }

        yield return new WaitForSeconds(0.2f);

        // 2. Scale up stars one by one with bounce
        for (int i = 0; i < starImages.Count; i++)
        {
            StartCoroutine(BounceScale(starImages[i].transform, 0.3f));
            yield return new WaitForSeconds(0.2f);
        }

        // 3. Trigger animations based on score
        if (finalScore == questions.Count)
        {
            // Victory confetti!
            StartCoroutine(SpawnConfettiRoutine());
        }
        else if (finalScore == 0)
        {
            // Disappointment wobble!
            StartCoroutine(WobbleStarsRoutine());
        }
    }

    private IEnumerator BounceScale(Transform target, float duration)
    {
        float elapsed = 0f;
        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / duration;
            // Sinusoidal bounce curve
            float scale = Mathf.Lerp(0f, 1f, t) + Mathf.Sin(t * Mathf.PI) * 0.2f;
            target.localScale = Vector3.one * scale;
            yield return null;
        }
        target.localScale = Vector3.one;
    }

    private IEnumerator WobbleStarsRoutine()
    {
        float elapsed = 0f;
        float duration = 1.5f;
        
        // Stars parent container
        Transform container = starImages[0].transform.parent;
        Vector3 originalPos = container.localPosition;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            // Fast shake side to side
            float offset = Mathf.Sin(elapsed * 40f) * 12f * (1f - (elapsed / duration));
            container.localPosition = originalPos + new Vector3(offset, 0f, 0f);
            yield return null;
        }
        container.localPosition = originalPos;
    }

    private IEnumerator SpawnConfettiRoutine()
    {
        int count = 50;
        Color[] colors = new Color[] {
            new Color32(236, 72, 153, 255),  // Pink
            new Color32(59, 130, 246, 255),  // Blue
            new Color32(16, 185, 129, 255),  // Green
            new Color32(245, 158, 11, 255),  // Orange
            new Color32(239, 68, 68, 255),   // Red
            new Color32(168, 85, 247, 255)   // Purple
        };

        for (int i = 0; i < count; i++)
        {
            GameObject confetti = new GameObject("Confetti", typeof(RectTransform));
            confetti.transform.SetParent(resultPanel, false);
            activeConfetti.Add(confetti);

            Image img = confetti.AddComponent<Image>();
            img.color = colors[Random.Range(0, colors.Length)];

            RectTransform rect = confetti.GetComponent<RectTransform>();
            // Spawn at random top coordinates
            rect.anchorMin = new Vector2(0.5f, 0.5f);
            rect.anchorMax = new Vector2(0.5f, 0.5f);
            rect.pivot = new Vector2(0.5f, 0.5f);
            
            float startX = Random.Range(-450f, 450f);
            float startY = 750f; // Above the card
            rect.anchoredPosition = new Vector2(startX, startY);

            // Random size
            float size = Random.Range(15f, 30f);
            rect.sizeDelta = new Vector2(size, size);

            StartCoroutine(AnimateConfettiPiece(rect, img));
            yield return new WaitForSeconds(0.02f);
        }
    }

    private IEnumerator AnimateConfettiPiece(RectTransform rect, Image img)
    {
        float elapsed = 0f;
        float duration = Random.Range(2.5f, 4f);
        Vector2 pos = rect.anchoredPosition;
        float fallSpeed = Random.Range(250f, 450f);
        float waveSpeed = Random.Range(2f, 5f);
        float waveMagnitude = Random.Range(30f, 80f);
        float rotationSpeedX = Random.Range(100f, 300f);
        float rotationSpeedY = Random.Range(100f, 300f);
        float rotationSpeedZ = Random.Range(100f, 300f);

        while (elapsed < duration && rect != null)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / duration;

            // Fall down
            pos.y -= fallSpeed * Time.deltaTime;
            // Sway left/right
            pos.x += Mathf.Sin(elapsed * waveSpeed) * waveMagnitude * Time.deltaTime;

            rect.anchoredPosition = pos;

            // Rotate in 3D space
            rect.Rotate(new Vector3(rotationSpeedX, rotationSpeedY, rotationSpeedZ) * Time.deltaTime);

            // Fade out near the end
            if (t > 0.7f)
            {
                Color c = img.color;
                c.a = Mathf.Lerp(1f, 0f, (t - 0.7f) / 0.3f);
                img.color = c;
            }

            yield return null;
        }

        if (rect != null)
        {
            activeConfetti.Remove(rect.gameObject);
            Destroy(rect.gameObject);
        }
    }

    private IEnumerator FadeInPanel(RectTransform panel, float duration)
    {
        CanvasGroup cg = panel.GetComponent<CanvasGroup>();
        if (cg == null) cg = panel.gameObject.AddComponent<CanvasGroup>();

        float elapsed = 0f;
        panel.localScale = Vector3.one * 0.95f;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / duration;
            cg.alpha = Mathf.Lerp(0f, 1f, t);
            panel.localScale = Vector3.Lerp(Vector3.one * 0.95f, Vector3.one, t);
            yield return null;
        }

        cg.alpha = 1f;
        panel.localScale = Vector3.one;
    }

    private IEnumerator SpawnConfettiBurstRoutine(RectTransform buttonRect)
    {
        int count = 20;
        Color[] colors = new Color[] {
            new Color32(236, 72, 153, 255),  // Pink
            new Color32(59, 130, 246, 255),  // Blue
            new Color32(16, 185, 129, 255),  // Green
            new Color32(245, 158, 11, 255),  // Orange
            new Color32(239, 68, 68, 255),   // Red
            new Color32(168, 85, 247, 255)   // Purple
        };

        // Convert the button's world position to quizPanel space so confetti renders on top of the card
        Vector3 worldPos = buttonRect.position;
        Vector2 localPos;
        RectTransformUtility.ScreenPointToLocalPointInRectangle(quizPanel, RectTransformUtility.WorldToScreenPoint(null, worldPos), null, out localPos);

        for (int i = 0; i < count; i++)
        {
            GameObject confetti = new GameObject("BurstConfetti", typeof(RectTransform));
            confetti.transform.SetParent(quizPanel, false);
            activeConfetti.Add(confetti);

            Image img = confetti.AddComponent<Image>();
            img.color = colors[Random.Range(0, colors.Length)];

            RectTransform rect = confetti.GetComponent<RectTransform>();
            rect.anchorMin = new Vector2(0.5f, 0.5f);
            rect.anchorMax = new Vector2(0.5f, 0.5f);
            rect.pivot = new Vector2(0.5f, 0.5f);
            rect.anchoredPosition = localPos;

            // Random size
            float size = Random.Range(12f, 22f);
            rect.sizeDelta = new Vector2(size, size);

            StartCoroutine(AnimateConfettiBurstPiece(rect, img));
        }
        yield break;
    }

    private IEnumerator AnimateConfettiBurstPiece(RectTransform rect, Image img)
    {
        float elapsed = 0f;
        float duration = Random.Range(1.2f, 2.0f);
        Vector2 pos = rect.anchoredPosition;

        // Shoot out in a random direction (upward arc)
        float angle = Random.Range(30f, 150f) * Mathf.Deg2Rad;
        float force = Random.Range(300f, 650f);
        Vector2 velocity = new Vector2(Mathf.Cos(angle), Mathf.Sin(angle)) * force;

        float gravity = 900f;
        float drag = 1.5f;

        float rotationSpeedX = Random.Range(150f, 400f);
        float rotationSpeedY = Random.Range(150f, 400f);
        float rotationSpeedZ = Random.Range(150f, 400f);

        while (elapsed < duration && rect != null)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / duration;

            // Apply physical movement forces
            velocity.y -= gravity * Time.deltaTime;
            velocity.x = Mathf.Lerp(velocity.x, 0f, drag * Time.deltaTime);

            pos += velocity * Time.deltaTime;
            rect.anchoredPosition = pos;

            // Spin it
            rect.Rotate(new Vector3(rotationSpeedX, rotationSpeedY, rotationSpeedZ) * Time.deltaTime);

            // Fade out
            if (t > 0.5f)
            {
                Color c = img.color;
                c.a = Mathf.Lerp(1f, 0f, (t - 0.5f) / 0.5f);
                img.color = c;
            }

            yield return null;
        }

        if (rect != null)
        {
            activeConfetti.Remove(rect.gameObject);
            Destroy(rect.gameObject);
        }
    }
}

// Helper class for Premium UI interactions
public class QuizButtonEffects : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler, IPointerDownHandler, IPointerUpHandler
{
    private Color normalColor;
    private Color hoverColor;
    private Image img;
    private Vector3 originalScale;
    private Button btn;

    public void Initialize(Color normal, Color hover)
    {
        normalColor = normal;
        hoverColor = hover;
        img = GetComponent<Image>();
        btn = GetComponent<Button>();
        originalScale = transform.localScale;
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        if (btn != null && !btn.interactable) return;
        if (img != null) img.color = hoverColor;
        StartCoroutine(ScaleTo(originalScale * 1.03f, 0.1f));
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        if (btn != null && !btn.interactable) return;
        if (img != null) img.color = normalColor;
        StartCoroutine(ScaleTo(originalScale, 0.1f));
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        if (btn != null && !btn.interactable) return;
        StartCoroutine(ScaleTo(originalScale * 0.97f, 0.05f));
    }

    public void OnPointerUp(PointerEventData eventData)
    {
        if (btn != null && !btn.interactable) return;
        StartCoroutine(ScaleTo(originalScale * 1.03f, 0.05f));
    }

    private IEnumerator ScaleTo(Vector3 targetScale, float duration)
    {
        float elapsed = 0f;
        Vector3 startScale = transform.localScale;
        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            transform.localScale = Vector3.Lerp(startScale, targetScale, elapsed / duration);
            yield return null;
        }
        transform.localScale = targetScale;
    }

    private void OnDisable()
    {
        transform.localScale = Vector3.one;
        if (img != null) img.color = normalColor;
    }
}
