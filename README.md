# YouTube Downloader — Windows

## Autor i licencja

Autor: **koles_pcd**. Copyright (c) 2026 koles_pcd.

Skrypty tego projektu i dokumentacja sa udostepnione na licencji **MIT**.
Mozna bezplatnie uzywac, kopiowac, modyfikowac i rozpowszechniac kod, takze
komercyjnie, z zachowaniem informacji o prawach autorskich i tresci licencji.
Oprogramowanie jest dostarczane bez gwarancji. Pelny tekst znajduje sie w pliku
[LICENSE](LICENSE); opis licencji: https://opensource.org/license/mit.

Zewnetrzne narzedzia (yt-dlp, FFmpeg, Deno i winget) podlegaja wlasnym licencjom.
Licencja tego projektu nie zmienia ich warunkow ani praw do pobieranych materialow.

## Uruchomienie

1. Rozpakuj caly folder ZIP.
2. Uruchom START.bat. Program sprawdza wymagane narzedzia (yt-dlp, FFmpeg i Deno), instaluje brakujace i aktualizuje zainstalowane przez winget.
3. Wpisz mp3 lub mp4, wklej link i wybierz jakosc.
4. Pliki znajdziesz w Pobrane/MP3 albo Pobrane/MP4 obok programu.

INSTALUJ.bat uruchamia samo sprawdzanie i instalacje. Nie trzeba uruchamiac go przed START.bat.
Potrzebny jest internet i Windows 10/11 z winget (Microsoft App Installer ze sklepu Microsoft Store). Python nie jest wymagany. Windows moze poprosic o uprawnienia instalatora; warunki pakietow i zrodla winget sa akceptowane automatycznie.

## Playlisty

- Link filmu zawierajacy list=: program pyta cala / film / anuluj. Enter wybiera tylko film.
- Link samej playlisty: program pyta tak / nie. Enter anuluje.
- Cale playlisty sa zapisywane w podfolderach z nazwa i identyfikatorem listy, z numerami porzadkowymi plikow.
- Wszystkie filmy z listy otrzymuja wybrany format i ustawienia jakosci.
- Niedostepne pozycje nie zatrzymuja pozostalych filmow. Bledy sa widoczne w terminalu; koncowy komunikat informuje o niepelnym pobraniu.

## Postep i jakosc

- Kolorowe menu, procent pobrania, rozmiar, predkosc oraz ETA (pozostaly czas). Dla playlist widac tez kolejnosc pobieranych pozycji.
- MP3: 128, 192 lub 320 kb/s. Wybrany bitrate nie poprawia jakosci zrodla.
- MP4: maksymalnie 480p, 720p, 1080p, 1440p, 2160p albo best (najlepsza dostepna jakosc).
- Po pobraniu FFmpeg laczy obraz z dzwiekiem lub konwertuje plik. Ten etap moze potrwac i nie ma procentowego paska.
- Ctrl+C zatrzymuje program. Ponowne podanie tego samego linku i ustawien pozwala wznowic dostepne pliki .part.
- Istniejace pliki nie sa nadpisywane. Przed pobraniem tego samego filmu w innej jakosci przenies poprzedni plik do innego folderu.
- q konczy prace.

## Aktualizacje i problemy

Sprawdzanie aktualizacji odbywa sie przy kazdym uruchomieniu. Dotyczy tylko trzech wymaganych pakietow, a nie wszystkich programow na komputerze. Aktualizacje samego skryptu wymagaja pobrania nowej paczki ZIP.

Jesli sprawdzenie aktualizacji nie powiedzie sie (np. brak internetu), mozna nadal korzystac z dostepnych narzedzi. Jesli brakuje wymaganego narzedzia i instalacja sie nie uda, menu nie uruchamia sie; przeczytaj komunikaty instalatora i sprobuj ponownie. Sciezki narzedzi sa odswiezane po instalacji. Gdy narzedzia wciaz nie sa wykrywane, uruchom START.bat ponownie.

Narzedzia zainstalowane recznie, poza winget, moga nie zostac rozpoznane przez menedzera aktualizacji. Program wyswietli komunikat; nie gwarantuje aktualizacji takich instalacji.

Materialy prywatne, wymagajace logowania, ograniczone regionalnie lub transmisje na zywo moga nie dzialac. Program nie konfiguruje logowania. Pobieraj materialy, do ktorych masz prawo.

Dokumentacja: https://github.com/yt-dlp/yt-dlp
Aktualizacje winget: https://learn.microsoft.com/windows/package-manager/winget/upgrade

Menu jest po polsku bez znakow diakrytycznych dla zgodnosci ze starszym terminalem; szczegolowe komunikaty narzedzi moga byc po angielsku.
