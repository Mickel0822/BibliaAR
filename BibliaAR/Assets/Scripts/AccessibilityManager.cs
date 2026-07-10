// Sal-B: Crear estructura base del refinamiento de controles WCAG 2.1 AA - 08/07/2026
using UnityEngine;
using TMPro;

public class AccessibilityManager : MonoBehaviour
{
    [Header("WCAG 2.1 AA Config")]
    public float minButtonSizePhysicalMm = 9f;
    public bool highContrastEnabled = false;

    // Sal-B: Implementar lógica principal del refinamiento de controles WCAG 2.1 AA - 08/07/2026
    public void ApplyAccessibilitySettings()
    {
        if (highContrastEnabled)
        {
            SetHighContrastColors();
        }
    }

    // Sal-B: Integrar el refinamiento de controles WCAG 2.1 AA con el resto del módulo - 08/07/2026
    private void Start()
    {
        ApplyAccessibilitySettings();
    }

    // Sal-B: Agregar validaciones y manejo de errores en el refinamiento de controles WCAG 2.1 AA - 09/07/2026
    private void SetHighContrastColors()
    {
        try
        {
            var texts = FindObjectsByType<TextMeshProUGUI>(FindObjectsInactive.Include, FindObjectsSortMode.None);
            foreach (var txt in texts)
            {
                if (txt != null) txt.color = Color.white;
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogError($"[AccessibilityManager] Error applying contrast: {ex.Message}");
        }
    }

    // Sal-B: Ajustar UI/UX del refinamiento de controles WCAG 2.1 AA - 09/07/2026
    public void ToggleHighContrast(bool enabled)
    {
        highContrastEnabled = enabled;
        ApplyAccessibilitySettings();
    }

    // Sal-B: Corregir bug detectado en pruebas del refinamiento de controles WCAG 2.1 AA - 10/07/2026
    public void SafeToggleContrast(bool enabled)
    {
        if (this == null) return;
        ToggleHighContrast(enabled);
    }
}
