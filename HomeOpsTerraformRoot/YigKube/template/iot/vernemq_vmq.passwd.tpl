%{ for name, account in mqtt_accounts ~}
# key ${ name }
${ account.user }: ${ bcrypt(account.pass) }
%{ endfor ~}