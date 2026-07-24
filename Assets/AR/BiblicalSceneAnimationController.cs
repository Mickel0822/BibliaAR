// Autor: TNTE BAYAS CRISTIAN
using System.Collections;
using UnityEngine;

/// <summary>
/// Coordina la animación de la escena bíblica del Buen Samaritano anclada al marcador AR.
///
/// Modos de operación:
///   • <b>Modo libre</b>  (narrativeMode = false): bucle de 10 s con walking + bob/rotación.
///   • <b>Modo narrativo</b> (narrativeMode = true):  cada fase del relato activa estados
///     distintos en los personajes, sincronizados con los subtítulos de StoryFlowController.
///
/// Fases del relato del Buen Samaritano:
///   Fase 0 — "Un viajero iba por el camino..."  → viajero camina, samaritano idle.
///   Fase 1 — "Lo dejaron herido y solo..."       → todos idle, escena rota lentamente.
///   Fase 2 — "Un samaritano se acercó..."        → samaritano camina, viajero idle.
///   Fase 3 — "Esta historia nos enseña..."       → todos idle, bob suave de celebración.
/// </summary>
public class BiblicalSceneAnimationController : MonoBehaviour
{
    [Header("Timing")]
    [SerializeField] private float minimumAnimationSeconds = 10f;
    [SerializeField] private bool  loopAnimation           = true;

    [Header("Scene Motion")]
    [SerializeField] private float rotationAmplitudeDegrees = 6f;
    [SerializeField] private float verticalBobAmplitude     = 0.015f;

    [Header("Modo Narrativo")]
    [Tooltip("Activa el modo de animaciones secuenciales sincronizadas al relato.")]
    [SerializeField] private bool narrativeMode = false;

    [Tooltip("Personajes en orden: [0] = Viajero/Hombre Herido, [1] = Samaritano. " +
             "Si está vacío se usan todos los CharacterAnimationController encontrados.")]
    [SerializeField] private CharacterAnimationController[] namedCharacters;

    // ─── Referencias internas ─────────────────────────────────────────────────
    private CharacterAnimationController[] characters;
    private Animator[]                     animators;
    private Coroutine                      animationRoutine;
    private Vector3                        initialLocalPosition;
    private Quaternion                     initialLocalRotation;

    // ─────────────────────────────────────────────────────────────────────────
    #region Unity Lifecycle

    private void Awake()
    {
        CacheSceneReferences();
        StoreInitialPose();
    }

    private void OnDisable()
    {
        StopSceneAnimation();
    }

    #endregion

    // ─────────────────────────────────────────────────────────────────────────
    #region Public API

    /// <summary>
    /// Inicia la animación de escena desde el principio.
    /// En modo libre ejecuta el bucle de 10 s; en modo narrativo espera llamadas
    /// a <see cref="PlayNarrativePhase"/>.
    /// </summary>
    public void PlayFromStart()
    {
        if (!isActiveAndEnabled) return;

        CacheSceneReferences();
        StopSceneAnimation();
        ResetScenePose();

        if (!narrativeMode)
        {
            animationRoutine = StartCoroutine(SceneAnimationRoutine());
        }
    }

    /// <summary>
    /// Ejecuta la animación correspondiente a la fase <paramref name="phaseIndex"/>
    /// del relato durante <paramref name="phaseDuration"/> segundos.
    /// Solo tiene efecto cuando <see cref="narrativeMode"/> está activo.
    /// </summary>
    /// <param name="phaseIndex">Índice de la línea narrativa (0–3).</param>
    /// <param name="phaseDuration">Duración en segundos de esta fase.</param>
    public void PlayNarrativePhase(int phaseIndex, float phaseDuration)
    {
        if (!isActiveAndEnabled) return;

        CacheSceneReferences();

        if (animationRoutine != null)
        {
            StopCoroutine(animationRoutine);
        }

        animationRoutine = StartCoroutine(NarrativePhaseRoutine(phaseIndex, phaseDuration));
    }

    /// <summary>
    /// Detiene la secuencia, devuelve la escena a su pose inicial y
    /// coloca a todos los personajes en idle.
    /// </summary>
    public void StopSceneAnimation()
    {
        if (animationRoutine != null)
        {
            StopCoroutine(animationRoutine);
            animationRoutine = null;
        }

        SetAllIdle();
        ResetScenePose();
    }

    #endregion

    // ─────────────────────────────────────────────────────────────────────────
    #region Free Mode (bucle de 10 s)

    private IEnumerator SceneAnimationRoutine()
    {
        do
        {
            yield return PlayTenSecondPass();
        }
        while (loopAnimation);

        animationRoutine = null;
    }

    private IEnumerator PlayTenSecondPass()
    {
        float elapsed = 0f;
        RestartAnimatorStates();
        SetAllWalking(true);

        while (elapsed < minimumAnimationSeconds)
        {
            elapsed += Time.deltaTime;
            ApplySceneMotion(elapsed, minimumAnimationSeconds);
            yield return null;
        }

        ResetScenePose();
        SetAllWalking(false);

        yield return new WaitForSeconds(0.15f);
    }

    #endregion

    // ─────────────────────────────────────────────────────────────────────────
    #region Narrative Mode (animaciones por fase del relato)

    private IEnumerator NarrativePhaseRoutine(int phaseIndex, float duration)
    {
        RestartAnimatorStates();
        ApplyNarrativePhaseState(phaseIndex, true);

        float elapsed = 0f;
        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            ApplyNarrativeSceneMotion(phaseIndex, elapsed, duration);
            yield return null;
        }

        ApplyNarrativePhaseState(phaseIndex, false);
        ResetScenePose();
        animationRoutine = null;
    }

    /// <summary>
    /// Aplica el estado de animación correspondiente a cada fase del relato.
    /// </summary>
    private void ApplyNarrativePhaseState(int phaseIndex, bool starting)
    {
        switch (phaseIndex)
        {
            // Fase 0: "Un viajero iba por el camino de Jerusalén a Jericó..."
            // → El viajero (índice 0) camina. El Samaritano (índice 1) está idle.
            case 0:
                SetCharacterWalking(0, starting);
                SetCharacterWalking(1, false);
                Debug.Log($"[BiblicalScene] Fase 0: viajero {(starting ? "camina" : "idle")}.");
                break;

            // Fase 1: "Lo dejaron herido y solo..."
            // → Todos idle. La escena rota lentamente (sensación de abandono).
            case 1:
                SetAllWalking(false);
                if (starting)
                {
                    SetCharacterHurt(0, true);
                }
                else
                {
                    SetCharacterHurt(0, false);
                }
                Debug.Log($"[BiblicalScene] Fase 1: todos idle, viajero {(starting ? "herido" : "recuperado")}.");
                break;

            // Fase 2: "Un samaritano se acercó, curó sus heridas..."
            // → El Samaritano (índice 1) camina. El viajero (0) idle/herido.
            case 2:
                SetCharacterWalking(1, starting);
                SetCharacterWalking(0, false);
                SetCharacterHurt(0, starting);
                Debug.Log($"[BiblicalScene] Fase 2: samaritano {(starting ? "camina" : "idle")}.");
                break;

            // Fase 3: "Esta historia nos enseña que debemos ayudar..."
            // → Todos idle. La escena hace un bob suave de conclusión.
            case 3:
                SetAllWalking(false);
                SetCharacterHurt(0, false);
                Debug.Log("[BiblicalScene] Fase 3: conclusión, todos idle.");
                break;
        }
    }

    /// <summary>
    /// Movimiento de cámara/escena adaptado a cada fase narrativa.
    /// </summary>
    private void ApplyNarrativeSceneMotion(int phaseIndex, float elapsed, float duration)
    {
        float t    = Mathf.Clamp01(elapsed / duration);
        float wave = Mathf.Sin(t * Mathf.PI * 2f);

        switch (phaseIndex)
        {
            case 0: // Viajero camina: ligera rotación de seguimiento
                transform.localPosition = initialLocalPosition + Vector3.up * (wave * verticalBobAmplitude * 0.5f);
                transform.localRotation = initialLocalRotation * Quaternion.Euler(0f, wave * rotationAmplitudeDegrees * 0.5f, 0f);
                break;

            case 1: // Abandono: rotación lenta y pendular (tristeza)
                float slow = Mathf.Sin(t * Mathf.PI);
                transform.localPosition = initialLocalPosition + Vector3.up * (slow * verticalBobAmplitude * 0.3f);
                transform.localRotation = initialLocalRotation * Quaternion.Euler(0f, slow * rotationAmplitudeDegrees * 1.5f, 0f);
                break;

            case 2: // Samaritano llega: movimiento más dinámico
                transform.localPosition = initialLocalPosition + Vector3.up * (wave * verticalBobAmplitude);
                transform.localRotation = initialLocalRotation * Quaternion.Euler(0f, wave * rotationAmplitudeDegrees, 0f);
                break;

            case 3: // Conclusión: bob suave y continuo
                float celebrate = Mathf.Abs(Mathf.Sin(t * Mathf.PI * 3f));
                transform.localPosition = initialLocalPosition + Vector3.up * (celebrate * verticalBobAmplitude * 0.6f);
                transform.localRotation = initialLocalRotation;
                break;

            default:
                ApplySceneMotion(elapsed, duration);
                break;
        }
    }

    #endregion

    // ─────────────────────────────────────────────────────────────────────────
    #region Character Helpers

    /// <summary>Activa/desactiva walking en el personaje por índice. Si el índice está fuera
    /// de rango, actúa sobre todos.</summary>
    private void SetCharacterWalking(int index, bool walking)
    {
        CharacterAnimationController[] pool = GetPool();
        if (index >= 0 && index < pool.Length)
        {
            if (walking) pool[index].PlayWalk();
            else         pool[index].PlayIdle();
        }
    }

    private void SetCharacterHurt(int index, bool hurt)
    {
        CharacterAnimationController[] pool = GetPool();
        if (index >= 0 && index < pool.Length)
        {
            pool[index].SetHurt(hurt);
        }
    }

    private void SetAllWalking(bool walking)
    {
        foreach (CharacterAnimationController c in GetPool())
        {
            if (c == null) continue;
            if (walking) c.PlayWalk();
            else         c.PlayIdle();
        }
    }

    private void SetAllIdle()
    {
        SetAllWalking(false);
    }

    private CharacterAnimationController[] GetPool()
    {
        if (namedCharacters != null && namedCharacters.Length > 0)
            return namedCharacters;
        return characters ?? System.Array.Empty<CharacterAnimationController>();
    }

    #endregion

    // ─────────────────────────────────────────────────────────────────────────
    #region Scene Motion / Pose

    private void ApplySceneMotion(float elapsed, float totalDuration)
    {
        float normalizedTime  = Mathf.Clamp01(elapsed / totalDuration);
        float wave            = Mathf.Sin(normalizedTime * Mathf.PI * 2f);
        float secondaryWave   = Mathf.Sin(normalizedTime * Mathf.PI * 4f);

        transform.localPosition = initialLocalPosition + Vector3.up * (secondaryWave * verticalBobAmplitude);
        transform.localRotation = initialLocalRotation * Quaternion.Euler(0f, wave * rotationAmplitudeDegrees, 0f);
    }

    private void CacheSceneReferences()
    {
        characters = GetComponentsInChildren<CharacterAnimationController>(true);
        animators  = GetComponentsInChildren<Animator>(true);
    }

    private void StoreInitialPose()
    {
        initialLocalPosition = transform.localPosition;
        initialLocalRotation = transform.localRotation;
    }

    private void ResetScenePose()
    {
        transform.localPosition = initialLocalPosition;
        transform.localRotation = initialLocalRotation;
    }

    private void RestartAnimatorStates()
    {
        if (animators == null) return;

        foreach (Animator anim in animators)
        {
            if (anim == null || !anim.isActiveAndEnabled || anim.runtimeAnimatorController == null)
                continue;

            anim.Rebind();
            anim.Update(0f);
        }
    }

    #endregion
}
