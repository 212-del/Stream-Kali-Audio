#/bin/bash
echo "Are Your Phone and PC Are connected to same Wi-Fi[y/n]: "
read -r choice
if [ "$choice" == "y" ]; then
 sudo apt install pipewire ffmpeg pipewire-audio-client-libraries wireplumber  pulseaudio-utils iproute2 net-tools gstreamer1.0-tools \
                 gstreamer1.0-plugins-good \
                 gstreamer1.0-plugins-base
else
 echo "Please Connect Both Devices to the same Wi-Fi"                 
fi
read -r -p "Enter the IP of Phone: " Phone-IP
read -r -p "Enter the IP of PC: " PC-IP
sleep 1
echo "Kindly allow RTP port 5004 to stream PC Audio"
sudo ufw allow 5004
echo "Allowing RTP port 5004 to stream PC Audio"
sleep 1
source=$(pactl list short sources)
sleep 1
echo "Creating a file audio.sdp on Desktop.(You can see too)"
cat <<EOL > /home/$(whoami)/Desktop/audio.sdp
v=0
o=- 0 0 IN IP4 ${PHONE-IP}
s=FFmpeg Opus RTP
c=IN IP4 ${PHONE-IP}
t=0 0
m=audio 500 RTP/AVP 96
a=rtpmap:96 opus/48000/2
EOL
echo "Kindly allow server port 8000 to serve the file audio.sdp to phone."
sudo ufw allow 8000
python3  -m http.server 8000 --directory /home/$(whoami)/Desktop
echo -e "\nDownload the audio.sdp from the link below\nSave This file at memorable place"
echo "http://${PC-IP:8000/audio.sdp}"
read -r -p "Have you downloaded the file audio.sdp.[y/n]" download

until false
do
if [[ "${download}" == "y" ]]; then
 ffmpeg -f pulse \
 -i ${source} \
 -acodec libopus -ac 2 -ar 44100 \
 -f rtp -payload_type 96 \
 -flags low_delay \
 rtp://PHONE-IP:5004 </dev/null
 echo "To play the audio open the audio.sdp file via the vlc's browse option in the centre of bottom menu"
else
 echo "Kindly download the file audio.sdp to stream audio"
fi
done
