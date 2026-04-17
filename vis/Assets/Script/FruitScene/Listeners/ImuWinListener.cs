using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ImuWinListener : BaseListener
{
    protected override void HandleMqtt(string topic, string payload)
    {
        if (!topic.StartsWith("fruitninja/defender/sword/imu/window") &&
            !topic.StartsWith("fruitninja/defender/hand/imu/window") &&
            !topic.StartsWith("fruitninja/attacker/imu/window")) 
        { 
            return; 
        }
        Debug.Log($"[DummyListener] {topic}: {payload}");
    }
}
