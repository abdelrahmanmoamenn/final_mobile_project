# Form — App Icon Package

## Palette
| Token     | Hex       |
|-----------|-----------|
| Primary   | #007AFF   |
| Surface   | #1C1C1E   |
| Elevated  | #2C2C2E   |
| Neutral   | #8E8E93   |

## Folder structure
```
form_icons/
├── ios/                  iOS App Store & home screen icons
│   ├── Icon-1024.png     App Store submission
│   ├── Icon-1024-light.png   Light bg variant
│   ├── Icon-1024-blue.png    Blue bg variant
│   └── Icon-{size}@{scale}.png  …all required sizes
├── android/
│   ├── mipmap-*/ic_launcher.png   Adaptive icon layers
│   ├── mipmap-xxxhdpi/ic_launcher_foreground.png
│   └── play_store_icon.png        512×512 Play Store
├── web/
│   ├── favicon-{16,32,48}.png
│   ├── icon-{192,512}.png          PWA
│   └── apple-touch-icon-180.png
└── ui_icons/
    ├── *.svg                       24×24 source vectors
    └── *@2x.png                    48×48 rasterized
```

## Flutter usage
Add to pubspec.yaml:
```yaml
flutter_icons:
  android: true
  ios: true
  image_path: "assets/icons/Icon-1024.png"
```
