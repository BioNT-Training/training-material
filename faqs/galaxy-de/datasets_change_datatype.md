---
title: Ändern des Datentyps
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


* Klicken Sie auf das {% icon galaxy-pencil %} **Bleistift-Symbol** für den Datensatz, um seine Attribute zu bearbeiten
* Klicken Sie im zentralen Panel auf {% icon galaxy-chart-select-data %} *registerkarte *Datentypen** oben
* Im Feld {% icon galaxy-chart-select-data %} **Datentyp zuweisen**, wählen Sie {% if include.datatype %}`{{ include.datatype }}`{% else %} Ihren gewünschten Datentyp {% endif %} aus dem "*Neuer Typ*"-Dropdown
  - Tipp: Sie können mit der Eingabe des Datentyps in das Feld beginnen, um das Dropdown-Menü zu filtern
* Klicken Sie auf die Schaltfläche **Speichern**

