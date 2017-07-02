
#DOCKER BLUE/GREEN ENVIRONMENT

## RUN vagrant server 

    cd /path-to-project/dockerserver
    vagrant up
    ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@10.0.0.210 
    
## Add host

    10.0.0.200 dockerserver

## Commands

- Go to project

      /path-to-project/symfony

- Build docker images

      ./docker.sh build-images
      
- Install packages

      ./docker.sh install

- Run local environment

      ./docker.sh run
      
- Create package to deploy
     
      ./docker.sh run

- Deploy to server 

      ansible-playbook -i deploy/hosts/vagrant deploy/deploy.yml

- Url
    http://dockerserver