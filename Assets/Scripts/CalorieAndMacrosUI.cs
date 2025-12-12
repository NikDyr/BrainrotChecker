using UnityEngine;
using UnityEngine.UI;

public class CalorieAndMacrosUI : MonoBehaviour
{
    // Текстовое поле для вывода streak
    public Text streakText;
    // Текстовые поля для средних значений за неделю
    public Text avgCaloriesText;
    public Text avgProteinText;
    public Text avgFatText;
    public Text avgCarbsText;

    public Image caloriesFrame;
    public Image proteinFrame;
    public Image fatFrame;
    public Image carbsFrame;

    private static readonly Color goodColor = new Color32(0x4E, 0xC7, 0x6E, 0xFF); // #4EC76E
    private static readonly Color badColor = new Color32(0xFF, 0x63, 0x47, 0xFF); // #FF6347
    private static readonly Color normalColor = new Color32(0xE3, 0x5D, 0x02, 0xFF); // #E35D02

    public CalorieAndMacrosJournal journal;
    public Text caloriesText;
    public Text proteinText;
    public Text fatText;
    public Text carbsText;
    public Image statusImage;
    public Sprite goodSprite;
    public Sprite normalSprite;
    public Sprite badSprite;

    // Задайте свои пороговые значения
    public int calorieTarget = 2000;
    public float proteinTarget = 100f;
    public float fatTarget = 70f;
    public float carbsTarget = 250f;

    void Update()
    {
        RefreshUI();
    }

    public void RefreshUI()
    {
        // Вывод streak (дней подряд с нормой)
        if (streakText != null)
        {
            int streak = journal.GetStreak(calorieTarget, proteinTarget);
            streakText.text = $"Healthy streak: {streak} days";
        }
        var (cal, prot, fat, carb) = journal.GetTodayTotals();
        caloriesText.text = $"Calories: {cal}";
        proteinText.text = $"Proteins: {prot:F1}";
        fatText.text = $"Fats: {fat:F1}";
        carbsText.text = $"Carbs: {carb:F1}";

        var (avgCal, avgProt, avgFat, avgCarb) = journal.GetWeeklyAverages();
        // Вывод средних значений за неделю
        if (avgCaloriesText != null) avgCaloriesText.text = $"Avg Calories (week): {avgCal:F0}";
        if (avgProteinText != null) avgProteinText.text = $"Avg Proteins (week): {avgProt:F1}";
        if (avgFatText != null) avgFatText.text = $"Avg Fats (week): {avgFat:F1}";
        if (avgCarbsText != null) avgCarbsText.text = $"Avg Carbs (week): {avgCarb:F1}";
        // Новая логика смены картинки
        float calDeviation = Mathf.Abs(avgCal - calorieTarget) / (float)calorieTarget;
        float protDeviation = Mathf.Abs(avgProt - proteinTarget) / proteinTarget;
        float maxDeviation = Mathf.Max(calDeviation, protDeviation);

        if (maxDeviation <= 0.10f)
        {
            statusImage.sprite = goodSprite; // веселый
            SetFramesColor(goodColor);
        }
        else if (maxDeviation <= 0.25f)
        {
            statusImage.sprite = normalSprite; // нормальный
            SetFramesColor(normalColor);
        }
        else
        {
            statusImage.sprite = badSprite; // грустный
            SetFramesColor(badColor);
        }
    }

    private void SetFramesColor(Color color)
    {
        if (caloriesFrame != null) caloriesFrame.color = color;
        if (proteinFrame != null) proteinFrame.color = color;
        if (fatFrame != null) fatFrame.color = color;
        if (carbsFrame != null) carbsFrame.color = color;
    }
}