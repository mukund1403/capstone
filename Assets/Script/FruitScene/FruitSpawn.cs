using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using TMPro;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

public class FruitSpawn : MonoBehaviour
{
    private float lowestYPoint = -5;

    [SerializeField] private float spawnRate;
    [SerializeField] private GameObject origin;
    private ARTrackedImageManager aRTrackedImageManager;

    private float timer;

    private bool isActive;
    private bool isFrozen;
    private bool isImageScanned;
    private Vector3 storedImagePos;

    [SerializeField] private GameObject lemonPrefab, pearPrefab, strawberryPrefab, applePrefab, watermelonPrefab, peachPrefab;
    [SerializeField] private GameObject bombPrefab;
    private GameObject[] fruits;
    private ARTrackedImage currentImage;


    private enum Direction
    {
        Left,
        Right,
        Up,
        Down
    }

    void Awake()
    {
        aRTrackedImageManager = origin.GetComponent<ARTrackedImageManager>();
        isActive = false;
        isImageScanned = false;
        timer = 0;
        fruits = new GameObject[]
        {
            lemonPrefab, 
            pearPrefab, 
            strawberryPrefab, 
            applePrefab, 
            watermelonPrefab, 
            peachPrefab
        };
        isFrozen = false;
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

    private void OnImageChanged(ARTrackedImagesChangedEventArgs obj)
    {
        foreach (ARTrackedImage image in obj.added)
        {
            if (image.referenceImage.name == "NUSLogo")
            {
                currentImage = image;
            }
        }
        foreach (ARTrackedImage image in obj.updated)
        {
            if (image.referenceImage.name == "NUSLogo")
            {
                currentImage = image;
            }
        }
    }

    private void SetMessage(string message)
    {
        TMP_Text text = GameObject.Find("ScanText").GetComponent<TMP_Text>();
        text.text = message;
    }

    public void SetSpawnOnClick()
    {
        if (isActive)
        {
            isActive = false;
        }
        else if (isImageScanned)
        {
            isActive = true;
        }
        else
        {
            SetMessage("No scanned location.");
        }
    }

    public void SetImageOnClick()
    {
        if (PlayerStatusManager.Instance.GetIdentity() != "Defender")
        {
            SetMessage("Scan disabled for your role.");
            return;
        }
        if (currentImage.referenceImage.name == "NUSLogo" && currentImage.trackingState == TrackingState.Tracking)
        {
            isImageScanned = true;
            storedImagePos = currentImage.transform.position;
            string message = "Image Scanned. \n" + storedImagePos.ToString();
            SetMessage(message);
        } 
        else
        {
            string message = "No Image Found. \n" + storedImagePos.ToString();
            SetMessage(message);
        }
    }

    public void SetFrozen(bool value)
    {
        isFrozen = value;
    }

    // Update is called once per frame
    void Update()
    {
        if (isFrozen)
        {
            return;
        }
        if (isActive)
        {
            if (timer < spawnRate)
            {
                timer += Time.deltaTime;
            }
            else
            {
                ThrowFromBottom();
                timer = 0;
            }
        }
    }

    private void applyPhysics(GameObject item, float force, Direction dir)
    {
        Rigidbody rb = item.GetComponent<Rigidbody>();
        rb.useGravity = true;
        float spinForce = 5;
        float gravityScale = 1f;
        switch (dir)
        {
            case Direction.Left:
                rb.AddForce(Vector3.left * force, ForceMode.Impulse);
                rb.AddTorque(Random.insideUnitSphere * spinForce, ForceMode.Impulse);
                break;
            case Direction.Right:
                rb.AddForce(Vector3.right * force, ForceMode.Impulse);
                rb.AddTorque(Random.insideUnitSphere * spinForce, ForceMode.Impulse);
                break;
            case Direction.Up:
                rb.AddForce(Vector3.up * force, ForceMode.Impulse);
                rb.AddTorque(Random.insideUnitSphere * spinForce, ForceMode.Impulse);
                break;
        }
    }

    private void ThrowFromBottom()
    {
        float force = 3;
        GameObject fruitChosen = fruits[Random.Range(0, fruits.Length)];
        bool isBomb = Random.value < 0.1f;
        //Vector3 offset = new Vector3(Random.Range(-0.1f, 0.1f), 0, Random.Range(-0.1f, 0.1f));
        Vector3 offset = new Vector3(0, 0, 0);
        Vector3 spawnPos = storedImagePos + offset;

        if (fruitChosen != null && !isBomb)
        {
            GameObject spawnedFruit = Instantiate(fruitChosen, spawnPos, Quaternion.identity);
            spawnedFruit.transform.SetParent(null);
            spawnedFruit.transform.localScale *= 0.067f;
            spawnedFruit.SetActive(true);
            applyPhysics(spawnedFruit, force, Direction.Up);
        }
        else if (isBomb)
        {
            GameObject bomb = Instantiate(bombPrefab, spawnPos, Quaternion.identity);
            bomb.transform.SetParent(null);
            bomb.transform.localScale *= 0.067f;
            bomb.SetActive(true);
            applyPhysics(bomb, force, Direction.Up);
        }
    }
}
