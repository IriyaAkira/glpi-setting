# glpi-setting
## Getting Start
Execute the following in your home directory or similar location:  
```bash
git clone https://github.com/IriyaAkira/glpi-setting.git glpi-docker
```

Edit /root/.smbcredentials
```yaml
username=smbuser
password=secretpassword
domain=WORKGROUP
```

Execute sudo ./scripts/start.sh

## Lisence
This repository does not contain any application code or Docker images.

It only provides scripts to pull and run the official glpi Docker image:
- https://hub.docker.com/r/glpi/glpi

Please refer to the original project and Docker image page for license information.