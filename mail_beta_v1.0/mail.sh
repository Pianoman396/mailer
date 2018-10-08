#!/usr/bin/sh

urls="webprojecthr@gmail.com career@mgplab.com hr@softcode.am talents@codics.am hr@smart-corner.org zoom@zoom.am hr@codecraft.am hr@velvet.am cretrixllc@gmail.com hr@erasofts.com job@beeoncode.com surveytimehr@gmail.com hr.softler@gmail.com info@novembit.com info@ayotech.am info@beewebsystems.com jobs@sflpro.com hr@lanar.am info@reload.am"  # add more URLs here

for url in $urls; do
   echo "fetching $url"
   curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd \
       --mail-from 'your@mail.com' --mail-rcpt $url \
       --upload-file mail.txt --user 'your@mail.com:password' --insecure
done
wait #Don't remove wait
