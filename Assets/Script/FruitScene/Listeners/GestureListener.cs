using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GestureListener : BaseListener
{
    private string[] allGestures = {"rectangle", "circle", "triangle"};
    public string atkHandGesture;
    public string defSwordGesture;
    public string defHandGesture;

    public static GestureListener gestureInstance;

    private void Awake()
    {
        gestureInstance = this;
    }

    void HandleMqtt(string topic, string payload)
    {
        if (!topic.StartsWith("fruitninja/defender/sword/gesture/detected") &&
            !topic.StartsWith("fruitninja/defender/hand/gesture/detected") &&
            !topic.StartsWith("fruitninja/attacker/gesture/detected"))
        {
            return;
        }

        if (topic.StartsWith("fruitninja/attacker/gesture/detected"))
        {
            atkHandGesture = payload;
            defSwordGesture = null;
            defHandGesture = null;
}

        if (topic.StartsWith("fruitninja/defender/sword/gesture/detected"))
        {
            defSwordGesture = payload;
            atkHandGesture = null;
            defHandGesture = null;
        }

        if (topic.StartsWith("fruitninja/defender/hand/gesture/detected"))
        {
            defHandGesture = payload;
            defSwordGesture = null;
            atkHandGesture = null;
        }
    }
}
