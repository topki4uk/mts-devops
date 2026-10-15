terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.0"
    }
  }
}

provider "docker" {
}

# Create Network
resource "docker_network" "nginx_network" {
  name   = "nginx-custom-network"
  driver = "bridge"
}

# 2. Create volume
resource "docker_volume" "nginx_volume" {
  name = "nginx-shared-volume"
}

# 3. Upload Nginx image
resource "docker_image" "nginx_image" {
  name         = "nginx:latest"
  keep_locally = true
}

# 4. Run Nginx
resource "docker_container" "nginx_container" {
  name  = "nginx-terraform"
  image = docker_image.nginx_image.image_id

  networks_advanced {
    name = docker_network.nginx_network.name
  }

  volumes {
    volume_name    = docker_volume.nginx_volume.name
    container_path = "/usr/share/nginx/html"
  }

  ports {
    internal = 80
    external = 8080
  }
}

output "nginx_url" {
  value       = "http://localhost:8080"
  description = "URL для проверки работоспособности Nginx"
}