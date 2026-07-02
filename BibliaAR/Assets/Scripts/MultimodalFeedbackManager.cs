using UnityEngine;

// Amb-AS: Corregir bug detectado en pruebas del sistema de feedback multimodal (vibración, sonido, animación) - 02/07/2026
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
            // Corrección de bug: verificar explícitamente si estamos en plataforma móvil compatible antes de llamar
            if (Application.platform == RuntimePlatform.Android || Application.platform == RuntimePlatform.IPhonePlayer)
            {
                #if UNITY_ANDROID || UNITY_IOS
                Handheld.Vibrate();
                #endif
            }
            else
            {
                Debug.Log("[MultimodalFeedbackManager] Simulación de vibración en editor.");
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
            // Corrección de bug: validar que el trigger existe en el controlador antes de dispararlo
            if (feedbackAnimator.runtimeAnimatorController != null)
            {
                feedbackAnimator.SetTrigger(triggerName);
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
