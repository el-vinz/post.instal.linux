#!/bin/bash

#L'installation se fera par github via git-clone qui téléchargera également les fichiers annexes.

#PACK_URL="http://myos.fr/migration/migration.pack.tar.gz"

TEMP=~/.tmpinstall
LINUX_DISTRIB=$(awk '{print ($1)}'  /etc/issue)
DISTRIB_VERSION=$(awk '{print ($2)}'  /etc/issue)
GNOME_VERSION=$(gnome-shell --version)
#SOFTWARES=vlc pingus mplayer id3v2 mixxx hydrogen rsync qemu-kvm libvirt-bin virt-manager vim ffmpeg tilix sshfs
SOFTWARES=vlc pingus rsync qemu-kvm libvirt-bin virt-manager vim ffmpeg tilix sshfs cmatrix ipcalc nmap
RELEASE=$(lsb_release -a | rev | cut -d " " -f1 | rev)


[ ! -d $TEMP ] && mkdir $TEMP

check_root () {

	if [ "$UID" -ne "0" ]
        then
                echo "Vous devez être administrateur. Fin du script."
                exit 1
fi

}


./packages_apt.sh

#packages_apt $SOFTWARES

./packages_yum.sh

#packages_yum $SOFTWARES

./packages_zypper.sh
#packages_zypper $SOFTWARES

choose_distribution () {
	case $LINUX_DISTRIB in
		Ubuntu) packages_apt $SOFTWARES;;
		Fedora) packages_yum $SOFTWARES;;
		Opensuse) packages_zypper $SOFTWARES;;
		*) echo "Your distribution $LINUX_DISTRIB is not supported by this script" 
			exit 1;;

	esac
}

tweak_it () {
	[ ! -d /usr/share/icons/twistos ] && mkdir /usr/share/icons/twistos
	cp $TEMP/icons/* /usr/share/icons/twistos/
	cp $TEMP/bin/* /usr/local/bin/
	#Attention ! copier les fichiers images dans le repertoire background ne suffit pas.Une histoire de xml --> A creuser 
	cp $TEMP/backgrounds/*  /usr/share/backgrounds/
    cp -r $TEMP/themes/* /usr/share/themes

	#Puis on modifie le xml charagé de faire tourner les fonds d'écrans

	xml_gen >>/usr/share/gnome-background-properties/${RELEASE}-wallpapers.xml

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

tweak_it 
