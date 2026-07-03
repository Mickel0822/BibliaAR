using System;
using UnityEngine;

// kguanoluisa, Panel de accesibilidad con validacion previa al aplicar cambios, variable v_validador, 2026-07-03
public class AccessibilityPanelController : MonoBehaviour
{
    [SerializeField] private AccessibilitySettings v_configuracion = new AccessibilitySettings();
    private readonly AccessibilitySettingsValidator v_validador = new AccessibilitySettingsValidator();

    public event Action<AccessibilitySettings> OnConfiguracionCambiada;
    public event Action<string> OnErrorValidacion;

    public AccessibilitySettings Configuracion => v_configuracion;

    public void EstablecerLse(bool v_activo)
    {
        v_configuracion.v_lseActivo = v_activo;
        AplicarSiValido();
    }

    public void EstablecerSubtitulos(bool v_activo)
    {
        v_configuracion.v_subtitulosActivos = v_activo;
        AplicarSiValido();
    }

    public void EstablecerAudio(bool v_activo)
    {
        v_configuracion.v_audioActivo = v_activo;
        AplicarSiValido();
    }

    public void EstablecerPictogramas(bool v_activo)
    {
        v_configuracion.v_pictogramasActivos = v_activo;
        AplicarSiValido();
    }

    public void EstablecerVelocidadAudio(float v_velocidad)
    {
        v_configuracion.v_velocidadAudio = Mathf.Clamp(v_velocidad, 0.5f, 2f);
        AplicarSiValido();
    }

    public void EstablecerVolumenAudio(float v_volumen)
    {
        v_configuracion.v_volumenAudio = Mathf.Clamp01(v_volumen);
        AplicarSiValido();
    }

    private void AplicarSiValido()
    {
        if (!v_validador.Validar(v_configuracion))
        {
            string v_mensaje = string.Join("; ", v_validador.Errores);
            OnErrorValidacion?.Invoke(v_mensaje);
            Debug.LogWarning($"[AccessibilityPanelController] {v_mensaje}");
            return;
        }

        OnConfiguracionCambiada?.Invoke(v_configuracion.Clone());
    }
}
