using UnityEngine;
using UnityEngine.Video;

namespace BibliaAR.Data
{
    [System.Serializable]
    public class BiblicalScenePhase
    {
        [Tooltip("Subtítulo que se mostrará en esta fase de la historia.")]
        [TextArea(2, 4)]
        public string subtitleText;

        [Tooltip("Duración en segundos de esta fase si no se usa un audio individual.")]
        public float duration = 4f;

        [Tooltip("Audio opcional para esta fase específica (útil si el audio de la escena está troceado).")]
        public AudioClip phaseAudio;

        [Tooltip("Pictograma que representa esta fase (accesibilidad).")]
        public Sprite pictogram;

        [Tooltip("Video en Lenguaje de Señas Ecuatoriano (LSE) para esta fase.")]
        public VideoClip lseVideo;

        [Tooltip("Nombre del estado de animación (o trigger) que debe activarse en los personajes en esta fase.")]
        public string animationStateName;
    }
}
