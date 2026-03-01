using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GestureListener : BaseListener
{
    private string[] allGestures = {"rectangle", "circle", "triangle"};
    public string gestureDetected;
    void HandleMqtt(string topic, string payload)
    {
        if (!topic.StartsWith("fruitninja/defender/sword/gesture/detected") &&
            !topic.StartsWith("fruitninja/defender/hand/gesture/detected") &&
            !topic.StartsWith("fruitninja/attacker/gesture/detected"))
        {
            return;
        }
        Debug.Log($"[DummyListener] {topic}: {payload}");
    }

    public string tempGestureInput(string input)
    {
        gestureDetected = input;
        return gestureDetected;
    }
}
