#/bin/bash
echo -n "Are Your Phone and PC Are connected to same Wi-Fi[y/n]: "
echo "Put Your Headphones or Earphones on connected to phone."
#Add a section to make sure is devices involved in this processes are able to talk to each other.
read -r choice
if [ "$choice" == "y" ]; then
 sudo apt install pipewire ffmpeg pipewire-audio-client-libraries wireplumber  pulseaudio-utils iproute2 net-tools gstreamer1.0-tools \
                 gstreamer1.0-plugins-good \
                 gstreamer1.0-plugins-base
else
 echo "Please Connect Both Devices to the same Wi-Fi"                 
fi
read -r -p "Enter the IP of Phone: " Phone_IP
read -r -p "Enter the IP of PC: " PC_IP
sleep 1
echo "Kindly allow RTP port 5004 to stream PC Audio"
sudo ufw allow 5004
echo "Allowing RTP port 5004 to stream PC Audio"
sleep 1
source=$(pactl list short sources | awk 'NR==1 {print $2}')
sleep 1
echo "Creating a file audio.sdp on Desktop.(You can see too)"
cat <<EOL > /home/$(whoami)/Desktop/audio.sdp
v=0
o=- 0 0 IN IP4 ${Phone_IP}
s=FFmpeg Opus RTP
c=IN IP4 ${Phone_IP}
t=0 0
m=audio 500 RTP/AVP 96
a=rtpmap:96 opus/48000/2
EOL
echo "Kindly allow server port 8000 to serve the file audio.sdp to phone."
sudo ufw allow 8000

echo -e "\nDownload the audio.sdp from the link below in the phone and Save This file at memorable place"
echo -e "\e[94;4;82m http://${PC_IP}:8000/audio.sdp \e[0m"
echo "Kindly press CTRL+C after downloading the file."
python3  -m http.server 8000 --directory /home/$(whoami)/Desktop

read -r -p "Have you downloaded the file audio.sdp.[y/n]: " download
until false
until [[ "${download}" == "y"  ]]; do
read -r -p "Have you downloaded the file audio.sdp.[y/n]: " download
done

if [[ "${download}" == "y" ]]; then
 ffmpeg -f pulse \
 -i ${source} \
 -acodec libopus -ac 2 -ar 48000 \
 -application lowdelay \
 -frame_duration 2.5 \
 -b:a 200k \
 -flush_packets 1 \
 -max_delay 0 \
 -f rtp -payload_type 96 \
 -flags low_delay \
 rtp://${Phone_IP}:5004 </dev/null
 echo "Streaming started. Open audio.sdp in VLC."
else
 echo "Kindly download the file audio.sdp to stream audio"
fi
