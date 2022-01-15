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
