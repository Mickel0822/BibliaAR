using UnityEngine;

// Amb-AS: Ajustar UI/UX del sistema de feedback multimodal (vibración, sonido, animación) - 01/07/2026
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

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    public void TriggerVibration()
    {
        if (!isVibrationEnabled) return;

        try
        {
            #if UNITY_ANDROID || UNITY_IOS
            Handheld.Vibrate();
            #else
            Debug.Log("[MultimodalFeedbackManager] Vibración no soportada en esta plataforma.");
            #endif
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
            feedbackAnimator.SetTrigger(triggerName);
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
