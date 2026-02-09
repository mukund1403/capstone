using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StatusListener : BaseListener
{
    void HandleMqtt(string topic, string payload)
    {
        if (!topic.StartsWith("fruitninja/defender/sword/status") &&
            !topic.StartsWith("fruitninja/defender/hand/status") &&
            !topic.StartsWith("fruitninja/attacker/status"))
        {
            return;
        }
        Debug.Log($"[DummyListener] {topic}: {payload}");
    }
}
