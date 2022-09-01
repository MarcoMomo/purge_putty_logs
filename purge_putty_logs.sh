#!/bin/sh
#----------------------------------------------------------------------------#
# @(#) SCRIPT : purge_putty_logs.sh                                          #
#----------------------------------------------------------------------------#
# @(#) Fonction                 : Traitement des logs de PuTTY               #
# @(#) Auteur                   : Marc MORALES                               #
# @(#) Parametres d'entree      :                                            #
# @(#) Parametres de sortie     :                                            #
# @(#) Retour                   : 0 ACTIF, 1 INACTIF                         #
# @(#) Scripts appeles          :                                            #
# @(#) Commentaires             : Déplacement dans un répertoire contenant   #
# @(#)                          : le nom du serveur des logs de plus de      #
# @(#)                          : ${nb_jours_dep} jour(s)                    #
# @(#)                          : Archivage des logs de plus de              #
# @(#)                          : ${nb_jours_arch} jour(s)                   #
#----------------------------------------------------------------------------#
#   1.00        MMS     14/01/20  Creation                                   #
#----------------------------------------------------------------------------#

#----------------------------------------------------------------------------#
# DECLARATION DES VARIABLES ET DES FICHIERS                                  #
#----------------------------------------------------------------------------#


fic_log=/c/temp/purge_putty_log.log
rep=/c/temp/putty_log
nb_fic_depl=0
nb_fic_arch=0
nb_jours_depl=10  # 3 Nombre de jours avant de déplacer les fichiers dans un répertoire <<nom_du_serveur>>
nb_jours_arch=20  # 7 Nombre de jours avant d'archiver les fichiers

######################################
# Fonctions
######################################

function msglog
# Affiche un message à l'écran et dans le fichier de la variable $fic_log
# Utilisation: msglog "message"
{
	#echo $1
	echo "$(date): $1" | tee -a ${fic_log}
}

> ${fic_log}


######################################
# Script
######################################
Heure_Debut=$(date)
msglog "------------------------------"
msglog "Archivage du répertoire ${rep}"
msglog "------------------------------"
msglog "Nombre de jours avant déplacement : ${nb_jours_depl}"
msglog "Nombre de jours avant archivage   : ${nb_jours_arch}"
msglog "------------------------------"

for fic in $(find ${rep} -maxdepth 1 -type f -mtime +${nb_jours_depl}); do
	nb_fic_depl=$(($nb_fic_depl + 1))
    msglog "Traitement du fichier[$nb_fic_depl] $fic"
     nom_fic=${fic##*\/}
    msglog "nom_fic=${nom_fic}"
    nom_serveur=${nom_fic%%.*}
    msglog "nom_serveur=${nom_serveur}"
    if [ ! -d ${rep}/${nom_serveur} ] ; then
       msglog "creation du repertoire  ${rep}/${nom_serveur}"
       mkdir ${rep}/${nom_serveur}
    fi
    msglog "mv ${rep}/${nom_fic} ${rep}/${nom_serveur}"
    mv ${rep}/${nom_fic} ${rep}/${nom_serveur}
    msglog "---------------------------------"
done
msglog "$nb_fic_depl fichier(s) déplacés"
msglog "---------------------------------"

for fic in $(find ${rep} -type f -mtime +${nb_jours_arch}); do
	nb_fic_arch=$(($nb_fic_arch + 1))
    msglog "Traitement du fichier[$nb_fic_arch] $fic"
    nom_fic=${fic##*\/}
    msglog "nom_fic=${nom_fic}"
    nom_serveur=${nom_fic%%.*}
    msglog "nom_serveur=${nom_serveur}"
    if [ ! -d ${rep}/${nom_serveur} ] ; then
       msglog "création du répertoire  ${rep}/${nom_serveur}"
       mkdir ${rep}/${nom_serveur}
    fi

    # Ajouter un fichier à une archive existante en 3 étapes.
    # 1 - Décompression (un fichier ne peut être ajouté à une archive compressée
    # $ gunzip monArchive.tar.gz
    # 2 - Ajout du fichier monFichier à l'archive
    # $ tar -rf monArchive.tar monFichier
    # 3 - Compression de l'archive
    # $ gzip monArchive.tar

    # 1 - Décompression (un fichier ne peut être ajouté à une archive compressée
    if [ -f ${rep}/${nom_serveur}/${nom_serveur}.tar.gz ] ; then
       msglog "l'archive existe: décompression"
       msglog "gunzip ${rep}/${nom_serveur}/${nom_serveur}.tar.gz"
       gunzip ${rep}/${nom_serveur}/${nom_serveur}.tar.gz
    fi

    # 2 - Ajout du fichier à l'archive
    msglog "Ajout du fichier à l'archive"
    msglog "tar rvf ${rep}/${nom_serveur}/${nom_serveur}.tar ${fic}"
    tar rvf ${rep}/${nom_serveur}/${nom_serveur}.tar ${fic}
    msglog "rm -f ${fic}"
    rm -f ${fic}

    # 3 - Compression de l'archive
    msglog "Compression de l'archive"
    msglog "${rep}/${nom_serveur}/${nom_serveur}.tar"
    gzip ${rep}/${nom_serveur}/${nom_serveur}.tar
    msglog "---------------------------------"
done
msglog "$nb_fic_depl fichier(s) déplacés"
msglog "$nb_fic_arch fichier(s) archivés"
msglog "---------------------------------"
msglog "Heure Début: ${Heure_Debut}"
msglog "Heure Fin  : $(date)"