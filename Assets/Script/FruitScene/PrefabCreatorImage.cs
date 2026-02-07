using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using TMPro;


public class PrefabCreatorImage : MonoBehaviour
{
    [SerializeField] private Vector3 prefabOffset;
    private GameObject contentRoot;
    private bool isInitialized;

    private ARTrackedImageManager aRTrackedImageManager;

    [SerializeField] private GameObject katanaPrefab;
    [SerializeField] private TMP_Text text;
    private GameObject katana;

    private void OnEnable()
    {
        aRTrackedImageManager = gameObject.GetComponent<ARTrackedImageManager>();
        aRTrackedImageManager.trackedImagesChanged += OnImageChanged;
    }

    private void SetMessage(string message)
    {
        text.text = message;
    }

    private void OnImageChanged(ARTrackedImagesChangedEventArgs obj)
    {
        foreach (ARTrackedImage image in obj.added)
        {
            contentRoot = new GameObject("ContentRoot");
            contentRoot.transform.SetParent(image.transform, false);
            katana = Instantiate(katanaPrefab, contentRoot.transform);
            isInitialized = false;
        }
        foreach (ARTrackedImage image in obj.updated)
        {
            if (katana == null)
            {
                SetMessage("Kanata Status: not exist");
                return;
            }
            if (image.trackingState == TrackingState.Tracking)
            {
                katana.SetActive(true);
                if (!isInitialized)
                {
                    InitializeContent();
                    isInitialized = true;
                }

                string message = "Kanata Status: tracking active\n" + katana.transform.position;
                message += "\n";
                message += image.transform.position;
                SetMessage(message);
            }
            else
            {
                katana.SetActive(false);
                SetMessage("Kanata Status: tracking inactive");
            }
        }
    }

    private void InitializeContent()
    {
        contentRoot.transform.localScale = new Vector3(0.1f, 0.1f, 0.1f);
        //contentRoot.transform.localPosition += prefabOffset;
        contentRoot.transform.localRotation = Quaternion.Euler(0, 90, 0);

        foreach (var r in contentRoot.GetComponentsInChildren<Renderer>())
        {
            r.enabled = false;
            r.enabled = true;
        }
    }
}
