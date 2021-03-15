#!/bin/bash

echo "---------------------------------------------------------------------------------------------------------"
dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "$dt"
echo "---------------------------------------------------------------------------------------------------------"

# appel des commandes bc (calculatrice) et dig (requete dns) 
command -v bc > /dev/null || { echo "package bc non trouvé"; exit 1; }
{ command -v drill > /dev/null && dig=drill; } || { command -v dig > /dev/null && dig=dig; } || { echo "package dig non trouvé"; exit 1; }

# liste de dns
dns="
1.1.1.1#cloudflare 
4.2.2.1#level3 
8.8.8.8#google 
9.9.9.9#quad9 
208.67.222.123#opendns 
199.85.126.20#norton 
185.228.168.168#cleanbrowsing 
77.88.8.7#yandex 
176.103.130.132#adguard 
156.154.70.3#neustar 
8.26.56.26#comodo
76.76.19.19#alternatedns
94.140.14.14#adguarddns
"

# noms de domaines à tester
domains="google.fr amazon.com facebook.com youtube.com wikipedia.fr twitter.com gmail.com insa-lyon.fr twitch.fr netflix.com"


totaldomains=0
printf "%-18s" ""
for d in $domains; do
    totaldomains=$((totaldomains + 1))
    #printf "%-8s" "test$totaldomains"
    printf "%-13s" "$d"
done
printf "%-8s" "Average"
echo ""



for p in $dns; do
    # on découpe la chaine $dns pour récupérer chaque adresse IP et nom associé
    adresse=${p%%#*}
    nom=${p##*#}
    ftime=0

    printf "%-18s" "$nom"
    for d in $domains; do
        # requete dns
        ttime=`$dig +tries=1 +time=2 +stats @$adresse $d |grep "Query time:" | cut -d : -f 2- | cut -d " " -f 2`
        if [ -z "$ttime" ]; then
                # temps réponse max
                ttime=2000
        elif [ "x$ttime" = "x0" ]; then
                # temps réponse min
                ttime=1
        fi

        printf "%-13s" "$ttime ms"
        ftime=$((ftime + ttime))
    done

    # calcul de la moyenne
    avg=`bc -lq <<< "scale=2; $ftime/$totaldomains"`
    echo "  $avg"
done

exit 0;
