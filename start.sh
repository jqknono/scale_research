chown 1000:1000 key.txt

# get the default gateway ip
default_gw=$(ip route | grep default | awk '{print $3}')
# change the last number of the ip address to 0
default_gw=$(echo $default_gw | awk -F. '{print $1"."$2"."$3".0"}')
# get the ip address of the default gateway
default_ip=$(ip route | grep $default_gw | awk '{print $9}')
# replace the line "<code class="url">.*</code>" with the new default_ip
sed -i "s/<code class=\"url\">.*<\/code>/<code class=\"url\">http:\/\/$default_ip:8080<\/code>/" html/index.html

# replace all "tailscale up --login-server http://10.106.107.31" with http://$default_ip
sed -i "s/tailscale up --login-server http:\/\/[^ ]*/tailscale up --login-server http:\/\/$default_ip:8080/ " ./html/index.html

# replace "server_url: .*" with "server_url: http://$default_ip"
sed -i "s/server_url: .*/server_url: http:\/\/$default_ip/" ./config.yaml

# replace "proxy_pass http://.*:" with "proxy_pass http://$default_ip:"
sed -i "s/proxy_pass http:\/\/.*:/proxy_pass http:\/\/$default_ip:/" ./nginx.conf

# replace "- HS_SERVER=.*" with "- HS_SERVER=http://$default_ip"
sed -i "s/- HS_SERVER=.*/- HS_SERVER=http:\/\/$default_ip:8080/" ./docker-compose.yaml

docker-compose up -d

# wait for the headscale to start
sleep 3

result=$(docker exec headscale headscale apikeys create --expiration 120d)
# docker exec headscale headscale apikeys list

# get the last line
api_key=$(echo $result | awk 'END {print $NF}')
# replace the line "<code class="apikey">.*</code>" with the new api_key
sed -i "s/<code class=\"apikey\">.*<\/code>/<code class=\"apikey\">$api_key<\/code>/" html/index.html

# create a new user
docker exec headscale headscale users create myfirstuser

# create preauthkey
result=$(docker exec headscale headscale --user myfirstuser preauthkeys create --expiration 120d --reusable --tags "tag:t1,tag:t2")

# get the last line
preauth_key=$(echo $result | awk 'END {print $NF}')

# replace "--authkey .*" with "--authkey $preauth_key"
sed -i "s/--authkey .*/--authkey $preauth_key/" html/index.html
