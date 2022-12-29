#!/usr/bin/sh

urls=""  # add more URLs with 'space' separation here

for url in $urls; do
   echo "fetching $url"
   curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd \
       --mail-from 'your@mail.com' --mail-rcpt $url \
       --upload-file mail.txt --user 'your@mail.com:password' --insecure
done
wait #Don't remove wait
