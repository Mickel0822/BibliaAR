#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.Animations;
using UnityEngine;

/// <summary>
/// Responsable: Teniente.
/// Genera automáticamente un Animator Controller con los estados "Idle" y "Walk"
/// (las animaciones básicas requeridas para los personajes de la escena AR),
/// controlados por el parámetro bool "IsWalking".
///
/// Uso: Tools > AR Samaritano > Crear Animator Idle-Walk
/// 1) Asigna el clip de animación de reposo (obligatorio).
/// 2) Asigna el clip de animación de caminar (opcional, si el modelo lo trae).
/// 3) Click en "Generar Animator Controller".
/// 4) Arrastra el .controller generado al campo "Controller" del componente
///    Animator del personaje correspondiente.
/// </summary>
public class AnimatorControllerBuilder : EditorWindow
{
    private AnimationClip idleClip;
    private AnimationClip walkClip;
    private string controllerName = "PersonajeAnimatorController";

    [MenuItem("Tools/AR Samaritano/Crear Animator Idle-Walk")]
    public static void ShowWindow()
    {
        GetWindow<AnimatorControllerBuilder>("Crear Animator Idle-Walk");
    }

    private void OnGUI()
    {
        GUILayout.Label("Generar Animator Controller (Idle / Walk)", EditorStyles.boldLabel);
        EditorGUILayout.HelpBox(
            "Genera un Animator Controller con animaciones básicas para un personaje " +
            "(Samaritano, Hombre Herido o Asno). Repite el proceso por cada personaje " +
            "que tenga animaciones distintas.", MessageType.Info);

        controllerName = EditorGUILayout.TextField("Nombre del Controller", controllerName);
        idleClip = (AnimationClip)EditorGUILayout.ObjectField("Clip Idle (reposo)", idleClip, typeof(AnimationClip), false);
        walkClip = (AnimationClip)EditorGUILayout.ObjectField("Clip Walk (caminar)", walkClip, typeof(AnimationClip), false);

        EditorGUILayout.Space();

        if (GUILayout.Button("Generar Animator Controller"))
        {
            if (idleClip == null)
            {
                EditorUtility.DisplayDialog("Falta el clip Idle",
                    "Debes asignar al menos la animación de reposo (Idle).", "OK");
                return;
            }
            CreateController();
        }
    }

    private void CreateController()
    {
        string path = AssetDatabase.GenerateUniqueAssetPath($"Assets/{controllerName}.controller");
        AnimatorController controller = AnimatorController.CreateAnimatorControllerAtPath(path);

        AnimatorStateMachine rootStateMachine = controller.layers[0].stateMachine;

        AnimatorState idleState = rootStateMachine.AddState("Idle");
        idleState.motion = idleClip;
        rootStateMachine.defaultState = idleState;

        if (walkClip != null)
        {
            controller.AddParameter("IsWalking", AnimatorControllerParameterType.Bool);

            AnimatorState walkState = rootStateMachine.AddState("Walk");
            walkState.motion = walkClip;

            AnimatorStateTransition toWalk = idleState.AddTransition(walkState);
            toWalk.AddCondition(AnimatorConditionMode.If, 0, "IsWalking");
            toWalk.hasExitTime = false;
            toWalk.duration = 0.15f;

            AnimatorStateTransition toIdle = walkState.AddTransition(idleState);
            toIdle.AddCondition(AnimatorConditionMode.IfNot, 0, "IsWalking");
            toIdle.hasExitTime = false;
            toIdle.duration = 0.15f;
        }

        AssetDatabase.SaveAssets();
        EditorUtility.DisplayDialog("Listo", $"Animator Controller creado en:\n{path}", "OK");
        EditorGUIUtility.PingObject(controller);
    }
}
#endif
