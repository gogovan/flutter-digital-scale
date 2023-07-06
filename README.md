# flutter_digital_scale

Integrate Digital scales with Flutter apps.

# Supported Digital scales
- Wuxianliang WXL-T12

## Getting Started

1. Update your app `android/app/build.gradle` and update minSdkVersion to at least 21
```groovy
defaultConfig {
    applicationId "com.example.app"
    minSdkVersion 21
    // ...
}
```
2. Setup required permissions according to OS and technology:

## Bluetooth
### Android

1. Add the following to your main `AndroidManifest.xml`.
   See [Android Developers](https://developer.android.com/guide/topics/connectivity/bluetooth/permissions)
   and [this StackOverflow answer](https://stackoverflow.com/a/70793272)
   for more information about permission settings.

```xml

<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.example.flutter_label_printer_example">

    <uses-feature android:name="android.hardware.bluetooth" android:required="true" />

    <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN"
        android:usesPermissionFlags="neverForLocation" tools:targetApi="s" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"
        android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"
        android:maxSdkVersion="30" />
    <!-- ... -->
</manifest>
```

### iOS

1. Include usage description keys for Bluetooth into `info.plist`.
   ![iOS XCode Bluetooth permission instruction](README_img/ios-bluetooth-perm.png)

## Usage
1. Choose an implementation that matches your digital scale device, and create an instance of it. i.e. `WXLT12()`
2. Connect to the digital scale. This will search for the scale nearby your scale and connect to it. Once connected the callback will be invoked.
```dart
scale.connect(const Duration(seconds: 30), () {
   // do something
});
```
3. To get the weight readings from your digital scale, use one of the following:
   1. `getWeightStream()` returns a dart Stream which continuously receive data from your scale. Oftentimes this is the real time output of the scale. Check with your manufacturer if this feature is supported and the exact behaviour.
   2. `getWeight()` returns the weight value as measured at the moment of its call. However you may want to use `getStabilizedWeight` instead.
   3. `getStabilizedWeight()` returns a weight that has been stabilized. In practice, when you use the scale by placing an object on it, the weight value will oscillate erratically before stabilizing due to the extra weight added by the action of placing the object. This function returns the weight of the object only when the weight reading has stopped moving. You can specify number of samples to wait until it is considered stabilized.
4. Disconnect your scale when you are done with it using `disconnect()`. Otherwise there may be lingering connections.
