using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using TMPro;
using System.Runtime.CompilerServices;
using System.Collections.Generic;


public class PrefabCreatorImage : MonoBehaviour
{
    private Vector3 prefabOffsetKatana = new Vector3(0, 0, 0);
    private Vector3 prefabOffsetHand = new Vector3(0, 0, 0);

    private ARTrackedImageManager aRTrackedImageManager;

    [SerializeField] private GameObject katanaPrefab;
    [SerializeField] private GameObject handPrefab;
    [SerializeField] private TMP_Text text;
    private GameObject katana;
    private GameObject hand;

    [SerializeField] private GameObject bombPrefab;
    private GameObject[] listToSpawn;
    private const int maxNumber = 5;
    private GameObject[] itemsToPick = new GameObject[maxNumber];

    private void Awake()
    {
        aRTrackedImageManager = gameObject.GetComponent<ARTrackedImageManager>();
        listToSpawn = new GameObject[]
        {
            bombPrefab
        };
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

    private void SpawnAroundImage(ARTrackedImage image)
    {
        List<Vector2> usedPositions = new List<Vector2>();
        float spawnRadius = 0.1f;
        int count = 0;
        bool isValidPosition = false;
        float minDistance = 0.05f;

        while (count < maxNumber)
        {
            GameObject itemChosen = listToSpawn[UnityEngine.Random.Range(0, listToSpawn.Length)];
            Vector2 spawnArea = UnityEngine.Random.insideUnitCircle * spawnRadius;
            isValidPosition = true;

            foreach (var position in usedPositions)
            {
                if (Vector2.Distance(spawnArea, position) <= minDistance)
                {
                    isValidPosition = false;
                    break;
                }
            }

            if (isValidPosition)
            {
                usedPositions.Add(spawnArea);
                Vector3 spawnPosition = new Vector3(spawnArea.x, 0, spawnArea.y);
                GameObject spawnedItem = Instantiate(itemChosen, image.transform);
                spawnedItem.transform.localPosition = spawnPosition;
                spawnedItem.transform.localScale = new Vector3(0.05f, 0.05f, 0.05f);
                spawnedItem.SetActive(true);
                count++;
            }
        }
        usedPositions.Clear();
    }

    private void OnImageChanged(ARTrackedImagesChangedEventArgs obj)
    {
        string playerIdentity = PlayerStatusManager.Instance.GetIdentity();
        foreach (ARTrackedImage image in obj.added)
        {
            if (image.referenceImage.name == "WaterDragon" && playerIdentity == "Defender")
            {
                katana = Instantiate(katanaPrefab, image.transform);
                InitializeContent(katana);
            }
            if (image.referenceImage.name == "Hand")
            {
                hand = Instantiate(handPrefab, image.transform);
                InitializeContent(hand);
            }
            if (image.referenceImage.name == "NUSLogo" && playerIdentity == "Attacker")
            {
                SpawnAroundImage(image);
            }
        }
        foreach (ARTrackedImage image in obj.updated)
        {
            if (hand == null)
            {
                //SetMessage("Hand Status: not exist");
                return;
            }
            if (image.referenceImage.name == "WaterDragon" && katana != null)
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
            if (image.referenceImage.name == "Hand" && hand != null)
            {
                if (image.trackingState == TrackingState.Tracking)
                {
                    hand.SetActive(true);

                    string message = "Hand Status: tracking active\n" + hand.transform.position;
                    message += "\n";
                    message += image.transform.position;
                    //SetMessage(message);
                }
                else
                {
                    //hand.SetActive(false);
                    //SetMessage("Hand Status: tracking inactive");
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
