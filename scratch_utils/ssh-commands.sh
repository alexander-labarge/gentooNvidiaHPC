ssh-keygen -t rsa -b 4096 -C "alex@labarge.dev"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
