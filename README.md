rTorrent-PS
===========

Extended `rTorrent` distribution with UI enhancements, colorization, and some added features.

![Extended Canvas Screenshot](http://i.imgur.com/B9qll.png)


## Feature Overview

`rTorrent-PS` is a `rTorrent` distribution in form of a set of patches 
that improves the user experience and stability of official `rTorrent` releases.

The main changes are these:

  * self-contained install into any location of your choosing, including your home directory, offering the ability to run several versions at once (in different client instances).
  * rpath-linked to the major dependencies, so you can upgrade those independently from your OS distribution's versions.
  * extended command set:
    * sort views by more than one value, and set the sort direction for each of these.
    * bind keys in the root display to any command, e.g. change the built-in views.
  * interface additions:
    * easily customizable colors.
    * collapsed 1-line item display.
    * network bandwidth graph.
    * displaying the tracker domain for each item.
    * some more minor modifications to the download list view. 

To get those, you just need to either follow the build instructions, or download and install a package from Bintray — assuming one is available for your platform. 


For more details, see the [wiki page at Google code](https://code.google.com/p/pyroscope/wiki/RtorrentExtended).


## Installation

See the [instructions on Google code](https://code.google.com/p/pyroscope/wiki/DebianInstallFromSource#rTorrent_installation), for either package based installation, or building from source.
