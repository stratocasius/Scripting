POWERSHELL
 
# Install Node.js

winget install -e --id OpenJS.NodeJS.LTS
 
# Close terminal and re-open
 
# Validate

node -v

npm -v
 
# If SSL decryption is happening, put root and intermediate certs in a file and update npm config to use it

npm config set cafile "C:\Local\jl-chain.crt"
 
# Install Codex

npm i -g @openai/codex
 
# Validate

codex --version
 
# 1st time use and login

codex
 
UBUNTU LINUX (For WSL)
 
# Update packages, install pre-req's

sudo apt update

sudo apt install -y curl
 
# Install Node.js

curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -

sudo apt install -y nodejs
 
# If SSL decryption is happening, put root and intermediate certs in a file and update Ubuntu OS to use it

touch /usr/local/share/ca-certificates/jl-chain.crt

nano /usr/local/share/ca-certificates/jl-chain.crt

sudo update-ca-certificates --fresh
 
# If SSL decryption is happening, put root and intermediate certs in a file and update npm config to use it

npm config set cafile "/usr/local/share/ca-certificates/jl-chain.crt"
 
# Install Codex

npm i -g @openai/codex
 
# Validate

codex --version
 
# 1st time use and login

codex
 