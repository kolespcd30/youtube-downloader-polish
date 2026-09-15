# Copyright (c) 2026 koles_pcd
# SPDX-License-Identifier: MIT
# Licencja MIT - pelny tekst w pliku LICENSE.
param([switch]$LibraryOnly, [switch]$SetupOnly)
$ErrorActionPreference = 'Stop'

function Test-YouTubeUrl([string]$Text) {
    $parsed = $null
    if (-not [Uri]::TryCreate($Text, [UriKind]::Absolute, [ref]$parsed)) { return $false }
    return ($parsed.Scheme -in @('https', 'http') -and
        $parsed.Host -in @('youtube.com', 'www.youtube.com', 'm.youtube.com', 'music.youtube.com', 'youtu.be') -and
        -not $parsed.UserInfo)
}

function Get-PlaylistInfo([string]$Url) {
    $uri = [Uri]$Url
    $query = @{}
    foreach ($part in $uri.Query.TrimStart('?').Split('&')) {
        $pair = $part.Split('=', 2)
        if ($pair.Count -eq 2) { $query[[Uri]::UnescapeDataString($pair[0])] = [Uri]::UnescapeDataString($pair[1]) }
    }
    $hasVideo = ($uri.Host -eq 'youtu.be' -and $uri.AbsolutePath.Trim('/')) -or
        ($uri.AbsolutePath -eq '/watch' -and $query['v']) -or
        ($uri.AbsolutePath -match '^/(shorts|live|embed)/[^/]+')
    return @{ IsPlaylist = [bool]$query['list']; HasVideo = [bool]$hasVideo }
}

function Update-ProcessPath {
    $paths = @([Environment]::GetEnvironmentVariable('Path', 'Machine'),
        [Environment]::GetEnvironmentVariable('Path', 'User'), $env:Path)
    $env:Path = (($paths -join ';').Split(';') | Where-Object { $_ } | Select-Object -Unique) -join ';'
}

function Test-Tools([string[]]$Names) {
    foreach ($name in $Names) {
        if (-not (Get-Command $name -CommandType Application -ErrorAction SilentlyContinue)) { return $false }
    }
    return $true
}

function Invoke-PackageManager([string[]]$PackageArgs) {
    & winget @PackageArgs | Out-Host
    return $LASTEXITCODE
}

function Initialize-Tools {
    Update-ProcessPath
    $packages = @(
        @{ Id = 'yt-dlp.yt-dlp'; Names = @('yt-dlp') },
        @{ Id = 'Gyan.FFmpeg'; Names = @('ffmpeg', 'ffprobe') },
        @{ Id = 'DenoLand.Deno'; Names = @('deno') }
    )
    $allNames = @('yt-dlp', 'ffmpeg', 'ffprobe', 'deno')
    if (-not (Test-Tools @('winget'))) {
        Write-Host 'Brak winget: zainstaluj lub zaktualizuj Microsoft App Installer w Microsoft Store.' -ForegroundColor Yellow
        Write-Host 'Nie mozna automatycznie instalowac narzedzi ani sprawdzac aktualizacji.' -ForegroundColor Yellow
        return (Test-Tools $allNames)
    }
    foreach ($package in $packages) {
        $action = if (Test-Tools $package.Names) { 'upgrade' } else { 'install' }
        Write-Host "`n[$($package.Id)] Sprawdzanie aktualizacji / instalacja brakujacych narzedzi..." -ForegroundColor Cyan
        try {
            $code = Invoke-PackageManager @($action, '--id', $package.Id, '--exact', '--source', 'winget',
                '--accept-source-agreements', '--accept-package-agreements', '--disable-interactivity')
            if ($code -ne 0 -and $code -ne -1978335189) {
                Write-Host "Operacja winget zwrocila kod $code. Szczegoly powyzej; dostepne narzedzia nadal moga byc uzywane." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "Nie udalo sie sprawdzic / zainstalowac narzedzia: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        Update-ProcessPath
    }
    if (-not (Test-Tools $allNames)) {
        Write-Host 'Brakuje wymaganych narzedzi. Sprawdz bledy instalacji powyzej i uruchom START.bat ponownie.' -ForegroundColor Red
        return $false
    }
    Write-Host "`nWymagane narzedzia sa dostepne." -ForegroundColor Green
    return $true
}

function Get-DownloadArguments([string]$Mode, [string]$Quality, [string]$Url, [string]$Folder, [bool]$Playlist = $false) {
    $template = if ($Playlist) { '%(playlist_title).80s [%(playlist_id)s]/%(playlist_index)03d - %(title)s [%(id)s].%(ext)s' } else { '%(title)s [%(id)s].%(ext)s' }
    $result = @('--ignore-config', '--no-overwrites', '--windows-filenames',
        '--trim-filenames', '160', '--progress', '--no-mtime', '--retries', '5',
        '--fragment-retries', '5', '--socket-timeout', '30', '--no-colors',
        '-P', $Folder, '-o', $template)
    if ($Playlist) { $result += @('--yes-playlist', '--no-abort-on-error') }
    else { $result += '--no-playlist' }
    if ($Mode -eq 'mp3') {
        $result += @('-f', 'bestaudio/best', '-x', '--audio-format', 'mp3', '--audio-quality', $Quality)
    } elseif ($Mode -eq 'mp4') {
        $limit = if ($Quality -eq 'best') { '' } else { "[height<=$Quality]" }
        $result += @('-f', "bv$limit[ext=mp4]+ba[ext=m4a]/b$limit[ext=mp4]/bv$limit+ba/b$limit",
            '--merge-output-format', 'mp4', '--recode-video', 'mp4')
    } else { throw 'Nieznany format.' }
    $result += @('--', $Url)
    return $result
}

function Read-Choice([string]$Label, [string[]]$Choices, [string]$Default) {
    while ($true) {
        $value = (Read-Host $Label).Trim().ToLowerInvariant()
        if (-not $value) { $value = $Default }
        if ($value -in $Choices) { return $value }
        Write-Host ('Wpisz: ' + ($Choices -join ', ')) -ForegroundColor Yellow
    }
}

function Start-Downloader {
    $Host.UI.RawUI.WindowTitle = 'YouTube Downloader | MP3 + MP4'
    if (-not (Initialize-Tools)) { return }
    $root = Join-Path $PSScriptRoot 'Pobrane'
    while ($true) {
        Write-Host ''
        Write-Host '  +--------------------------------------------------+' -ForegroundColor Yellow
        Write-Host '  |           Y O U T U B E   D O W N L O A D E R     |' -ForegroundColor Yellow
        Write-Host '  |           MP3 / MP4  -  Twoje pliki lokalnie      |' -ForegroundColor Yellow
        Write-Host '  +--------------------------------------------------+' -ForegroundColor Yellow
        Write-Host '    mp3  Muzyka       mp4  Film       q  Wyjscie'
        Write-Host "    Folder: $root" -ForegroundColor DarkGray
        Write-Host '    Ctrl+C zatrzymuje program. Pliki .part pozwalaja wznowic pobieranie.' -ForegroundColor DarkGray
        Write-Host ''
        $mode = Read-Choice 'Format [mp3/mp4/q]' @('mp3', 'mp4', 'q') 'mp4'
        if ($mode -eq 'q') { return }
        $url = (Read-Host 'Wklej link YouTube (Enter = powrot)').Trim()
        if (-not $url) { continue }
        if (-not (Test-YouTubeUrl $url)) {
            Write-Host 'Niepoprawny link. Wklej pelny adres https://www.youtube.com/... lub https://youtu.be/...' -ForegroundColor Yellow
            continue
        }
        $playlist = $false
        $playlistInfo = Get-PlaylistInfo $url
        if ($playlistInfo.IsPlaylist) {
            if ($playlistInfo.HasVideo) {
                $selection = Read-Choice 'Link zawiera playliste: cala / film / anuluj [Enter = film]' @('cala', 'film', 'anuluj') 'film'
            } else {
                $selection = Read-Choice 'Pobrac cala playliste? tak / nie [Enter = nie]' @('tak', 'nie') 'nie'
            }
            if ($selection -in @('anuluj', 'nie')) { continue }
            $playlist = $selection -in @('cala', 'tak')
            if (-not $playlist) {
                $clean = [UriBuilder]$url
                $clean.Query = (($clean.Query.TrimStart('?').Split('&') | Where-Object { [Uri]::UnescapeDataString(($_ -split '=', 2)[0]) -notin @('list', 'index', 'start_radio') }) -join '&')
                $url = $clean.Uri.AbsoluteUri
            }
        } elseif (-not $playlistInfo.HasVideo) {
            Write-Host 'Wklej link do konkretnego filmu lub playlisty (z parametrem list=).' -ForegroundColor Yellow
            continue
        }
        if ($mode -eq 'mp3') {
            $quality = Read-Choice 'Jakosc MP3: 128 / 192 / 320 kb/s [Enter = 192]' @('128', '192', '320') '192'
            $quality += 'K'
        } else {
            $quality = Read-Choice 'Maks. rozdzielczosc: 480 / 720 / 1080 / 1440 / 2160 / best [Enter = 1080]' @('480', '720', '1080', '1440', '2160', 'best') '1080'
        }
        try {
            $folder = Join-Path $root $mode.ToUpperInvariant()
            New-Item -ItemType Directory -Force -Path $folder | Out-Null
            $downloadArgs = Get-DownloadArguments $mode $quality $url $folder $playlist
            Write-Host "`n[1/3] Odczytuje film i dostepne formaty..." -ForegroundColor Cyan
            Write-Host '[2/3] Pobieranie: procent / rozmiar / predkosc / ETA (pozostaly czas).' -ForegroundColor Cyan
            Write-Host '[3/3] Po pobraniu: laczenie lub konwersja. Zaczekaj na komunikat GOTOWE.' -ForegroundColor Cyan
            & yt-dlp @downloadArgs
            if ($LASTEXITCODE -ne 0) { throw "Nie wszystkie pliki zostaly pobrane poprawnie (kod $LASTEXITCODE). Zapisane pliki pozostaja w folderze. Szczegoly sa powyzej." }
            Write-Host "`nGOTOWE! Pliki sa w: $folder" -ForegroundColor Green
        } catch {
            Write-Host "`nBLAD: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host 'Sprawdz link i internet. W razie problemow uruchom ponownie INSTALUJ.bat, aby zaktualizowac narzedzia.' -ForegroundColor Yellow
        }
    }
}

if (-not $LibraryOnly) {
    if ($SetupOnly) { $ready = Initialize-Tools; if (-not $ready) { exit 1 } }
    else { Start-Downloader }
}
