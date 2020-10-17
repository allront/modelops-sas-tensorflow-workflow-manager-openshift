export PATH=$PATH:/home/ec2-user/minishift-1.34.2-linux-amd64/
minishift status
minishift start --remote-ipaddress 10.249.20.186 --remote-ssh-user root --remote-ssh-key /home/ec2-user/.ssh/id_rsa
oc status
minishift oc-env
export PATH="/home/ec2-user/.minishift/cache/oc/v3.11.0/linux:$PATH"
eval $(minishift oc-env)
export PROJECT_DIR=/opt/demos/modelops

