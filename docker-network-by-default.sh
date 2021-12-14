#!/bin/bash
#by @eberil

DOCKER_PATH=/etc/docker
#who run script?
RUN_USER=$(export | grep SUDO_USER | sed 's/declare\|-\|x\|SUDO_USER\|=\|"\| //g')
echo -e "\e[33mHello \e[0m\e[1m'$RUN_USER'!\e[0m"
echo ""

#lets go

#create file
echo -e "\e[33m Creating daemon.json ...\e[0m"

sudo cat /etc/docker/daemon.json > /dev/null 2>&1

if [ $? -eq 0 ]
then
  echo -e "\e[32m daemon.json founded. Copy backup to /etc/docker/daemon.json.backup..\e[0m"
  sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.backup
  sudo rm /etc/docker/daemon.json
  echo -e "\e[33m Please add setting from backup in to daemon.json after installation.\e[0m"
else
  echo -e "\e[33m daemon.json not found. Creating...\e[0m" >&2
fi

#
#copy settings to daemon.json
echo -e "\e[33m Create and Copy settings to daemon.json ...\e[0m"

echo -e '{\n "default-address-pools" : [\n {\n  "base" : "172.200.0.0/16",\n  "size" : 24\n  }\n ]\n }' | tee $DOCKER_PATH/daemon.json > /dev/n$
echo -e 'version: "2.4"\nservices:\n redis:\n  image: library/redis:6-alpine\n  container_name: redis' | tee $DOCKER_PATH/test.yml > /dev/null $


if [ $? -eq 0 ]
then
  echo -e "\e[32m Done.\e[0m"
else
  echo -e "\e[31m Copy failed! Abort\e[0m" >&2
  exit 1
fi

#restart docker
echo -e "\e[33m Apply settings ...\e[0m"

sudo systemctl restart docker

if [ $? -eq 0 ]
then
  echo -e "\e[32m Done.\e[0m"
else
  echo -e "\e[31m Daemon of docker can't been reload. Please, see docker logs, to fix problem\e[0m" >&2
  exit 1
fi

#healthcheck
echo -e "\e[33m Checking ip-address with redis ...\e[0m"

cd $DOCKER_PATH
sudo docker-compose -f test.yml up -d

if [ $? -eq 0 ]

then
  IP_ADDRESS=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' redis | cut -c 1-8)
  echo $IP_ADDRESS

  if [ $IP_ADDRESS == "172.200." ]

  then
     sudo docker-compose -f test.yml down && docker rmi redis:6-alpine --force
     echo -e "\e[32m All Good. Bye\e[0m"
     echo -e "\e[33m Don't forget copy data from daemon.json, if its necessary\e[0m"
     exit 0
  else
     echo -e "\e[31m IP-address not equal 172.200.*.*/24 . Removing redis\e[0m" >&2
     sudo docker-compose -f test.yml down
  exit 1

  fi

else
  echo -e "\e[31m Something wrone with redis. Try again. Remove redis..\e[0m" >&2
  sudo docker-compose -f test.yml down
  exit 1

fi
