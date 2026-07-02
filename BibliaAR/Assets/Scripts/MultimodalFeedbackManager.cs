using UnityEngine;

// Amb-AS: Optimizar rendimiento del sistema de feedback multimodal (vibración, sonido, animación) - 02/07/2026
public class MultimodalFeedbackManager : MonoBehaviour
{
    public static MultimodalFeedbackManager Instance { get; private set; }

    [Header("Configuración Feedback")]
    public bool isVibrationEnabled = true;
    public bool isSoundEnabled = true;
    public bool isAnimationEnabled = true;

    [Header("Componentes de Audio")]
    public AudioSource audioSource;
    public AudioClip feedbackClip;

    [Header("Componentes de Animación")]
    public Animator feedbackAnimator;

    // Optimización de rendimiento: cachear los IDs de los triggers del animator
    private int successTriggerId;
    private int narrativePhaseTriggerId;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
            InitializeAnimatorHashes();
        }
        else
        {
            Destroy(gameObject);
        }
    }

    private void InitializeAnimatorHashes()
    {
        successTriggerId = Animator.StringToHash("success");
        narrativePhaseTriggerId = Animator.StringToHash("narrative_phase");
    }

    public void TriggerVibration()
    {
        if (!isVibrationEnabled) return;

        try
        {
            if (Application.platform == RuntimePlatform.Android || Application.platform == RuntimePlatform.IPhonePlayer)
            {
                #if UNITY_ANDROID || UNITY_IOS
                Handheld.Vibrate();
                #endif
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[MultimodalFeedbackManager] Error al vibrar: {ex.Message}");
        }
    }

    public void TriggerSound()
    {
        if (!isSoundEnabled) return;
        if (audioSource == null || feedbackClip == null) return;

        try
        {
            audioSource.PlayOneShot(feedbackClip);
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[MultimodalFeedbackManager] Error al reproducir audio: {ex.Message}");
        }
    }

    public void TriggerAnimation(string triggerName)
    {
        if (!isAnimationEnabled || feedbackAnimator == null) return;

        try
        {
            if (feedbackAnimator.runtimeAnimatorController != null)
            {
                int triggerId = (triggerName == "success") ? successTriggerId : narrativePhaseTriggerId;
                feedbackAnimator.SetTrigger(triggerId);
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[MultimodalFeedbackManager] Error al disparar animación: {ex.Message}");
        }
    }

    public void TriggerAllFeedback(string triggerName)
    {
        TriggerVibration();
        TriggerSound();
        TriggerAnimation(triggerName);
    }
}
