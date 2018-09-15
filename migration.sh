#!/bin/bash

packages () {
	apt update && apt upgrade -y
	# installation de youtube-dl
	wget https://yt-dl.org/latest/youtube-dl -O /usr/local/bin/youtube-dl
	chmod a+x /usr/local/bin/youtube-dl
	hash -r
	#installation mp3 gain

	sudo add-apt-repository ppa:flexiondotorg/audio -y
	sudo apt-get update
	sudo apt-get install mp3gain -y

	#installation des logiciels usuels
	apt install -y vlc pingus mplayer id3v2 mixxx hydrogen rsync qemu-kvm libvirt-bin virt-manager

}


visual_configure () {
	[ ! -d /usr/share/icons/twistos ] && mkdir /usr/share/icons/twistos
	cp icons/* /usr/share/icons/twistos/
	cp bin/* /usr/local/bin/
	cp backgrounds/*  /usr/share/backgrounds/
        cp -r themes/* /usr/share/themes	

}

packages && visual_configure
