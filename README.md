Demo_Ansible_Terraform
Installation
- Install Ansible
    python3 -m pip install --user ansible

- Install Terraform
    sudo apt install terraform
Configuration
- Create a GCP project
    Navigation menu > Project selector > New project

- Create a service account
    Navigation menu > IAM & Admin > Service accounts > Create a service account

- Generate credentials 
    Click on the created service account > Keys > Add key > Create a new key > JSON
    Save the JSON file, rename it credentials.json and move it at the root of your project

- Create a key pair 
    Open a terminal and execute : ssh-keygen -t ed25519 -f ~/.ssh/ansible_ed25519 -C ansible
    Copy and upload the public key to the service account (Compute Engine > Metadata > SSH keys > Add SSH key > paste the public key)

- Download the project zip archive on the link : https://github.com/mounacqflo/Demo_Ansible_Terraform
    Change the second line of the main.tf file with your own GCP project ID
Launch
- terraform init
- terraform plan
- terraform apply

- wait the VM creation end

- Access nginx on your browser with the output ip address 
    nginx_ip = "xx.xxx.xxx.xxx"

- Connect to the created VM instance and type the following commands to display the data put in database.sql that we finally stored in the database
    sudo mysql -u root -p
    enter the password: password
    show databases;
    use testdb;
    select * from test;

- terraform destroy (at the end to destroy the generated VM)
Contributors
Matthieu Cabrera, cabreramat@cy-tech.fr
Aurélien Carmes, carmesaure@cy-tech.fr
Florian Mounacq, mounacqflo@cy-tech.fr
Titouan Riot, riottitoua@cy-tech.fr