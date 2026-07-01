using UnityEngine;

// Amb-AS: Agregar validaciones y manejo de errores en el sistema de feedback multimodal (vibración, sonido, animación) - 01/07/2026
public class MultimodalFeedbackManager : MonoBehaviour
{
    public static MultimodalFeedbackManager Instance { get; private set; }

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
        if (audioSource == null)
        {
            Debug.LogWarning("[MultimodalFeedbackManager] AudioSource no está asignado.");
            return;
        }
        if (feedbackClip == null)
        {
            Debug.LogWarning("[MultimodalFeedbackManager] AudioClip de feedback no está asignado.");
            return;
        }

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
        if (feedbackAnimator == null)
        {
            Debug.LogWarning("[MultimodalFeedbackManager] Animator no está asignado.");
            return;
        }

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
