# create headscale server
mkdir config
mkdir data
mkdir html
mkdir run
mkdir webui
# touch ./config/db.sqlite
wget -O ./config/config.yaml https://raw.githubusercontent.com/juanfont/headscale/main/config-example.yaml

docker exec headscale headscale users list

docker exec headscale headscale apikeys create --expiration 120d
docker exec headscale headscale apikeys list

docker exec headscale headscale --user myfirstuser preauthkeys create --reusable --expiration 24h
docker exec headscale headscale --user myfirstuser preauthkeys list
