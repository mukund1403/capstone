 using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class StatusListener : BaseListener
{
    public bool attackerOnline;
    public bool swordOnline;
    public bool handOnline;
    public bool playersOnline;
    public bool gamePaused;

    public bool attackerActive;
    public bool defenderActive;

    private bool swordActive;
    private bool handActive;

    private List<string> validMsgs = new List<string> { "online", "offline", "paused", "resumed" };

    protected override void HandleMqtt(string topic, string payload)
    {
        if (!topic.StartsWith("fruitninja/defender/sword/status") &&
            !topic.StartsWith("fruitninja/defender/hand/status") &&
            !topic.StartsWith("fruitninja/attacker/status"))
        {
            return;
        }

        if (topic.StartsWith("fruitninja/attacker/status"))
        {
            attackerOnline = validMsgs.Contains(payload) && payload != "offline" ? true : false;
        }

        if (topic.StartsWith("fruitninja/defender/sword/status"))//only sword send paused/resumed
        {
            swordOnline = validMsgs.Contains(payload) && payload != "offline" ? true : false;

            if (swordActive == false && payload == "paused")
            {
                swordActive = false;
            }
            else if (swordActive == false && payload == "resumed")
            {
                swordActive = true;
            }
        }

        if (topic.StartsWith("fruitninja/defender/hand/status"))
        {
            handOnline = validMsgs.Contains(payload) && payload != "offline" ? true : false;
        }

        defenderActive = swordActive && handActive;
        playersOnline = attackerOnline && swordOnline && handOnline;
    }
}
