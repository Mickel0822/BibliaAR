using UnityEngine;

/// <summary>
/// Responsable: Teniente.
/// Controla las animaciones básicas (Idle / Walk) de un personaje de la escena AR
/// (Samaritano, Hombre Herido o Asno).
///
/// Colocar este script en el GameObject raíz de cada personaje, que debe tener
/// un componente Animator con un Animator Controller que contenga:
///   - Estado "Idle" (por defecto)
///   - Estado "Walk"
///   - Parámetro bool "IsWalking" controlando la transición entre ambos.
///
/// El Animator Controller puede generarse automáticamente con la herramienta
/// de editor: Tools > AR Samaritano > Crear Animator Idle-Walk.
/// </summary>
[RequireComponent(typeof(Animator))]
public class CharacterAnimationController : MonoBehaviour
{
    private static readonly int IsWalkingHash = Animator.StringToHash("IsWalking");

    private Animator animator;

    private void Awake()
    {
        animator = GetComponent<Animator>();
    }

    /// <summary>Reproduce la animación de reposo (Idle). Estado por defecto del personaje.</summary>
    public void PlayIdle()
    {
        if (animator == null) return;
        animator.SetBool(IsWalkingHash, false);
    }

    /// <summary>Reproduce la animación de caminar (Walk).</summary>
    public void PlayWalk()
    {
        if (animator == null) return;
        animator.SetBool(IsWalkingHash, true);
    }
}
