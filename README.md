# ubuntu-post-install

> [!CAUTION]
> Este repo esta siendo modificado para el uso de debian XFCE o XUBUNTU.

## Descripcion
Estos son archivos de uso personal, puedes copiartelos, descargarlo y mejorarlo a tu gusto. 
Esto esta hecho para facilitar la tarea de instalar y configurar aplicaciones y archivos luego de una reinstalacion o una nueva instalacion.
Puede que no sea lo mas optimo y/o prolijo pero me es util y posiblemente te pueda servir.
Se ira mejorando poco a poco...

Si llegaste a este repo, te invito a que lo uses y lo modifique a tu gusto, no hace falta que lo diga, pero si queres hacer comentarios y subir modificaciones bienvenido sea

## Aplicaciones

El script tiene segmentado por tipo de entorno (Gnome, KDE, XFCE):
##### Para GNOME:
- g-programs_core.src
- g-programs.src

##### Para KDE:
- k-programs_core.src
- k-programs.src

##### Para XFCE:
- x-programs_core.src
- x-programs.src

##### Server:
Para los que quieran usar el script para un ubuntu server, hay un listado de paqueteria unico para instalar, como tambien un menu dedicado a esta opcion.
- server.src

## Resumen

Podes agregar y quitar los programas que necesites, en los listados estan los que generalmente uso para mi dia a dia.

```bash
# en caso de ser necesario, dar permiso de ejecucion al archivo
chmod +x postinstall.sh
# para ejecutarlo:
sudo bash postinstall.sh
```
