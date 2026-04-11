using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Video;

public class VideoController : MonoBehaviour
{
    [SerializeField] private VideoPlayer videoPlayer;
    [SerializeField] private VideoClip[] clips;
    private GameObject videoPlayerObject;

    public static VideoController Instance;

    void Awake()
    {
        Instance = this;
        videoPlayerObject = GameObject.Find("VideoPlayer");
        if (videoPlayerObject != null)
        {
            videoPlayerObject.SetActive(false);
        }
        videoPlayer.enabled = false;
    }

    public void SwitchStep(string input)
    {
        switch (input)
        {
            case "carat":
                PlayClip(0);
                break;
            case "checkmark":
                PlayClip(1);
                break;
            case "circle":
                PlayClip(2);
                break;
            case "z":
                PlayClip(3);
                break;
            case "infinity":
                PlayClip(4);
                break;
            default:
                PlayClip(-1);
                break;
        }
    }

    private void PlayClip(int index)
    {
        if (videoPlayerObject == null)
        {
            return;
        }
        videoPlayer.Stop();
        if (index < 0)
        {
            videoPlayer.clip = null;
            videoPlayerObject.SetActive(false);
        }
        else
        {
            videoPlayerObject.SetActive(true);
            videoPlayer.clip = clips[index];
            videoPlayer.enabled = true;
            videoPlayer.Play();
        }
    }
}
