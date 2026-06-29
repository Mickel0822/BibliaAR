using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

// kguanoluisa, Ajustes UI/UX de ventana flotante LSE BIAR-25, variables v_animacionDuracion y v_colorFondo, 2026-06-29
public class LSEWindowController : MonoBehaviour
{
    [Header("Contenido LSE")]
    [SerializeField] private string v_titulo = "Intérprete LSE";
    [SerializeField] private string v_descripcion = "Traducción en lengua de señas";

    [Header("UI")]
    [SerializeField] private RectTransform v_panel;
    [SerializeField] private TextMeshProUGUI v_tituloTexto;
    [SerializeField] private TextMeshProUGUI v_descripcionTexto;
    [SerializeField] private TextMeshProUGUI v_mensajeError;
    [SerializeField] private Button v_botonExpandir;
    [SerializeField] private Image v_fondo;
    [SerializeField] private float v_animacionDuracion = 0.25f;
    [SerializeField] private Color32 v_colorFondo = new Color32(45, 55, 72, 240);

    [Header("Video")]
    [SerializeField] private LSEVideoPlayer v_videoPlayer;

    private bool v_expandido;
    private float v_anchoReducido = 0.25f;
    private float v_anchoExpandido = 0.50f;
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
            v_fondo.color = v_colorFondo;
        }

        ActualizarTextos();
        AplicarAncho(instantaneo: true);
        OcultarError();
    }

    public void AlternarExpansion()
    {
        v_expandido = !v_expandido;
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
        ActualizarTextos();
        gameObject.SetActive(true);
    }

    public void Ocultar()
    {
        v_videoPlayer?.Detener();
        gameObject.SetActive(false);
        OcultarError();
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
        if (v_tituloTexto != null)
        {
            v_tituloTexto.text = v_titulo;
        }

        ActualizarDescripcionVisible();
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

        float v_ancho = v_expandido ? v_anchoExpandido : v_anchoReducido;
        Vector2 v_min = new Vector2(1f - v_ancho, 0.70f);
        Vector2 v_max = Vector2.one;

        if (instantaneo || v_animacionDuracion <= 0f)
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

        while (v_tiempo < v_animacionDuracion)
        {
            v_tiempo += Time.deltaTime;
            float v_t = Mathf.Clamp01(v_tiempo / v_animacionDuracion);
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
