using System.Collections.Generic;
using System.IO;
using UnityEngine;
using System;

public class JournalLoader : MonoBehaviour
{
    // Загружать журнал при запуске приложения (Awake вызывается до Start и Update)
    private void Awake()
    {
        LoadJournal();
    }
    public CalorieAndMacrosJournal journal;
    public string fileName = "journal.json";

    public void SaveJournal()
    {
        string path = Path.Combine(Application.persistentDataPath, fileName);
        string json = JsonUtility.ToJson(new EntryListWrapper { entries = journal.entries });
        File.WriteAllText(path, json);
    }

    public void LoadJournal()
    {
        string path = Path.Combine(Application.persistentDataPath, fileName);
        if (File.Exists(path))
        {
            string json = File.ReadAllText(path);
            var wrapper = JsonUtility.FromJson<EntryListWrapper>(json);
            journal.entries = wrapper.entries ?? new List<CalorieAndMacrosEntry>();
            // Парсим дату для каждой записи
            foreach (var entry in journal.entries)
            {
                entry.ParseDateString();
            }
        }
        // Обновить все UI после загрузки
        foreach (var ui in GameObject.FindObjectsOfType<CalorieAndMacrosUI>())
        {
            ui.RefreshUI();
        }
    }

    [Serializable]
    private class EntryListWrapper
    {
        public List<CalorieAndMacrosEntry> entries;
    }

    // Сохранять журнал при выходе из приложения (работает и на мобильных устройствах)
    private void OnApplicationQuit()
    {
        SaveJournal();
    }

    // Сохранять журнал при сворачивании/приостановке приложения (актуально для мобильных)
    private void OnApplicationPause(bool pause)
    {
        if (pause)
        {
            SaveJournal();
        }
    }
}