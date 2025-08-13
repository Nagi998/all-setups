# Update system and install required packages
sudo yum update -y
sudo yum install wget -y
sudo yum install java-17-amazon-corretto -y  # Correct Java package

# Create application directory and download Nexus
sudo mkdir /app && cd /app
sudo wget https://download.sonatype.com/nexus/3/nexus-3.79.1-04-linux-x86_64.tar.gz
sudo tar -xvf nexus-3.79.1-04-linux-x86_64.tar.gz
sudo mv nexus-3.79.1-04 nexus

# Create nexus user and set ownership
sudo adduser nexus
sudo chown -R nexus:nexus /app/nexus
sudo chown -R nexus:nexus /app/sonatype*

# Configure Nexus to run as nexus user
sudo sed -i 's/^#run_as_user=/run_as_user="nexus"/' /app/nexus/bin/nexus

# Create systemd service file
sudo tee /etc/systemd/system/nexus.service > /dev/null << EOL
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/app/nexus/bin/nexus start
ExecStop=/app/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOL

# Enable and start Nexus service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus
sudo systemctl status nexus

# Optional: Open firewall port if needed
# sudo firewall-cmd --add-port=8081/tcp --permanent
# sudo firewall-cmd --reload
