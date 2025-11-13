#!/bin/bash
set -euxo pipefail

# Vars from templatefile:
# ${MONGO_ADMIN_USER} ${MONGO_ADMIN_PASS} ${MONGO_DB_NAME} ${BACKUP_BUCKET} ${BACKUP_CRON}

export DEBIAN_FRONTEND=noninteractive

# Basic deps
apt-get update -y
apt-get install -y gnupg curl ca-certificates lsb-release unzip

# MongoDB 6.0 for Ubuntu 22.04 (jammy)
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-6.gpg
echo "deb [signed-by=/usr/share/keyrings/mongodb-server-6.gpg] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" \
  > /etc/apt/sources.list.d/mongodb-org-6.0.list
apt-get update -y
apt-get install -y mongodb-org

systemctl enable mongod
systemctl start mongod

# Bind to all (SG restricts network)
sed -i 's/^  bindIp: .*/  bindIp: 0.0.0.0/' /etc/mongod.conf
systemctl restart mongod
sleep 5

# Create admin user
cat >/tmp/init-admin.js <<'JS'
db = db.getSiblingDB("admin");
db.createUser({
  user: "${MONGO_ADMIN_USER}",
  pwd: "${MONGO_ADMIN_PASS}",
  roles: [ { role: "root", db: "admin" } ]
});
JS
mongosh --quiet < /tmp/init-admin.js || true

# Enforce auth
if ! grep -q "^security:" /etc/mongod.conf; then
  printf "\nsecurity:\n  authorization: enabled\n" >> /etc/mongod.conf
else
  sed -i 's/^security:.*$/security:\n  authorization: enabled/' /etc/mongod.conf
fi
systemctl restart mongod

# Install AWS CLI v2 (for S3 backups)
tmpd=$(mktemp -d)
cd "$tmpd"
curl -fsSLo awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
unzip awscliv2.zip >/dev/null
./aws/install
cd /
rm -rf "$tmpd"

# Daily mongodump → S3 (public bucket)
# Daily mongodump → S3 (public bucket)
cat >/usr/local/bin/mongo_backup.sh <<'BASH'
#!/bin/bash
set -euo pipefail
TS=$(date +%F_%H-%M-%S)
# Dump with auth enforced
mongodump --authenticationDatabase admin \
  -u "${MONGO_ADMIN_USER}" -p "${MONGO_ADMIN_PASS}" \
  --db "${MONGO_DB_NAME}" --archive --gzip \
  | aws s3 cp - "s3://${BACKUP_BUCKET}/$${TS}.archive.gz" --only-show-errors
BASH
chmod +x /usr/local/bin/mongo_backup.sh

# Export env for backup script
cat >/etc/default/mongo_backup_env <<ENV
MONGO_ADMIN_USER="${MONGO_ADMIN_USER}"
MONGO_ADMIN_PASS="${MONGO_ADMIN_PASS}"
MONGO_DB_NAME="${MONGO_DB_NAME}"
BACKUP_BUCKET="${BACKUP_BUCKET}"
ENV

# Cron job (uses envfile)
cat >/etc/cron.d/mongo_backup <<CRON
SHELL=/bin/bash
${BACKUP_CRON} root source /etc/default/mongo_backup_env && /usr/local/bin/mongo_backup.sh >> /var/log/mongo_backup.log 2>&1
CRON

echo "MongoDB ready with daily S3 backups."
