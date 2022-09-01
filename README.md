# purge_putty_logs
------
SCRIPT : purge_putty_logs.sh
---
    Fonction                 : Traitement des logs de PuTTY </br>
    Auteur                   : Marc MORALES
    Parametres d'entree      : Aucun
    Parametres de sortie     : Aucun
    Retour                   : 0 ACTIF, 1 INACTIF
    Scripts appeles          : Aucun
    Commentaires :
    - Déplacement dans un répertoire contenant le nom du serveur des logs de plus de ${nb_jours_dep} jour(s)
    - Archivage des logs de plus de ${nb_jours_arch} jour(s)
