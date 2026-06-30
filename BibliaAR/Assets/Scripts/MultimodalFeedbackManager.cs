using UnityEngine;

// Amb-AS: Implementar lógica principal del sistema de feedback multimodal (vibración, sonido, animación) - 30/06/2026
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
        #if UNITY_ANDROID || UNITY_IOS
        Handheld.Vibrate();
        #endif
        Debug.Log("[MultimodalFeedbackManager] Vibración disparada.");
    }

    public void TriggerSound()
    {
        if (audioSource != null && feedbackClip != null)
        {
            audioSource.PlayOneShot(feedbackClip);
        }
    }

    public void TriggerAnimation(string triggerName)
    {
        if (feedbackAnimator != null)
        {
            feedbackAnimator.SetTrigger(triggerName);
        }
    }

    public void TriggerAllFeedback(string triggerName)
    {
        TriggerVibration();
        TriggerSound();
        TriggerAnimation(triggerName);
    }
}
