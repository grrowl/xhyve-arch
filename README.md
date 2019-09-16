# scripts for xhyve

Install an Ubuntu 16.04 or Arch Linux VM on macOS using [xhyve].

## Download guest

* Ubuntu 16.05 is known to work
* Arch Linux 201905 is known to work
  * https://wiki.archlinux.org/index.php/QEMU#Preparing_an_(Arch)_Linux_guest
  * `mkinitcpio -p linux`

## Install xhyve

```
brew install xhyve
```

## Get booting kernel

```
sudo ./prepare.sh ubuntu-16.04.5-server-amd64.iso
```

## Create storage and boot to ISO

Passing paths with spaces may fail here. Better if you copy the iso into this directory first.

```
sudo ./create.sh ubuntu-16.04.5-server-amd64.iso
```

After booting, install Ubuntu just like you normally would.

Pro tip: Don't resize your terminal while you're going through the installer.

When you get to this question.

```
Install the GRUB boot loader to the master boot record?
```

Make sure you say, "yes".

## Very important DO NOT QUIT Installation

### Grab newer kernel from install

When you get to "Installation complete", select "Go Back". Then, "Execute a
shell".

Find your current IP address.

```
/sbin/ip addr show enp0s2
2: enp0s2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    inet 192.168.64.8/24 brd 192.168.64.255 scope global enp0s2
```

Next, we're gonna copy some files back to the host. The exact name of the
following files might be slightly different, depending on when you download the
Ubuntu server ISO.

In the guest, run this.

```
cd /target/boot
cat initrd.img-4.4.0-131-generic | nc -l -p 1234
# now run the below `nc ...` command on the host
cat vmlinuz-4.4.0-131-generic | nc -l -p 1234
# run the next `nc ...` on the host
```

On the host, run this.

```
cd boot/
# after running `cat ...` on the guest:
nc 192.168.64.8 1234 > initrd.img-4.4.0-131-generic
# and again for the next file:
nc 192.168.64.8 1234 > vmlinuz-4.4.0-131-generic
```

after copying the files, run `ls -la` on both guest and host to ensure the file sizes are exactly the same.

Now, you can `exit` the shell and finish the installation.

## Modify the environment.sh

Update environment.sh to ensure the filenames in `boot/` match.

## Start your new OS

```
sudo ./start.sh
```

## First steps

Here are some things you should probably do after logging in.

```
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install -y xterm
echo "export TERM=xterm-256color" >> $HOME/.bashrc
```

`xterm` is important because it'll install the `resize` command. You'll need to
manually resize the terminal dimensions because we're using a serial TTY or
something.

The default terminal is `vt220`, which doesn't have colors by default. We're
probably more used to `xterm`.

Everytime you resize your terminal, you need to run `resize`. Otherwise, your
output will get jacked.

## Reboot

That's it! You don't really need to reboot, but here's what that looks like.

```
jaime@xhyve:~$ sudo poweroff
[  636.675689] reboot: System halted
jaime@mac:~$ sudo ./start.sh
```

## Launch Daemons

The purpose is unclear.  But I think it may be because the author want to boot the ubuntu when MacOS reboot.
Not sure it is what you want and hence if you are not sure, there is no need.
And if you need it, you have to modify the file variadico.xhyve.ubuntu.plist as it contains the directory where the file belong

```
sudo chown root variadico.xhyve.ubuntu.plist
sudo ln -s $(pwd)/variadico.xhyve.ubuntu.plist /Library/LaunchDaemons/
sudo launchctl load /Library/LaunchDaemons/variadico.xhyve.ubuntu.plist

# Verify status
sudo launchctl list | grep "xhyve"

# Stop
sudo launchctl unload /Library/LaunchDaemons/variadico.xhyve.ubuntu.plist
```

[xhyve]: https://github.com/mist64/xhyve
