# Loop a Video 4evr
Casey Anderson, 2019

## pre-flight

* [The Command Line](https://gist.github.com/caseyanderson/5d08e5c5fb276b1e8bbc9e56d677492b)
* [Writing, Backing Up, and Cloning Raspbian (RPi) Images](https://gist.github.com/caseyanderson/31b615045332a6ab3f4028c696920f57)
* [Connectivity: Laptop to RPi](https://gist.github.com/caseyanderson/7871deb02ca6dd418844db04d3c146fc)


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
    1. `sudo wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl`
    2. `sudo chmod a+rx /usr/local/bin/youtube-dl`
    3. `hash -r`
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


## looping one video forever

With minimal alterations, and a bit of setup, one can make a `bash` file that runs the omxplayer loop command:

1. On your raspberry pi make a folder called `videolooper` in your `home` directory: `mkdir videolooper`
2. `cd` into `videolooper`: `cd videolooper`
3. Make a `video` folder inside `videolooper` (videos will be stored here): `mkdir video`
4. On your mac make a new file called `loop_one.sh` wherever you want (we are going to set this up and then send it to the raspberry pi via `scp`): `touch loop_one.sh`
5. Open up `loop_one.sh` in whatever text editor you like (remember, we are still on our mac at this point). i like [Vim](https://www.vim.org/)
6. Copy the following code and paste it all into your `loop_one.sh` file (then save and exit):

    ```bash
    #!/bin/sh

    omxplayer -b --loop --no-osd -o hdmi /home/pi/nyan_cat.mp4

    ```
7. Use `scp` to send `loop_one.sh` to your raspberry pi (note, this requires knowledge of your pi's ip address): `scp loop_one.sh pi@<PI_IP_ADDRESS>:/home/pi/`
8. Back on your pi, make `loop_one.sh` executable with `chmod`: `chmod +x loop_one.sh`
9. Run `loop_one.sh` with the following command `./loop_one.sh`
10. `Control-C` (KeyboardInterrupt) to exit loop


## looping all videos in a playlist forever

1. On your mac make a new file called `loop_all.sh`: `touch loop_all.sh`
2. Open it with your preferred text editor  (again, I use Atom so it looks like this when I do it): `atom loop_all.sh`
3. Copy the code from [this](/scripts/loop_all.sh) file and paste it all into your `loop_all.sh` file (then save and exit)
4. Send `loop_all.sh` to your raspberry pi: `scp loop_all.sh pi@<PI_IP_ADDRESS>:/home/pi/`
5. Move the file into the `videolooper` directory: `mv loop_all.sh videolooper/loop_all.sh`
6. Update `loop_all.sh` to include the correct path and filename information (via `nano` or `vi`) stored at `VIDEOPATH`
7. Make `loop_all.sh` executable with `chmod`: `chmod +x loop_all.sh`
8. Run `loop_all.sh` with the following command `./loop_all.sh`
9. `Control-C` (KeyboardInterrupt) to exit loop


## running loop script on startup

There are lots of ways to run a file on startup. Regardless of whether one needs to loop one video forever on boot or loop several videos in a folder forever on boot, its simply a matter of specifying which script (file) one wants to use with `rc.local` (the service which will launch the script on boot):

1. On your pi open `rc.local` with `nano` or `vi`: `sudo nano /etc/rc.local`
2. Scroll until you see `exit 0` at the bottom of the file and add two new lines above `exit 0` (`exit 0` has to be the last line in this file)
3. Assuming you want to loop all folders in a directory, configure `rc.local` to run `loop_all.sh` with `bash` as a background process  on boot (the `&` at the end of the loop is mission critical here): `su -c "sh /path/to/file/loop_all.sh" pi &`
4. Save and exit
5. Reboot: `sudo reboot now`
6. Confirm that the looper starts up shortly after the login prompt appears. if not happen make sure `loop_all.sh` has been made executable (`chmod +x loop_all.sh`)
7. Since the line in `rc.local` ends with an `&` one can login back into the pi and, among other things, stop the looping process from launching automatically on boot: comment out (add a `#` in front of) the line we just added to `rc.local` in order to revert to non-looping functionality. save, exit, and reboot to confirm non-looping behavior.

Alternately, if one wanted to use the `loop_one.sh` script and not `loop_all.sh`, or even to some other `bash` script, one would simply point `rc.local` to `loop_one.sh`, resulting in the following line: `su -c "sh /path/to/file/loop_all.sh" pi &`
