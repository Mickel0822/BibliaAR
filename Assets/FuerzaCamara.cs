using UnityEngine;
using UnityEngine.Android;

public class FuerzaCamara : MonoBehaviour
{
    void Awake()
    {
        // Esto obliga a Unity a inyectar el permiso en el APK y lo pide al arrancar
        if (!Permission.HasUserAuthorizedPermission(Permission.Camera))
        {
            Permission.RequestUserPermission(Permission.Camera);
        }
    }
}