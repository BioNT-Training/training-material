---
title: Rinominare un set di dati
area: datasets
box_type: tip
layout: faq
contributors:
- bebatut
- nsoranzo
- shiltemann
- wm75
- hexylena
optional_parameters:
  name: The new name for the dataset
examples:
  Without prescribing a name: {}
  Suggest the user rename the dataset genomes.fa:
    name: genomes.fa
---


- Fare clic sull'icona {% galaxy-pencil %} **icona della matita** per il set di dati per modificarne gli attributi
- Nel pannello centrale, cambiare il campo **Name** {% if include.name %} in `{{ include.name }}` {% endif %}
- Fare clic sul pulsante **Save**

