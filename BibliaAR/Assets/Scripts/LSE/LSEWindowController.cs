using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

// kguanoluisa, Refactor de ventana flotante LSE BIAR-25, clase auxiliar LSEWindowUiState, 2026-07-01
public class LSEWindowController : MonoBehaviour
{
    [System.Serializable]
    private class LSEWindowUiState
    {
        public float v_anchoReducido = 0.25f;
        public float v_anchoExpandido = 0.50f;
        public float v_animacionDuracion = 0.25f;
        public Color32 v_colorFondo = new Color32(45, 55, 72, 240);
    }

    [Header("Contenido LSE")]
    [SerializeField] private string v_titulo = "Intérprete LSE";
    [SerializeField] private string v_descripcion = "Traducción en lengua de señas";

    [Header("UI")]
    [SerializeField] private RectTransform v_panel;
    [SerializeField] private TextMeshProUGUI v_tituloTexto;
    [SerializeField] private TextMeshProUGUI v_descripcionTexto;
    [SerializeField] private TextMeshProUGUI v_mensajeError;
    [SerializeField] private TextMeshProUGUI v_etiquetaExpandir;
    [SerializeField] private Button v_botonExpandir;
    [SerializeField] private Image v_fondo;
    [SerializeField] private LSEWindowUiState v_estadoUi = new LSEWindowUiState();

    [Header("Video")]
    [SerializeField] private LSEVideoPlayer v_videoPlayer;

    private bool v_expandido;
    private bool v_visibleDuranteNarracion;
    private float v_cacheAncho = -1f;
    private bool v_requiereRepintado = true;
    private Coroutine v_rutinaAnimacion;

    public bool Expandido => v_expandido;

    private void Awake()
    {
        if (v_botonExpandir != null)
        {
            v_botonExpandir.onClick.AddListener(AlternarExpansion);
        }

        if (v_fondo != null)
        {
            v_fondo.color = v_estadoUi.v_colorFondo;
        }

        ActualizarEtiquetaExpansion();
        ActualizarTextos();
        AplicarAncho(instantaneo: true);
        OcultarError();
    }

    public void AlternarExpansion()
    {
        v_expandido = !v_expandido;
        v_requiereRepintado = true;
        ActualizarEtiquetaExpansion();
        AplicarAncho();
        ActualizarDescripcionVisible();
    }

    public void Mostrar(string v_tituloFragmento, string v_descripcionFragmento)
    {
        if (string.IsNullOrWhiteSpace(v_tituloFragmento) && string.IsNullOrWhiteSpace(v_descripcionFragmento))
        {
            MostrarError("No hay contenido LSE disponible para este fragmento.");
            return;
        }

        OcultarError();
        v_titulo = string.IsNullOrWhiteSpace(v_tituloFragmento) ? "Intérprete LSE" : v_tituloFragmento;
        v_descripcion = v_descripcionFragmento ?? string.Empty;
        v_visibleDuranteNarracion = true;
        v_requiereRepintado = true;
        ActualizarTextos();
        gameObject.SetActive(true);
    }

    public void Ocultar()
    {
        v_visibleDuranteNarracion = false;
        v_videoPlayer?.Detener();
        gameObject.SetActive(false);
        OcultarError();
    }

    private void OnDisable()
    {
        if (v_visibleDuranteNarracion)
        {
            v_videoPlayer?.Detener();
        }
    }

    private void ActualizarEtiquetaExpansion()
    {
        if (v_etiquetaExpandir != null)
        {
            v_etiquetaExpandir.text = v_expandido ? "Reducir" : "Ampliar";
        }
    }

    private void MostrarError(string v_mensaje)
    {
        if (v_mensajeError != null)
        {
            v_mensajeError.text = v_mensaje;
            v_mensajeError.gameObject.SetActive(true);
        }

        Debug.LogWarning($"[LSEWindowController] {v_mensaje}");
    }

    private void OcultarError()
    {
        if (v_mensajeError != null)
        {
            v_mensajeError.gameObject.SetActive(false);
        }
    }

    private void ActualizarTextos()
    {
        if (v_tituloTexto != null && v_requiereRepintado)
        {
            v_tituloTexto.text = v_titulo;
        }

        ActualizarDescripcionVisible();
        v_requiereRepintado = false;
    }

    private void ActualizarDescripcionVisible()
    {
        if (v_descripcionTexto != null)
        {
            v_descripcionTexto.text = v_expandido ? v_descripcion : string.Empty;
            v_descripcionTexto.gameObject.SetActive(v_expandido);
        }
    }

    private void AplicarAncho(bool instantaneo = false)
    {
        if (v_panel == null)
        {
            return;
        }

        float v_ancho = v_expandido ? v_estadoUi.v_anchoExpandido : v_estadoUi.v_anchoReducido;
        if (!instantaneo && Mathf.Approximately(v_cacheAncho, v_ancho))
        {
            return;
        }

        v_cacheAncho = v_ancho;
        Vector2 v_min = new Vector2(1f - v_ancho, 0.70f);
        Vector2 v_max = Vector2.one;

        if (instantaneo || v_estadoUi.v_animacionDuracion <= 0f)
        {
            v_panel.anchorMin = v_min;
            v_panel.anchorMax = v_max;
            v_panel.offsetMin = Vector2.zero;
            v_panel.offsetMax = Vector2.zero;
            return;
        }

        if (v_rutinaAnimacion != null)
        {
            StopCoroutine(v_rutinaAnimacion);
        }

        v_rutinaAnimacion = StartCoroutine(AnimarAncho(v_min, v_max));
    }

    private IEnumerator AnimarAncho(Vector2 v_destinoMin, Vector2 v_destinoMax)
    {
        Vector2 v_inicioMin = v_panel.anchorMin;
        Vector2 v_inicioMax = v_panel.anchorMax;
        float v_tiempo = 0f;

        while (v_tiempo < v_estadoUi.v_animacionDuracion)
        {
            v_tiempo += Time.deltaTime;
            float v_t = Mathf.Clamp01(v_tiempo / v_estadoUi.v_animacionDuracion);
            v_panel.anchorMin = Vector2.Lerp(v_inicioMin, v_destinoMin, v_t);
            v_panel.anchorMax = Vector2.Lerp(v_inicioMax, v_destinoMax, v_t);
            yield return null;
        }

        v_panel.anchorMin = v_destinoMin;
        v_panel.anchorMax = v_destinoMax;
        v_panel.offsetMin = Vector2.zero;
        v_panel.offsetMax = Vector2.zero;
        v_rutinaAnimacion = null;
    }
}
