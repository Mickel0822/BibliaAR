using System.Collections.Generic;
using UnityEngine;

// kguanoluisa, Validador base de configuracion de accesibilidad, variable v_errores, 2026-07-02
public class AccessibilitySettingsValidator
{
    private readonly List<string> v_errores = new List<string>();

    public IReadOnlyList<string> Errores => v_errores;

    public bool Validar(AccessibilitySettings v_configuracion)
    {
        v_errores.Clear();
        if (v_configuracion == null)
        {
            v_errores.Add("La configuracion de accesibilidad es nula.");
            return false;
        }

        return true;
    }
}
