# ClipGrid

Native macOS-App auf Basis von SwiftUI, die mehrere Videos einliest und pro Video eine Videovorschau als `JPG` oder `PNG` exportiert.

![ClipGrid Screenshot](screen.png)

## Funktionen

- Mehrere Videos gleichzeitig laden
- Drag-and-Drop und Dateiauswahl fuer Videoimporte
- Videovorschauen mit konfigurierbarem Grid und Zeitstempeln pro Thumbnail
- Metadaten im Header der Videovorschau optional ein- und ausblendbar
- Konfigurierbares Grid mit Spalten, Zeilen, Thumbnail-Größe und Abstand
- Einstellbare Hintergrundfarbe
- Persistente Einstellungen ueber App-Neustarts hinweg
- Deutsche und englische Lokalisierung
- Export aller geladenen Videos in einem Durchlauf

## Voraussetzungen

- macOS 13 oder neuer
- Xcode Command Line Tools oder Xcode mit Swift 6

## Entwicklung

```bash
swift build
swift run
```

Alternativ kann `Package.swift` direkt in Xcode geöffnet werden.

## Projektstruktur

- `Sources/ClipGrid`: SwiftUI-App, ViewModels, Renderer und Services
- `Sources/ClipGrid/Resources`: lokalisierte `Localizable.strings`
- `Resources/Info.plist`: Bundle-Metadaten fuer die gepackte App
- `Scripts/package-app.sh`: erzeugt das native `.app`-Bundle
- `icon.png`: Quellbild fuer das App-Icon

## App-Bundle erzeugen

```bash
bash Scripts/package-app.sh
```

Danach liegt die native macOS-App als `dist/ClipGrid.app` vor.

## Hinweise

- Das App-Icon wird beim Packaging aus `icon.png` erzeugt.
- Die Exportbilder erhalten denselben Dateinamen wie das Video, nur mit der gewaehlten Bildendung.
