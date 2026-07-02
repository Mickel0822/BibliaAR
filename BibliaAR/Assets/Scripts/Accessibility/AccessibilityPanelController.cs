using UnityEngine;

// kguanoluisa, Controlador base del panel de accesibilidad, variable v_configuracion, 2026-07-02
public class AccessibilityPanelController : MonoBehaviour
{
    [SerializeField] private AccessibilitySettings v_configuracion = new AccessibilitySettings();

    public AccessibilitySettings Configuracion => v_configuracion;
}
