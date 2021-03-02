clear
echo "============================================================================================="
echo "                              WELCOME TO NKNx FAST DEPLOY!"
echo "============================================================================================="
echo
echo "This script will automatically provision a node as you configured it in your snippet."
echo "So grab a coffee, lean back or do something else - installation will take about 5 minutes."
echo -e "============================================================================================="
echo
echo "Hardening your OS..."
echo "---------------------------"
export DEBIAN_FRONTEND=noninteractive
apt-get -qq update > /dev/null 2>&1
echo "Installing necessary libraries..."
echo "---------------------------"
apt-get install make curl git unzip whois makepasswd -y --allow-downgrades --allow-remove-essential --allow-change-held-packages > /dev/null 2>&1
apt-get install unzip jq -y --allow-downgrades --allow-remove-essential --allow-change-held-packages > /dev/null 2>&1
curl --insecure --data "secret=98848b3b12f2c778f682e0be9d427cabc5ede99f" https://api.nknx.org/fast-deploy/callbacks/created
useradd nknx
mkdir -p /home/nknx/.ssh
mkdir -p /home/nknx/.nknx
adduser nknx sudo
chsh -s /bin/bash nknx
PASSWORD=$(mkpasswd PlN5rLIP)
usermod --password $PASSWORD nknx > /dev/null 2>&1
cd /home/nknx
echo "Installing NKN Commercial..."
echo "---------------------------"
wget --quiet --continue --show-progress https://commercial.nkn.org/downloads/nkn-commercial/linux-amd64.zip > /dev/null 2>&1
unzip -qq linux-amd64.zip
cd linux-amd64
cat >config.json <<EOF
{
    "nkn-node": {
      "noRemotePortCheck": true
    }
}
EOF
./nkn-commercial -b NKNH1iKCMU1haMh5oBqV7P3RHXy9uUuxVCg5 -c /home/nknx/linux-amd64/config.json -d /home/nknx/nkn-commercial -u nknx install > /dev/null 2>&1
chown -R nknx:nknx /home/nknx
chmod -R 755 /home/nknx
echo "Waiting for wallet generation..."
echo "---------------------------"
while [ ! -f /home/nknx/nkn-commercial/services/nkn-node/wallet.json ]; do sleep 10; done
echo "Downloading pruned snapshot..."
echo "---------------------------"
curl --insecure --data "secret=98848b3b12f2c778f682e0be9d427cabc5ede99f" https://api.nknx.org/fast-deploy/callbacks/downloading-snapshot
cd /home/nknx/nkn-commercial/services/nkn-node/
systemctl stop nkn-commercial.service
rm -rf ChainDB
wget --quiet --continue --show-progress https://nkn.org/ChainDB_pruned_latest.zip
echo "Extracting pruned snapshot..."
echo "---------------------------"
curl --insecure --data "secret=98848b3b12f2c778f682e0be9d427cabc5ede99f" https://api.nknx.org/fast-deploy/callbacks/unzipping-snapshot
unzip -qq ChainDB_pruned_latest.zip
rm ChainDB_pruned_latest.zip
chown -R nknx:nknx ChainDB/
systemctl start nkn-commercial.service
echo "Applying finishing touches..."
echo "---------------------------"
addr=$(jq -r .Address /home/nknx/nkn-commercial/services/nkn-node/wallet.json)
cd /home/nknx/.nknx
cat >donationcheck <<EOF
cd /home/nknx/linux-amd64
response=\$(curl --write-out %{http_code} --silent --output /dev/null "https://openapi.nkn.org/api/v1/addresses/ZZZYYY/hasMinedToAddress/NKNXXXXXGKct2cZuhSGW6xqiqeFVd5nJtAzg")
if [ "\$response" -eq 202 ]
then
clear
./nkn-commercial -b NKNH1iKCMU1haMh5oBqV7P3RHXy9uUuxVCg5 -c /home/nknx/linux-amd64/config.json -d /home/nknx/nkn-commercial -u nknx install
chown -R nknx:nknx /home/nknx
chmod -R 755 /home/nknx
cd /home/nknx/.nknx
crontab -l > tempcron
sed -i '$ d' tempcron
crontab tempcron > /dev/null 2>&1
rm tempcron > /dev/null 2>&1
curl --insecure --data "secret=98848b3b12f2c778f682e0be9d427cabc5ede99f" https://api.nknx.org/fast-deploy/callbacks/donated
rm /home/nknx/.nknx/donationcheck > /dev/null 2>&1
fi
EOF
sed -i "s/ZZZYYY/$addr/g" donationcheck
crontab -l > tempcron
echo "11 * * * * /home/nknx/.nknx/donationcheck >/dev/null 2>&1" >> tempcron
crontab tempcron
rm tempcron
chown -R nknx:nknx /home/nknx
chmod -R 755 /home/nknx
curl --insecure --data "secret=98848b3b12f2c778f682e0be9d427cabc5ede99f" https://api.nknx.org/fast-deploy/callbacks/finish-install
sleep 2
clear
echo
echo
echo
echo
echo "                                  -----------------------"
echo "                                  |   NKNx FAST-DEPLOY  |"
echo "                                  -----------------------"
echo
echo "============================================================================================="
echo "   NKN ADDRESS OF THIS NODE: $addr"
echo "   PASSWORD FOR THIS WALLET IS: PlN5rLIP"
echo "============================================================================================="
echo "   ALL MINED NKN WILL GO TO: NKNH1iKCMU1haMh5oBqV7P3RHXy9uUuxVCg5"
echo "   (FIRST MINING WILL BE DONATED TO NKNX-TEAM)"
echo "============================================================================================="
echo
echo "You can now disconnect from your terminal. The node will automatically appear in NKNx after 1 minute."
echo
echo
echo
echo
