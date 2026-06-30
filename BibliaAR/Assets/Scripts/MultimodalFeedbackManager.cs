using UnityEngine;

// Amb-AS: Crear estructura base del sistema de feedback multimodal (vibración, sonido, animación) - 30/06/2026
public class MultimodalFeedbackManager : MonoBehaviour
{
    public static MultimodalFeedbackManager Instance { get; private set; }

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
}
