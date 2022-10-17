# Loop a Video 4evr
Casey Anderson, 2022

*Note* `OMXPlayer` is being "phased out" in favor of `VLC`, this tutorial assumes usage of `Raspbian Buster Lite (Legacy)`, under which `OMXPlayer` is still available via `aptitude`

## pre-flight

* [Writing, Backing Up, and Cloning Raspbian (RPi) Images](https://gist.github.com/caseyanderson/396f94678cccda35dcd4d5a2a91fd69b)


## overview

The Raspberry Pi is an excellent low-cost video looper, particularly for situations in which the video needs to "loop forever" and do so automatically on boot. Below are instructions for running the raspberry pi over the command line (via `ssh` or `screen`), also known as running "headless."


## omxplayer

`OMXPlayer` is the recommended [command line](https://en.wikipedia.org/wiki/Command-line_interface) video player for `raspbian`. One can download and install it via `aptitude`: `sudo apt-get install omxplayer`


## config file changes

Two quick changes to one config file: `/boot/config.txt`

1. Uncomment (delete the `#`) the line reading `#hdmi_force_hotplug=1`
2. Uncomment `hdmi_group` and `hdmi_mode` and use the following numbers to set HDMI and 1080p at 60Hz as default (if you need a different default in the future it is simply a matter of updating with different values):

    ```bash
    hdmi_group=1
    hdmi_mode=16
    ```

3. Save and exit the file

## acquiring and playing a video

1. Download and install `youtube downloader` via their [manual installation instructions](https://ytdl-org.github.io/youtube-dl/download.html), also include below:
    1. `sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl`
    2. `sudo chmod a+rx /usr/local/bin/youtube-dl`
    3. Confirm that it is working with `youtube-dl --version`
    4. (optional) Run the following to update `youtube-dl` to the latest version (might not be necessary): `sudo youtube-dl -U`
2. Locate a short video on youtube to act as a test file. for example, one can download the "original" [Nyan Cat](https://en.wikipedia.org/wiki/Nyan_Cat) animation from youtube (as of 03/14/2017) via: `youtube-dl https://www.youtube.com/watch?v=QH2-TGUlwu4&t=4s`
3. Use the Unix command `mv` to change the Nyan Cat video filename (which is obnoxious) to simply `nyan_cat.mp4`: `mv Nyan\ Cat\ \[original\]-QH2-TGUlwu4.mp4 nyan_cat.mp4`
4. Play the video: `omxplayer nyan_cat.mp4`


## looping a video file

omxplayer player has built-in looping functionality: `omxplayer --loop nyan_cat.mp4`

omxplayer also has a bunch of parameters to customize the specifics of the loop playback. try running the following (replace `nyan_cat.mp4` with whatever your video is called): `omxplayer -b --loop --no-osd -o hdmi nyan_cat.mp4`

more specifically:

* `-b`: forces omxplayer to create a black background behind the video
* `--loop`: the normal command to force omxplayer to loop a video file
* `--no-osd`: hides the on-screen dialogue messages (like "Seeking..." when looping back to the beginning of the video)
* `-o hdmi`: forces audio output via the HDMI cable
* `-r`: not used in the command above but can force the video to fill the screen


## looping one video forever w/ bash

With minimal alterations, and a bit of setup, one can make a `bash` file that runs the omxplayer loop command:

1. On your raspberry pi make a file called `loop-one.sh`: `nano loop-one.sh` (you could `vi` if you prefer)
2. Copy the following code and paste it all into your `loop-one.sh` file (then save and exit):

    ```bash
    #!/bin/sh

    omxplayer -b --loop --no-osd -o hdmi /home/pi/FILENAME.mp4

    ```

3. Make `loop-one.sh` executable with `chmod`: `chmod +x loop-one.sh`
4. Run `loop-one.sh` with the following command `./loop-one.sh`
5. `Control-C` (KeyboardInterrupt) to exit loop


## running loop script on startup

1. On your pi open `rc.local` with `nano`: `sudo nano /etc/rc.local`
2. Scroll until you see `exit 0` at the bottom of the file and add two new lines above `exit 0` (`exit 0` has to be the last line in this file)
3. Assuming you want to loop one video forever configure `rc.local` to run `loop-one.sh` with `bash` as a background process  on boot (the `&` at the end of the loop is mission critical here): `su -c "sh /path/to/file/loop-one.sh" pi &`
4. Save and exit
5. Test that we configured `rc.local` correctly (the video should start playing): `sudo /etc/rc.local`
6. Control-C to cancel playback (assuming it's working)
7. Reboot: `sudo reboot now`
8. Confirm that the looper starts up shortly after the login prompt appears. if not happen make sure `loop-one.sh` has been made executable (`chmod +x loop-one.sh`)
9. Since the line in `rc.local` ends with an `&` one can login back into the pi and, among other things, stop the looping process from launching automatically on boot: comment out (add a `#` in front of) the line we just added to `rc.local` in order to revert to non-looping functionality. save, exit, and reboot to confirm non-looping behavior.
