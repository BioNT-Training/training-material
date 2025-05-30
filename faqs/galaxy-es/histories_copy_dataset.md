---
title: Copiar un conjunto de datos entre historiales
description: Sometimes you may want to use a dataset in multiple histories. You do
  not need to re-upload the data, but you can copy datasets from one history to another.
area: histories
box_type: tip
layout: faq
contributors:
- lecorguille
- shiltemann
- hexylena
- bebatut
- lldelisle
---


Hay 3 formas de copiar conjuntos de datos entre historiales

1. Del historial original

    1. Haga clic en el icono {% icono galaxy-gear %} que se encuentra en la parte superior de la lista de conjuntos de datos en el panel de historial
    2. Haga clic en **Copiar conjuntos de datos**
    3. Seleccione los archivos deseados {% if include.history_name %}
    4. "Nuevo historial llamado:" `{{ include.history_name }}` {% else %}
    4. Dé un nombre relevante al "Nuevo historial" {% endif %}
    5. Validar por 'Copiar elementos del historial'
    5. Haga clic en el nombre de la nueva historia en el cuadro verde que acaba de aparecer para cambiar a esta historia

2. Uso del {% icono galaxy-columns %} **Mostrar Historias lado a lado**

    1. Haga clic en la flecha desplegable {% icono galaxia-desplegable %} arriba a la derecha del panel de historial (**Opciones de historial**)
    2. Haga clic en {% icono galaxia-columnas %} **Mostrar Historias lado a lado**
    3. Si el historial de destino no está presente
        1. Haga clic en "Seleccionar historiales
        2. Haga clic en el historial de destino
        3. Validar por 'Cambiar seleccionado'
    3. Arrastre el conjunto de datos a copiar desde su historial original
    4. Colócalo en el historial de destino

3. Del historial de destino

    1. Haga clic en **Usuario** en la barra superior
    2. Haga clic en **Conjuntos de datos**
    3. Buscar el conjunto de datos a copiar
    4. Haga clic en su nombre
    5. Haga clic en **Copiar al historial actual**

