using System.Runtime.InteropServices;
using System.Collections.Generic;

namespace ThumbnailGridStudio.WinUI.Services;

public sealed record FfmpegTools(string FfmpegPath, string FfprobePath);

public static class FfmpegService
{
    public static FfmpegTools ResolveTools()
    {
        var ffmpeg = ResolveTool("THUMBNAIL_GRID_STUDIO_FFMPEG", "ffmpeg.exe");
        var ffprobe = ResolveTool("THUMBNAIL_GRID_STUDIO_FFPROBE", "ffprobe.exe");
        return new FfmpegTools(ffmpeg, ffprobe);
    }

    private static string ResolveTool(string envVar, string executableName)
    {
        var explicitPath = Environment.GetEnvironmentVariable(envVar);
        if (!string.IsNullOrWhiteSpace(explicitPath) && File.Exists(explicitPath))
        {
            return explicitPath;
        }

        foreach (var bundled in GetBundledPaths(executableName))
        {
            if (File.Exists(bundled))
            {
                return bundled;
            }
        }

        var fromPath = ResolveFromPath(executableName);
        if (fromPath is not null)
        {
            return fromPath;
        }

        throw new FileNotFoundException(
            $"{executableName} wurde nicht gefunden. Lege {executableName} unter " +
            $"`Tools\\{CurrentArchFolder()}\\` ab oder setze {envVar}.");
    }

    private static IEnumerable<string> GetBundledPaths(string executableName)
    {
        var archFolder = CurrentArchFolder();
        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        foreach (var root in EnumerateCandidateRoots())
        {
            var candidate = Path.GetFullPath(Path.Combine(root, "Tools", archFolder, executableName));
            if (seen.Add(candidate))
            {
                yield return candidate;
            }
        }
    }

    private static IEnumerable<string> EnumerateCandidateRoots()
    {
        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        foreach (var path in ExpandWithParents(AppContext.BaseDirectory))
        {
            if (seen.Add(path))
            {
                yield return path;
            }
        }

        foreach (var path in ExpandWithParents(Path.GetDirectoryName(Environment.ProcessPath)))
        {
            if (seen.Add(path))
            {
                yield return path;
            }
        }

        foreach (var path in ExpandWithParents(Environment.CurrentDirectory))
        {
            if (seen.Add(path))
            {
                yield return path;
            }
        }
    }

    private static IEnumerable<string> ExpandWithParents(string? path)
    {
        if (string.IsNullOrWhiteSpace(path))
        {
            yield break;
        }

        var current = Path.GetFullPath(path);
        for (var depth = 0; depth < 6; depth++)
        {
            if (string.IsNullOrWhiteSpace(current))
            {
                yield break;
            }

            yield return current;

            var parent = Directory.GetParent(current)?.FullName;
            if (string.IsNullOrWhiteSpace(parent) || string.Equals(parent, current, StringComparison.OrdinalIgnoreCase))
            {
                yield break;
            }

            current = parent;
        }
    }

    private static string CurrentArchFolder()
    {
        return RuntimeInformation.ProcessArchitecture switch
        {
            Architecture.Arm64 => "win-arm64",
            _ => "win-x64"
        };
    }

    private static string? ResolveFromPath(string executableName)
    {
        var rawPath = Environment.GetEnvironmentVariable("PATH");
        if (string.IsNullOrWhiteSpace(rawPath))
        {
            return null;
        }

        foreach (var pathEntry in rawPath.Split(';', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
        {
            var candidate = Path.Combine(pathEntry, executableName);
            if (File.Exists(candidate))
            {
                return candidate;
            }
        }

        return null;
    }
}
