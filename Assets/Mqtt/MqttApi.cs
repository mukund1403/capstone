// Visualiser adds new functions which are called from game in here
using UnityEngine;


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

    // Unity detect first collision between sword and a fruit (indicate defender's start of slicing), and send a control message
    public static void SliceCollisionDetected()
    {
        MqttService.Instance.PublishImuControl(
        MqttService.PublishTopic.DEFENDER_SWORD_IMU_CONTROL_TOPIC,
        new ImuControlMessage("imuWindow", "sliceStart")
        );
        Debug.Log("collide message sent");
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
}
