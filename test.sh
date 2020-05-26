#! /bin/bash

sudo snap install node --classic --channel=14
sudo npm install -g serve
echo "<head></head>/n<body>Welcome to Terraform Auto Provisioning</body>" > /home/ubuntu/index.html
