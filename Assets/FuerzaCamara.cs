using UnityEngine;
using UnityEngine.Android;

// kguanoluisa, Solicita permiso de camara al iniciar la app para habilitar la experiencia AR, sin nuevas variables, 2026-07-24
public class FuerzaCamara : MonoBehaviour
{
    void Awake()
    {
        // kguanoluisa, Inyecta el permiso de camara en el APK y lo solicita al usuario al arrancar, sin nuevas variables, 2026-07-24
        if (!Permission.HasUserAuthorizedPermission(Permission.Camera))
        {
        // kguanoluisa, Solicita al sistema Android el permiso de camara requerido por ARCore, sin nuevas variables, 2026-07-06
            Permission.RequestUserPermission(Permission.Camera);
        }
    }
}