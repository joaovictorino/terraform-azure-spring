# Terraform criando IaaS no Azure e fazendo deploy de Java 11 e MySQL 8

Pré-requisitos

- Az-cli instalado
- Terraform instalado

Logar no Azure via az-cli, o navegador será aberto para que o login seja feito

```sh
az login
```

Inicializar o Terraform

```sh
terraform init
```

Executar o Terraform

```sh
terraform apply -auto-approve
```
