using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.EventSystems;

public class FoodItemUI : MonoBehaviour, IBeginDragHandler, IDragHandler, IEndDragHandler
{
    public Image iconImage;
    public Text nameText;
    public Text infoText;

    private FoodBalanceMiniGame.FoodItem foodData;
    private FoodBalanceMiniGame miniGame;
    private Transform originalParent;
    private Vector2 originalAnchoredPosition;
    private CanvasGroup canvasGroup;
    private RectTransform rectTransform;
    private bool onPlate = false;

    void Awake()
    {
        canvasGroup = GetComponent<CanvasGroup>();
        if (canvasGroup == null)
            canvasGroup = gameObject.AddComponent<CanvasGroup>();
        rectTransform = GetComponent<RectTransform>();
    }

    public void Setup(FoodBalanceMiniGame.FoodItem food, FoodBalanceMiniGame game)
    {
        foodData = food;
        miniGame = game;
        if (iconImage != null) {
            iconImage.sprite = food.icon;
            // Устанавливаем исходные пропорции спрайта
            if (food.icon != null) {
                Rect spriteRect = food.icon.rect;
                float spriteAspect = spriteRect.width / spriteRect.height;
                RectTransform imgRect = iconImage.GetComponent<RectTransform>();
                if (imgRect != null) {
                    // Сохраняем одну из сторон (например, высоту), подгоняем ширину
                    float height = imgRect.sizeDelta.y;
                    imgRect.sizeDelta = new Vector2(height * spriteAspect, height);
                }
            }
        }
        if (nameText != null) nameText.text = food.name;
        if (infoText != null) infoText.text = $"C:{food.calories} P:{food.protein} F:{food.fat} Cb:{food.carbs}";
    }

    public void OnBeginDrag(PointerEventData eventData)
    {
        originalParent = transform.parent;
        originalAnchoredPosition = rectTransform.anchoredPosition;
        transform.SetParent(transform.root); // На верхний уровень Canvas
        canvasGroup.blocksRaycasts = false;
        canvasGroup.alpha = 0.7f;
    }

    public void OnDrag(PointerEventData eventData)
    {
        rectTransform.position = eventData.position;
    }

    public void OnEndDrag(PointerEventData eventData)
    {
        canvasGroup.blocksRaycasts = true;
        canvasGroup.alpha = 1f;
        var plateRect = miniGame.plateParent as RectTransform;
        // Проверяем, над тарелкой ли отпустили
        if (RectTransformUtility.RectangleContainsScreenPoint(plateRect, eventData.position, eventData.pressEventCamera))
        {
            // Переводим позицию мыши в локальные координаты тарелки
            Vector2 localPoint;
            RectTransformUtility.ScreenPointToLocalPointInRectangle(plateRect, eventData.position, eventData.pressEventCamera, out localPoint);
            transform.SetParent(miniGame.plateParent);
            rectTransform.anchoredPosition = localPoint;
            if (!onPlate)
            {
                miniGame.OnFoodDropped(foodData);
                onPlate = true;
            }
        }
        else
        {
            transform.SetParent(originalParent);
            rectTransform.anchoredPosition = originalAnchoredPosition;
            if (onPlate)
            {
                miniGame.OnFoodRemoved(foodData);
                onPlate = false;
            }
        }
    }
}
