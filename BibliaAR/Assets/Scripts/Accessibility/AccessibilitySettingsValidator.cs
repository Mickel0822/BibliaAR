using System.Collections.Generic;
using UnityEngine;

// kguanoluisa, Validaciones y manejo de errores del panel de accesibilidad, variables v_errores y v_advertencias, 2026-07-03
public class AccessibilitySettingsValidator
{
    private readonly List<string> v_errores = new List<string>();
    private readonly List<string> v_advertencias = new List<string>();

    public IReadOnlyList<string> Errores => v_errores;
    public IReadOnlyList<string> Advertencias => v_advertencias;

    public bool Validar(AccessibilitySettings v_configuracion)
    {
        v_errores.Clear();
        v_advertencias.Clear();

        if (v_configuracion == null)
        {
            v_errores.Add("La configuracion de accesibilidad es nula.");
            return false;
        }

        if (v_configuracion.v_velocidadAudio < 0.5f || v_configuracion.v_velocidadAudio > 2f)
        {
            v_errores.Add("La velocidad de audio debe estar entre 0.5x y 2.0x.");
        }

        if (v_configuracion.v_volumenAudio < 0f || v_configuracion.v_volumenAudio > 1f)
        {
            v_errores.Add("El volumen de audio debe estar entre 0 y 1.");
        }

        if (!v_configuracion.v_lseActivo && !v_configuracion.v_subtitulosActivos && !v_configuracion.v_audioActivo)
        {
            v_advertencias.Add("Todos los canales sensoriales estan desactivados.");
        }

        return v_errores.Count == 0;
    }

    public string ObtenerResumen()
    {
        return $"Errores: {v_errores.Count}, Advertencias: {v_advertencias.Count}";
    }
}
