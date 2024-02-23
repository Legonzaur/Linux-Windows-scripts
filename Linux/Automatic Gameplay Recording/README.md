Automatic Nvidia Shadowplay-like for Linux

**Current features** : Records the entire display while a game is launched

Currently, it records everything to a file, but it should be very easy to tweaks these scripts a bit to allow for a replay feature akin to Shadowplay to be created.
## Installation
### Requirements
Install [Feral Gamemode](https://github.com/FeralInteractive/gamemode) and [gpu-screen-recorder](https://git.dec05eba.com/gpu-screen-recorder/about/)

* Archlinux
  ```sh
  yay -S gamemode lib32-gamemode gpu-screen-recorder-git 
  ```
### Configuration files
Copy the corresponding files inside your $HOME directory

You should edit the command line located in `.local/bin/startRecord` to match your wanted settings.

You can use `gpu-screen-recorder --help` to get more information about the usage of this command

## Usage

Start a program using gamemoderun

Example : 
```sh
gamemoderun glxgears
```

### Steam

To make Steam start a game with gamemode, right click the game in the Library, select Properties..., then in the Launch Options text box enter:
`gamemoderun %command%`


## Misc

All recording is done using gpu-screen-recorder, a program that should allow recording a game with close to no overhead.



Please refer to the following repositories for more information about the resources used.

[Gamemode](https://github.com/FeralInteractive/gamemode)

[Systemd user units](https://wiki.archlinux.org/title/Systemd/User)

[gpu-screen-recorder](https://git.dec05eba.com/gpu-screen-recorder/about/)
