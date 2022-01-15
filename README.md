<h1 align="center">DevOps School test task</h1>
<p align = "center">
<img src = "https://img.shields.io/github/workflow/status/maaaaaarkova/devtask/Docker%20Image%20CI">
</p>

<h2 align="center"><a href="http://devopstask.pp.ua/">LINK TO THE SITE</a></h2>
<p align = "center">
  <br>
  <img src = "https://media.giphy.com/media/ijgei9cL5vqK5uVhll/giphy.gif">
</p>
 
 <h2 align="center">Getting started</h2>
 
 Setup the Ubuntu `aws_instance` with some specific settings and values
 
 ```tf
 resource "aws_instance" "devtask" {
    ami = "ami-0d527b8c289b4af7f"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.devtask_web.id]
    key_name = "devtask"

    connection {
        type = "ssh"
        host = self.public_ip
        user = "ubuntu"
        private_key = file("devtask-key.pem")
    }
 ``` 
 <br>
 
 Using customised `aws_security_group` for our EC2 instance to control inbound and outbound traffic
 
 ```tf
 resource "aws_security_group" "devtask_web" {
    name = "allow traffic"

    ingress{
        description = "HTTPS"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

     ingress{
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

     ingress{
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}
 ```
   <br>
   <h3>Running some Linux command to setup Docker</h3>
   <p> 
      With 
      <a href="https://github.com/containrrr/watchtower">WATCHTOWER</a>
      you can update the running version of your containerized app simply by pushing a new image to the Docker Hub or your own image registry.<br>
      It will pull down your new image, gracefully shut down your existing container and restart it with the same options that were used when it was deployed initially with your       setted delay.
   </p>
   
 ```tf
 provisioner "remote-exec" {
    inline = [
        "sudo apt update",
        "sudo apt-get install curl",
        "curl -ssl https://get.docker.com/ | sh",
        "sudo docker run -d --name devopstask -p 80:80 maaaaaarkova/devopstask",
        "sudo docker run -d --name watchtower --volume /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --cleanup -i 20"
    ]
}
 ```
 
 <br>
 <h2>Github actions</h2>
 <p>
 Github actions let us build a pipeline, which runs a Lint to check the code and deploy this code to Docker with "latest" tag, so it gets auto-updated with each push to Github.
  </p>
 
```yml
on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

jobs:

  build:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2
    
    - name: Lint Dockerfile
      uses: luke142367/Docker-Lint-Action@v1.0.0
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Docker Login
      uses: docker/login-action@v1.12.0
      with:
        username: ${{ secrets.docker_username }}
        password: ${{ secrets.docker_password }}
        
    - name: Build and push
      id: docker_build
      uses: docker/build-push-action@v2
      with:
          push: true
          tags: maaaaaarkova/devopstask:latest

```
 
 <br>
 <h2>Monitoring tools (AWS CloudWatch)</h2>
 Setting monitoring tools and creating alarms on some metrics if something goes wrong.
<br><br>
<img src="https://user-images.githubusercontent.com/76499690/149620935-7a78211c-0eaa-4aea-ad8f-d6fd174f0cf3.png">
<br>
<img src = "https://user-images.githubusercontent.com/76499690/149621047-8ed32504-a5db-4280-9591-9df427c8d09a.png">

<br>
 <h2>Connecting to a DNS name</h2>
Connecting to a real DNS name using WEB service AWS route 53
<br> <br>
<img src = "https://user-images.githubusercontent.com/76499690/149621217-43d4c0ce-76f0-4635-bc36-3776fe645eaa.png">
