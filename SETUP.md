# Guía de instalación — MusicWorks (para principiantes)

Sigue estos pasos para tener la base de datos corriendo en tu computadora.
No necesitas experiencia previa con MySQL.

## Paso 1: Instala MySQL

### Mac

1. Instala [Homebrew](https://brew.sh) si no lo tienes (copia y pega esto en Terminal):
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
2. Instala MySQL:
   ```
   brew install mysql
   ```
3. Enciende el servidor:
   ```
   brew services start mysql
   ```

### Windows

1. Descarga el instalador desde [dev.mysql.com/downloads/installer](https://dev.mysql.com/downloads/installer/)
2. Ejecuta el instalador, elige "Server only" (o "Developer Default")
3. Durante la instalación te va a pedir una contraseña para el usuario `root` — **anótala**, la vas a necesitar
4. Termina la instalación; el servidor arranca solo

## Paso 2: Descarga el repositorio

Si tu profesor te dio un link de GitHub:

1. Entra al link
2. Botón verde "Code" → "Download ZIP"
3. Descomprime el ZIP en tu escritorio (o usa `git clone <link>` si ya sabes usar git)

## Paso 3: Carga la base de datos

Abre una terminal (Mac: Terminal.app / Windows: `cmd` o PowerShell), navega a la carpeta descomprimida y corre:

**Mac** (sin contraseña, por default):
```
mysql -u root -h 127.0.0.1 -P 3306 < install_musicworks.sql
```

**Windows** (con la contraseña que pusiste al instalar):
```
mysql -u root -h 127.0.0.1 -P 3306 -p < install_musicworks.sql
```
Te va a pedir la contraseña — escríbela y dale Enter (no se ve mientras escribes, es normal).

Espera unos segundos. Al final debe aparecer:
```
MusicWorks database created successfully.
```

Si aparece un error de `mysql: command not found`, tu MySQL no está en el PATH — en Mac corre `export PATH="/opt/homebrew/bin:$PATH"` y vuelve a intentar; en Windows reinstala marcando la opción de agregar al PATH.

## Paso 4: Conéctate con un cliente visual (opcional pero recomendado)

Usa cualquier programa que te deje ver tablas y escribir queries con una interfaz gráfica: **MySQL Workbench** (gratis, oficial), **DBeaver** (gratis), o la extensión de base de datos que traiga tu editor (VSCode, Antigravity, etc.).

Datos de conexión — usa estos en cualquier programa:

| Campo | Valor |
|---|---|
| Host | `127.0.0.1` |
| Port | `3306` |
| Username | `root` |
| Password | (vacío en Mac / la que pusiste en Windows) |
| Database | `musicworks` |

## Paso 5: Practica

Abre `example_queries.sql` — trae 10 consultas de ejemplo para explorar la base de datos (top canciones, comparación indie vs. mainstream, retorno de campañas, etc.). Cópialas y pégalas en tu cliente, o corre el archivo completo:

```
mysql -u root -h 127.0.0.1 -P 3306 musicworks < example_queries.sql
```

## Problemas comunes

- **"Access denied for user root"**: en Windows, agrega `-p` al comando y escribe tu contraseña. En Mac, si le pusiste contraseña a tu MySQL en algún momento, igual agrega `-p`.
- **"Can't connect to MySQL server"**: el servidor no está prendido. Mac: `brew services start mysql`. Windows: busca "Services" en el menú de inicio, busca "MySQL80" y dale click derecho → Start.
- **Los números no cuadran con los de un compañero**: es normal — la base se genera con datos aleatorios cada vez que corres el script. Los nombres de artistas y la estructura son iguales para todos, pero los streams/revenue exactos varían.
