// This file has all the payload formats so that we can easily serialize and deserialize

[System.Serializable] // Required for JsonUtility
public class ImuControlMessage
{
    public string device;
    public string action;

    public ImuControlMessage(string device, string action)
    {
        this.device = device;
        this.action = action;
    }
}
