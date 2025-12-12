using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Collections.Generic;

public class FoodBalanceMiniGame : MonoBehaviour
{
    public RectTransform goodJobPanelRect;
    public RectTransform goodJobPanelParentRect;

    public GameObject goodJobPanel; // Панель с надписью и кнопкой
    public UnityEngine.UI.Button restartButton;
    [System.Serializable]
    public class FoodItem
    {
        public string name;
        public int calories;
        public float protein;
        public float fat;
        public float carbs;
        public Sprite icon;
    }

    public List<FoodItem> allFoods;
    public Transform foodColumnParent; // Родитель для столбцов с продуктами
    public Transform plateParent; // Родитель для тарелки
    public GameObject foodItemPrefab; // Префаб для отображения продукта
    public Text balanceText;
    public Image borderFrame; // Рамка модального окна
    public ModalWindowAnimator modalAnimator;

    public int calorieTarget = 500;
    public float proteinTarget = 20f;
    public float fatTarget = 15f;
    public float carbsTarget = 60f;
    public float tolerance = 0.10f; // 10% допуск

    private List<FoodItem> availableFoods = new List<FoodItem>();
    private List<FoodItem> plateFoods = new List<FoodItem>();
    private Color goodColor = new Color32(0x4E, 0xC7, 0x6E, 0xFF);
    private Color badColor = new Color32(0xFF, 0x63, 0x47, 0xFF);
    private Color normalColor = new Color32(0xE3, 0x5D, 0x02, 0xFF);
    private bool isBalanced = false;

    void Start()
    {
        if (goodJobPanel != null) {
            goodJobPanel.SetActive(false);
        }
        if (restartButton != null) restartButton.onClick.AddListener(OnRestartButtonClicked);
        GenerateSessionFoodsAndTarget();
        // Инициализация: создаём продукты в столбцах с рандомной позицией по вертикали
        var colRect = foodColumnParent as RectTransform;
        float colWidth = colRect.rect.width;
        float colHeight = colRect.rect.height;
        int count = availableFoods.Count;
        for (int i = 0; i < count; i++)
        {
            var food = availableFoods[i];
            var go = Instantiate(foodItemPrefab, foodColumnParent);
            var ui = go.GetComponent<FoodItemUI>();
            ui.Setup(food, this);
            // Случайная позиция по всей области колонки
            var rt = go.GetComponent<RectTransform>();
            float x = Random.Range(-colWidth/2f, colWidth/2f);
            float y = Random.Range(-colHeight/2f, colHeight/2f);
            rt.anchoredPosition = new Vector2(x, y);
        }
        UpdateBalanceText();
        SetFrameColor(badColor);
    }

    // Генерация цели и продуктов для сессии
    void GenerateSessionFoodsAndTarget()
    {
        availableFoods.Clear();
        List<FoodItem> pool = new List<FoodItem>(allFoods);
        int maxMain = Mathf.Min(5, pool.Count);
        int minMain = Mathf.Min(3, pool.Count);
        int mainCount = Random.Range(minMain, maxMain + 1);
        List<FoodItem> mainSet = new List<FoodItem>();
        for (int i = 0; i < mainCount && pool.Count > 0; i++)
        {
            int idx = Random.Range(0, pool.Count);
            mainSet.Add(pool[idx]);
            pool.RemoveAt(idx);
        }
        // Цель — сумма КБЖУ выбранных продуктов
        calorieTarget = 0; proteinTarget = 0; fatTarget = 0; carbsTarget = 0;
        foreach (var f in mainSet)
        {
            calorieTarget += f.calories;
            proteinTarget += f.protein;
            fatTarget += f.fat;
            carbsTarget += f.carbs;
        }
        availableFoods.AddRange(mainSet);
        // Добавляем ещё 2-3 случайных продукта (не обязательно используемых)
        int maxExtra = Mathf.Min(3, pool.Count);
        int minExtra = Mathf.Min(2, pool.Count);
        int extraCount = (pool.Count > 0) ? Random.Range(minExtra, maxExtra + 1) : 0;
        for (int i = 0; i < extraCount && pool.Count > 0; i++)
        {
            int idx = Random.Range(0, pool.Count);
            availableFoods.Add(pool[idx]);
            pool.RemoveAt(idx);
        }
    }

    public void OnFoodDropped(FoodItem food)
    {
        plateFoods.Add(food);
        UpdateBalanceText();
        CheckBalance();
    }

    public void OnFoodRemoved(FoodItem food)
    {
        plateFoods.Remove(food);
        UpdateBalanceText();
        CheckBalance();
    }

    void UpdateBalanceText()
    {
        int cal = 0;
        float prot = 0, fat = 0, carb = 0;
        foreach (var f in plateFoods)
        {
            cal += f.calories;
            prot += f.protein;
            fat += f.fat;
            carb += f.carbs;
        }
        balanceText.text = $"C: {cal}/{calorieTarget}  P: {prot:F1}/{proteinTarget}  F: {fat:F1}/{fatTarget}  Cb: {carb:F1}/{carbsTarget}";
    }

    void CheckBalance()
    {
        int cal = 0;
        float prot = 0, fat = 0, carb = 0;
        foreach (var f in plateFoods)
        {
            cal += f.calories;
            prot += f.protein;
            fat += f.fat;
            carb += f.carbs;
        }

        bool calOk = Mathf.Abs(cal - calorieTarget) <= calorieTarget * tolerance;
        bool protOk = Mathf.Abs(prot - proteinTarget) <= proteinTarget * tolerance;
        bool fatOk = Mathf.Abs(fat - fatTarget) <= fatTarget * tolerance;
        bool carbOk = Mathf.Abs(carb - carbsTarget) <= carbsTarget * tolerance;

        float maxDev = Mathf.Max(
            Mathf.Abs(cal - calorieTarget) / calorieTarget,
            Mathf.Abs(prot - proteinTarget) / proteinTarget,
            Mathf.Abs(fat - fatTarget) / fatTarget,
            Mathf.Abs(carb - carbsTarget) / carbsTarget
        );

        if (calOk && protOk && fatOk && carbOk)
        {
            if (!isBalanced)
            {
                isBalanced = true;
                if (modalAnimator != null) modalAnimator.ShakeWindow();
                if (goodJobPanel != null)
                {
                    goodJobPanel.SetActive(true);
                    if (restartButton != null) restartButton.interactable = true;
                }
            }
            SetFrameColor(goodColor);
        }
        else if (maxDev <= 0.25f)
        {
            isBalanced = false;
            SetFrameColor(normalColor);
            if (goodJobPanel != null) goodJobPanel.SetActive(false);
        }
        else
        {
            isBalanced = false;
            SetFrameColor(badColor);
            if (goodJobPanel != null) goodJobPanel.SetActive(false);
        }
    }

    public void RestartGame()
    {
        // Удаляем все продукты с тарелки
        foreach (Transform child in plateParent)
        {
            Destroy(child.gameObject);
        }
        plateFoods.Clear();
        // Удаляем все продукты из колонки
        foreach (Transform child in foodColumnParent)
        {
            Destroy(child.gameObject);
        }
        // Генерируем новую сессию
        GenerateSessionFoodsAndTarget();
        var colRect = foodColumnParent as RectTransform;
        float colWidth = colRect.rect.width;
        float colHeight = colRect.rect.height;
        int count = availableFoods.Count;
        for (int i = 0; i < count; i++)
        {
            var food = availableFoods[i];
            var go = Instantiate(foodItemPrefab, foodColumnParent);
            var ui = go.GetComponent<FoodItemUI>();
            ui.Setup(food, this);
            var rt = go.GetComponent<RectTransform>();
            float x = Random.Range(-colWidth/2f, colWidth/2f);
            float y = Random.Range(-colHeight/2f, colHeight/2f);
            rt.anchoredPosition = new Vector2(x, y);
        }
        UpdateBalanceText();
        SetFrameColor(badColor);
        isBalanced = false;
        if (goodJobPanel != null)
        {
            goodJobPanel.SetActive(false);
            if (restartButton != null) restartButton.interactable = false;
        }
    }

    private void OnRestartButtonClicked()
    {
        if (goodJobPanel != null) goodJobPanel.SetActive(false);
        RestartGame();
    }


    private float EaseOutBounce(float t)
    {
        if (t < (1 / 2.75f))
            return 7.5625f * t * t;
        else if (t < (2 / 2.75f))
        {
            t -= (1.5f / 2.75f);
            return 7.5625f * t * t + 0.75f;
        }
        else if (t < (2.5f / 2.75f))
        {
            t -= (2.25f / 2.75f);
            return 7.5625f * t * t + 0.9375f;
        }
        else
        {
            t -= (2.625f / 2.75f);
            return 7.5625f * t * t + 0.984375f;
        }
    }
    

    private void SetFrameColor(Color color)
    {
        if (borderFrame != null)
        {
            borderFrame.color = color;
            // Переливание (анимация) цвета
            StopAllCoroutines();
            StartCoroutine(BorderPulse(color));
        }
    }

    System.Collections.IEnumerator BorderPulse(Color baseColor)
    {
        float t = 0f;
        float duration = 0.8f;
        while (true)
        {
            t += Time.unscaledDeltaTime;
            float pulse = 0.5f + 0.5f * Mathf.Sin(t * Mathf.PI * 2 / duration);
            borderFrame.color = Color.Lerp(baseColor, Color.white, pulse * 0.15f);
            yield return null;
        }
    }
}
