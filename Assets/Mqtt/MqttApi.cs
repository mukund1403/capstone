// Visualiser adds new functions which are called from game in here
using UnityEngine;
using UnityEngine.XR.ARSubsystems;


public static class MqttApi
{
    // defender successfully cuts fruit (using sword) and you need to send back a buzzer control message to esp
    // Example invocation: MqttApi.BuzzSuccess() -> can see in DummyPublisher.cs
    public static void BuzzSuccess()
    {
        MqttService.Instance.PublishImuControl(
            MqttService.PublishTopic.DEFENDER_SWORD_IMU_CONTROL_TOPIC,
            new ImuControlMessage("buzzer", "successBuzz")
        );
        Debug.Log("buzz message sent");
    }

    // defender does not successfully cut fruit (using sword) and you need to send back a buzzer control message to esp
    public static void BuzzFailure()
    {
        MqttService.Instance.PublishImuControl(
            MqttService.PublishTopic.DEFENDER_SWORD_IMU_CONTROL_TOPIC,
            new ImuControlMessage("buzzer", "failBuzz")
        );
        Debug.Log("buzz message sent");
    }

    // Unity detect first collision between sword and a fruit (indicate defender's start of slicing), and send a control message
    public static void SliceCollisionDetected()
    {
        MqttService.Instance.PublishImuControl(
        MqttService.PublishTopic.DEFENDER_SWORD_IMU_CONTROL_TOPIC,
        new ImuControlMessage("imuWindow", "sliceStart")
        );
        Debug.Log("collide message sent");
    }

    // Unity send a control message indicating successful slice
    public static void SuccessfulSliceDetected()
    {
        MqttService.Instance.PublishImuControl(
        MqttService.PublishTopic.DEFENDER_SWORD_IMU_CONTROL_TOPIC,
        new ImuControlMessage("buzzer", "successBuzz")
        );
        Debug.Log("success message sent");
    }

    // Unity send a control message indicating unsuccessful slice
    public static void UnsuccessfulSliceDetected()
    {
        MqttService.Instance.PublishImuControl(
        MqttService.PublishTopic.DEFENDER_SWORD_IMU_CONTROL_TOPIC,
        new ImuControlMessage("buzzer", "successBuzz")
        );
        Debug.Log("unsuccess message sent");
    }

    // Unity detect first collision between hand and a fruit/item (indicate attacker's pick-up action), and send a control message
    public static void PickCollisionDetected()
    {
        MqttService.Instance.PublishImuControl(
        MqttService.PublishTopic.ATTACKER_IMU_CONTROL_TOPIC,
        new ImuControlMessage("imuWindow", "pickUpStart")
        );
        Debug.Log("pick message sent");
    }

    public static void DummyGesture(string input, string topic)
    {
        string msg = $"{{\"gesture\":\"{input}\",\"confidence\":0.92}}";
        string fullTopic = "";
        if (topic == "defHand")
        {
            fullTopic = "fruitninja/defender/hand/gesture/detected";
        }
        if (topic == "atkHand")
        {
            fullTopic = "fruitninja/attacker/throw";
        }
        if (topic == "defSword")
        {
            fullTopic = "fruitninja/defender/sword/gesture/detected";
        }
        MqttService.Instance.Publish(fullTopic, msg, 0);
    }
}
