using System;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

// kguanoluisa, Optimizacion de rendimiento del panel de accesibilidad, variables v_requiereNotificar y v_cacheHash, 2026-07-06
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
    private int v_cacheHash;

    public event Action<AccessibilitySettings> OnConfiguracionCambiada;
    public event Action<string> OnErrorValidacion;

    public AccessibilitySettings Configuracion => v_configuracion;

    private void Awake()
    {
        v_canvasGroup = GetComponent<CanvasGroup>() ?? gameObject.AddComponent<CanvasGroup>();
        v_configuracionAplicada = v_configuracion.Clone();
        v_cacheHash = CalcularHash(v_configuracionAplicada);

        if (v_fondo != null) v_fondo.color = v_colorFondo;
        if (v_tituloTexto != null) v_tituloTexto.text = "Accesibilidad";
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
            OnErrorValidacion?.Invoke(string.Join("; ", v_validador.Errores));
            return;
        }

        int v_nuevoHash = CalcularHash(v_configuracion);
        if (v_nuevoHash == v_cacheHash)
        {
            return;
        }

        v_cacheHash = v_nuevoHash;
        v_configuracionAplicada = v_configuracion.Clone();
        OnConfiguracionCambiada?.Invoke(v_configuracionAplicada.Clone());
    }

    private static int CalcularHash(AccessibilitySettings v_cfg)
    {
        if (v_cfg == null) return 0;
        unchecked
        {
            int v_hash = 17;
            v_hash = v_hash * 31 + v_cfg.v_lseActivo.GetHashCode();
            v_hash = v_hash * 31 + v_cfg.v_subtitulosActivos.GetHashCode();
            v_hash = v_hash * 31 + v_cfg.v_audioActivo.GetHashCode();
            v_hash = v_hash * 31 + v_cfg.v_pictogramasActivos.GetHashCode();
            v_hash = v_hash * 31 + v_cfg.v_velocidadAudio.GetHashCode();
            v_hash = v_hash * 31 + v_cfg.v_volumenAudio.GetHashCode();
            return v_hash;
        }
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
