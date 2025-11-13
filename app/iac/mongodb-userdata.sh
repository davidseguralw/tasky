#!/bin/bash
set -eux

# ======== ALTERABLE: Choose a 1+ year-old OS and Mongo version ========
# Example below shows Ubuntu 20.04 with MongoDB 5.0.x (old). Adjust for your AMI’s distro.
# If using Amazon Linux 2, replace with the right repo commands.

export DEBIAN_FRONTEND=noninteractive

if [ -f /etc/lsb-release ]; then
  # Ubuntu example
  apt-get update -y
  apt-get install -y gnupg curl awscli

  curl -fsSL https://pgp.mongodb.com/server-5.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-5.0.gpg
  echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-5.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" \
    | tee /etc/apt/sources.list.d/mongodb-org-5.0.list

  apt-get update -y
  # Pin an older patch intentionally (example 5.0.15). You can choose another old patch.
  apt-get install -y mongodb-org=5.0.15 mongodb-org-server=5.0.15 mongodb-org-shell=5.0.15 mongodb-org-mongos=5.0.15 mongodb-org-tools=5.0.15 || true
  # Hold to avoid upgrades
  apt-mark hold mongodb-org mongodb-org-server mongodb-org-shell mongodb-org-mongos mongodb-org-tools

else
  # Amazon Linux 2 example (adjust versions if you pick AL2 as your old AMI)
  yum update -y
  yum install -y awscli
  cat >/etc/yum.repos.d/mongodb-org-5.0.repo <<'EOF'
[mongodb-org-5.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-5.0.asc
EOF
  yum install -y mongodb-org-5.0.15 mongodb-org-server-5.0.15 mongodb-org-shell-5.0.15 mongodb-org-mongos-5.0.15 mongodb-org-tools-5.0.15 || true
fi

# ======== Configure MongoDB with auth ========
mkdir -p /data/db
chown -R mongodb:mongodb /data/db || true

# Enable auth in mongod.conf (paths differ by distro)
if [ -f /etc/mongod.conf ]; then
  sed -i 's/^#*security:.*$/security:\n  authorization: enabled/' /etc/mongod.conf || echo -e "security:\n  authorization: enabled" >> /etc/mongod.conf
else
  cat >/etc/mongod.conf <<'EOF'
storage:
  dbPath: /data/db
net:
  port: 27017
  bindIp: 0.0.0.0
security:
  authorization: enabled
processManagement:
  fork: false
EOF
fi

systemctl enable mongod
systemctl start mongod

# Wait for mongod to accept connections
sleep 10

# Create admin user (values templated from Terraform)
mongo --eval "db.getSiblingDB('admin').createUser({user: '${MONGO_ADMIN_USER}', pwd: '${MONGO_ADMIN_PASS}', roles:[{role:'root',db:'admin'}]})"

# Create app DB (optional)
mongo --username "${MONGO_ADMIN_USER}" --password "${MONGO_ADMIN_PASS}" --authenticationDatabase "admin" --eval "db.getSiblingDB('${MONGO_DB_NAME}').createCollection('init')"

# ======== Daily backup to S3 with public bucket (lab requirement) ========
cat >/usr/local/bin/mongo_backup.sh <<EOF
#!/bin/bash
set -eux
STAMP=\$(date +%F)
TMP="/tmp/mdb_\${STAMP}.archive"
mongodump --username "${MONGO_ADMIN_USER}" --password "${MONGO_ADMIN_PASS}" --authenticationDatabase "admin" --archive="\$TMP"
aws s3 cp "\$TMP" "s3://${S3_BUCKET}/"
rm -f "\$TMP"
EOF
chmod +x /usr/local/bin/mongo_backup.sh

# Cron at 2:00 AM daily
( crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/mongo_backup.sh" ) | crontab -
