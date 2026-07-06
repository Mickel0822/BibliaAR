using System;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

// kguanoluisa, Correccion de sincronizacion de toggles con StoryFlow, variable v_configuracionAplicada, 2026-07-06
public class AccessibilityPanelController : MonoBehaviour
{
    [SerializeField] private AccessibilitySettings v_configuracion = new AccessibilitySettings();
    [SerializeField] private Image v_fondo;
    [SerializeField] private TextMeshProUGUI v_tituloTexto;
    [SerializeField] private float v_animacionDuracion = 0.2f;
    [SerializeField] private Color32 v_colorFondo = new Color32(30, 41, 59, 230);

    private readonly AccessibilitySettingsValidator v_validador = new AccessibilitySettingsValidator();
    private AccessibilitySettings v_configuracionAplicada;
    private CanvasGroup v_canvasGroup;
    private Coroutine v_rutinaFade;

    public event Action<AccessibilitySettings> OnConfiguracionCambiada;
    public event Action<string> OnErrorValidacion;

    public AccessibilitySettings Configuracion => v_configuracion;

    private void Awake()
    {
        v_canvasGroup = GetComponent<CanvasGroup>();
        if (v_canvasGroup == null)
        {
            v_canvasGroup = gameObject.AddComponent<CanvasGroup>();
        }

        v_configuracionAplicada = v_configuracion.Clone();

        if (v_fondo != null)
        {
            v_fondo.color = v_colorFondo;
        }

        if (v_tituloTexto != null)
        {
            v_tituloTexto.text = "Accesibilidad";
        }
    }

    public void MostrarPanel()
    {
        gameObject.SetActive(true);
        if (v_rutinaFade != null) StopCoroutine(v_rutinaFade);
        v_rutinaFade = StartCoroutine(FadePanel(1f));
    }

    public void OcultarPanel()
    {
        if (v_rutinaFade != null) StopCoroutine(v_rutinaFade);
        v_rutinaFade = StartCoroutine(FadePanel(0f, true));
    }

    public void EstablecerLse(bool v_activo) { v_configuracion.v_lseActivo = v_activo; AplicarSiValido(); }
    public void EstablecerSubtitulos(bool v_activo) { v_configuracion.v_subtitulosActivos = v_activo; AplicarSiValido(); }
    public void EstablecerAudio(bool v_activo) { v_configuracion.v_audioActivo = v_activo; AplicarSiValido(); }
    public void EstablecerPictogramas(bool v_activo) { v_configuracion.v_pictogramasActivos = v_activo; AplicarSiValido(); }
    public void EstablecerVelocidadAudio(float v_velocidad) { v_configuracion.v_velocidadAudio = Mathf.Clamp(v_velocidad, 0.5f, 2f); AplicarSiValido(); }
    public void EstablecerVolumenAudio(float v_volumen) { v_configuracion.v_volumenAudio = Mathf.Clamp01(v_volumen); AplicarSiValido(); }

    private void AplicarSiValido()
    {
        if (!v_validador.Validar(v_configuracion))
        {
            v_configuracion = v_configuracionAplicada.Clone();
            string v_mensaje = string.Join("; ", v_validador.Errores);
            OnErrorValidacion?.Invoke(v_mensaje);
            Debug.LogWarning($"[AccessibilityPanelController] {v_mensaje}");
            return;
        }

        v_configuracionAplicada = v_configuracion.Clone();
        OnConfiguracionCambiada?.Invoke(v_configuracionAplicada.Clone());
    }

    private System.Collections.IEnumerator FadePanel(float v_objetivo, bool v_ocultarAlFinal = false)
    {
        float v_inicio = v_canvasGroup.alpha;
        float v_tiempo = 0f;

        while (v_tiempo < v_animacionDuracion)
        {
            v_tiempo += Time.deltaTime;
            v_canvasGroup.alpha = Mathf.Lerp(v_inicio, v_objetivo, v_tiempo / v_animacionDuracion);
            yield return null;
        }

        v_canvasGroup.alpha = v_objetivo;
        if (v_ocultarAlFinal) gameObject.SetActive(false);
        v_rutinaFade = null;
    }
}
