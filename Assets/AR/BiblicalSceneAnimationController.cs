using System.Collections;
using UnityEngine;

/// <summary>
/// Coordinates the short biblical scene animation that plays after the QR marker is detected.
/// The controller keeps the AR content anchored to the tracked image while giving the characters
/// a visible 10-second motion sequence that can be restarted every time the marker is found again.
/// </summary>
public class BiblicalSceneAnimationController : MonoBehaviour
{
    [Header("Timing")]
    [SerializeField] private float minimumAnimationSeconds = 10f;
    [SerializeField] private bool loopAnimation = true;

    [Header("Scene Motion")]
    [SerializeField] private float rotationAmplitudeDegrees = 6f;
    [SerializeField] private float verticalBobAmplitude = 0.015f;

    private CharacterAnimationController[] characters;
    private Animator[] animators;
    private Coroutine animationRoutine;
    private Vector3 initialLocalPosition;
    private Quaternion initialLocalRotation;

    private void Awake()
    {
        CacheSceneReferences();
        StoreInitialPose();
    }

    private void OnDisable()
    {
        StopSceneAnimation();
    }

    /// <summary>
    /// Starts the biblical scene from the beginning. If a previous pass is still running,
    /// it is stopped first so the marker can restart the same synchronized 10-second loop.
    /// </summary>
    public void PlayFromStart()
    {
        if (!isActiveAndEnabled)
        {
            return;
        }

        CacheSceneReferences();
        StopSceneAnimation();
        ResetScenePose();
        animationRoutine = StartCoroutine(SceneAnimationRoutine());
    }

    /// <summary>
    /// Stops the running sequence, returns the root content to its tracked-image pose,
    /// and places every character back into its idle state.
    /// </summary>
    public void StopSceneAnimation()
    {
        if (animationRoutine != null)
        {
            StopCoroutine(animationRoutine);
            animationRoutine = null;
        }

        SetCharactersWalking(false);
        ResetScenePose();
    }

    private void CacheSceneReferences()
    {
        characters = GetComponentsInChildren<CharacterAnimationController>(true);
        animators = GetComponentsInChildren<Animator>(true);
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
        SetCharactersWalking(true);

        while (elapsed < minimumAnimationSeconds)
        {
            elapsed += Time.deltaTime;
            float normalizedTime = Mathf.Clamp01(elapsed / minimumAnimationSeconds);
            float wave = Mathf.Sin(normalizedTime * Mathf.PI * 2f);
            float secondaryWave = Mathf.Sin(normalizedTime * Mathf.PI * 4f);

            transform.localPosition = initialLocalPosition + Vector3.up * (secondaryWave * verticalBobAmplitude);
            transform.localRotation = initialLocalRotation * Quaternion.Euler(0f, wave * rotationAmplitudeDegrees, 0f);

            yield return null;
        }

        ResetScenePose();
        SetCharactersWalking(false);

        yield return new WaitForSeconds(0.15f);
    }

    private void SetCharactersWalking(bool isWalking)
    {
        if (characters == null)
        {
            return;
        }

        foreach (CharacterAnimationController character in characters)
        {
            if (character == null)
            {
                continue;
            }

            if (isWalking)
            {
                character.PlayWalk();
            }
            else
            {
                character.PlayIdle();
            }
        }
    }

    private void RestartAnimatorStates()
    {
        if (animators == null)
        {
            return;
        }

        foreach (Animator animator in animators)
        {
            if (animator == null || !animator.isActiveAndEnabled || animator.runtimeAnimatorController == null)
            {
                continue;
            }

            animator.Rebind();
            animator.Update(0f);
        }
    }
}
