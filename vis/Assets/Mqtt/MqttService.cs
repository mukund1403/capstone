using UnityEngine;
using uPLibrary.Networking.M2Mqtt;
using uPLibrary.Networking.M2Mqtt.Messages;
using System.Security.Cryptography.X509Certificates;
using System.IO;
using System.Text;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Collections;
using UnityEngine.Networking;

public class MqttService : MonoBehaviour
{
    public static MqttService Instance;

    private MqttClient client;

    public enum PublishTopic
    {
        ATTACKER_IMU_CONTROL_TOPIC,
        DEFENDER_SWORD_IMU_CONTROL_TOPIC,
        DEFENDER_HAND_IMU_CONTROL_TOPIC,
        ATTACKER_THROW,
    }

    // Roles and topic building
    private string[] roles = { "attacker", "defender" };
    private string[] defenderParts = { "sword", "hand" };

    private string[] subTopics;
    private byte[] qos;

    // Game-facing event
    public event Action<string, string> OnMessageReceived;

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }

        Instance = this;
        DontDestroyOnLoad(gameObject);

        BuildSubTopics();
    }

    IEnumerator Start()
    {
        string path = Path.Combine(Application.streamingAssetsPath, "Certificates/ca.crt");

        UnityWebRequest www = UnityWebRequest.Get(path);
        yield return www.SendWebRequest();

        var caCert = new X509Certificate2(www.downloadHandler.data);

        client = new MqttClient(
            "192.168.137.2",
            8883,
            true,
            caCert,
            null,
            MqttSslProtocols.TLSv1_2,
            (sender, certificate, chain, sslPolicyErrors) => true
        );

        client.MqttMsgPublishReceived += HandleMqttMessage;

        string clientId = Guid.NewGuid().ToString();
        client.Connect(clientId, "unity", "capstone");

        client.Subscribe(subTopics, qos);

        Debug.Log("Connected to MQTT with TLS + CA cert");
    }

    private void BuildSubTopics()
    {
        List<string> subTopicList = new List<string>();

        // Status topics
        subTopicList.Add("fruitninja/attacker/status");
        foreach (var part in defenderParts)
        {
            subTopicList.Add($"fruitninja/defender/{part}/status");
        }

        //Gesture Topics
        subTopicList.Add("fruitninja/attacker/gesture/detected");
        foreach (var part in defenderParts) {
            subTopicList.Add($"fruitninja/defender/{part}/gesture/detected");
        }

        subTopicList.Add("fruitninja/attacker/throw");

        subTopics = subTopicList.ToArray();
        qos = Enumerable.Repeat(MqttMsgBase.QOS_LEVEL_AT_MOST_ONCE, subTopics.Length).ToArray();
    }

    // Publish to Control
    public void PublishImuControl(PublishTopic topic, ImuControlMessage msg, byte qosLevel = MqttMsgBase.QOS_LEVEL_AT_MOST_ONCE)
    {
        string json = JsonUtility.ToJson(msg);

        string topicString = topic switch
        {
            PublishTopic.ATTACKER_IMU_CONTROL_TOPIC => "fruitninja/attacker/control",
            PublishTopic.DEFENDER_SWORD_IMU_CONTROL_TOPIC => "fruitninja/defender/sword/control",
            PublishTopic.DEFENDER_HAND_IMU_CONTROL_TOPIC => "fruitninja/defender/hand/control",
            PublishTopic.ATTACKER_THROW => "fruitninja/attacker/throw",
            _ => throw new ArgumentOutOfRangeException(nameof(topic), topic, null)
        };

        Publish(topicString, json, qosLevel);
    }

    public void Publish(string topic, string payload, byte qosLevel)
    {
        if (client == null || !client.IsConnected)
        {
            Debug.LogWarning("MQTT not connected, publish skipped");
            return;
        }

        client.Publish(
            topic,
            Encoding.UTF8.GetBytes(payload),
            qosLevel,
            false
        );

        Debug.Log($"Published → {topic}: {payload}");
    }

    // Subscribe Handling
    private void HandleMqttMessage(object sender, MqttMsgPublishEventArgs e)
    {
        string topic = e.Topic;
        string payload = Encoding.UTF8.GetString(e.Message);

        Debug.Log($"Received ← {topic}: {payload}");

        // Fan out to game logic
        OnMessageReceived?.Invoke(topic, payload);
    }
}
