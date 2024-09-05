# Prueba-Dummy 

## Requisitos

Para completar esta prueba, se utilizaron las siguientes herramientas:

- SonarQube
- Organización en Azure DevOps
- Docker
- Kubernetes (EKS) (Minikube)
- La imagen desde el repositorio de Docker

- ## Procedimiento

### 1. Descarga de archivos del repositorio elegido

Utilicé la aplicación Compose sample application: ASP.NET with MS SQL server database. [Repositorio Elegido](https://github.com/docker/awesome-compose/tree/master/aspnet-mssql)

### 2. Instalación del framework necesario

Ya tenía el framework necesario. 

### 3. Análisis y compilación de la aplicación con SonarQube

#### Instalación de SonarQube

Usé la documentacion del [Try out SonarQube](https://docs.sonarsource.com/sonarqube/latest/try-out-sonarqube/)

1 Instalar instancia local de SonarQube desde imagen de Docker.
   
   ```bash
$ docker run -d --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p
9000:9000 sonarqube:latest
   ```
2. Accedí a SonarQube en `http://localhost:9000` y configuré un nuevo proyecto.

#### Inicio de Analisis del proyecto

   ```bash
Install the SonarScanner .NET Core Global Tool
dotnet tool install --global dotnet-sonarscanner
Execute the Scanner
dotnet sonarscanner begin -k:"aspnet-mssql" -
d:sonar.host.url="http://localhost:9000" - d:sonar.token="{token} "
dotnet build
dotnet sonarscanner end /d:sonar.token="{token}"
   ```

#### Resultados Análisis
Exitoso

![image](https://github.com/user-attachments/assets/83be1097-75ec-4a27-ae80-81a736b6da6b)

Fallido (Forcé el fallo duplicando codigo) 

![image](https://github.com/user-attachments/assets/6f851771-dc93-4287-962b-d4e654c59e0d)


### 5. Generación de la imagen de Docker y subida a DockerHub (Subir la imagen a dockerhub/ACR/ECR desde el pipeline yaml) 

Creo una cuenta en Docker hub [Dockerhub](https://hub.docker.com/)

Creo el repositorio

Registro la conexión con Docker hub desde azure

![image](https://github.com/user-attachments/assets/92a97ee3-b530-46e2-872a-c6b6f22ed753)

Creo del pipeline en Azure DevOps

1. Creé una organización en Azure DevOps y un repositorio en git para subir los archivos.
2. Pipeline que genera la imagen de Docker y la sube a Docker Hub. También
dentro del Dentro del pipeline se ejecuta lo siguiente en bash .
a. Imprime Hola Mundo 10 veces en pantalla con un job paralelo.
b. Script que cree 10 archivos con la fecha y luego lo imprima en consola

```yaml
trigger:
- main

resources:
- repo: self

variables:
  tag: '$(Build.BuildId)'

stages:
- stage: BuildAndPush
  displayName: Build image
  jobs:
  - job: BuildAndPushDockerImage
    displayName: 'Build and Push Docker Image'
    pool:
      vmImage: ubuntu-latest
    steps:
    - task: Docker@2
      inputs:
        containerRegistry: 'docker'
        repository: 'rolando999/aspnet-mssql'
        command: 'buildAndPush'
        Dockerfile: '**/Dockerfile'
        
- stage: ScriptBaschPrint
  displayName: ScriptBasch
  jobs:
  - job: ScriptBasch
    displayName: 'Script Basch write Hello Word'
    steps:
      - script: |
            for i in {1..10}
            do
              echo 'Hello world'
            done
        displayName: 'Print Hello World 10 times'

  - job: ScriptBaschFiles
    displayName: 'Script Basch Create and Print Files'
    steps:
      - script: |
              for i in {1..10}
              do
                filename="file_$i.txt"
                date > $filename
              done
              cat $filename
```
Resultado ejecución del Pipeline (se adjuntan los logs en el repositorio (logs_15.zip ))

![image](https://github.com/user-attachments/assets/652891b1-6c1c-4c29-abed-a7e9ac7d0c46)

![image](https://github.com/user-attachments/assets/28e280d7-35e6-4f3a-94be-1f9778210e91)

![image](https://github.com/user-attachments/assets/bd25a907-b8cc-4ac1-bd9f-821dcc8124f9)

[Link docker Imagen](https://hub.docker.com/r/rolando999/aspnet-mssql)

### 6. Despliegue de la aplicación en Kubernetes en este caso minikube con el driver
de VirtualBox

```bash
minikube start
minikube status
```

Creé los archivos `deployment-config-file.yaml`, `service-config-file.yaml` y `ingress-config-file.yaml` para que la aplicación se despliegue correctamente estan en la carpeta "/environment/".

```bash
kubectl apply -f deployment-config-file.yaml
$ kubectl apply -f service-config-file.yaml
Kubectl describe deployment aspnetapp-pod
minikube addons enable ingress
minikube service aspnetapp-service
```

### 7. Construye un clúster de kubernetes usando IaC (terraform). [eks cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster)

1. Creé los documentos de terraform `network.tf`, `provider.tf`, `eks.tf` y `terraform.tf` para que la aplicación se despliegue correctamente estan en la carpeta "/environment/".

```bash
terraform fmt
terraform validate
terraform init
terraform plan
terraform apply

aws eks update-kubeconfig --region us-east-1 --name my-cluster --profile default
kubectl get nodes
```

Codigo
yaml de k8s
Pipelines
Logs
Printscreen
Repositorio de github
