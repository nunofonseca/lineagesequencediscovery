# Introduction #

Follow the instructions below to install all the components necessary to use LSD to its fullest!


# Details #

## Ubuntu Lucid Lynx (10.4) and related ##

Use the .deb package available at the download section.

Double click the file and Synaptic should open.

Click 'Install Package' and you're done!

T-Coffee will also be installed by the package manager.

To install MEME, you have to compile it on your own. See below how!

### Installing MEME ###

MEME is only available through it's source code. Meaning, you have to compile it first!
First, ensure that your operating system has all packages necessary for building C++ programs: kernel-devel, linux-headers, gcc, g++, etc.

Then go to MEME's download [repository](http://meme.nbcr.net/downloads/) and download _meme\_current.tar.gz_ and it's correspondent patches.

At the moment of the writing of this document, MEME is at version 4.4.0, so the downloads would be: meme\_4.4.0.tar.gz (or meme\_current.tar.gz), meme\_4.4.0.patch\_1, meme\_4.4.0.patch\_2 and meme\_4.4.0.patch\_3.

Instructions on how to apply the patches are available on the repository under the name _meme\_4.4.0.patch`_#_`readme.txt_, where # is the patch number.

Open a terminal and navigate to the folder where you putted the tar.gz.
Now type
```
    $ tar zxf meme_VERSION.tar.gz
    $ cd meme_VERSION 
    $ ./configure --prefix=/usr/local
```

If this step fails, you may be missing the necessary tools to compile a program.
Run the following commands as root to install the necessary tools and libraries:

```
    # yum groupinstall "Development Tools"
```

Now, apply all the necessary patches to MEME, compile and install!

Compile:
```
    $ make
```

Install:
```
    $ su
      [Enter root password!]
    # make install
```

Everything should have gone well!

Try to run MEME:
```
    $ meme
```

If it shows the following error: "/bin/csh: Bad interpreter", run the following command as root:
```
    # yum install csh
```

## Fedora 12/13 ##

Download the RPM packages available at the download section.

LSD uses the Gtk2 SourceView component to show sequences, but this component isn't easily available as a RPM package. To help most users circumvent this situation, a RPM package for Fedora 12/13 for the i686 architecture is provided. This package may also work on x64 environments with a few modifications, but it hasn't been tested yet.

First install the Gtk2 SourceView package (as root!):
```
    # yum -y --nogpgcheck install perl-Gtk2-SourceView-1.000-1.n0i.1.fc12.i686.rpm
```
then the LSD package and you're done :)
```
    # yum -y --nogpgcheck install lineagesequencediscovery-0.3.3-2.i386.rpm
```

Now, you probably want to install TCoffee and MEME to take the full out of LSD.

Unfortunately, you have to install them manually! Check above for how to install MEME.

### Installing `T-Coffee` ###

Go to [`T-Coffee`'s homepage](http://www.tcoffee.org/Projects_home_page/t_coffee_home_page.html) and download the source package (check the 'Downloads' box -> 'Latest Version').

LSD was tested using version 8.69, but, unless the `T-Coffee`'s command line arguments changed, newer versions should work.
  1. Uncompress the file you just downloaded
  1. Open a terminal where the 'install' file
  1. On the terminal, type
> > `su -c './install all'`

> This ensures you will be able access all modes of `T-Coffee`.

The compiling process will take a while, so go do something else :)