using UnityEngine;
using UnityEngine.Video;

// kguanoluisa, Validaciones del reproductor LSE BIAR-25, variables v_videoPlayer v_clip y v_mensajeError, 2026-06-29
[RequireComponent(typeof(VideoPlayer))]
public class LSEVideoPlayer : MonoBehaviour
{
    private VideoPlayer v_videoPlayer;
    [SerializeField] private VideoClip v_clip;
    private string v_mensajeError;

    public string MensajeError => v_mensajeError;

    private void Awake()
    {
        v_videoPlayer = GetComponent<VideoPlayer>();
        v_videoPlayer.playOnAwake = false;
        v_videoPlayer.isLooping = true;
    }

    public bool Reproducir(VideoClip v_clipEntrada)
    {
        v_mensajeError = string.Empty;
        v_clip = v_clipEntrada != null ? v_clipEntrada : v_clip;

        if (v_clip == null)
        {
            v_mensajeError = "Clip LSE no asignado.";
            Debug.LogWarning("[LSEVideoPlayer] Clip LSE no asignado.");
            return false;
        }

        v_videoPlayer.clip = v_clip;
        v_videoPlayer.Play();
        return true;
    }

    public void Detener()
    {
        if (v_videoPlayer != null && v_videoPlayer.isPlaying)
        {
            v_videoPlayer.Stop();
        }
    }
}
