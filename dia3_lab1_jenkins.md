# Dia 3 - Laboratorio 6 - Jenkins

## Configuración del nuevo entorno

El entorno para este laboratorio se creará completamente en AWS.

Constará de dos máquinas:
- Un servidor gitlab
- Un servidor jenkins

Antes de lanzar los playbooks, deberemos hacer checkout del nuevo código:

```text
git clone http://gitlab.teradisk.net/trainings/lab-jenkins-devops.git
```

Si miramos su estructura:

```text
.
├── ansible.cfg
├── crear-controller-aws.yml
├── crear-jenkins-aws.yml
├── env_vars
│   └── aws_vault.yml
├── inventories
└── roles
    ├── ansible-dev
    │   └── tasks
    │       └── main.yml
    ├── crear-maquina-aws
    │   ├── README.md
    │   ├── defaults
    │   │   └── main.yml
    │   ├── tasks
    │   │   └── main.yml
    │   └── templates
    │       └── inventory.txt.j2
    ├── docker
    │   └── tasks
    │       └── main.yml
    └── jenkins
        └── tasks
            └── main.yml
```


Hay dos playbooks, estos playbooks inicializan las máquinas que necesitamos, pero incluyen una novedad, se les
tiene que pasar un parámetro en tiempo de ejecución indicando nuestro nombre:

**Jenkins**

```text
ansible-playbook crear-jenkins-aws.yml -e "NOMBRE_ALUMNO=Abel"
```

También si nos fijamos, existe ya el fichero aws_vault.yml... investigar un poco como almacena las credenciales..


* Ver el vault
* Encontrar que fichero se usa como clave

## Configuración de Jenkins

Una vez lanzados el  playbook, tendremos una máquina con Jenkins a la que accederemos con:

http://ip:8080

Seguiremos el workflow... hay que tomar BUENA NOTA del user y pass que se configura.

Cuando lleguemos a la pantalla inicial de Jenkins añadiremos el módulo **Gitlab**

(seguiremos las indicaciones del profesor)

## Configuración de gitlab

1. Instalaremos el rol de gitlab de geerlinguy (via ansible galaxy)

```ansible-galaxy install geerlingguy.gitlab```

2. Ejecutaremos el playbook que generará la máquina de gitlab

```ansible-playbook crear-gitlab.yml -e "NOMBRE_ALUMNO=Abel"```

**nota**: si falla, acceder via ssh a la máquina de gitlab y ejecutar

```
sudo gitlab-ctl stop
sudo gitlab-ctl reconfigure
sudo gitlab-ctl start
```

3. Acceder via SSH a la máquina de gitlab y comprobar que URL se ha configurado:

```
sudo grep external_url /etc/gitlab/gitlab.rb 
```

4. Acceder via web a nuestro gitlab mediante la url obtenida en el paso 3

   Guardar bien la password, es la del usuario ROOT
   
5. Generar la clave API para el usuario root de gitlab

   Ir a propiedades del usuario de gitlab y apuntar la clave API que generemos

6. Añadir clave SSH pública al usuario root

   Ir a propiedades del usuario de gitlab y asignar una clave ssh para poder hacer checkout
   Ojo que tendremos que subir la parte privada a jenkins, recomendado crear un juego
   específico (```ssh-keygen```)


## El repositorio de prueba que usaremos

Para probar el CI usaremos el repositorio ```https://gitlab.teradisk.net/trainings/apache-webpage```

Podéis descargarlo en vuestra nueva máquina controller, ver que hace... pasar el test kitchen...


Si os fijáis tiene un fichero Jenkinsfile en la raíz. Este fichero le indicará a Jenkins como hacer un build.

Vamos a analizar a fondo el repositorio...


## Gitlab Deshabilitar autodevops

Deshabilitar autodevops 

Settings de GITLAB, CI/CD Default to Auto DevOps pipeline for all projects

## Clonar el repositorio en nuestro gitlab

Crearemos un nuevo repo en nuestro gitlab, importando el repo indicado más arriba.
Lo dejaremos importado como public. (en el mundo real... debería ser private ;) )

## Configurar integración con Jenkins

En Jenkins, iremos a Manage Jenkins -> configure system y en Gitlab indicaremos:
- Url de Gitlab
- API token

haremos click en Test para validar

**añadir clave ssh para git**

En Jenkins, iremos a credentials, click en el store jenkins, click en global credentials, click en add credentials
tipo "SSH Username with private key" y especificar el user de gitlab (root) y la clave privada (como introducida directamente)

**obtener api key de jenkins**

En Jenkins, en la parte superior derecha veremos el nombre de usuario "admin",
haremos click en él, seleccionaremos configure, y haremos click en show api token.

Lo anotaremos para más adelante

## Crear el job en jenkins

En Jenkins, creamos un nuevo job de tipo pipeline:
```
Enable this checkbox in build triggers: 
“Build when a change is pushed to GitLab”. If it is not available, install Gitlab Hook Plugin in Jenkins.
Copy the displayed “GitLab CI Service URL” (e.g., “https://my-jenkins/jenkins/project/my_project&#8221;), you will need it later for GitLab configuration.
Check events that should trigger builds on Jenkins. 
I personally like these three events: “Merge Request”, “Push to source branch” and “Comment”
```

Hay que añadir también la config de SCP para el pipeline del proyecto

## Configurar el hook en gitlab

usando la Service URL que salía en el paso anterior, activar el webhook para comments y merge request en gitlab (en el propio proyecto)

Importante: desactivar el check de SSL

Importante 2:
La URL debe quedar como http://user:apitoken@ipjenkins:8080.... , p.e.

```
http://admin:b2ebfef8fc996e87813f73953716035b@34.240.40.194:8080/project/test-our-project
```

## Configurar seguridad de jenkins

en Jenkins , en In Process Script Approval, añadir, para esto deberemos ejecutar el job y, veremos que falla el job, entonces deberemos habilitar y repetir el proceso.

```
method hudson.plugins.git.GitSCM getUserRemoteConfigs
method hudson.plugins.git.UserRemoteConfig getCredentialsId
````

## Probar de hacer una merge request

1. En el código de apache-webpage, haremos un cambio que no rompa nada en una nueva rama
2. Haremos push de esa rama a github
3. Haremos una pull request de esa rama a ver que pasa

repetiremos con un cambio que falle

## cosas curiosas

Con el comentario "Jenkins please retry a build" se relanza el pipeline
