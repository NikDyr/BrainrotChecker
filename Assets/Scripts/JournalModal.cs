using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class JournalModal : MonoBehaviour
{
    [Header("UI References")]
    public GameObject modalWindow; // Панель модального окна
    public TextMeshProUGUI journalText; // Текстовое поле для вывода записей
    private RectTransform journalTextRect; // RectTransform текстового поля
    public ScrollRect scrollRect; // ScrollRect для прокрутки

    private List<CalorieAndMacrosEntry> entries = new List<CalorieAndMacrosEntry>();

    [Header("Journal Loader")]
    public JournalLoader journalLoader; // Ссылка на загрузчик журнала
    public CalorieAndMacrosJournal journal; // Ссылка на сам журнал

    // Вызывайте этот метод для открытия модального окна и загрузки записей
    public void Open()
    {
        if (journal != null)
        {
            entries = journal.entries;
        }
        modalWindow.SetActive(true);
        LoadEntriesToText();
        ResetScroll();
    }

    // Закрыть модальное окно
    public void Close()
    {
        modalWindow.SetActive(false);
    }

    // Формирует текст для вывода всех записей по датам
    private void LoadEntriesToText()
    {
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        if (entries != null)
        {
            foreach (var entry in entries)
            {
                if (entry == null)
                    continue;
                sb.AppendLine($"<b>{entry.date:dd.MM.yyyy}</b>");
                sb.AppendLine(entry.ToString());
                sb.AppendLine("----------------------");
            }
        }
        if (journalText != null)
            journalText.text = sb.ToString();
        AdaptTextHeight();
    }

    // Адаптировать высоту текстового поля под содержимое
    private void AdaptTextHeight()
    {
        if (journalTextRect == null && journalText != null)
            journalTextRect = journalText.GetComponent<RectTransform>();
        if (journalTextRect != null && journalText != null)
        {
            // Обновить layout, чтобы получить актуальную высоту
            LayoutRebuilder.ForceRebuildLayoutImmediate(journalTextRect);
            float preferredHeight = journalText.preferredHeight;
            journalTextRect.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, preferredHeight);
        }
    }

    // Сбросить скролл в начало
    private void ResetScroll()
    {
        Canvas.ForceUpdateCanvases();
        scrollRect.verticalNormalizedPosition = 1f;
    }
}
