# glpi-setting
## Getting Start
Execute the following in your home directory or similar location:  
```bash
git clone https://github.com/IriyaAkira/glpi-setting.git glpi
```

Edit ./glpi/.env
```
TZ=Asia/Tokyo
GLPI_DB_HOST=db
GLPI_DB_PORT=3306
GLPI_DB_ROOT_PASSWORD=rootpassword
GLPI_DB_NAME=glpi
GLPI_DB_USER=glpi
GLPI_DB_PASSWORD=glpi
BK_SERVER=HOSTNAME
BK_SHARE=SHARENAME
MOUNT_POINT=/mnt/foo/bar
```

Edit /root/.smbcredentials for backup
```yaml
username=smbuser
password=secretpassword
domain=WORKGROUP
```
and change the permissions just in case.
```bash
chmod 600 /root/.smbcredentials
```

Execute sudo ./scripts/start.sh

## Lisence
This repository does not contain any application code or Docker images.

It only provides scripts to pull and run the official glpi Docker image:
- https://hub.docker.com/r/glpi/glpi

Please refer to the original project and Docker image page for license information.