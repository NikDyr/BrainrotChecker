using UnityEngine;

public class LockScreenPosition : MonoBehaviour
{
    // Устанавливаем позицию объекта в центре экрана
    private void Start()
    {
        Screen.orientation = ScreenOrientation.Portrait;
    }
}