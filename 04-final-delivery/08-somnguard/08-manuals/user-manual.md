# Manual de usuario de SomnGuard

**Uso del portal web y la aplicación móvil**  
**Edición de revisión 1.1 · 9 de octubre de 2026**  
**Dirigido a:** usuarios de SomnGuard y personal administrador autorizado

## Contenido

1. Antes de empezar
2. Cuentas y permisos
3. Acceso al sistema
4. Portal web para usuarios
5. Aplicación móvil
6. Portal web para administradores
7. Configuración del dispositivo
8. Eventos, evidencias y notificaciones
9. Roles y catálogos
10. Mensajes y solución de problemas
11. Recomendaciones de uso
12. Glosario


## 1. Antes de empezar

SomnGuard combina un dispositivo con cámara que detecta señales relacionadas con somnolencia o distracción al volante y aplicaciones para consultar el estado del equipo, los eventos registrados y los avisos. El dispositivo analiza la imagen localmente y puede seguir registrando eventos cuando pierde la conexión; sincroniza la información cuando vuelve a tener comunicación.

Este manual cubre las pantallas disponibles en el portal web y la app móvil revisados el 9 de octubre de 2026. Las opciones visibles pueden variar según el rol, los permisos de la cuenta y los servicios habilitados en la instalación. La dirección oficial del portal y las versiones compatibles deben ser proporcionadas por la organización que opera SomnGuard.

Para utilizar las funciones personales necesita una cuenta activa. Para consultar el dispositivo, este debe estar registrado y asociado a la cuenta. El video en vivo requiere que el equipo esté activo y que la instalación tenga habilitado el servicio de streaming. Si el video no está disponible, el dispositivo puede seguir detectando y enviando telemetría.

> **Atención:** desde **Monitoreo** en la app puede iniciar o pausar la transmisión de cámara y, por separado, pausar o reanudar la detección del dispositivo. La disponibilidad de video depende del equipo, la conexión y los servicios de streaming de la instalación. Siga siempre las indicaciones de seguridad vial; no manipule la app mientras conduce.

## 2. Cuentas y permisos

SomnGuard distingue dos perfiles en el portal:

| Perfil | Acceso visible |
|---|---|
| Administrador | Resumen, inventario y configuración de dispositivos, eventos, centro de avisos, roles/permisos y catálogos. Algunas acciones requieren permisos adicionales. |
| Usuario | Inicio, monitoreo del dispositivo asociado, historial propio, notificaciones y preferencias. |

La app móvil está orientada a la cuenta de usuario. Si no encuentra una opción de administración, compruebe que inició sesión con la cuenta correcta o comuníquese con quien administra SomnGuard. La pantalla web **Usuarios** está incompleta en esta versión y no se incluye como una función disponible.

## 3. Acceso al sistema

### 3.1 Iniciar sesión en el portal

**Ubicación:** página pública del portal, botón **Iniciar sesión**.

1. Abra la dirección del portal que le proporcionó la organización.
2. Pulse **Iniciar sesión**.
3. Escriba su **Correo electrónico** y su **Contraseña**.
4. Si necesita revisar lo escrito, use **Mostrar contraseña**; vuelva a pulsarlo para ocultarla.
5. Pulse **Iniciar sesión**.

Cuando el acceso es válido, el portal abre el inicio correspondiente a su rol. Si aparece un error, revise el correo y la contraseña. El portal valida los campos y muestra mensajes junto al campo o en el formulario.

**Captura 1 pendiente.** Insertar imagen real de la página pública con el cuadro **Iniciar sesión** abierto. No incluir una contraseña escrita.

### 3.2 Crear una cuenta desde el portal

La página pública incluye **Registrarse**. La organización debe confirmar si el registro abierto está habilitado en su ambiente.

1. Pulse **Registrarse**.
2. Complete **Nombres**, **Apellidos**, **Correo electrónico**, **Teléfono**, **Contraseña** y **Confirmar contraseña**.
3. Cree una contraseña de al menos 8 caracteres con mayúscula, minúscula, número y símbolo, sin espacios.
4. Revise los mensajes de validación y pulse **Registrarse**.
5. Abra el correo de verificación y complete el código en la pantalla **Verificar correo**.

El formulario exige nombres y apellidos, un correo válido, teléfono y contraseñas coincidentes. El correo y el teléfono no pueden estar ya registrados. Al crear la cuenta, el portal informa que debe verificarse el correo para continuar. El rol resultante depende de la configuración de la cuenta; confírmelo con el administrador.

### 3.3 Recuperar o cambiar la contraseña

1. En el cuadro de acceso, pulse **¿Olvidaste tu contraseña?**.
2. Escriba el correo de la cuenta y solicite el código.
3. En **Verificar código de recuperación**, introduzca el código recibido.
4. En **Restablecer contraseña**, escriba la nueva contraseña y vuelva a escribirla para confirmarla.
5. Guarde el cambio e inicie sesión con la nueva contraseña.

El código tiene seis dígitos. La nueva contraseña debe cumplir las reglas indicadas por el formulario. Si el código no llega o vence, la disponibilidad de reenvío y el canal de soporte deben confirmarse con la organización.

### 3.4 Iniciar sesión y recuperar el acceso desde la app móvil

1. Abra SomnGuard en el teléfono.
2. En **Iniciar sesión**, escriba **Correo electrónico** y **Contraseña**.
3. Pulse **Iniciar sesión**. Para crear una cuenta, use **Regístrate** y complete los campos que aparecen.
4. Use **¿Ha olvidado su contraseña?** para iniciar la recuperación por correo.

La app contiene pantallas para verificar el correo y el código de recuperación. El envío de códigos requiere conexión con el servicio de cuentas y correo de la instalación.

### 3.5 Cerrar sesión

- En el portal, pulse **Cerrar sesión** en la barra superior.
- En la app, abra **Perfil/Ajustes**, pulse **Cerrar sesión** y confirme en el cuadro que aparece.

Al cerrar sesión, vuelva a iniciar con sus credenciales para entrar de nuevo. La sesión móvil utiliza almacenamiento seguro del sistema para los tokens de sesión.

## 4. Portal web para usuarios

### 4.1 Inicio

Después de iniciar sesión, la página **SOMNGUARD** presenta **Iniciar monitoreo** y **Ver eventos**. El menú lateral permite abrir **Monitoreo**, **Historial** y **Notificaciones**; **Preferencias** permite cambiar la recepción de avisos.

### 4.2 Ver el dispositivo y el video en vivo

**Ubicación:** menú **Monitoreo**.

1. Abra **Monitoreo**. El portal busca un dispositivo asociado a su cuenta.
2. Revise el indicador **Sistema activo** o **Sistema inactivo** y el mensaje que aparece sobre el video.
3. Si el equipo está activo y el servicio de video disponible, espere a que aparezca la imagen en vivo.
4. Para detener la transmisión desde el portal, pulse **Apagar cámara**. El portal cierra la sesión de video.
5. Para volver a abrirla, pulse **Encender cámara**.

Apagar la transmisión detiene el envío de imágenes al portal; no equivale a apagar físicamente la cámara ni a detener el análisis local del dispositivo. Si el equipo está desconectado, la vista informa el estado y vuelve a intentar conectarse.

**Captura 2 pendiente.** Insertar captura real de **Monitoreo** que muestre estado y controles, con video o datos personales ocultos.

### 4.3 Pausar o reanudar la detección desde el portal

**Requisito:** dispositivo disponible y visible en **Monitoreo**.

1. Abra **Monitoreo** y confirme que el portal identificó su dispositivo.
2. Pulse **Pausar detección** para pedir al dispositivo que suspenda detección y alertas.
3. Espere la confirmación de estado en pantalla.
4. Para continuar, pulse **Reanudar detección**.

La pantalla indica que una detección pausada no se reanuda automáticamente; use el control de reanudación o reinicie el dispositivo según el procedimiento de operaciones. Si no se aplica el cambio, revise que el equipo esté activo y conectado. No dé por pausada la detección hasta que el portal confirme el resultado.

### 4.4 Consultar eventos propios

**Ubicación:** menú **Historial**.

1. Abra **Historial**. La lista contiene eventos asociados a su dispositivo.
2. Elija una severidad: **Todas**, **Informativa**, **Advertencia**, **Alta** o **Crítica**.
3. Escriba **Desde** o **Hasta**, si quiere limitar por fecha y hora.
4. Pulse **Aplicar filtros**. Para volver al listado sin restricciones, pulse **Limpiar**.
5. Use **Hoy**, **7 días** o **30 días** para aplicar un periodo rápido.
6. Seleccione la cantidad de **Eventos por página** y use los controles numerados para avanzar.
7. Seleccione un evento para abrir su detalle. Si tiene evidencia disponible, use la acción para verla.

La lista muestra el total de eventos y cuántos son críticos. Los resultados dependen de los filtros aplicados. Una lista vacía significa que no hay eventos para ese dispositivo y ese rango, o que aún no se sincronizaron.

**Captura 3 pendiente.** Insertar pantalla real de **Historial** con datos sintéticos, filtros visibles y sin evidencia personal.

### 4.5 Consultar y marcar notificaciones

1. Abra **Notificaciones** en el menú.
2. Revise el título, mensaje, fecha, canal y estado de cada aviso.
3. En un aviso nuevo, pulse **Marcar como leída**.

La página muestra el total, el número sin leer y el estado general. Marcar un aviso como leído actualiza su estado en la cuenta.

### 4.6 Cambiar preferencias de notificación

1. Abra **Preferencias**.
2. Espere a que cargue la preferencia actual **Recibir notificaciones**.
3. Active o desactive el control.
4. Espere el mensaje de guardado o revise el error mostrado.

El control modifica avisos en la aplicación y notificaciones push. Otras opciones guardadas por la cuenta pueden incluir correo, horario silencioso, zona horaria y severidad mínima, aunque la pantalla web revisada solo expone el control general. Para esas opciones use los ajustes disponibles en su app o solicite orientación al administrador.

## 5. Aplicación móvil

### 5.1 Navegación principal

La barra inferior contiene **Inicio**, **Monitoreo**, **Historial** y **Ajustes**. En Ajustes/Perfil aparecen opciones de cuenta, dispositivo, preferencias, notificaciones, seguridad, privacidad y soporte.

### 5.2 Inicio y estado de monitoreo

1. En **Inicio**, pulse **Iniciar monitoreo** para abrir la pantalla **Monitoreo**. Si no hay dispositivo asociado, la app informa que debe vincular uno y ofrece ir a **Cuenta**.
2. En **Monitoreo**, revise el estado del dispositivo y los eventos del día. Pulse el icono de actualizar para volver a cargar los eventos.
3. Pulse **Reanudar cámara** para solicitar una sesión de video y ver la transmisión en vivo. Espere el estado **EN VIVO**; si aparece un aviso, siga la indicación de conexión.
4. Pulse **Pausar cámara** para cerrar la sesión de video. Al salir de la pantalla, la app también detiene la sesión de cámara.
5. Use **Pausar detección** o **Reanudar detección** para cambiar la detección del dispositivo. La app confirma ese cambio con el servicio y muestra un aviso cuando está pausada.

La transmisión de cámara y la detección tienen controles independientes: pausar el video no pausa la detección. La imagen puede tardar en aparecer o no estar disponible si el equipo, la red o LiveKit/relay no están conectados; en ese caso, la detección puede continuar en el dispositivo. La app intenta usar una conexión de respaldo cuando LiveKit no entrega video.

**Captura 4 pendiente.** Insertar capturas reales de **Inicio** y **Monitoreo**, incluida una sesión de video en un teléfono de prueba con dispositivo y streaming de QA. Ocultar datos personales y cualquier credencial.

### 5.3 Consultar historial en la app

1. Abra **Historial** desde la pestaña inferior o desde el botón de Inicio.
2. Elija una categoría (por ejemplo, distracción o somnolencia) si desea filtrar.
3. Seleccione fechas **Desde** y **Hasta** para acotar la búsqueda. No use fechas futuras.
4. Avance o retroceda con la paginación.
5. Abra un evento para consultar su detalle. Si hay evidencia, use la opción para cargarla.

Los eventos se muestran ordenados por fecha reciente. Si no hay dispositivo asociado, la app no puede cargar su historial. La evidencia puede no estar disponible para todos los eventos.

### 5.4 Consultar dispositivo vinculado

1. Abra **Ajustes** o **Perfil**.
2. Pulse **Dispositivo**.
3. Revise serie, estado, versión del firmware, fecha de asignación, último contacto y versión de configuración aplicada.
4. Si aparece un error de carga, pulse **Reintentar**.

La pantalla muestra la información del dispositivo vinculado. La app permite introducir el código de vinculación desde **Cuenta**; necesita un código válido generado para el equipo.

### 5.5 Cuenta, preferencias y otras opciones

- **Cuenta:** permite consultar/actualizar datos personales, vincular un dispositivo con **Código de vinculación** y **Vincular dispositivo**, y desvincular el que aparece asociado. Revise el resumen de confirmación antes de guardar.
- **Preferencias:** permite ajustar las opciones que se muestran en esa pantalla y guardar los cambios.
- **Notificaciones:** consulte los avisos disponibles en la cuenta.
- **Seguridad:** incluye cambio de correo, que solicita la contraseña actual y confirmación del nuevo correo, y eliminación de cuenta con confirmación.
- **Privacidad de datos:** **Política de tratamiento** y **Descargar mis datos** muestran mensajes informativos. La app no abre una política externa ni inicia una descarga.
- **Soporte:** las acciones para contacto, preguntas frecuentes y reportar un problema abren mensajes informativos locales; no envían una solicitud a soporte.

Los cambios de cuenta o eliminación pueden ser definitivos. Antes de confirmar, revise los datos y consulte al administrador si no está seguro. La organización debe indicar el canal real de soporte y las políticas de datos aplicables.

## 6. Portal web para administradores

### 6.1 Resumen general

Al entrar como administrador se abre **Resumen general**. La página muestra dispositivos registrados, dispositivos activos, eventos de los últimos siete días, alertas sin leer y eventos recientes.

- Pulse **Actualizar** para volver a consultar los datos.
- Pulse **Ver dispositivos** para abrir el inventario.
- Use **Reintentar avisos** para pedir a la API que vuelva a procesar notificaciones pendientes.

Si una fuente no responde, el panel puede indicar **Dashboard parcialmente disponible** y mostrar datos incompletos. Las métricas son las cantidades reportadas por el servicio.

### 6.2 Registrar un dispositivo

**Ubicación:** menú **Inventario** → **Registrar dispositivo**.

1. Pulse **Registrar dispositivo**.
2. Complete **Número de serie** y **Versión de firmware**.
3. Pulse **Crear dispositivo**.
4. Guarde la **API Key** y el **Código de vinculación** que aparecen. Puede usar **Copiar** para cada valor.
5. Pulse **Cerrar** cuando haya guardado las credenciales de forma segura.

Las credenciales se muestran en el momento de creación; el portal advierte que no volverán a mostrarse. No las comparta en capturas ni mensajes públicos. Si se pierden, revise con operaciones el proceso autorizado para renovar credenciales.

**Captura 5 pendiente.** Insertar captura real del inventario y el formulario de alta con datos ficticios; ocultar API Key y código.

### 6.3 Revisar, filtrar y editar el inventario

1. Abra **Inventario**. La tabla muestra serie, estado, firmware, asignación, último contacto y acciones.
2. En **Estado**, elija **Todos**, **Activo**, **Desconectado** o **Pendiente** y pulse **Filtrar**.
3. Use **Anterior** y **Siguiente** para cambiar de página.
4. Pulse **Detalle** para revisar identificador, estado, firmware, usuario, último heartbeat y estado de configuración.
5. Pulse **Editar** para modificar la versión de firmware o el estado y guarde con **Guardar cambios**.

Cambiar un estado puede alterar la disponibilidad del dispositivo. Use solo valores autorizados por el procedimiento operativo. Para liberar una asignación, pulse **Desasignar** en la fila correspondiente.

### 6.4 Asignar o vincular un dispositivo

**Asignación administrativa:** pulse **Asignar** en la fila del dispositivo, escriba el **ID de usuario (UUID)** y pulse **Asignar**. Compruebe después que la columna Asignación muestra el usuario esperado.

**Vinculación por código:** el administrador puede seleccionar **Vincular por código**, escribir el **Código de vinculación** y pulsar **Vincular**. El titular de la cuenta también puede hacerlo desde **Cuenta** en la app móvil.

Asigne el equipo únicamente a la cuenta correcta. Un dispositivo ya asociado puede devolver un error de conflicto; confirme primero su asignación actual.

### 6.5 Crear un token de aprovisionamiento

1. En **Inventario**, pulse **Token de aprovisionamiento**.
2. Si corresponde, escriba el **Número de serie (opcional)**.
3. Pulse **Generar token**.
4. Guarde el token mostrado y revise su fecha de expiración y cantidad máxima de usos.
5. Cierre la ventana después de registrar el token en el canal seguro autorizado.

El token es una credencial de aprovisionamiento, no un código para compartir con conductores. No lo incluya en capturas, correos abiertos o documentación de usuario.

### 6.6 Renovar una API Key

1. En la fila del dispositivo, pulse **Detalle**.
2. En el detalle, pulse **Rotar API Key**.
3. Guarde la nueva clave cuando se muestre y aplique el procedimiento operativo autorizado para actualizar las credenciales del dispositivo.

La rotación puede interrumpir comunicación hasta que el equipo tenga la nueva clave. El detalle ofrece **Copiar**. No realice esta operación sin coordinar con operaciones.

## 7. Configuración del dispositivo

**Ubicación:** menú **Configuración** dentro de la gestión de dispositivos.

1. En **Dispositivo**, elija el equipo que quiere revisar.
2. Compare **Versión publicada**, **Versión aplicada** y **Estado**.
3. Revise **Parámetros del dispositivo**. La configuración se presenta como un objeto JSON.
4. Para cambiarla, edite el contenido y complete **Motivo del cambio (opcional)** con una explicación breve.
5. Pulse **Guardar configuración**. El portal valida que el contenido sea JSON válido y que su nivel superior sea un objeto.
6. El equipo recibirá la versión cuando se sincronice. Para pedir que consulte su configuración, pulse **Solicitar actualización**.
7. Revise de nuevo el estado. La pantalla muestra **Pendiente de sincronizar** hasta que el equipo aplique la versión.

No modifique parámetros sin conocer los valores aprobados para el dispositivo. Un objeto JSON sintácticamente correcto aún puede contener valores no admitidos. Si aparece **JSON inválido**, corrija comas, comillas y llaves; si aparece **Configuración inválida**, asegúrese de que el valor principal sea un objeto y no una lista.

## 8. Eventos, evidencias y notificaciones

### 8.1 Historial administrativo de eventos

1. Abra **Eventos** → **Historial**.
2. En **Severidad**, seleccione **Todas**, **Informativa**, **Advertencia**, **Alta** o **Crítica**.
3. Indique **Desde** y/o **Hasta** si necesita limitar por fecha y hora.
4. Revise las columnas **Evento**, **Dispositivo**, **Severidad**, **Ocurrido** y **Evidencia**.
5. Seleccione una fila para abrir el detalle.
6. Si el detalle indica evidencia disponible, pulse **Ver evidencia**. La imagen o el video aparece en el panel; otro formato puede abrirse o descargarse desde su enlace.
7. Use **Anterior** y **Siguiente** para recorrer resultados.

El detalle puede indicar si el evento se sincronizó mientras el dispositivo estaba sin conexión. La evidencia solo aparece cuando el evento la tiene y el servicio puede recuperarla. Trate las imágenes y videos según la política de privacidad vigente.

### 8.2 Centro de avisos

Abra **Centro de avisos** para consultar los avisos disponibles. En cada elemento revise título, mensaje, fecha, canal y estado. Pulse **Marcar como leída** cuando haya revisado un aviso nuevo. Si el servicio devuelve error, reintente más tarde o informe al administrador del entorno.

El botón **Reintentar avisos** del resumen está destinado a administradores. Inicia el reprocesamiento de avisos pendientes en el servicio y presenta el resultado. No garantiza la entrega si el canal externo no está configurado o disponible.

## 9. Roles y catálogos

### 9.1 Roles y permisos

**Ubicación:** menú **Seguridad** → **Roles y permisos**. Requiere el permiso correspondiente.

La pantalla permite crear o editar un rol con **Código**, **Nombre** y **Descripción**; crear o editar una **Funcionalidad** asociada a un módulo; asignar funcionalidades a un rol; retirar un vínculo; y asignar o quitar un rol a un usuario identificado por UUID.

1. Para un rol, complete los campos y pulse **Crear rol** o **Guardar cambios**.
2. Para asignar funcionalidades, seleccione **Rol** y **Módulo**, marque los permisos requeridos y pulse **Asignar funcionalidades**.
3. Para asignar un rol a una cuenta, escriba el **UUID del usuario**, elija **Rol** y pulse **Asignar rol**.
4. Para retirar una asignación, use el control **Quitar rol** o **Retirar vínculo** según el tipo de relación.

Eliminar o retirar permisos puede bloquear el acceso de una persona. Verifique el cambio con el responsable antes de guardarlo. La interfaz no ofrece un directorio funcional de usuarios: se requiere conocer el UUID desde una fuente autorizada.

### 9.2 Catálogos del sistema

**Ubicación:** menú **Seguridad** → **Catálogos**.

El selector **Catálogo** permite elegir **Categorías**, **Tipos de evento**, **Severidades**, **Patrones sonoros** o **Tipos de medio**. El panel muestra los registros y un formulario de creación/edición.

1. Elija el catálogo y pulse **Actualizar** si necesita recargarlo.
2. Para crear, complete los campos del editor y pulse **Crear registro**.
3. Para modificar un elemento, selecciónelo en la lista, cambie los campos y pulse **Guardar cambios**.
4. Para eliminarlo, pulse **Eliminar** y confirme el mensaje.

Los campos cambian según el catálogo. Por ejemplo, **Tipos de evento** asocia categoría, severidad predeterminada y patrón sonoro; **Severidades** incluye prioridad; **Patrones sonoros** incluye frecuencia, duración y repeticiones; **Tipos de medio** incluye MIME y tamaño máximo. Las relaciones requeridas deben elegirse de las listas cargadas. El campo JSON debe tener estructura válida. La eliminación puede fallar si existen referencias o reglas que impiden borrarla.

## 10. Mensajes y solución de problemas

| Lo que observa | Qué hacer |
|---|---|
| Correo o contraseña incorrectos | Revise el correo escrito y use la recuperación si olvidó la contraseña. Confirme que el correo fue verificado. |
| Código de verificación o recuperación no válido | Confirme que escribió los seis dígitos más recientes. Solicite orientación si no llega un código nuevo o el anterior venció. |
| No hay dispositivo asociado | Vincule uno desde **Cuenta** con un código válido o pida al administrador que asigne el dispositivo. |
| Dispositivo desconectado o pendiente | Revise **Último contacto** y estado. El equipo debe estar encendido y recuperar conexión; los eventos pueden sincronizarse después. |
| Pantalla de video negra o sin imagen | Confirme que el dispositivo está activo. Espere el mensaje de estado; el video necesita streaming habilitado y conectividad. La detección local puede seguir activa sin imagen en el portal. |
| No aparecen eventos | Pulse actualizar o **Reintentar**, quite filtros y revise el dispositivo y el rango de fechas. Puede que todavía no haya eventos sincronizados. |
| No se puede cargar evidencia | Compruebe que el evento indique evidencia disponible y vuelva a intentarlo. Si persiste, informe al administrador con la fecha e identificador del evento. |
| Error al guardar configuración | Corrija el JSON y verifique que el contenido principal sea un objeto. No cambie parámetros sin los valores aprobados. |
| No se ve un menú administrativo | Confirme su rol y permisos con la persona administradora. |
| Los botones de privacidad solo muestran un aviso | La app no abre una política externa ni inicia la descarga de datos. Consulte el canal oficial de la organización. |

Si necesita informar un problema, anote la pantalla, fecha/hora, dispositivo y texto del mensaje. No adjunte contraseñas, API Keys, tokens ni videos de evidencia en canales abiertos.

## 11. Recomendaciones de uso

- Vincule el dispositivo correcto antes de iniciar una consulta.
- Compruebe el estado y el último contacto del equipo cuando los datos parezcan antiguos.
- Recuerde que **Pausar cámara** detiene la transmisión, mientras que **Pausar detección** cambia el procesamiento del dispositivo. Compruebe el estado que muestra la app.
- No pause detección sin una razón autorizada y no espere que se reanude sola.
- Reserve las API Keys, códigos de vinculación y tokens de aprovisionamiento para personal autorizado.
- Consulte evidencia solo con el propósito autorizado y respete las reglas de privacidad de su organización.
- No utilice el teléfono mientras conduce.

## 12. Glosario

| Término | Significado para el usuario |
|---|---|
| Dispositivo | Equipo SomnGuard con cámara y procesamiento local que observa señales de riesgo. |
| Evento | Registro de una detección reportada por el dispositivo. |
| Evidencia | Imagen u otro medio asociado a un evento, si fue generado y está disponible. |
| Severidad | Nivel asignado al evento: informativa, advertencia, alta o crítica. |
| Heartbeat / último contacto | Comunicación periódica del dispositivo que permite conocer cuándo estuvo conectado. |
| Configuración publicada | Versión de parámetros disponible para que el dispositivo la consulte. |
| Configuración aplicada | Versión que el dispositivo confirma haber recibido. |
| Sincronización offline | Envío posterior de eventos que el dispositivo guardó mientras no tenía conexión. |
| Token de aprovisionamiento | Credencial temporal para registrar/preparar un dispositivo; debe tratarse como secreto. |


