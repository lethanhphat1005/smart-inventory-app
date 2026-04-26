docker --version

# bỏ CRLF từ windows để thực thi scripts
sed -i 's/\r$//' /opt/sis/env/docker-hub.env
sed -i 's/\r$//' /opt/sis/env/backend.env
sed -i 's/\r$//' /opt/sis/stacks/docker-stack.yml
sed -i 's/\r$//' /opt/sis/nginx/default.conf
sed -i 's/\r$//' /opt/sis/scripts/deploy.sh
sed -i 's/\r$//' /opt/sis/secrets/serviceAccountKey.json

docker secret create firebase_service_account \
  /opt/sis/secrets/serviceAccountKey.json

chmod 755 /opt/sis/scripts/deploy.sh
