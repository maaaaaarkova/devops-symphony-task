provider "aws" {
    region = "eu-central-1"
    access_key = "AKIAYMYPYOANUQSF7CLK"
    secret_key = "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"
}

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

provisioner "remote-exec" {
    inline = [
        "sudo apt update",
        "sudo apt-get install curl",
        "curl -ssl https://get.docker.com/ | sh",
        "sudo docker run -d --name devopstask -p 80:80 maaaaaarkova/devopstask",
        "sudo docker run -d --name watchtower --volume /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --cleanup -i 20"
    ]
}
}

resource "aws_eip" "lb" {
  instance = aws_instance.devtask.id
  vpc      = true
}
