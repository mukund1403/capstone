using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Text;
using System.Linq;
using System;

public class GestureListener : BaseListener
{
    private string[] allGestures = {"rectangle", "circle", "triangle"};

    private Stack<GestureMsg> atkHandStack = new Stack<GestureMsg>();
    private Stack<GestureMsg> defHandStack = new Stack<GestureMsg>();
    private Stack<GestureMsg> defSwordStack = new Stack<GestureMsg>();
    private Stack<GestureMsg> throwStack = new Stack<GestureMsg>();
    [System.Serializable]
    public class GestureMsg
    {
        public string gesture;
        public float confidence;
        //public float timestamp;
    }

    public string GetLastFiveGestures()
    {
        if (defSwordStack == null || defSwordStack.Count == 0)
            return "No gestures";

        StringBuilder sb = new StringBuilder();

        // Stack enumerates from top ? bottom
        var lastFive = defSwordStack.Take(5);

        foreach (var msg in lastFive)
        {
            sb.AppendLine($"gesture: {msg.gesture}, confidence: {msg.confidence}");
        }

        return sb.ToString();
    }

    public string GetLastFiveGesturesHand()
    {
        if (atkHandStack == null || atkHandStack.Count == 0)
            return "No gestures";

        StringBuilder sb = new StringBuilder();

        // Stack enumerates from top ? bottom
        var lastFive = atkHandStack.Take(5);

        foreach (var msg in lastFive)
        {
            sb.AppendLine($"gesture: {msg.gesture}, confidence: {msg.confidence}");
        }

        return sb.ToString();
    }

    //public GestureMsg takeLatestMsg(string name)
    //{
    //    Stack<GestureMsg> selected = name switch
    //    {
    //        "atkHand" => atkHandStack,
    //        "defHand" => defHandStack,
    //        "defSword" => defSwordStack,
    //        _ => null
    //    };

    //    if (selected != null && selected.Count > 0)
    //    {
    //        if (name == "atkHand")
    //        {
    //            GestureMsg latest = selected.Peek();
    //            return latest;
    //        }
    //        else
    //        {
    //            GestureMsg latest = selected.Pop();
    //            selected.Clear();
    //            return latest;
    //        }
    //    }
    //    return null;
    //}
    public GestureMsg takeLatestMsg(string name)
    {
        Stack<GestureMsg> selected = name switch
        {
            "atkHand" => atkHandStack,
            "defHand" => defHandStack,
            "defSword" => defSwordStack,
            "atkthrown" => throwStack,
            _ => null
        };
        
        if (selected != null && selected.Count > 0)
        {
            GestureMsg latest;
            if (selected == atkHandStack)
            {
                lock (selected)
                {
                    latest = selected.Pop();
                    selected.Clear();
                    return latest;
                }
            }
            latest = selected.Pop();
            selected.Clear();
            return latest;
        }
        
        return null;
    }
    protected override void HandleMqtt(string topic, string payload)
    {
        if (!topic.StartsWith("fruitninja/defender/sword/gesture/detected") &&
            !topic.StartsWith("fruitninja/defender/hand/gesture/detected") &&
            !topic.StartsWith("fruitninja/attacker/gesture/detected") &&
            !topic.StartsWith("fruitninja/attacker/throw")) 
        {
            return;
        }

        GestureMsg inputMsg = JsonUtility.FromJson<GestureMsg>(payload);

        if (topic.StartsWith("fruitninja/attacker/gesture/detected"))
        {
            Debug.Log(inputMsg);
            if (inputMsg.confidence >= 0.9f)
            {
                atkHandStack.Push(inputMsg);
                Debug.Log("Push to stack.");
            }
        }

        if (topic.StartsWith("fruitninja/defender/sword/gesture/detected"))
        {
            if (inputMsg.gesture == "idle" || inputMsg.confidence < 0.9f)
            {
                return;
            }
            defSwordStack.Push(inputMsg);
            Debug.Log("sword push to stack");
        }

        if (topic.StartsWith("fruitninja/defender/hand/gesture/detected"))
        {
            if (inputMsg.confidence >= 0.99f)
            {
                defHandStack.Push(inputMsg);
            }
        }

        if (topic.StartsWith("fruitninja/attacker/throw"))
        {
            throwStack.Push(inputMsg);
            Debug.Log("Bomb throw pushed to stack.");
        }
        //Debug.Log("Def Sword Gesture is: " + "\n" + takeFirstMsg("defSword").gesture);
    }
}
