---
%{ for name, account in mqtt_accounts ~}
DOCKER_VERNEMQ_USER_${ account.user }: ${ account.pass }
%{ endfor ~}