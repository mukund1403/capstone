# FruitARProject

FruitARProject is a Unity-based augmented reality game prototype for mobile devices. It combines AR Foundation image tracking, role-based attacker/defender gameplay, and optional external MQTT/IMU integration for gesture and feedback interactions.

## What this project does

- Provides an AR gameplay experience with two player roles: **Attacker** and **Defender**
- Uses AR tracked images to place interactable fruit, bombs, and hand avatars in real-world space
- Includes a tutorial flow, role selection, and main gameplay scene
- Demonstrates MQTT support for external device feedback, buzzer control, and gesture messaging

## Why this project is useful

- Shows how to build a mobile AR game with **Unity 2022.3 LTS** and **AR Foundation**
- Includes both **gameplay logic** and **hardware integration** for rapid prototyping
- Uses image tracking with reference images such as `NUSLogo` and `BombOmbThrower`
- Supports Android development via **ARCore** and **OpenXR** packages

## Key features

- Role selection flow in `Assets/Scenes/FruitStartScene.unity`
- Main AR game in `Assets/Scenes/FruitScene.unity`
- Guided tutorial in `Assets/Scenes/FruitTutorialScene.unity`
- Fruit spawning, bomb throwing, and hand action logic
- MQTT and IMU-style event messaging via `Assets/Mqtt/MqttApi.cs`
- Configurable god mode

## Getting started

### Requirements

- Unity Editor **2022.3.62f3** or compatible 2022.3 LTS version
- Android support installed in Unity Hub
- AR packages restored automatically from `Packages/manifest.json`

### Install and open

1. Open Unity Hub.
2. Add the project from the repository root folder.
3. Open the project in Unity.
4. Open the start scene: `Assets/Scenes/FruitStartScene.unity`.

### Run in the Editor

1. Select `Assets/Scenes/FruitStartScene.unity`.
2. Press Play.
3. Use the on-screen role selection menus to choose **Attacker** or **Defender**.

### Build for Android

1. Switch the project platform to **Android** in Build Settings.
2. Ensure **ARCore** and **OpenXR** support are enabled.
3. Build and deploy to a supported AR-capable Android device.

### Usage example

After selecting a role, the game uses MQTT for external feedback. For example, to trigger a success buzzer from code:

```csharp
using UnityEngine;

public class ExampleUsage : MonoBehaviour
{
    void OnFruitCut()
    {
        MqttApi.BuzzSuccess();  // Sends buzzer control via MQTT
    }
}
```

See `Assets/Mqtt/MqttApi.cs` for more API methods like `BuzzSuccess()` or `BuzzFailure()`.

## Project structure

- `Assets/Scenes/` — main scene assets and gameplay scenes
- `Assets/Script/` — game logic, scene controllers, tutorial and AR interaction scripts
- `Assets/Mqtt/` — MQTT bridge and message publishing helpers
- `Packages/manifest.json` — project package dependencies
- `ProjectSettings/ProjectVersion.txt` — targeted Unity version

## Package highlights

- `com.unity.xr.arfoundation` 5.2.0
- `com.unity.xr.arcore` 5.2.0
- `com.unity.xr.openxr` 1.14.3
- `com.unity.xr.meta-openxr` 1.0.4
- `com.unity.textmeshpro` 3.0.7

## Where to get help

- Open an issue or pull request in the repository
- Use Unity documentation for AR Foundation, ARCore, and OpenXR
- Inspect scene-specific scripts in `Assets/Script/` for behavior details

## Contributing

Contributions are welcome. If you want to improve the project:

1. Fork the repository.
2. Create a branch for your feature or fix.
3. Submit a pull request with a short description.

> Note: This repository does not currently include a dedicated `CONTRIBUTING.md` file.

