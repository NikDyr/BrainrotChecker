using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class ModalWindowAnimator : MonoBehaviour
{
    public RectTransform windowPanel; // Панель окна
    public CanvasGroup backgroundGroup; // Затемнение
    public float animationDuration = 0.4f;
    public float hiddenY = -1000f; // Координата Y вне экрана
    public float shownY = 0f; // Координата Y для показа

    public float shakeDuration = 0.4f;
    public float shakeMagnitude = 30f;

    private bool isAnimating = false;

    void Awake()
    {
        // Скрыть окно и затемнение при старте
        windowPanel.anchoredPosition = new Vector2(windowPanel.anchoredPosition.x, hiddenY);
        backgroundGroup.alpha = 0f;
        backgroundGroup.blocksRaycasts = false;
        backgroundGroup.interactable = false;
    }

    public void Show()
    {
        if (isAnimating) return;
        gameObject.SetActive(true);
        StartCoroutine(AnimateIn());
    }

    public void Hide()
    {
        if (isAnimating) return;
        StartCoroutine(AnimateOut());
    }

    public void ShakeWindow()
    {
        if (!gameObject.activeInHierarchy) return;
        StopAllCoroutines();
        StartCoroutine(ShakeCoroutine());
    }

    private IEnumerator ShakeCoroutine()
    {
        Vector2 originalPos = windowPanel.anchoredPosition;
        float elapsed = 0f;
        while (elapsed < shakeDuration)
        {
            float x = Random.Range(-1f, 1f) * shakeMagnitude;
            windowPanel.anchoredPosition = new Vector2(originalPos.x + x, originalPos.y);
            elapsed += Time.unscaledDeltaTime;
            yield return null;
        }
        windowPanel.anchoredPosition = originalPos;
    }

    IEnumerator AnimateIn()
    {
        isAnimating = true;
        float t = 0f;
        Vector2 startPos = new Vector2(windowPanel.anchoredPosition.x, hiddenY);
        Vector2 endPos = new Vector2(windowPanel.anchoredPosition.x, shownY);
        windowPanel.anchoredPosition = startPos;
        backgroundGroup.blocksRaycasts = true;
        backgroundGroup.interactable = true;
        while (t < animationDuration)
        {
            t += Time.unscaledDeltaTime;
            float k = Mathf.Clamp01(t / animationDuration);
            windowPanel.anchoredPosition = Vector2.Lerp(startPos, endPos, EaseOutCubic(k));
            backgroundGroup.alpha = Mathf.Lerp(0f, 1f, k);
            yield return null;
        }
        windowPanel.anchoredPosition = endPos;
        backgroundGroup.alpha = 1f;
        isAnimating = false;
    }

    IEnumerator AnimateOut()
    {
        isAnimating = true;
        float t = 0f;
        Vector2 startPos = new Vector2(windowPanel.anchoredPosition.x, shownY);
        Vector2 endPos = new Vector2(windowPanel.anchoredPosition.x, hiddenY);
        while (t < animationDuration)
        {
            t += Time.unscaledDeltaTime;
            float k = Mathf.Clamp01(t / animationDuration);
            windowPanel.anchoredPosition = Vector2.Lerp(startPos, endPos, EaseInCubic(k));
            backgroundGroup.alpha = Mathf.Lerp(1f, 0f, k);
            yield return null;
        }
        windowPanel.anchoredPosition = endPos;
        backgroundGroup.alpha = 0f;
        backgroundGroup.blocksRaycasts = false;
        backgroundGroup.interactable = false;
        isAnimating = false;
        gameObject.SetActive(false);
    }

    float EaseOutCubic(float t) => 1f - Mathf.Pow(1f - t, 3f);
    float EaseInCubic(float t) => t * t * t;
}
