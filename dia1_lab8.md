# Dia 1 - Laboratorio 8

El objetivo de este laboratorio es familiarizarse con el funcionamiento del inventario dinámico.

Se configurará el inventario dinámico contra AWS.

# Inventario de elementos en el cloud de AWS

Este ejercicio puede y debe seguirse por todos los alumnos. Configuraremos en la vagrant que se ha usado durante
todo el curso el inventario dinámico contra la cuenta de AWS en la que se crean los laboratorios.

**Nota:** algunas de las configuraciones de este inventario dinámico son complejas y solo comprensibles con
conocimiento de como funciona el cloud de AWS. No os preocupéis si hay algún concepto que no os queda claro.
A modo de glosario especificamos:
- EC2 : servicio de máquinas virtuales de AWS
- RDS : servicio de bases de datos como servicio de AWS
- ElastiCache : servicio de instancias de caché (redis o memcache) como servicio de AWS
- secret/key par : conjunto de clave y palabra secreta que se utilizan para acceder a la API de AWS
- region : zona geográfica que se usa de AWS (en el curso estamos usando Irlanda, reperesentada por eu-west-1)

Lo primero es asegurarse de que existen máquinas arrancadas en AWS. Para ello lanzaremos el siguiente comando:

```text
ansible-playbook crear-lab-1vm.yml
```

Seguido, descargaremos el script ec2.py (inventario dinámico de AWS) y su fichero de configuración. Lo dejaremos en el
directorio inventories:

```text
cd inventories/
wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.ini
wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py
chmod +x ec2.py
```

Ahora, tenemos que configurar las credenciales de Amazon para el script de inventario dinámico. Para ello tomaremos
nota de las variables aws_secret y aws_access que hay
en el fichero env_vars/aws_vault.yml

```text
[root@localhost ansible-devops]# cat env_vars/aws_vault.yml
aws_vpc: "xxxxxx"
aws_access: "xxxxxxxxxxx"
aws_secret: "yyyyyyyyyyyy"
aws_keypair_name: "xxxxxx"
aws_ec2_ami: "xxxx"
aws_ec2_subnet: "xxxxxx"
```

Y añadiremos estas variables al final del fichero ```inventories/ec2.ini```:

```text
[root@localhost ansible-devops]# tail inventories/ec2.ini
# way as you would a private SSH key.
#
# Unlike the boto and AWS configure files, this section does not support
# profiles.
#
# aws_access_key_id = AXXXXXXXXXXXXXX
# aws_secret_access_key = XXXXXXXXXXXXXXXXXXX
# aws_security_token = XXXXXXXXXXXXXXXXXXXXXXXXXXXX
aws_access_key_id = xxxxxxxxxxx
aws_secret_access_key = yyyyyyyyyyyy
```

También pondremos los siguientes valores en el fichero ```inventories/ec2.ini```:

 ```text
regions = eu-west-1 #para limitar la busqueda a IRLANDA
```

```text
rds = False #para evitar indexar servicio RDS
```

```text
elasticache = False #para evitar indexar servicio elasticache
```
Para validar que funciona, ejecutaremos ```inventories/ec2.py --list```

Veremos que:
- La salida es enorme: esto es porque crea grupos basándose en varios parámetros de EC2
  - security groups
  - nombre
  - tags
  - tipo de instancia
  - vpc
  - clave ssh
  - ...

Es infinitamente más complejo que el de vagrant

Si lo ejecutamos de nuevo , veremos que va más rápido, esto es porque hace una caché y hasta que no caduca, no vuevle
a preguntar a AWS si han habido cambios.

**Aplicar playbook a todas las máquinas que tengan el tag "curso ansible"**

Crearemos una copia de nuestro playbook favorito:

```text
cp d1l1_configurar_nginx.yml lab-dinamico-aws.yml
```

Y modificaremos los grupos a los que se aplica la instalación de nginx por "tag_MaquinaNombreAlumno"

Y lo ejecutaremos:
```ansible-playbook -i inventories/ec2.py lab-dinamico-aws.yml```

Fallará miserablemente.

**¿Por qué?**

Si os fijáis en el json que ha salido al hacer la lista de máquinas, las máquinas no tienen ningún atributo que
especifique ni el usuario de ssh ni la clave a usar.

Para solucionarlo podemos pasar más parámetros al comando ansible-playbook (que para una vez ya está bien), o podemos
utilizar el **fichero de configuración de ansible**.

En la raíz del repositorio hay un fichero que ha pasado desapercibido, hasta ahora, es el ```ansible.cfg```

Este fichero contiene configuración que queremos que sea por defecto para los comandos de ansible.

Puede estar en ```/etc/ansible``` o en el directorio donde se ejecuten los playbooks.

Vamos a editarlo y dejarlo como sigue:

```text
[defaults]
host_key_checking = False
remote_user = centos
private_key_file = /home/centos/curso-itnow.pem
```

```ansible-playbook -i inventories/ec2.py lab-dinamico-aws.yml```

**Recomendado:** Ver la lista de variables del fichero ansible.cfg en
http://docs.ansible.com/ansible/latest/intro_configuration.html


# Fin del laboratorio

En este laboratorio se habrán adquirido los siguientes conocimientos:
- Como funciona el inventario dinámico
- Configurar ansible para el uso de un inventario dinámico
- Como funciona el fichero ansible.cfg y para que sirve

