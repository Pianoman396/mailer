#!/usr/bin/sh

rtmp_url="smtp://smtp.gmail.com:587"
rtmp_from="yourmail@gmail.com"
rtmp_to="somemail@some.ru"
rtmp_credentials="yourmail@gmail.com:yourpassword"

file_upload="new_mail.txt"

# html message to send
echo "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml'>
 <head>
  <meta http-equiv='Content-Type' content='text/html; charset=UTF-8' />
  <title>Demystifying Email Design</title>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'/>
</head>
<body>
</style>
    <div style='width:50%; padding:2%; background:blueviolet; color:snow; margin:2px;'>
        <p style='font-size:22px;'>Hello</p>
        <p>Please see the log file attached</p>
        <p>Admin Team</p>
        <img src=\"cid:admin.jpg\" width=\"150\" height=\"50\">
    </div>
</body>
</html>" > message.html

# log.txt file to attached to the mail
echo "some log in a txt file to attach to the mail" > log.txt

mail_from="Some Name <$rtmp_from>"
mail_to="Some Name <$rtmp_to>"
mail_subject="example of mail"
mail_reply_to="Some Name <$rtmp_from>"
mail_cc=""

# add an image to data.txt :
# $1 : type (ex : image/png)
# $2 : image content id filename (match the cid:filename.png in html document)
# $3 : image content base64 encoded
# $4 : filename for the attached file if content id filename empty
function add_file {
    echo "--MULTIPART-MIXED-BOUNDARY
Content-Type: $1
Content-Disposition: attachment; filename=$5
Content-Transfer-Encoding: base64

 $2 "  >> "$file_upload"

    if [ ! -z "$3" ]; then
        echo "Content-Disposition: inline
              Content-Id: <$3>" >> "$file_upload"
    else
        echo "Content-Disposition: attachment; filename=$5" >> "$file_upload"
    fi
    echo "$4

" >> "$file_upload"
}

message_base64=$(cat message.html | base64)
pdf_file=$(cat CV.pdf | base64)


echo "From: $mail_from
To: $mail_to
Subject: $mail_subject
Reply-To: $mail_reply_to
Cc: $mail_cc
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=\"MULTIPART-MIXED-BOUNDARY\"

--MULTIPART-MIXED-BOUNDARY
Content-Type: multipart/alternative; boundary=\"MULTIPART-ALTERNATIVE-BOUNDARY\"

--MULTIPART-ALTERNATIVE-BOUNDARY
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: base64
Content-Disposition: inline

$message_base64
--MULTIPART-ALTERNATIVE-BOUNDARY--" > "$file_upload"

# add an image with corresponding content-id (here admin.png)
image_base64=$(curl -s "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_116x41dp.png" | base64)
# add_file "image/jpg" "admin.jpg" "$image_base64"
add_file "application/pdf" "$pdf_file" "CV.pdf" "CV.pdf" "CV.pdf"

# add the log file
log_file=$(cat log.txt | base64)
# with log file -- add_file "text/plain" "" "$log_file" "log.txt"

# add another image
#image_base64=$(curl -s "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_116x41dp.png" | base64)
#add_file "image/png" "something.png" "$image_base64"

# end of uploaded file
echo "--MULTIPART-MIXED-BOUNDARY--" >> "$file_upload"

# send email
echo "sending ...."
for url in $rtmp_to;do

    echo "fetching $url"
    curl -s "$rtmp_url" --ssl-reqd\
         --mail-from "$rtmp_from" \
         --mail-rcpt "$url" \
         --ssl -u "$rtmp_credentials" \
         -T "$file_upload" -k --anyauth
    res=$?
    if test "$res" != "0"; then
        echo "sending failed with: $res"
    else
        echo "OK"
    fi
done
wait
