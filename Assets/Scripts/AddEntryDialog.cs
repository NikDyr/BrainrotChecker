using UnityEngine;
using UnityEngine.UI;
using System;
using TMPro;

public class AddEntryDialog : MonoBehaviour
{
    public TMP_InputField caloriesInput;
    public TMP_InputField proteinInput;
    public TMP_InputField fatInput;
    public TMP_InputField carbsInput;
    public CalorieAndMacrosJournal journal;
    public JournalLoader journalLoader; // Для сохранения после добавления
    public Text warningText;
    public ModalWindowAnimator modalAnimator;

    // Пропорции для автоматического расчёта БЖУ (в % от калорий)
    private const float ProteinPercent = 0.15f;
    private const float FatPercent = 0.30f;
    private const float CarbsPercent = 0.55f;
    private const float KcalPerGramProtein = 4f;
    private const float KcalPerGramFat = 9f;
    private const float KcalPerGramCarb = 4f;

    public void OnAddEntry()
    {
        warningText.text = "";
        string calStr = caloriesInput.text.Trim();
        if (string.IsNullOrEmpty(calStr))
        {
            warningText.text = "Please enter at least the calorie value!";
            if (modalAnimator != null) modalAnimator.ShakeWindow();
            return;
        }

        int calories;
        if (!int.TryParse(calStr, out calories) || calories <= 0)
        {
            warningText.text = "Incorrect calorie value!";
            if (modalAnimator != null) modalAnimator.ShakeWindow();
            return;
        }

        float protein, fat, carbs;
        bool proteinOk = float.TryParse(proteinInput.text, out protein) && protein > 0f;
        bool fatOk = float.TryParse(fatInput.text, out fat) && fat > 0f;
        bool carbsOk = float.TryParse(carbsInput.text, out carbs) && carbs > 0f;

        // Если не введены БЖУ, рассчитываем автоматически
        if (!proteinOk || !fatOk || !carbsOk)
        {
            protein = (calories * ProteinPercent) / KcalPerGramProtein;
            fat = (calories * FatPercent) / KcalPerGramFat;
            carbs = (calories * CarbsPercent) / KcalPerGramCarb;
        }

        var entry = new CalorieAndMacrosEntry(DateTime.Now, calories, protein, fat, carbs);
        journal.AddEntry(entry);
        if (journalLoader != null)
        {
            journalLoader.SaveJournal();
        }
        caloriesInput.text = "";
        proteinInput.text = "";
        fatInput.text = "";
        carbsInput.text = "";
        if (modalAnimator != null)
            modalAnimator.Hide();
        else
            gameObject.SetActive(false);
    }
}