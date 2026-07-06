using System;

// kguanoluisa, Modelo completo de configuracion de accesibilidad, variables v_pictogramasActivos v_velocidadAudio v_volumenAudio, 2026-07-02
[Serializable]
public class AccessibilitySettings
{
    public bool v_lseActivo = true;
    public bool v_subtitulosActivos = true;
    public bool v_audioActivo = true;
    public bool v_pictogramasActivos = true;
    public float v_velocidadAudio = 1f;
    public float v_volumenAudio = 1f;

    public AccessibilitySettings Clone()
    {
        return new AccessibilitySettings
        {
            v_lseActivo = v_lseActivo,
            v_subtitulosActivos = v_subtitulosActivos,
            v_audioActivo = v_audioActivo,
            v_pictogramasActivos = v_pictogramasActivos,
            v_velocidadAudio = v_velocidadAudio,
            v_volumenAudio = v_volumenAudio
        };
    }
}
