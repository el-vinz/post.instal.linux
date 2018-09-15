#!/bin/bash

PACK_URL="http://myos.fr/migration/migration.pack.tar.gz"
TEMP=~/.tmpinstall
LINUX_DISTRIB=$(awk '{print ($1)}'  /etc/issue)
DISTRIB_VERSION=$(awk '{print ($2)}'  /etc/issue)
GNOME_VERSION=$(gnome-shell --version)
SOFTWARES=vlc pingus mplayer id3v2 mixxx hydrogen rsync qemu-kvm libvirt-bin virt-manager vim ffmpeg tilix 

[ ! -d $TEMP ] && mkdir $TEMP

choose_distribution () {
	case $LINUX_DISTRIB in
		Ubuntu) packages_apt ;;
		Fedora) packages_yum ;;
		Opensuse) packages_zypper;;
		*) echo "Your distribution $LINUX_DISTRIB is not supported by this script" 
			exit 1;;

	esac
}



packages_apt () {
	apt update && apt upgrade -y
	
	wget https://yt-dl.org/latest/youtube-dl -O /usr/local/bin/youtube-dl
	chmod a+x /usr/local/bin/youtube-dl
	hash -r

	add-apt-repository ppa:flexiondotorg/audio -y
	apt-get update
	apt-get install mp3gain -y

	apt install -y $SOFTWARES  

}

packages_yum () {

	yum update && yum upgrade -y

	# installation de youtube-dl
	wget https://yt-dl.org/latest/youtube-dl -O /usr/local/bin/youtube-dl
	chmod a+x /usr/local/bin/youtube-dl
	hash -r
	#installation mp3 gain

	 add-yum-repository ppa:flexiondotorg/audio -y
	 yum-get update
	 yum-get install mp3gain -y

	#installation des logiciels usuels des dépôts.
	yum install -y $SOFTWARES

}

desktop_configure () {
	[ ! -d /usr/share/icons/twistos ] && mkdir /usr/share/icons/twistos
	cp $TEMP/icons/* /usr/share/icons/twistos/
	cp $TEMP/bin/* /usr/local/bin/
	#Attention ! copier les fichiers images dans le repertoire background ne suffit pas.Une histoire de xml --> A creuser 
	cp $TEMP/backgrounds/*  /usr/share/backgrounds/
    cp -r $TEMP/themes/* /usr/share/themes

	#Puis on modifie le xml charagé de faire tourner les fonds d'écrans

	xml_gen >#ou est ce fichier ? 

}


xml_gen () {
	for f in $(ls -1 $TEMP/backgrounds/)
do
	cat <<EOF
<wallpaper>
    <name>${f}</name>
    <filename>${f}</filename>
    <options>zoom</options>
    <pcolor>#000000</pcolor>
    <scolor>#000000</scolor>      
    <shade_type>solid</shade_type>
</wallpaper>
EOF
done	
}


themes_download () {

		
 apt-add-repository ppa:tista/adapta -y  
 apt update  
 apt install adapta-gtk-theme -y 

}


check_gnome () {
if [ -z $1] then
	echo "Gnome-shell n'existe pas sur votre poste. Fin de Script"
	return 1
	else
	echo "Votre version de gnome est la $GNOME_VERSION"
fi
}


###### Let's go

echo "Vérification de la présence de Gnome-shell"
check_gnome ($GNOME_VERSION)


cat <<<EOF


Téléchargement des sources 
 
EOF

wget $PACK_URL $TEMP

#wget $PACK_URL $TEMP -O pack.download.tar.gz && tar -xvf  pack.download.tar.gz

tar -xvf $TEMP/$PACK_URL

choose_distribution

packages_apt || echo "Erreur dans le téléchargement des paquets" && exit 1 

desktop_configure 
