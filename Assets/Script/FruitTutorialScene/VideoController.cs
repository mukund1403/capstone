using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Video;

public class VideoController : MonoBehaviour
{
    [SerializeField] private VideoPlayer videoPlayer;
    [SerializeField] private VideoClip[] clips;
    [SerializeField] private RawImage videoDisplay;

    void Awake()
    {
        videoDisplay.enabled = false;
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
        videoPlayer.Stop();
        if (index < 0)
        {
            videoPlayer.clip = null;
            videoDisplay.enabled = false;
        }
        else
        {
            videoPlayer.clip = clips[index];
            videoDisplay.enabled = true;
            videoPlayer.Play();
        }
    }
}
