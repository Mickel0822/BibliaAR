using UnityEngine;
using System.Collections.Generic;

namespace BibliaAR.Data
{
    [CreateAssetMenu(fileName = "NewBiblicalScene", menuName = "BibliaAR/Biblical Scene Data")]
    public class BiblicalSceneData : ScriptableObject
    {
        [Header("Scene Identification")]
        public string sceneId;
        public string sceneName;

        [Header("Assets Base")]
        [Tooltip("Prefab del modelo 3D y entorno que conforma la escena.")]
        public GameObject scenePrefab;

        [Tooltip("Audio completo de la narración de la escena (si no está dividido por fases).")]
        public AudioClip fullNarrationAudio;

        [Header("Story Flow")]
        [Tooltip("Fases que componen la narrativa de la escena.")]
        public List<BiblicalScenePhase> phases = new List<BiblicalScenePhase>();
    }
}
