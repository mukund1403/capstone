 using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class StatusListener : BaseListener
{

    public bool attackerActive;
    public bool defenderActive;

    private bool swordActive;
    private bool handActive;

    public static StatusListener statusInstance;

    private void Awake()
    {
        statusInstance = this;
    }

    void HandleMqtt(string topic, string payload)
    {
        if (!topic.StartsWith("fruitninja/defender/sword/status") &&
            !topic.StartsWith("fruitninja/defender/hand/status") &&
            !topic.StartsWith("fruitninja/attacker/status"))
        {
            return;
        }
        if (topic.StartsWith("fruitninja/attacker/status"))
        {
            if (payload == "online")
            {
                attackerActive = true;
            }
            else if (payload == "offline")
            {
                attackerActive = false;
            }
        }

        if (topic.StartsWith("fruitninja/defender/sword/status"))
        {
            if (payload == "online")
            {
                swordActive = true;
            }
            else if (payload == "offline")
            {
                swordActive = false;
            }
        }

        if (topic.StartsWith("fruitninja/defender/hand/status"))
        {
            if (payload == "online")
            {
                handActive = true;
            }
            else if (payload == "offline")
            {
                handActive = false;
            }
        }

        if (swordActive && handActive)
        {
            defenderActive = true;
        }
        else
        {
            defenderActive = false;
        }

    }
}
