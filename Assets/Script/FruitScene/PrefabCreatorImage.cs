using System;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;


public class PrefabCreatorImage : MonoBehaviour
{
    [SerializeField] private GameObject lemonPrefab, pearPrefab, strawberryPrefab, applePrefab, watermelonPrefab, peachPrefab;
    [SerializeField] private Vector3 prefabOffset;

    private GameObject lemon, pear, strawberry, apple, watermelon, peach;
    private ARTrackedImageManager aRTrackedImageManager;

    [SerializeField] private GameObject katanaPrefab;
    private GameObject katana;

    private void OnEnable()
    {
        aRTrackedImageManager = gameObject.GetComponent<ARTrackedImageManager>();
        aRTrackedImageManager.trackedImagesChanged += OnImageChanged;
    }

    private void OnImageChanged(ARTrackedImagesChangedEventArgs obj)
    {
        foreach (ARTrackedImage image in obj.added)
        {
            //CreateFruit(lemon, image, lemonPrefab);
            //CreateFruit(pear, image, pearPrefab);
            //CreateFruit(strawberry, image, strawberryPrefab);
            //CreateFruit(apple, image, applePrefab);
            //CreateFruit(watermelon, image, watermelonPrefab);
            //CreateFruit(peach, image, peachPrefab);
            katana = Instantiate(katanaPrefab, image.transform);
            katana.SetActive(true);
        }
    }

    private void CreateFruit(GameObject fruit, ARTrackedImage image, GameObject fruitPrefab)
    {
        fruit = Instantiate(fruitPrefab, image.transform);
        fruit.SetActive(true);
        //fruit.SetActive(image.trackingState == TrackingState.Tracking);
        //fruit.transform.SetParent(image.transform, false);
    }
}
