echo $0: Creating key files

# Create the public and private key files from the environment variables.
mkdir -p ${HOME}/.ssh
echo "${AUTH_SECRET_KEY}" > ${HOME}/.ssh/auth_key.pem
chmod 644 ${HOME}/.ssh/auth_key.pem

echo $0: Finished creating key files