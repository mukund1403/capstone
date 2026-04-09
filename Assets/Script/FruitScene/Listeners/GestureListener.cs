using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GestureListener : BaseListener
{
    private string[] allGestures = { "rectangle", "circle", "triangle" };

    private Queue<GestureMsg> atkHandQueue = new Queue<GestureMsg>();
    private Queue<GestureMsg> defHandQueue = new Queue<GestureMsg>();
    private Queue<GestureMsg> defSwordQueue = new Queue<GestureMsg>();

    [System.Serializable]
    public class GestureMsg
    {
        public string gesture;
        public float confidence;
    }

    public GestureMsg takeFirstMsg(string name)
    {
        Queue<GestureMsg> selected = name switch
        {
            "atkHand" => atkHandQueue,
            "defHand" => defHandQueue,
            "defSword" => defSwordQueue,
            _ => null
        };

        if (selected != null && selected.Count > 0)
        {
            return selected.Dequeue();
        }
        return null;
    }

    public void ClearQueue(string name)
    {
        switch (name)
        {
            case "atkHand": atkHandQueue.Clear(); break;
            case "defHand": defHandQueue.Clear(); break;
            case "defSword": defSwordQueue.Clear(); break;
        }
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
            atkHandQueue.Enqueue(inputMsg);
        }

        if (topic.StartsWith("fruitninja/defender/sword/gesture/detected"))
        {
            defSwordQueue.Enqueue(inputMsg);
        }

        if (topic.StartsWith("fruitninja/defender/hand/gesture/detected"))
        {
            defHandQueue.Enqueue(inputMsg);
        }
        //Debug.Log("Def Sword Gesture is: " + "\n" + takeFirstMsg("defSword").gesture);
    }
}
