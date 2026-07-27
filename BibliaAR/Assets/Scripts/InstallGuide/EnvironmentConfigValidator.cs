using System.Collections.Generic;
using UnityEngine;

// kguanoluisa, Validaciones y manejo de errores del entorno BIAR-15, variables v_errores y v_advertencias, 2026-06-25
public class EnvironmentConfigValidator : MonoBehaviour
{
    private readonly List<string> v_errores = new List<string>();
    private readonly List<string> v_advertencias = new List<string>();

    public IReadOnlyList<string> Errores => v_errores;
    public IReadOnlyList<string> Advertencias => v_advertencias;

    public bool ValidarEntornoCompleto()
    {
        v_errores.Clear();
        v_advertencias.Clear();

        ValidarVersionUnity();
        ValidarPlataformaAndroid();

        return v_errores.Count == 0;
    }

    public bool ValidarVersionUnity()
    {
        string v_version = Application.unityVersion;
        if (!v_version.StartsWith("6000.5"))
        {
            v_errores.Add($"Se requiere Unity 6000.5.x. Detectado: {v_version}");
            return false;
        }

        return true;
    }

    public bool ValidarPlataformaAndroid()
    {
#if !UNITY_ANDROID
        v_advertencias.Add("La plataforma activa no es Android. Cambie a Android antes del build.");
        return false;
#else
        return true;
#endif
    }

    public string ObtenerResumen()
    {
        if (v_errores.Count == 0 && v_advertencias.Count == 0)
        {
            return "Entorno validado correctamente.";
        }

        return $"Errores: {v_errores.Count}, Advertencias: {v_advertencias.Count}";
    }
}
