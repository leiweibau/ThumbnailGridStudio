using System.Globalization;

namespace ThumbnailGridStudio.WinUI.Services;

public static class Localizer
{
    private static readonly Dictionary<string, string> De = new(StringComparer.Ordinal)
    {
        ["Main.CheckUpdates"] = "Auf Updates prüfen",
        ["Main.NoPreview"] = "Keine Vorschau",
        ["Update.Available.Title"] = "Update verfügbar",
        ["Update.Available.Content"] = "Neue Version: {0}\nInstalliert: {1}\n\nMöchtest du die Release-Seite öffnen?",
        ["Update.Available.Primary"] = "Release öffnen",
        ["Update.Available.Close"] = "Später",
        ["Update.None.Title"] = "Kein Update gefunden",
        ["Update.None.Content"] = "Installierte Version: {0}",
        ["Update.Error.Title"] = "Update-Prüfung fehlgeschlagen",
        ["Update.InvalidResponse"] = "Ungültige Antwort von GitHub.",
        ["Settings.Title"] = "Einstellungen",
        ["Settings.Columns"] = "Spalten",
        ["Settings.Rows"] = "Zeilen",
        ["Settings.ThumbWidth"] = "Thumbnail Breite",
        ["Settings.ThumbHeight"] = "Thumbnail Höhe",
        ["Settings.Spacing"] = "Abstand",
        ["Settings.BgHex"] = "Hintergrundfarbe (HEX-Code)",
        ["Settings.TextHex"] = "Schriftfarbe (HEX-Code)",
        ["Settings.ExportSeparate"] = "Separate Thumbnails exportieren",
        ["Settings.ShowTitle"] = "Titel anzeigen",
        ["Settings.ShowDuration"] = "Laufzeit anzeigen",
        ["Settings.ShowTimestamp"] = "Timestamp anzeigen",
        ["Settings.ShowFileSize"] = "Dateigröße anzeigen",
        ["Settings.ShowResolution"] = "Auflösung anzeigen",
        ["Settings.RenderConcurrency"] = "Parallelität",
        ["Settings.Layout"] = "Layout",
        ["Settings.ColorsExport"] = "Farben & Export",
        ["Settings.ExportFormat"] = "Exportformat",
        ["Settings.MetadataPreview"] = "Metadaten im Vorschaubild",
        ["Settings.Cancel"] = "Abbrechen",
        ["Settings.Apply"] = "Übernehmen",
        ["View.PreviewFallbackTitle"] = "Vorschau",
        ["View.Status.Waiting"] = "Wartet...",
        ["View.Status.Rendering"] = "Render läuft...",
        ["View.Status.Exported"] = "Exportiert: {0}",
        ["View.Status.Error"] = "Fehler: {0}",
        ["View.Error.ImportFailed"] = "Import fehlgeschlagen ({0}): {1}",
        ["View.Error.ExportFailed"] = "Export fehlgeschlagen ({0}): {1}",
        ["View.Error.UnsupportedExtensions"] = "Folgende Dateiendungen wurden wegen fehlender Unterstützung nicht importiert: {0}",
        ["View.Error.ExtensionCountItem"] = "{0}x {1}",
        ["View.Error.NoExtension"] = "(ohne Endung)"
    };

    private static readonly Dictionary<string, string> En = new(StringComparer.Ordinal)
    {
        ["Main.CheckUpdates"] = "Check for updates",
        ["Main.NoPreview"] = "No preview",
        ["Update.Available.Title"] = "Update available",
        ["Update.Available.Content"] = "New version: {0}\nInstalled: {1}\n\nDo you want to open the release page?",
        ["Update.Available.Primary"] = "Open release",
        ["Update.Available.Close"] = "Later",
        ["Update.None.Title"] = "No update found",
        ["Update.None.Content"] = "Installed version: {0}",
        ["Update.Error.Title"] = "Update check failed",
        ["Update.InvalidResponse"] = "Invalid response from GitHub.",
        ["Settings.Title"] = "Settings",
        ["Settings.Columns"] = "Columns",
        ["Settings.Rows"] = "Rows",
        ["Settings.ThumbWidth"] = "Thumbnail width",
        ["Settings.ThumbHeight"] = "Thumbnail height",
        ["Settings.Spacing"] = "Spacing",
        ["Settings.BgHex"] = "Background color (hex)",
        ["Settings.TextHex"] = "Text color (hex)",
        ["Settings.ExportSeparate"] = "Export separate thumbnails",
        ["Settings.ShowTitle"] = "Show title",
        ["Settings.ShowDuration"] = "Show duration",
        ["Settings.ShowTimestamp"] = "Show timestamp",
        ["Settings.ShowFileSize"] = "Show file size",
        ["Settings.ShowResolution"] = "Show resolution",
        ["Settings.RenderConcurrency"] = "Parallelism",
        ["Settings.Layout"] = "Layout",
        ["Settings.ColorsExport"] = "Colors & export",
        ["Settings.ExportFormat"] = "Export format",
        ["Settings.MetadataPreview"] = "Metadata in preview image",
        ["Settings.Cancel"] = "Cancel",
        ["Settings.Apply"] = "Apply",
        ["View.PreviewFallbackTitle"] = "Preview",
        ["View.Status.Waiting"] = "Waiting...",
        ["View.Status.Rendering"] = "Rendering...",
        ["View.Status.Exported"] = "Exported: {0}",
        ["View.Status.Error"] = "Error: {0}",
        ["View.Error.ImportFailed"] = "Import failed ({0}): {1}",
        ["View.Error.ExportFailed"] = "Export failed ({0}): {1}",
        ["View.Error.UnsupportedExtensions"] = "The following file extensions were not imported due to missing support: {0}",
        ["View.Error.ExtensionCountItem"] = "{0}x {1}",
        ["View.Error.NoExtension"] = "(no extension)"
    };

    private static readonly Dictionary<string, string> Es = new(En, StringComparer.Ordinal)
    {
        ["Settings.Title"] = "Configuracion",
        ["Main.CheckUpdates"] = "Buscar actualizaciones"
    };

    private static readonly Dictionary<string, string> Fr = new(En, StringComparer.Ordinal)
    {
        ["Settings.Title"] = "Parametres",
        ["Main.CheckUpdates"] = "Verifier les mises a jour"
    };

    private static readonly Dictionary<string, string> Pt = new(En, StringComparer.Ordinal)
    {
        ["Settings.Title"] = "Configuracoes",
        ["Main.CheckUpdates"] = "Verificar atualizacoes"
    };

    private static readonly Dictionary<string, string> Ru = new(En, StringComparer.Ordinal)
    {
        ["Settings.Title"] = "Nastroiki",
        ["Main.CheckUpdates"] = "Proverit obnovleniya"
    };

    private static readonly Dictionary<string, string> Tr = new(En, StringComparer.Ordinal)
    {
        ["Settings.Title"] = "Ayarlar",
        ["Main.CheckUpdates"] = "Guncellemeleri denetle"
    };

    private static readonly Dictionary<string, string> Ar = new(En, StringComparer.Ordinal)
    {
        ["Settings.Title"] = "Settings",
        ["Main.CheckUpdates"] = "Check for updates"
    };

    private static readonly Dictionary<string, string> Bn = new(En, StringComparer.Ordinal)
    {
        ["Settings.Title"] = "Settings",
        ["Main.CheckUpdates"] = "Check for updates"
    };

    private static readonly Dictionary<string, string> Hi = new(En, StringComparer.Ordinal)
    {
        ["Settings.Title"] = "Settings",
        ["Main.CheckUpdates"] = "Check for updates"
    };

    private static readonly Dictionary<string, string> Ja = new(En, StringComparer.Ordinal)
    {
        ["Settings.Title"] = "Settings",
        ["Main.CheckUpdates"] = "Check for updates"
    };

    private static readonly Dictionary<string, string> Ko = new(En, StringComparer.Ordinal)
    {
        ["Settings.Title"] = "Settings",
        ["Main.CheckUpdates"] = "Check for updates"
    };

    private static readonly Dictionary<string, string> ZhHans = new(En, StringComparer.Ordinal)
    {
        ["Settings.Title"] = "Settings",
        ["Main.CheckUpdates"] = "Check for updates"
    };

    private static readonly Dictionary<string, Dictionary<string, string>> ByLanguage = new(StringComparer.OrdinalIgnoreCase)
    {
        ["de"] = De,
        ["en"] = En,
        ["es"] = Es,
        ["fr"] = Fr,
        ["pt"] = Pt,
        ["ru"] = Ru,
        ["tr"] = Tr,
        ["ar"] = Ar,
        ["bn"] = Bn,
        ["hi"] = Hi,
        ["ja"] = Ja,
        ["ko"] = Ko,
        ["zh"] = ZhHans
    };

    public static string Get(string key, string fallback)
    {
        var map = ResolveMap(CultureInfo.CurrentUICulture);
        if (map.TryGetValue(key, out var value))
        {
            return value;
        }

        if (En.TryGetValue(key, out var english))
        {
            return english;
        }

        return fallback;
    }

    private static Dictionary<string, string> ResolveMap(CultureInfo culture)
    {
        if (string.Equals(culture.Name, "zh-Hans", StringComparison.OrdinalIgnoreCase))
        {
            return ZhHans;
        }

        if (ByLanguage.TryGetValue(culture.TwoLetterISOLanguageName, out var map))
        {
            return map;
        }

        return En;
    }
}
