---
title: Copiare un set di dati tra le cronologie
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


Esistono 3 modi per copiare i set di dati tra le cronologie

1. Dalla cronologia originale

    1. Cliccare sull'icona {% icon galaxy-gear %} che si trova in cima all'elenco dei dataset nel pannello della cronologia
    2. Fare clic su **Copia set di dati**
    3. Selezionare i file desiderati {% if include.history_name %}
    4. "Nuova cronologia denominata:" `{{ include.history_name }}` {% else %}
    4. Dare un nome rilevante alla "Nuova cronologia" {% endif %}
    5. Convalida per 'Copia elementi della cronologia'
    5. Fare clic sul nome della nuova cronologia nel riquadro verde appena visualizzato per passare a questa cronologia

2. Utilizzo dell'icona {% icon galaxy-columns %} **Mostra le cronologie affiancate**

    1. Fare clic sulla freccia a discesa {% icon galaxy-dropdown %} in alto a destra del pannello della cronologia (**opzioni cronologia**)
    2. Cliccare su {% icon galaxy-columns %} **Mostra le cronologie affiancate**
    3. se la cronologia di destinazione non è presente
        1. Fare clic su "Seleziona cronologia"
        2. Fare clic sulla cronologia di destinazione
        3. Convalidare con 'Cambia selezionato'
    3. Trascinare il dataset da copiare dalla sua cronologia originale
    4. rilasciarlo nella cronologia di destinazione

3. Dalla cronologia di destinazione

    1. Cliccare su **Utente** nella barra in alto
    2. Cliccare su **Datasets**
    3. Ricerca del set di dati da copiare
    4. Fare clic sul suo nome
    5. Cliccare su **Copia nella cronologia corrente**

