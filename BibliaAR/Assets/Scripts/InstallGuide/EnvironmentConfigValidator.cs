using System.Collections.Generic;
using UnityEngine;

// kguanoluisa, Validador base del entorno de desarrollo BIAR-15, variable v_errores, 2026-06-24
public class EnvironmentConfigValidator : MonoBehaviour
{
    private readonly List<string> v_errores = new List<string>();

    public IReadOnlyList<string> Errores => v_errores;

    public bool ValidarVersionUnity()
    {
        v_errores.Clear();
        string v_version = Application.unityVersion;
        if (!v_version.StartsWith("6000.5"))
        {
            v_errores.Add($"Se requiere Unity 6000.5.x. Detectado: {v_version}");
            return false;
        }

        return true;
    }
}
