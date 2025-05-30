---
title: Importieren über Links
area: data upload
box_type: tip
layout: faq
contributors:
- bebatut
- hexylena
- mtekman
- lecorguille
- shiltemann
- nomadscientist
- nekrut
- mblue9
optional_parameters:
  reset_form: Tell the user to reset the form first
  collection: Adds step to click the collection button
  collection_type: Suggests a collection type
  link: (Deprecated) Instead of collections use a link-type input
  link2: (Deprecated) Second link
  format: Suggests a format for the user to set
  genome: Suggests a genome for the user to set
  pairswaptext: Provides a filter for the pair detection
  collection_name_convention: Suggests a naming convention for the collection
examples:
  Import a list of files:
    collection: 'true'
    collection_type: List
    collection_name: raw_files
    format: thermo.raw
  Create a paired collection with a given naming scheme:
    collection: 'true'
    collection_type: Paired
    collection_name_convention: '''&lt;name&gt;_&lt;plate&gt;_&lt;batch&gt;'' to preserve
      the sample names, sequencing plate number and batch number.'
    collection_name: Here we will write 'C57_P1_B1'
    genome: GRCm38/mm10
    pairswaptext: '''SRR5683689_1'' and ''SRR5683689_2'''
  Import an interval file with specified genome, though providing the links in a code block is preferred:
    link: https://zenodo.org/record/3254917/files/chr21.gtf
    format: interval
    genome: mm9
---


* Kopieren der Linkposition
* Klicken Sie auf {% icon galaxy-upload %} **Daten hochladen** am oberen Rand der Werkzeugleiste {% if include.reset_form %}
* Klicken Sie auf die Schaltfläche **Zurücksetzen** am unteren Rand des Formulars. Wenn die Schaltfläche ausgegraut ist -> zum nächsten Schritt übergehen. {% endif %} {% if include.collection %}
* Klicken Sie oben auf **Sammlung** {% endif %} {% if include.collection_type %}
* Klicken Sie auf **Sammlungstyp** und wählen Sie `{{ include.collection_type }}` {% endif %}
* Wählen Sie {% icon galaxy-wf-edit %} **Daten einfügen/holen**
* Fügen Sie den/die Link(s) in das Textfeld ein {% if include.link %} `{{ include.link }}` {% endif %} {% if include.link2 %} `{{ include.link2 }}` {% endif %} {% if include.format %}
* Ändern Sie **Type (set all):** von "Auto-detect" auf `{{ include.format }}` {% endif %} {% if include.genome %}
* **Genom** auf `{{ include.genome }}` ändern {% endif %}
* Drücken Sie **Start** {% if include.collection %}
* Klicken Sie auf **Build** wenn verfügbar {% if include.pairswaptext %}
* Stellen Sie sicher, dass die Vorwärts- und Rückwärtslesungen jeweils auf {{ include.pairswaptext }} gesetzt sind.
    * Klick auf **Tauschen** sonst {% endif %}
* Geben Sie einen Namen für die Sammlung ein {% if include.collection_name_convention %}
    * Eine nützliche Namenskonvention ist die Verwendung von {{ include.collection_name_convention }} {% endif %} {% if include.collection_name %}
    * {{ include.collection_name }} {% endif %}
* Klicken Sie auf **Liste erstellen** (und warten Sie ein wenig) {% else %}
* **Schließen** Sie das Fenster {% endif %}

