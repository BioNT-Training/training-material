---
title: Modifica del tipo di dato
description: Galaxy will try to autodetect the datatype of your files, but you may
  need to manually set this occasionally.
area: datasets
box_type: tip
layout: faq
contributors:
- bebatut
- nsoranzo
- hexylena
- shiltemann
- ajadi-abiola
- lldelisle
- nekrut
optional_parameters:
  datatype: A string representing the Galaxy datatype
examples:
  Assign datatype without specifying the datatype: {}
  Assign datatype with a specific datatype:
    datatype: fastqsanger
---


* Cliccare sull'icona {% icon galaxy-pencil %} **icona della matita** per il set di dati per modificarne gli attributi
* Nel pannello centrale, fare clic su {% icon galaxy-chart-select-data %} *scheda *Datipi** in alto
* Nella sezione {% icon galaxy-chart-select-data %} **Assegna tipo di dato**, selezionare {% if include.datatype %}`{{ include.datatype }}`{% else %} il tipo di dato desiderato {% endif %} dal menu a discesa "*Nuovo tipo*"
  - Suggerimento: si può iniziare a digitare il tipo di dato nel campo per filtrare il menu a discesa
* Fare clic sul pulsante **Salva**

