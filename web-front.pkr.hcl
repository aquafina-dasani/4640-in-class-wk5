# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer
packer {
  required_plugins {
    amazon = {
      version = ">= 1.5"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "debian" {
  ami_name      = "web-nginx-aws"
  instance_type = "t3.micro"
  region        = "us-west-1"
  source_ami_filter {
    filters = {
      name                = "debian-*-amd64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["136693071363"]
  }
  ssh_username = "admin"
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build
build {
  name = "web-nginx"
  sources = [
    # COMPLETE ME Use the source defined above
    "source.amazon-ebs.debian"
  ]
  
  # https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/provisioner
  provisioner "shell" {
    inline = [
      "echo creating directories",
      # COMPLETE ME add inline scripts to create necessary directories and change directory ownership.
      # See nginx.conf file for root directory where files will be served.
      # Files need appropriate ownership for default user
      "sudo mkdir -p /web/html",
      "sudo mkdir -p /tmp/web/",
      "sudo mkdir -p /home/admin/scripts",
      "sudo chown -R admin:admin /tmp/web/",
      "sudo chown -R admin:admin /home/admin/scripts",
      "sudo chown -R admin:admin /web/html",
    ]
  }

  provisioner "file" {
    # COMPLETE ME add the HTML file to your image
    source = "files/index.html"
    destination = "/web/html/index.html"
  }

  provisioner "file" {
    # COMPLETE ME add the nginx.conf file to your image
    source = "files/nginx.conf"
    
    # !!! find place for nginx.conf plsss bc nginx does not exist"
    destination = "/tmp/web/nginx.conf" 
  }

  # COMPLETE ME add additional provisioners to run shell scripts and complete any other tasks  
  # run the scripts
  provisioner "shell" {
    script = "scripts/install-nginx"
    pause_before = "10s"
    timeout = "10s"
  }


  provisioner "shell" {
    script = "scripts/setup-nginx"
    pause_before = "10s"
    timeout = "10s"
  }
}

