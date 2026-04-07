using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using TMPro;
using System.Runtime.CompilerServices;
using System.Collections.Generic;

// Manage creating AR prefabs using ARTrackedImageManager
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
    private bool atkBombSpawned;
    private ARTrackedImage currentBombImage;

    private void Awake()
    {
        aRTrackedImageManager = gameObject.GetComponent<ARTrackedImageManager>();
        listToSpawn = new GameObject[]
        {
            bombPrefab
        };
        atkBombSpawned = false;
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

    public void RemovePrefabs()
    {
        // Destroy existing spawned objects
        if (katana != null)
        {
            Destroy(katana);
            katana = null;
        }
        if (hand != null)
        {
            Destroy(hand);
            hand = null;
        }
    }

    private void SetMessage(string message)
    {
        text.text = message;
    }

    public void SpawnBombByButton()
    {
        if (currentBombImage.referenceImage.name == "NUSLogo" && currentBombImage.trackingState == TrackingState.Tracking)
        {
            SpawnAroundImage(currentBombImage);
        }
    }

    // spawn multiple prefabs randomly in an area centred around the tracked image's location
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

            // ensure enough distance between new and existing prefabs
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
        atkBombSpawned = true;
    }

    private void SpawnForImage(ARTrackedImage image, string identity)
    {
        // create katana for defender role
        if (image.referenceImage.name == "WaterDragon" && identity == "Defender")
        {
            katana = Instantiate(katanaPrefab, image.transform);
            InitializeContent(katana);
        }
        if (image.referenceImage.name == "Hand" && (identity == "Defender" || identity == "Attacker"))
        {
            hand = Instantiate(handPrefab, image.transform);
            InitializeContent(hand);
            if (identity == "Attacker")
            {
                hand.tag = "Attacker AR Spawn";
            }
            else if (identity == "Defender")
            {
                hand.tag = "Defender AR Spawn";
            }
        }
        if (image.referenceImage.name == "NUSLogo" && identity == "Attacker")
        {
            currentBombImage = image;
            if (!atkBombSpawned)
            {
                SpawnAroundImage(image);
            }
        }
    }

    private void OnImageChanged(ARTrackedImagesChangedEventArgs obj)
    {
        string playerIdentity = PlayerStatusManager.Instance.GetIdentity();
        foreach (ARTrackedImage image in obj.added)
        {
            //// create katana for defender role
            //if (image.referenceImage.name == "WaterDragon" && playerIdentity == "Defender")
            //{
            //    katana = Instantiate(katanaPrefab, image.transform);
            //    InitializeContent(katana);
            //}
            //if (image.referenceImage.name == "Hand")
            //{
            //    hand = Instantiate(handPrefab, image.transform);
            //    InitializeContent(hand);
            //    if (playerIdentity == "Attacker")
            //    {
            //        hand.tag = "Attacker AR Spawn";
            //    }
            //    else if (playerIdentity == "Defender")
            //    {
            //        hand.tag = "Defender AR Spawn";
            //    }
            //}
            //if (image.referenceImage.name == "NUSLogo" && playerIdentity == "Attacker")
            //{
            //    SpawnAroundImage(image);
            //}
            SpawnForImage(image, playerIdentity);
        }
        foreach (ARTrackedImage image in obj.updated)
        {
            if (image.referenceImage.name == "WaterDragon" && katana == null)
            {
                SpawnForImage(image, playerIdentity);
            }
            if (image.referenceImage.name == "Hand" && hand == null)
            {
                SpawnForImage(image, playerIdentity);
            }
            if (image.referenceImage.name == "NUSLogo")
            {
                SpawnForImage(image, playerIdentity);
            }
            if (image.referenceImage.name == "WaterDragon" && katana != null)
            {
                if (image.trackingState == TrackingState.Tracking)
                {
                    katana.SetActive(true);
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
                }
            }
        }
    }

    // Set local orientation data
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
            instance.transform.localRotation = Quaternion.Euler(0, -90, -90);
        }
    }
}
