# Create the key files from the environment variables.
echo "${AUTH_SECRET_KEY}" > ${HOME}/config/auth_key.pem
chmod 644 ${HOME}/config/auth_key.pem