using UnityEngine;
using BibliaAR.Data;

namespace BibliaAR.Core
{
    /// <summary>
    /// Se encarga de instanciar y proveer la data dinámica de la escena al StoryFlowController.
    /// Si no se le asigna un BiblicalSceneData, el StoryFlowController actuará en modo legado (Samaritano).
    /// </summary>
    public class SceneDataLoader : MonoBehaviour
    {
        [Header("Scene Configuration")]
        [Tooltip("Asigna el ScriptableObject con la historia que deseas cargar.")]
        public BiblicalSceneData sceneData;

        [Header("Runtime")]
        public GameObject spawnedScene;

        private void Awake()
        {
            if (sceneData != null && sceneData.scenePrefab != null)
            {
                // Instanciar el prefab principal de la escena
                spawnedScene = Instantiate(sceneData.scenePrefab, transform);
            }
        }
    }
}
