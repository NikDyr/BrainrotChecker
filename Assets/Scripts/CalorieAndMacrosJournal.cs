using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;


public class CalorieAndMacrosJournal : MonoBehaviour
{    // Возвращает количество дней подряд, когда калории и белки были в пределах нормы (±10%)
    public int GetStreak(int calorieTarget, float proteinTarget)
    {
        // Группируем записи по дате
        var grouped = entries
            .GroupBy(e => e.date.Date)
            .OrderByDescending(g => g.Key)
            .ToList();

        int streak = 0;
        foreach (var day in grouped)
        {
            int cal = day.Sum(e => e.calories);
            float prot = day.Sum(e => e.protein);
            bool calOk = Mathf.Abs(cal - calorieTarget) <= calorieTarget * 0.10f;
            bool protOk = Mathf.Abs(prot - proteinTarget) <= proteinTarget * 0.10f;
            if (calOk && protOk)
                streak++;
            else
                break;
        }
        return streak;
    }

    public void ClearAllEntries()
    {
        entries.Clear();
    }

    public List<CalorieAndMacrosEntry> entries = new List<CalorieAndMacrosEntry>();

    public void AddEntry(CalorieAndMacrosEntry entry)
    {
        // Синхронизируем строковое поле для сериализации
        entry.dateString = entry.date.ToString("yyyy-MM-dd HH:mm:ss");
        entries.Add(entry);
    }

    // Удалить запись по индексу
    public void RemoveEntryAt(int index)
    {
        if (index >= 0 && index < entries.Count)
            entries.RemoveAt(index);
    }

    // Удалить запись по ссылке
    public void RemoveEntry(CalorieAndMacrosEntry entry)
    {
        entries.Remove(entry);
    }


    public (int, float, float, float) GetTodayTotals()
    {
        var today = DateTime.Today;
        var todayEntries = entries.Where(e => e.date.Date == today);
        return (
            todayEntries.Sum(e => e.calories),
            todayEntries.Sum(e => e.protein),
            todayEntries.Sum(e => e.fat),
            todayEntries.Sum(e => e.carbs)
        );
    }

    public (float, float, float, float) GetWeeklyAverages()
    {
        var weekAgo = DateTime.Today.AddDays(-6);
        var weekEntries = entries.Where(e => e.date.Date >= weekAgo && e.date.Date <= DateTime.Today).ToList();
        var daysWithEntries = weekEntries.Select(e => e.date.Date).Distinct().Count();
        if (daysWithEntries == 0)
            return (0f, 0f, 0f, 0f);
        return (
            weekEntries.Sum(e => e.calories) / (float)daysWithEntries,
            weekEntries.Sum(e => e.protein) / daysWithEntries,
            weekEntries.Sum(e => e.fat) / daysWithEntries,
            weekEntries.Sum(e => e.carbs) / daysWithEntries
        );
    }
}