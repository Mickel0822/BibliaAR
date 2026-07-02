using System;
using UnityEngine;

// kguanoluisa, Logica principal del panel de accesibilidad, variables v_configuracion y evento OnConfiguracionCambiada, 2026-07-02
public class AccessibilityPanelController : MonoBehaviour
{
    [SerializeField] private AccessibilitySettings v_configuracion = new AccessibilitySettings();

    public event Action<AccessibilitySettings> OnConfiguracionCambiada;

    public AccessibilitySettings Configuracion => v_configuracion;

    public void EstablecerLse(bool v_activo)
    {
        v_configuracion.v_lseActivo = v_activo;
        NotificarCambio();
    }

    public void EstablecerSubtitulos(bool v_activo)
    {
        v_configuracion.v_subtitulosActivos = v_activo;
        NotificarCambio();
    }

    public void EstablecerAudio(bool v_activo)
    {
        v_configuracion.v_audioActivo = v_activo;
        NotificarCambio();
    }

    public void EstablecerPictogramas(bool v_activo)
    {
        v_configuracion.v_pictogramasActivos = v_activo;
        NotificarCambio();
    }

    public void EstablecerVelocidadAudio(float v_velocidad)
    {
        v_configuracion.v_velocidadAudio = Mathf.Clamp(v_velocidad, 0.5f, 2f);
        NotificarCambio();
    }

    public void EstablecerVolumenAudio(float v_volumen)
    {
        v_configuracion.v_volumenAudio = Mathf.Clamp01(v_volumen);
        NotificarCambio();
    }

    private void NotificarCambio()
    {
        OnConfiguracionCambiada?.Invoke(v_configuracion.Clone());
    }
}
