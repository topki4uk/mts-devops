# DevOps Homework №1

## Описание

Базовая инфраструктура: `terraform` + `ansible` + `docker-compose` + `bash`-мониторинг.

## Структура проекта

```sh
├── ansible                 # Файлы Ansible
│   ├── inventory.ini
│   └── setup_host.yml
├── compose                 # Docker файлы
│   └── docker-compose.yml
├── README.md               # Файл с инструкцией
├── scripts                 # Скрипт мониторинга
│   └── monitor.sh
└── terraform               # Terraform файлы
    └── main.tf
```

## Требования

- Terraform >= 1.x
- Ansible >= 2.x
- Docker, Docker Compose
- SSH-ключ

## Установка и запуск

### Установка Terraform

Я проводил установку terraform на ubuntu через скачивание пакета с офф сайта (использовал сервис на три буквы) -> `terraform_1.16.5_linux_amd64.zip`

Распаковываем архив в дирректорию `/usr/local/bin`:
```bash
sudo unzip terraform_1.16.5_linux_arm64.zip -d /usr/local/bin
```

### Установка Ansible

```bash
sudo apt update && sudo apt install ansible-core
```

### Запуск автоматизации Ansible

```bash
cd ansible
ansible-playbook -i inventory.ini setup_host.yml
```

### Запуск автоматизации Terraform

```bash
# Подготавливаем директорию к работе с terraform
cd terraform
terraform init
```

```bash
# Запускаем сборку контейнера с Nginx
terraform plan
terraform apply
```

### Права для `monitor.sh`

```bash
sudo chmod +x monitor.sh
```

## Доказательства работы

### Terraform

```bash
alex@mipt:~/mts-devops/terraform$ terraform state list
docker_container.nginx_container
docker_image.nginx_image
docker_network.nginx_network
docker_volume.nginx_volume
```

```bash
# Успешный запуск docker контейнера с nginx
alex@mipt:~/mts-devops/terraform$ terraform apply

docker_network.nginx_network: Creating...
docker_image.nginx_image: Creating...
docker_volume.nginx_volume: Creating...
docker_volume.nginx_volume: Creation complete after 0s [id=nginx-shared-volume]
docker_image.nginx_image: Creation complete after 0s [id=sha256:abe47724e466aeab9a345d8e46a221c2fa8953c7848bb4a3bd9976a7199f8cf2nginx:latest]
docker_network.nginx_network: Creation complete after 2s [id=34cf9658b26ed6bf9977afea2b9df1e963c769dcc7de5653604f2289630535b0]
docker_container.nginx_container: Creating...
docker_container.nginx_container: Creation complete after 1s [id=546ccb0b1e851153b4ad36d3ea9988cfe83fe103f63a1756e64729aec4aa5f45]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

nginx_url = "http://localhost:8080"
```

```bash
# Демонстрация работы curl к контейнеру с nginx
alex@mipt:~/mts-devops/terraform$ curl -i http://0.0.0.0:8080
HTTP/1.1 200 OK
Server: nginx/1.31.6
Date: Sun, 04 Oct 2026 15:34:22 GMT
Content-Type: text/html
Content-Length: 896
Last-Modified: Tue, 15 Sep 2026 12:54:15 GMT
Connection: keep-alive
ETag: "6aa93ff7-380"
Accept-Ranges: bytes

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, nginx is successfully installed and working.
Further configuration is required for the web server, reverse proxy, 
API gateway, load balancer, content cache, or other features.</p>

<p>For online documentation and support please refer to
<a href="https://nginx.org/">nginx.org</a>.<br/>
To engage with the community please visit
<a href="https://community.nginx.org/">community.nginx.org</a>.<br/>
For enterprise grade support, professional services, additional 
security features and capabilities please refer to
<a href="https://f5.com/nginx">f5.com/nginx</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

### Ansible (идемпотентность, `changed=0`)
```sh
alex@mipt:~/mts-devops/ansible$ ansible-playbook -i inventory.ini setup_host.yml 

PLAY [Базовая настройка хоста] *********************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************************
ok: [web1.mts.ru]

TASK [Создать пользователя deployer с правами sudo без пароля] *************************************************************************************************************************
ok: [web1.mts.ru]

TASK [Добавить SSH-ключ для deploy] ****************************************************************************************************************************************************
ok: [web1.mts.ru]

TASK [Установить зависимости (Debian/Ubuntu)] ******************************************************************************************************************************************
ok: [web1.mts.ru]

TASK [Создать директорию для ключей] ***************************************************************************************************************************************************
ok: [web1.mts.ru]

TASK [Добавить GPG-ключ Docker] ********************************************************************************************************************************************************
ok: [web1.mts.ru]

TASK [Добавить репозиторий Docker (Debian/Ubuntu)] *************************************************************************************************************************************
ok: [web1.mts.ru]

TASK [Установить Docker Engine и Compose (Debian/Ubuntu)] ******************************************************************************************************************************
ok: [web1.mts.ru]

TASK [Запустить и включить Docker] *****************************************************************************************************************************************************
ok: [web1.mts.ru]

TASK [Добавить deployer в группу docker] ***********************************************************************************************************************************************
ok: [web1.mts.ru]

PLAY RECAP *****************************************************************************************************************************************************************************
web1.mts.ru                : ok=10   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

### Запуск monitor.sh

```bash
# Запуск без параметра
alex@mipt:~/mts-devops/scripts$ ./monitor.sh
Ошибка: Не указано имя сервиса.
Использование: ./monitor.sh <имя_сервиса>
```

```bash
# Запуск на локалке
alex@mipt:~/mts-devops/scripts$ systemctl status docker
● docker.service - Docker Application Container Engine
     Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; preset: enabled)
     Active: active (running) since Sun 2026-10-04 17:09:13 MSK; 12min ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 1940 (dockerd)
      Tasks: 15
     Memory: 138.9M (peak: 143.6M)
        CPU: 2.215s
     CGroup: /system.slice/docker.service
             └─1940 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock

Warning: some journal files were not opened due to insufficient permissions.

alex@mipt:~/mts-devops/scripts$ sudo ./monitor.sh docker
Сервис 'docker' работает.
Количество ошибок в /var/log/syslog за последний час: 0
```

```bash
# Запуск на VM
student@chukalovai:~$ ./monitor.sh docker
Сервис 'docker' работает.
Количество ошибок в /var/log/syslog за последний час: 0

student@chukalovai:~$ ./monitor.sh nginx
Сервис 'nginx' НЕ работает (текущий статус: inactive).
--- Последние 10 строк лога ---
Sep 24 16:07:27 chukalovai systemd[1]: Started nginx.service - A high performance web server and a reverse proxy server.
Sep 25 06:01:17 chukalovai systemd[1]: Stopping nginx.service - A high performance web server and a reverse proxy server...
Sep 25 06:01:17 chukalovai systemd[1]: nginx.service: Deactivated successfully.
Sep 25 06:01:17 chukalovai systemd[1]: Stopped nginx.service - A high performance web server and a reverse proxy server.
Sep 25 06:01:17 chukalovai systemd[1]: Starting nginx.service - A high performance web server and a reverse proxy server...
Sep 25 06:01:17 chukalovai systemd[1]: Started nginx.service - A high performance web server and a reverse proxy server.
Sep 30 06:44:26 chukalovai systemd[1]: Stopping nginx.service - A high performance web server and a reverse proxy server...
Oct 03 17:56:32 chukalovai systemd[1]: Stopping nginx.service - A high performance web server and a reverse proxy server...
Oct 03 17:56:32 chukalovai systemd[1]: nginx.service: Deactivated successfully.
Oct 03 17:56:32 chukalovai systemd[1]: Stopped nginx.service - A high performance web server and a reverse proxy server.
Количество ошибок в /var/log/syslog за последний час: 0
```

### `docker-compose ps` и `curl`

```bash
# Проверка работы docker compose
deployer@chukalovai:/opt/app$ docker compose ps
NAME          IMAGE          COMMAND                  SERVICE   CREATED        STATUS        PORTS
app           nginx:alpine   "/docker-entrypoint.…"   app       21 hours ago   Up 21 hours   80/tcp
nginx-proxy   nginx:alpine   "/docker-entrypoint.…"   nginx     21 hours ago   Up 21 hours   0.0.0.0:80->80/tcp, [::]:80->80/tcp
```

```bash
# curl на IP виртуальной машины с контейнером nginx
alex@mipt:~/mts-devops/scripts$ curl http://111.88.162.84
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hello</title>
</head>
<body>
    <h1>Hello World!</h1>
</body>
</html>
```

## Работа на скриншотах

Результаты для ДЗ №1 скриншотами см. в папке `images/`