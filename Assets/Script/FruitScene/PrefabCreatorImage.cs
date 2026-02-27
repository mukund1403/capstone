using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using TMPro;
using System.Runtime.CompilerServices;


public class PrefabCreatorImage : MonoBehaviour
{
    [SerializeField] private Vector3 prefabOffsetKatana;
    [SerializeField] private Vector3 prefabOffsetHand;
    //private GameObject contentRoot;
    //private bool isInitialized;

    private ARTrackedImageManager aRTrackedImageManager;

    [SerializeField] private GameObject katanaPrefab;
    [SerializeField] private GameObject handPrefab;
    [SerializeField] private TMP_Text text;
    private GameObject katana;
    private GameObject hand;

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
            if (image.referenceImage.name == "WaterDragon")
            {
                katana = Instantiate(katanaPrefab, image.transform);
                InitializeContent(katana);
            }
            if (image.referenceImage.name == "Hand")
            {
                hand = Instantiate(handPrefab, image.transform);
                InitializeContent(hand);
            }
        }
        //if (!isInitialized && katana)
        //{
        //    InitializeContent(katana);
        //    isInitialized = true;
        //}
        foreach (ARTrackedImage image in obj.updated)
        {
            if (hand == null)
            {
                SetMessage("Hand Status: not exist");
                return;
            }
            if (image.referenceImage.name == "WaterDragon")
            {
                if (image.trackingState == TrackingState.Tracking)
                {
                    katana.SetActive(true);
                }
                else
                {
                    //katana.SetActive(false);
                }
            }
            if (image.referenceImage.name == "Hand")
            {
                if (image.trackingState == TrackingState.Tracking)
                {
                    hand.SetActive(true);

                    string message = "Hand Status: tracking active\n" + hand.transform.position;
                    message += "\n";
                    message += image.transform.position;
                    SetMessage(message);
                }
                else
                {
                    //hand.SetActive(false);
                    SetMessage("Hand Status: tracking inactive");
                }
            }
        }
    }

    private void InitializeContent(GameObject instance)
    {
        if (instance == katana)
        {
            instance.transform.localScale = new Vector3(0.15f, 0.15f, 0.15f);
            instance.transform.localPosition += prefabOffsetKatana;
            instance.transform.localRotation = Quaternion.Euler(90, 0, 0);
        }
        else if (instance == hand)
        {
            instance.transform.localScale = new Vector3(0.3f, 0.3f, 0.3f);
            instance.transform.localPosition += prefabOffsetHand;
            instance.transform.localRotation = Quaternion.Euler(0, -90, 0);
        }
    }
}
