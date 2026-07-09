using UnityEngine;

/// <summary>
/// Exposes simple animation commands for each character in the AR biblical scene.
/// The scene-level controller uses these commands to keep Samaritano, Hombre Herido
/// and the companion props synchronized during the marker-triggered animation.
///
/// Expected Animator setup:
/// - Default state: "Idle"
/// - Motion state: "Walk"
/// - Bool parameter: "IsWalking"
/// </summary>
[RequireComponent(typeof(Animator))]
public class CharacterAnimationController : MonoBehaviour
{
    private static readonly int IsWalkingHash = Animator.StringToHash("IsWalking");

    private Animator animator;
    private bool hasWalkingParameter;

    private void Awake()
    {
        animator = GetComponent<Animator>();
        hasWalkingParameter = HasBoolParameter(animator, IsWalkingHash);
    }

    /// <summary>
    /// Returns the character to the idle pose used before and after the 10-second scene pass.
    /// </summary>
    public void PlayIdle()
    {
        if (animator == null)
        {
            return;
        }

        if (hasWalkingParameter)
        {
            animator.SetBool(IsWalkingHash, false);
        }
    }

    /// <summary>
    /// Activates the movement state while the biblical scene animation is running.
    /// </summary>
    public void PlayWalk()
    {
        if (animator == null)
        {
            return;
        }

        if (hasWalkingParameter)
        {
            animator.SetBool(IsWalkingHash, true);
        }
    }

    private static bool HasBoolParameter(Animator targetAnimator, int parameterHash)
    {
        if (targetAnimator == null)
        {
            return false;
        }

        foreach (AnimatorControllerParameter parameter in targetAnimator.parameters)
        {
            if (parameter.type == AnimatorControllerParameterType.Bool && parameter.nameHash == parameterHash)
            {
                return true;
            }
        }

        return false;
    }
}
