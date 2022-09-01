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
#   2.00        MMS     28/01/20  Optimisation de l'archivage                #
#----------------------------------------------------------------------------#

#----------------------------------------------------------------------------#
# DECLARATION DES VARIABLES ET DES FICHIERS                                  #
#----------------------------------------------------------------------------#
VERSION="2.00"
PROG=${0##*/}

fic_log=/c/temp/purge_putty_log.log
rep=/c/temp/putty_log.save2
rep_arch_tmp=a_archiver
nb_fic_depl=0
nb_fic_arch=0
total_fic_depl=0
total_fic_arch=0
nb_jours_depl=10  # 3 Nombre de jours avant de déplacer les fichiers dans un répertoire <<nom_du_serveur>>
nb_jours_arch=20  # 7 Nombre de jours avant d'archiver les fichiers

#----------------------------------------------------------------------------#
# Functions
#----------------------------------------------------------------------------#

function msglog
# Affiche un message à l'écran et dans le fichier de la variable $fic_log
# Utilisation: msglog "message"
{
	#echo $1
	echo "$(date): $1" | tee -a ${fic_log}
}

> ${fic_log}


#----------------------------------------------------------------------------#
# MAIN
#----------------------------------------------------------------------------#
Heure_Debut=$(date)
msglog "------------------------------"
msglog "Archivage du répertoire ${rep}"
msglog "------------------------------"
msglog "Nombre de jours avant déplacement : ${nb_jours_depl}"
msglog "Nombre de jours avant archivage   : ${nb_jours_arch}"

#-----------------------------------#
# Comptage
#-----------------------------------#
for fic in $(find ${rep} -maxdepth 1 -type f -mtime +${nb_jours_depl}); do
    total_fic_depl=$((${total_fic_depl} + 1))
    #total_fic_depl=$(ls $fic | wc -l)
done
for fic in $(find ${rep} -maxdepth 1 -type f -mtime +${nb_jours_arch}); do
    total_fic_arch=$((${total_fic_arch} + 1))
    #ls $fic
done
msglog "Nombre de fichier à déplacer     : ${total_fic_depl}"
msglog "Nombre de fichier à archiver     : ${total_fic_arch}"
msglog "------------------------------"

#-----------------------------------#
# Déplacement
#-----------------------------------#
for fic in $(find ${rep} -maxdepth 1 -type f -mtime +${nb_jours_depl}); do
	nb_fic_depl=$((${nb_fic_depl} + 1))
    msglog "Traitement du fichier[${nb_fic_depl}/${total_fic_depl}] $fic"
    nom_fic=${fic##*\/}
    msglog "nom_fic=${nom_fic}"
    serveur=${nom_fic%%.*}
    msglog "serveur=${serveur}"
    if [ ! -d ${rep}/${serveur} ] ; then
       msglog "creation du repertoire ${rep}/${serveur}"
       mkdir ${rep}/${serveur}
    fi
    msglog "mv ${rep}/${nom_fic} ${rep}/${serveur}"
    mv ${rep}/${nom_fic} ${rep}/${serveur}
    msglog "---------------------------------"
done
msglog "$nb_fic_depl fichier(s) déplacés"
msglog "---------------------------------"

#-----------------------------------#
# Archivage
#-----------------------------------#

# Déplacement dans /$rep/$serveur/$rep/arch_tmp
#                  /putty_log/knx30i01/a_archiver

# Comptage
total_fic_arch=0
for reptmp in $(find ${rep}/* -type d); do
    for fic in $(find ${reptmp} -maxdepth 1 -type f -mtime +${nb_jours_arch}); do
        total_fic_arch=$((${total_fic_arch} + 1))
    done
done

# Déplacement dans $rep/$rep_arch_tmp serveur (a_archiver)

msglog "------------------------------"
msglog "Nombre de fichier à archiver     : ${total_fic_arch}"
msglog "------------------------------"
msglog "Début Déplacement dans $rep/$rep_arch_tmp serveur (a_archiver)"
msglog "------------------------------"
for reptmp in $(find ${rep}/* -type d); do
    for fic in $(find ${reptmp} -maxdepth 1 -type f -mtime +${nb_jours_arch}); do
        nb_fic_arch=$(($nb_fic_arch + 1))
        msglog "Traitement du fichier[$nb_fic_arch/${total_fic_arch}]"
        msglog "$fic"
        nom_fic=${fic##*\/}
        msglog "nom_fic=${nom_fic}"
        serveur=${nom_fic%%.*}
        msglog "serveur=${serveur}"
        if [ ! -d ${reptmp}/${rep_arch_tmp} ] ; then
           msglog "creation du repertoire ${reptmp}/${rep_arch_tmp}"
           mkdir ${reptmp}/${rep_arch_tmp}
        fi
        msglog "mv ${rep}/${serveur}/${nom_fic} ${reptmp}/${rep_arch_tmp}/"
        mv ${rep}/${serveur}/${nom_fic} ${reptmp}/${rep_arch_tmp}/
    done
done
msglog "------------------------------"
msglog "Fin Déplacement dans $rep/$rep_arch_tmp serveur (a_archiver)"
msglog "------------------------------"

# Archivage des fichiers dans $rep/$rep_arch_tmp/serveur (a_archiver)
msglog "Début Archivage des fichiers dans $rep/$rep_arch_tmp/serveur (a_archiver --> tar)"
msglog "------------------------------"

for reptmp in $(find ${rep}/*/${rep_arch_tmp} -type d); do
    msglog "Traitement du répertoire ${reptmp}"
    repertoire=${reptmp%/*}
    msglog "repertoire=$repertoire"
    serveur=${repertoire##*/}
    msglog "serveur=${serveur}"
    if [ -f ${repertoire}/${serveur}.tar.gz ] ; then
       msglog "l'archive existe: décompression"
       msglog "gunzip ${repertoire}/${serveur}.tar.gz"
       gunzip ${repertoire}/${serveur}.tar.gz
    fi
    for fic in $(find ${reptmp} -type f); do
        msglog "--- Traitement du fichier $fic"
        msglog "Ajout du fichier à l'archive"
        msglog "tar rvf ${repertoire}/${serveur}.tar ${fic}"
        tar rvf ${repertoire}/${serveur}.tar ${fic}
        msglog "Suppression du fichier ${fic}"
        msglog "rm -f ${fic}"
        rm -f ${fic}
    done
    msglog "Suppression du répertoire ${reptmp}"
    msglog "rm -rf ${reptmp}"
    rm -rf ${reptmp}
    msglog "Compression de l'archive"
    msglog "gzip ${repertoire}/${serveur}.tar"
    gzip ${repertoire}/${serveur}.tar
done

msglog "---------------------------------"
msglog "$nb_fic_depl fichier(s) déplacés"
msglog "$nb_fic_arch fichier(s) archivés"
msglog "---------------------------------"
msglog "Heure Début: ${Heure_Debut}"
msglog "Heure Fin  : $(date)"