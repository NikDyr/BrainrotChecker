using System;

[Serializable]
public class CalorieAndMacrosEntry
{
    // Для сериализации
    public string dateString;
    // Для работы в коде
    [NonSerialized]
    public DateTime date;
    public int calories;
    public float protein;
    public float fat;
    public float carbs;

    public CalorieAndMacrosEntry(DateTime date, int calories, float protein, float fat, float carbs)
    {
        this.date = date;
        this.dateString = date.ToString("yyyy-MM-dd HH:mm:ss");
        this.calories = calories;
        this.protein = protein;
        this.fat = fat;
        this.carbs = carbs;
    }

    // Для десериализации
    public void ParseDateString()
    {
        if (!string.IsNullOrEmpty(dateString))
        {
            DateTime.TryParse(dateString, out date);
        }
    }

    public override string ToString()
    {
        // Если дата не установлена, пробуем распарсить
        if (date == default && !string.IsNullOrEmpty(dateString))
        {
            DateTime.TryParse(dateString, out date);
        }
        return $"Дата: {date:dd.MM.yyyy} Время: {date:HH:mm}\nКалории: {calories}\nБелки: {protein:F1}\nЖиры: {fat:F1}\nУглеводы: {carbs:F1}";
    }
}