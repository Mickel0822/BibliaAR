using UnityEngine;
using UnityEngine.Video;

// kguanoluisa, Reproductor de video LSE BIAR-25, variables v_videoPlayer y v_clip, 2026-06-26
[RequireComponent(typeof(VideoPlayer))]
public class LSEVideoPlayer : MonoBehaviour
{
    private VideoPlayer v_videoPlayer;
    [SerializeField] private VideoClip v_clip;

    private void Awake()
    {
        v_videoPlayer = GetComponent<VideoPlayer>();
        v_videoPlayer.playOnAwake = false;
        v_videoPlayer.isLooping = true;
    }

    public void Reproducir(VideoClip v_clipEntrada)
    {
        v_clip = v_clipEntrada != null ? v_clipEntrada : v_clip;
        if (v_clip == null)
        {
            return;
        }

        v_videoPlayer.clip = v_clip;
        v_videoPlayer.Play();
    }

    public void Detener()
    {
        if (v_videoPlayer != null && v_videoPlayer.isPlaying)
        {
            v_videoPlayer.Stop();
        }
    }
}
