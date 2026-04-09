using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GestureListener : BaseListener
{
    private string[] allGestures = {"rectangle", "circle", "triangle"};

    private Stack<GestureMsg> atkHandStack = new Stack<GestureMsg>();
    private Stack<GestureMsg> defHandStack = new Stack<GestureMsg>();
    private Stack<GestureMsg> defSwordStack = new Stack<GestureMsg>();

    [System.Serializable]
    public class GestureMsg
    {
        public string gesture;
        public float confidence;
    }

    public GestureMsg takeLatestMsg(string name)
    {
        Stack<GestureMsg> selected = name switch
        {
            "atkHand" => atkHandStack,
            "defHand" => defHandStack,
            "defSword" => defSwordStack,
            _ => null
        };

        if (selected != null && selected.Count > 0)
        {
            GestureMsg latest = selected.Pop();
            selected.Clear();
            return latest;
        }
        return null;
    }

    protected override void HandleMqtt(string topic, string payload)
    {
        if (!topic.StartsWith("fruitninja/defender/sword/gesture/detected") &&
            !topic.StartsWith("fruitninja/defender/hand/gesture/detected") &&
            !topic.StartsWith("fruitninja/attacker/gesture/detected"))
        {
            return;
        }

        GestureMsg inputMsg = JsonUtility.FromJson<GestureMsg>(payload);

        if (topic.StartsWith("fruitninja/attacker/gesture/detected"))
        {
            atkHandStack.Push(inputMsg);
}

        if (topic.StartsWith("fruitninja/defender/sword/gesture/detected"))
        {
            defSwordStack.Push(inputMsg);
        }

        if (topic.StartsWith("fruitninja/defender/hand/gesture/detected"))
        {
            defHandStack.Push(inputMsg);
        }
        //Debug.Log("Def Sword Gesture is: " + "\n" + takeFirstMsg("defSword").gesture);
    }
}
