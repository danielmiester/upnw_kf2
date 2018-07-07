#!/bin/bash
TIMEOUT=5
echo -n Sleeping for $TIMEOUT seconds...
for ((i=$TIMEOUT;--i>=0;)); do sleep 1; echo -n " $i"; done
cd $HOME

echo ENVIRONMENT VARIABLES:==============================
set
echo ====================================================

WS_ITEMS=`echo "$WORKSHOP_ITEMS" | xargs -n1 -d "," -I{} echo "ServerSubscribedWorkshopItems={}"`
export ADMIN_PASSWORD=`cat /proc/sys/kernel/random/uuid`
echo "Running $0"


#disable takeover
ENGINE=$(cat <<HEREDOC
$ENGINE

[Engine.GameEngine]
bUsedForTakeover=${bUsedForTakeover:=FALSE}
HEREDOC
)

#enable workshop items
ENGINE=$(cat <<HEREDOC
$ENGINE

[OnlineSubsystemSteamworks.KFWorkshopSteamworks]
$WS_ITEMS
HEREDOC
)


#Set server name and admin contact
GAME=$(cat <<HEREDOC
$GAME

[Engine.GameReplicationInfo]
ServerName=${SERVER_NAME:=UPNW}
AdminContact=${ADMIN_CONTACT:=Nonaya Bidniss}
HEREDOC
)

#Set server passwords
GAME=$(cat <<HEREDOC
$GAME

[Engine.AccessControl]
AdminPassword=$ADMIN_PASSWORD
GamePassword=$GAME_PASSWORD
HEREDOC
)

cp ${ENGINE_INI}.bak $ENGINE_INI
cp ${GAME_INI}.bak $GAME_INI

echo "Engine:$ENGINE"
echo "Game:$GAME"

echo "$ENGINE" >> $ENGINE_INI
echo "$GAME" >> $GAME_INI

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
${MODIFIED_STARTUP}
