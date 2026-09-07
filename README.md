# linux-audio-fix (aka. maelstrom-audio-fix)
Prevent HDMI audio glitches caused by memory clock frequency transitions on Linux for hybrid graphics laptops.

By [M4elstr0m](https://github.com/M4elstr0m)

## Overview

This is a fix I created for my Arch laptop which had an issue with HDMI audio where audio just stopped randomly before reappearing, especially during downloads.

> [!IMPORTANT]
> This only works for NVIDIA GPUs

**Don't hesitate to star :star: this repository so other people having this issue can find it more easily!**

## Usage

The fix is really simple: only two commands. But to make it persistent, you have to create a new systemd service, that's why I created this repository.

So here you have two bash files `install.sh` and `uninstall.sh`, both need to be ran with `sudo`.

---

Full walkthrough
```sh
# [1] Confirm the non-persistent fix works first

nvidia-smi -pm 1

## find your maximum supported memory clock
MEM_CLOCK=$(nvidia-smi -q -d SUPPORTED_CLOCKS | grep -oP 'Memory\s*:\s*\K[0-9]+' | sort -n | tail -1)
echo $MEM_CLOCK

## lock your memory clock to this maximum frequency
sudo nvidia-smi --lock-memory-clocks=$MEM_CLOCK,$MEM_CLOCK

# [2] Now test whether your audio issue still occurs

# [3] If your issue seems fixed, make it persistent

## download this repo
git clone https://github.com/M4elstr0m/linux-audio-fix.git

## enter the directory
cd linux-audio-fix

## make both scripts executable
chmod +x install.sh uninstall.sh

## install the service
./install.sh

# [4] If you need to uninstall the service for some reason
./uninstall.sh
```

## License

Licensed under MIT License.