// Autor: TNTE BAYAS CRISTIAN
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
    private static readonly int IsHurtHash    = Animator.StringToHash("IsHurt");

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

    /// <summary>
    /// Dispara un trigger en el Animator por nombre (p.ej. "Hurt", "Help").
    /// Si el trigger no existe en el controller, la llamada se ignora de forma segura.
    /// </summary>
    public void PlayEmote(string triggerName)
    {
        if (animator == null || string.IsNullOrEmpty(triggerName)) return;

        foreach (AnimatorControllerParameter param in animator.parameters)
        {
            if (param.type == AnimatorControllerParameterType.Trigger &&
                param.name  == triggerName)
            {
                animator.SetTrigger(triggerName);
                return;
            }
        }
    }

    /// <summary>
    /// Activa o desactiva el estado "herido" si el Animator tiene el bool <c>IsHurt</c>.
    /// </summary>
    public void SetHurt(bool hurt)
    {
        if (animator == null) return;

        foreach (AnimatorControllerParameter param in animator.parameters)
        {
            if (param.type     == AnimatorControllerParameterType.Bool &&
                param.nameHash == IsHurtHash)
            {
                animator.SetBool(IsHurtHash, hurt);
                return;
            }
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
