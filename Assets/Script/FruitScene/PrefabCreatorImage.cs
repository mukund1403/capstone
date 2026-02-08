using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using TMPro;
using System.Runtime.CompilerServices;


public class PrefabCreatorImage : MonoBehaviour
{
    [SerializeField] private Vector3 prefabOffset;
    //private GameObject contentRoot;
    //private bool isInitialized;

    private ARTrackedImageManager aRTrackedImageManager;

    [SerializeField] private GameObject katanaPrefab;
    [SerializeField] private TMP_Text text;
    private GameObject katana;

    private void Awake()
    {
        aRTrackedImageManager = gameObject.GetComponent<ARTrackedImageManager>();
    }

    private void OnEnable()
    {
        if (aRTrackedImageManager != null)
        {
            aRTrackedImageManager.trackedImagesChanged += OnImageChanged;
        }
    }

    private void OnDisable()
    {
        if (aRTrackedImageManager != null)
        {
            aRTrackedImageManager.trackedImagesChanged -= OnImageChanged;
        }
    }

    private void SetMessage(string message)
    {
        text.text = message;
    }

    private void OnImageChanged(ARTrackedImagesChangedEventArgs obj)
    {
        foreach (ARTrackedImage image in obj.added)
        {
            //contentRoot = new GameObject("ContentRoot");
            //contentRoot.transform.SetParent(image.transform, false);
            //katana = Instantiate(katanaPrefab, contentRoot.transform);
            katana = Instantiate(katanaPrefab, image.transform);
            InitializeContent(katana);
        }
        //if (!isInitialized && katana)
        //{
        //    InitializeContent(katana);
        //    isInitialized = true;
        //}
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

    private void InitializeContent(GameObject instance)
    {
        if (instance != null)
        {
            instance.transform.localScale = new Vector3(0.15f, 0.15f, 0.15f);
            instance.transform.localPosition += prefabOffset;
            instance.transform.localRotation = Quaternion.Euler(90, 0, 0);
        }
    }
}
