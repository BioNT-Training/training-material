---
layout: tutorial_hands_on

title: "Reference-basierte RNA-Seq-Datenanalyse"
subtopic: introduction
priority: 2

tags:
    - bulk
    - rna-seq
    - collections
    - drosophila
    - QC
    - cyoa
level: Introductory
zenodo_link: "https://zenodo.org/record/6457007"
questions:
    - Was sind die Schritte zur Verarbeitung von RNA-Seq-Daten?
    - Wie identifiziert man differentielle Genexpression über mehrere experimentelle Bedingungen hinweg?
    - Welche biologischen Funktionen werden durch die differentielle Expression von Genen beeinflusst?
objectives:
    - Überprüfe einen von FastQC für RNA-Seq-Daten generierten Qualitätsbericht
    - Erkläre das Prinzip und die Spezifität der Zuordnung von RNA-Seq-Daten zu einem eukaryotischen Referenzgenom
    - Wähle und führe ein modernes Mapping-Tool für RNA-Seq-Daten aus
    - Bewerte die Qualität der Mapping-Ergebnisse
    - Beschreibe den Prozess zur Schätzung der Bibliothekssträngigkeit
    - Schätze die Anzahl der Reads pro Gen
    - Erkläre die Zählnormalisierung, die vor dem Vergleich der Proben durchgeführt werden muss
    - Konstruiere und führe eine Analyse der differentiellen Genexpression durch
    - Analysiere die DESeq2-Ausgabe, um differentielle Gene zu identifizieren, zu annotieren und zu visualisieren
    - Führe eine Genontologie-Anreicherungsanalyse durch
    - Führe eine Anreicherungsanalyse für KEGG-Pfade durch und visualisiere sie
time_estimation: 8h
key_points:
    - Ein spliced Mapping-Tool sollte für eukaryotische RNA-Seq-Daten verwendet werden
    - Zahlreiche Faktoren müssen bei der Durchführung einer Analyse der differentiellen Genexpression berücksichtigt werden
follow_up_training:
    -
        type: "internal"
        topic_name: transcriptomics
        tutorials:
            - rna-seq-viz-with-heatmap2
            - rna-seq-viz-with-volcanoplot
            - rna-seq-genes-to-pathways

contributions:
  authorship:
    - bebatut
    - malloryfreeberg
    - moheydarian
    - erxleben
    - pavanvidem
    - blankclemens
    - mblue9
    - nsoranzo
    - pvanheus
    - lldelisle
  editing:
    - hexylena
---

In den letzten Jahren hat sich die RNA-Sequenzierung (kurz RNA-Seq) zu einer weit verbreiteten Technologie entwickelt, um das sich kontinuierlich verändernde zelluläre Transkriptom zu analysieren, d.h. die Gesamtheit aller RNA-Moleküle in einer Zelle oder einer Zellpopulation. Ein häufiges Ziel von RNA-Seq ist das Profiling der Genexpression, indem Gene oder molekulare Wege identifiziert werden, die zwischen zwei oder mehr biologischen Bedingungen differentziell exprimiert sind (DE). Dieses Tutorial demonstriert einen computergestützten Arbeitsablauf zur Erkennung von DE-Genen und -Wegen aus RNA-Seq-Daten, indem eine vollständige Analyse eines RNA-Seq-Experiments gezeigt wird, das *Drosophila*-Zellen nach der Depletion eines regulatorischen Gens profiliert.

In der Studie {% cite brooks2011conservation %} identifizierten die Autoren Gene und Wege, die vom *Pasilla*-Gen (dem *Drosophila*-Homologen der Säugetier-Splicing-Regulatoren Nova-1 und Nova-2-Proteine) reguliert werden, unter Verwendung von RNA-Seq-Daten. Sie depleted das *Pasilla*-Gen (*PS*) in *Drosophila melanogaster* durch RNA-Interferenz (RNAi). Gesamt-RNA wurde dann isoliert und verwendet, um sowohl Single-End- als auch Pair-End-RNA-Seq-Bibliotheken für behandelte (PS depleted) und unbehandelte Proben vorzubereiten. Diese Bibliotheken wurden sequenziert, um RNA-Seq-Reads für jede Probe zu erhalten. Die RNA-Seq-Daten für die behandelten und unbehandelten Proben können verglichen werden, um die Auswirkungen der Depletion des *Pasilla*-Gens auf die Genexpression zu identifizieren.

In diesem Tutorial illustrieren wir die Analyse der Genexpressionsdaten Schritt für Schritt anhand von 7 der ursprünglichen Datensätze:

- 4 unbehandelte Proben: [GSM461176](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM461176), [GSM461177](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM461177), [GSM461178](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM461178), [GSM461182](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM461182)
- 3 behandelte Proben (*Pasilla*-Gen durch RNAi depleted): [GSM461179](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM461179), [GSM461180](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM461180), [GSM461181](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM461181)

Jede Probe stellt ein separates biologisches Replikat der entsprechenden Bedingung (behandelt oder unbehandelt) dar. Darüber hinaus stammen zwei der behandelten und zwei der unbehandelten Proben aus einer Pair-End-Sequenzierung, während die verbleibenden Proben aus einem Single-End-Sequenzierungsexperiment stammen.

> <comment-title>Vollständige Daten</comment-title>
>
> Die Originaldaten sind im NCBI Gene Expression Omnibus (GEO) unter der Zugangsnummer [GSE18508](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE18508) verfügbar. Die Roh-RNA-Seq-Reads wurden aus den Sequence Read Archive (SRA)-Dateien extrahiert und in FASTQ-Dateien umgewandelt.
{: .comment}
>
> <agenda-title></agenda-title>
>
> In diesem Tutorial werden wir uns mit folgendem beschäftigen:
>
> 1. TOC
> {:toc}
>
{: .agenda}

# Daten-Upload

Im ersten Teil dieses Tutorials verwenden wir die Dateien für 2 der 7 Proben, um zu demonstrieren, wie man Lesezahlen (ein Maß für die Genexpression) aus FASTQ-Dateien berechnet (Qualitätskontrolle, Mapping, Lesezählung). Wir stellen die FASTQ-Dateien für die anderen 5 Proben zur Verfügung, wenn du die gesamte Analyse später reproduzieren möchtest.

Im zweiten Teil des Tutorials werden die Lesezahlen aller 7 Proben verwendet, um die DE-Gene, Genfamilien und molekularen Wege aufgrund der Depletion des *PS*-Gens zu identifizieren und zu visualisieren.

> <hands-on-title>Daten-Upload</hands-on-title>
>
> 1. Erstelle eine neue Historie für diese RNA-Seq-Übung
>
>    {% snippet faqs/galaxy/histories_create_new.md %}
>
> 2. Importiere die FASTQ-Dateipärchen von [Zenodo]({{ page.zenodo_link }}) oder aus einer Datenbibliothek:
>    - `GSM461177` (unbehandelt): `GSM461177_1` und `GSM461177_2`
>    - `GSM461180` (behandelt): `GSM461180_1` und `GSM461180_2`
>
>    ```text
>    {{ page.zenodo_link }}/files/GSM461177_1.fastqsanger
>    {{ page.zenodo_link }}/files/GSM461177_2.fastqsanger
>    {{ page.zenodo_link }}/files/GSM461180_1.fastqsanger
>    {{ page.zenodo_link }}/files/GSM461180_2.fastqsanger
>    ```
>
>    {% snippet faqs/galaxy/datasets_import_via_link.md %}
>
>    {% snippet faqs/galaxy/datasets_import_from_data_library.md %}
>
>    > <comment-title></comment-title>
>    >
>    > Beachte, dass dies die vollständigen Dateien für die Proben sind und jeweils ~1,5 Gb groß, sodass der Import einige Minuten dauern kann.
>    >
>    > Für eine schnellere Durchsicht der FASTQ-Schritte kann hier auf [Zenodo]({{ page.zenodo_link }}) eine kleine Teilmenge jeder FASTQ-Datei (~5 Mb) gefunden werden:
>    >
>    > ```text
>    > {{ page.zenodo_link }}/files/GSM461177_1_subsampled.fastqsanger
>    > {{ page.zenodo_link }}/files/GSM461177_2_subsampled.fastqsanger
>    > {{ page.zenodo_link }}/files/GSM461180_1_subsampled.fastqsanger
>    > {{ page.zenodo_link }}/files/GSM461180_2_subsampled.fastqsanger
>    > ```
>    >
>    {: .comment}
>
> 3. Überprüfe, ob der Datentyp `fastqsanger` ist (z.B. **nicht** `fastq`). Falls nicht, ändere den Datentyp auf `fastqsanger`.
>
>    {% snippet faqs/galaxy/datasets_change_datatype.md datatype="fastqsanger" %}
>
> 4. Erstelle eine gepaarte Sammlung mit dem Namen `2 PE fastqs`, benenne deine Paare um mit dem Probenamen gefolgt von den Attributen: `GSM461177_untreat_paired` und `GSM461180_treat_paired`.
>
>    {% snippet faqs/galaxy/collections_build_list_paired.md %}
>
{: .hands_on}

{% include topics/sequence-analysis/tutorials/quality-control/fastq_question.md %}

Die Reads sind Rohdaten von der Sequenzierungsmaschine ohne jegliche Vorbehandlung. Sie müssen auf ihre Qualität überprüft werden.

# Qualitätskontrolle

Während der Sequenzierung werden Fehler eingeführt, wie z.B. falsche Nukleotide. Diese entstehen durch die technischen Einschränkungen der jeweiligen Sequenzierungsplattform. Sequenzierungsfehler können die Analyse verzerren und zu einer Fehlinterpretation der Daten führen. Adapter können ebenfalls vorhanden sein, wenn die Reads länger sind als die sequenzierten Fragmente, und deren Entfernung kann die Anzahl der gemappten Reads verbessern.

Die Qualitätskontrolle der Sequenzen ist daher ein wesentlicher erster Schritt in deiner Analyse. Wir werden ähnliche Werkzeuge wie im ["Qualitätskontrolle"-Tutorial]({% link topics/sequence-analysis/tutorials/quality-control/tutorial.md %}) verwenden: [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) zur Erstellung eines Berichts über die Sequenzqualität, [MultiQC](https://multiqc.info/) ({% cite ewels2016multiqc %}) zur Aggregation der generierten Berichte und [Cutadapt](https://cutadapt.readthedocs.io/en/stable/guide.html) ({% cite marcel2011cutadapt %}) zur Verbesserung der Sequenzqualität durch Trimmen und Filtern.

Leider unterstützt die aktuelle Version von MultiQC (dem Werkzeug, das wir zur Kombination der Berichte verwenden) keine Listen von gepaarten Sammlungen.
Wir müssen zunächst die Liste der Paare in eine einfache Liste umwandeln.

> <details-title>Was bedeutet das genau?</details-title>
>
> Die aktuelle Situation ist oben und das **Flatten collection**-Werkzeug wird sie in die unten dargestellte Situation umwandeln:
> ![Flatten](../../images/ref-based/flatten.png "Flatten die Liste der Paare in eine Liste")
{: .details}

> <hands-on-title>Qualitätskontrolle</hands-on-title>
>
> 1. {% tool [Flatten collection](__FLATTEN__) %} mit den folgenden Parametern, um die Liste der Paare in eine einfache Liste umzuwandeln:
>     - *"Input Collection"*: `2 PE fastqs`
>
> 2. {% tool [FastQC](toolshed.g2.bx.psu.edu/repos/devteam/fastqc/fastqc/0.73+galaxy0) %} mit den folgenden Parametern:
>    - {% icon param-collection %} *"Short read data from your current history"*: Output von **Flatten collection** {% icon tool %} ausgewählt als **Dataset collection**
>
>    {% snippet faqs/galaxy/tools_select_collection.md %}
>
> 3. Überprüfe die Webseiten-Ausgabe von **FastQC** {% icon tool %} für die Probe `GSM461177_untreat_paired` (vorwärts und rückwärts)
>
>    > <question-title></question-title>
>    >
>    > Wie lang sind die Reads?
>    >
>    > > <solution-title></solution-title>
>    > >
>    > > Die Read-Länge beider Paare beträgt 37 bp.
>    > >
>    > {: .solution}
>    >
>    {: .question}
>
>    Da es mühsam ist, all diese Berichte einzeln zu überprüfen, werden wir sie mit {% tool [MultiQC](toolshed.g2.bx.psu.edu/repos/iuc/multiqc/multiqc/1.11+galaxy1) %} kombinieren.
>
> 4. {% tool [MultiQC](toolshed.g2.bx.psu.edu/repos/iuc/multiqc/multiqc/1.11+galaxy1) %} zur Aggregation der FastQC-Berichte mit den folgenden Parametern:
>    - In *"Results"*:
>        - *"Results"*
>            - *"Welches Werkzeug wurde verwendet, um Logs zu erstellen?"*: `FastQC`
>                - In *"FastQC output"*:
>                    - {% icon param-repeat %} *"Füge FastQC-Ausgabe ein"*
>                        - {% icon param-collection %} *"FastQC output"*: `FastQC on collection N: Raw data` (Output von **FastQC** {% icon tool %})
> 5. Untersuche die Webseiten-Ausgabe von MultiQC für jede FASTQ-Datei
>
>    > <question-title></question-title>
>    >
>    > 1. Was denkst du über die Qualität der Sequenzen?
>    > 2. Was sollten wir tun?
>    >
>    > > <solution-title></solution-title>
>    > >
>    > > 1. Alles scheint für 3 der Dateien gut zu sein. Die `GSM461177_untreat_paired` hat 10,6 Millionen gepaarte Sequenzen und `GSM461180_treat_paired` 12,3 Millionen gepaarte Sequenzen. Aber bei `GSM461180_treat_paired_reverse` (Reverse-Reads von GSM461180) sinkt die Qualität gegen Ende der Sequenzen erheblich.
>    > >
>    > >    Alle Dateien außer `GSM461180_treat_paired_reverse` haben einen hohen Anteil an duplizierten Reads (erwartet bei RNA-Seq-Daten).
>    > >
>    > >    ![Sequence Counts](../../images/ref-based/fastqc_sequence_counts_plot.png "Sequence Counts")
>    > >
>    > >    Die "Per base sequence quality" ist insgesamt gut, mit einem leichten Rückgang am Ende der Sequenzen. Für `GSM461180_treat_paired_reverse` ist der Rückgang jedoch ziemlich stark.
>    > >
>    > >    ![Sequence Quality](../../images/ref-based/fastqc_per_base_sequence_quality_plot.png "Sequence Quality")
>    > >
>    > >    Der durchschnittliche Qualitätswert über die Reads ist ziemlich hoch, aber die Verteilung ist für `GSM461180_treat_paired_reverse` etwas anders.
>    > >
>    > >    ![Per Sequence Quality Scores](../../images/ref-based/fastqc_per_sequence_quality_scores_plot.png "Per Sequence Quality Scores")
>    > >
>    > >    Die Reads folgen nicht wirklich einer Normalverteilung des GC-Gehalts, außer bei `GSM461180_treat_paired_reverse`.
>    > >
>    > >    ![Per Sequence GC Content](../../images/ref-based/fastqc_per_sequence_gc_content_plot.png "Per Sequence GC Content")
>    > >
>    > >    Der Anteil an N in den Reads (Basen, die nicht bestimmt werden konnten) ist gering.
>    > >
>    > >    ![Per base N content](../../images/ref-based/fastqc_per_base_n_content_plot.png "Per base N content")
>    > >
>    > >    Duplizierte Sequenzen: >10 bis >500
>    > >
>    > >    ![Sequence Duplication Levels](../../images/ref-based/fastqc_sequence_duplication_levels_plot.png "Sequence Duplication Levels")
>    > >
>    > >    Es gibt fast keine bekannten Adapter und überrepräsentierten Sequenzen.
>    > >
>    > > 2. Wenn die Qualität der Reads schlecht ist, sollten wir:
>    > >    1. Überprüfen, was falsch ist und mögliche Gründe für die schlechte Read-Qualität in Betracht ziehen: Dies kann vom Sequenzierungstyp oder dem, was wir sequenziert haben, kommen (hohe Menge an überrepräsentierten Sequenzen in Transkriptomik-Daten, verzerrter Prozentsatz von Basen in Hi-C-Daten).
>    > >    2. Das Sequenzierungszentrum danach fragen.
>    > >    3. Einige Qualitätsbehandlungen durchführen (darauf achten, nicht zu viele Informationen zu verlieren) mit Trimmen oder Entfernen von schlechten Reads.
>    > >
>    > {: .solution}
>    {: .question}
>
{: .hands_on}

Wir sollten die Reads trimmen, um Basen zu entfernen, die mit hoher Unsicherheit sequenziert wurden (d.h. Low-Quality-Basen) an den Enden der Reads, und auch die Reads von insgesamt schlechter Qualität entfernen.

{% include topics/sequence-analysis/tutorials/quality-control/paired_end_question.md forward="GSM461177_untreat_paired_forward" reverse="GSM461177_untreat_paired_reverse" %}

> <hands-on-title>Trimmen von FASTQs</hands-on-title>
>
> 1. {% tool [Cutadapt](toolshed.g2.bx.psu.edu/repos/lparsons/cutadapt/cutadapt/4.0+galaxy1) %} mit den folgenden Parametern, um Sequenzen niedriger Qualität zu trimmen:
>    - *"Single-end oder Paired-end Reads?"*: `Paired-end Collection`
>       - {% icon param-collection %} *"Paired Collection"*: `2 PE fastqs`
>    - In *"Filter Options"*
>       - *"Mindestlänge (R1)"*: `20`
>    - In *"Read Modification Options"*
>       - *"Qualitätsschwelle"*: `20`
>    - In *"Outputs selector"*
>       - Wähle: `Report: Cutadapt's per-adapter statistics. You can use this file with MultiQC.`
>
>      {% include topics/sequence-analysis/tutorials/quality-control/trimming_question.md %}
>
> 2. {% tool [MultiQC](toolshed.g2.bx.psu.edu/repos/iuc/multiqc/multiqc/1.11+galaxy1) %} zur Aggregation der Cutadapt-Berichte mit den folgenden Parametern:
>    - In *"Results"*:
>        - {% icon param-repeat %} *"Results"*
>            - *"Welches Werkzeug wurde verwendet, um Logs zu erstellen?"*: `Cutadapt/Trim Galore!`
>               - {% icon param-collection %} *"Output von Cutadapt"*: `Cutadapt on collection N: Report` (Output von **Cutadapt** {% icon tool %}) ausgewählt als **Dataset collection**
>
>    > <question-title></question-title>
>    >
>    > 1. Wie viele Sequenzpaare wurden entfernt, weil mindestens ein Read kürzer als die Längenschwelle war?
>    > 2. Wie viele Basenpaare wurden von den Forward-Reads wegen schlechter Qualität entfernt? Und von den Reverse-Reads?
>    >
>    > > <solution-title></solution-title>
>    > >
>    > > 1. 147.810 (1,4%) Reads waren für `GSM461177_untreat_paired` zu kurz und 1.101.875 (9%) für `GSM461180_treat_paired`.
>    > >    ![Cutadapt Filtered reads](../../images/ref-based/cutadapt_filtered_reads_plot.png "Cutadapt Filtered reads")
>    > > 2. Die MultiQC-Ausgabe bietet nur den Anteil der insgesamt getrimmten Basenpaare an, nicht für jeden Read. Um diese Information zu erhalten, musst du in die einzelnen Berichte zurückgehen. Für `GSM461177_untreat_paired` wurden 5.072.810 bp von den Forward-Reads (Read 1) und 8.648.619 bp von den Reverse-Reads (Read 2) wegen Qualität getrimmt. Für `GSM461180_treat_paired` wurden 10.224.537 bp von den Forward-Reads und 51.746.850 bp von den Reverse-Reads getrimmt. Das ist nicht überraschend; wir haben gesehen, dass die Qualität am Ende der Reads insbesondere für `GSM461180_treat_paired` stärker abfällt.
>    > {: .solution }
>    {: .question}
{: .hands_on}

# Mapping

Um die Reads zu interpretieren, müssen wir zunächst herausfinden, woher die Sequenzen im Genom stammen, damit wir dann bestimmen können, zu welchen Genen sie gehören. Wenn ein Referenzgenom für das Organismus verfügbar ist, wird dieser Prozess als Ausrichten oder "Mapping" der Reads auf das Referenzgenom bezeichnet. Dies ist vergleichbar mit dem Lösen eines Puzzles, aber leider sind nicht alle Teile einzigartig.
> <comment-title></comment-title>
>
> Möchtest du mehr über die Prinzipien hinter dem Mapping lernen? Folge unserem [Training]({% link topics/sequence-analysis/tutorials/mapping/tutorial.md %}).
{: .comment}

In dieser Studie haben die Autoren *Drosophila melanogaster*-Zellen verwendet. Daher sollten wir die qualitätskontrollierten Sequenzen auf das Referenzgenom von *Drosophila melanogaster* abgleichen.

{% include topics/sequence-analysis/tutorials/mapping/ref_genome_explanation.md answer_3="Das Genom von *Drosophila melanogaster* ist bekannt und vollständig montiert und kann als Referenzgenom in dieser Analyse verwendet werden. Beachte, dass neue Versionen von Referenzgenomen veröffentlicht werden können, wenn die Montage verbessert wird. Für dieses Tutorial verwenden wir die Version 6 der Referenzgenom-Montage von *Drosophila melanogaster* [(dm6)](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4383921/)." %}

Bei eukaryotischen Transkriptomen stammen die meisten Reads von prozessierten mRNAs, die Introns fehlen:

![Types of RNA-Seq reads](../../images/ref-based/rna-seq-reads.png "Die Arten von RNA-seq Reads (Anpassung von Abbildung 1a aus {% cite kim2015hisat %}): Reads, die vollständig innerhalb eines Exons liegen (in Rot), Reads, die über 2 Exons hinwegspannen (in Blau), Reads, die über mehr als 2 Exons hinwegspannen (in Lila)")

Daher können sie nicht einfach wie bei DNA-Daten auf das Genom zurückgemappt werden. Splice-aware Mapper wurden entwickelt, um Transkript-abgeleitete Reads effizient gegen ein Referenzgenom abzugleichen:

![Splice-aware alignment](../../images/transcriptomics_images/splice_aware_alignment.png "Prinzip von spliced mappers: (1) Identifizierung der Reads, die ein einzelnes Exon überspannen, (2) Identifizierung der Splicing Junctions an den nicht gemappten Reads")

> <details-title>Weitere Details zu den verschiedenen spliced mappers</details-title>
>
> Mehrere spliced Mapper wurden in den letzten Jahren entwickelt, um die Explosion von RNA-Seq-Daten zu verarbeiten.
>
> [**TopHat**](https://ccb.jhu.edu/software/tophat/index.shtml) ({% cite trapnell2009tophat %}) war eines der ersten Werkzeuge, die speziell entwickelt wurden, um dieses Problem zu adressieren. In **TopHat** werden Reads gegen das Genom abgebildet und in zwei Kategorien unterteilt: (1) diejenigen, die abgebildet werden, und (2) diejenigen, die anfänglich nicht gemappt sind (IUM). "Haufen" von Reads, die potenzielle Exons darstellen, werden auf mögliche Donor/Acceptor-Splice-Stellen erweitert, und potenzielle Splice-Junctions werden rekonstruiert. IUMs werden dann auf diese Junctions gemappt.
>
> ![TopHat](../../images/transcriptomics_images/tophat.png "TopHat (Abbildung 1 aus {% cite trapnell2009tophat %})")
>
> **TopHat** wurde später mit der Entwicklung von **TopHat2** ({% cite kim2013tophat2 %}) verbessert:
>
> ![TopHat2](../../images/transcriptomics_images/13059_2012_Article_3053_Fig6_HTML.jpg "TopHat2 (Abbildung 6 aus {% cite kim2013tophat2 %})")
>
> Um die spliced Read-Ausrichtung weiter zu optimieren und zu beschleunigen, wurde [**HISAT2**](https://ccb.jhu.edu/software/hisat2/index.shtml) ({% cite kim2019graph %}) entwickelt. Es verwendet einen hierarchischen Graphen [FM](https://en.wikipedia.org/wiki/FM-index) (HGFM)-Index, der das gesamte Genom und mögliche Varianten darstellt, zusammen mit überlappenden lokalen Indizes (jeweils etwa 57 kb), die zusammen das Genom und seine Varianten abdecken. Dies ermöglicht es, anfängliche Seed-Standorte für potenzielle Read-Ausrichtungen im Genom mithilfe des globalen Index zu finden und diese Ausrichtungen mithilfe des entsprechenden lokalen Index schnell zu verfeinern:
>
> ![Hierarchical Graph FM index in HISAT/HISAT2](../../images/transcriptomics_images/hisat.png "Hierarchical Graph FM index in HISAT/HISAT2 (Abbildung S8 aus {% cite kim2015hisat %})")
>
> Ein Teil des Reads (blaue Pfeil) wird zuerst mithilfe des globalen FM-Index auf das Genom gemappt. **HISAT2** versucht dann, die Ausrichtung direkt unter Verwendung der Genomsequenz (violetter Pfeil) zu erweitern. In (**a**) gelingt dies und dieser Read ist ausgerichtet, da er vollständig innerhalb eines Exons liegt. In (**b**) trifft die Erweiterung auf eine Fehlanpassung. Jetzt nutzt **HISAT2** den lokalen FM-Index, der diesen Ort überlappt, um die geeignete Abbildung für den verbleibenden Teil dieses Reads zu finden (grüner Pfeil). (**c**) zeigt eine Kombination dieser beiden Strategien: Der Anfang des Reads wird mithilfe des globalen FM-Index (blauer Pfeil) gemappt, bis er das Ende des Exons erreicht (violetter Pfeil), dann wird er mithilfe des lokalen FM-Index (grüner Pfeil) gemappt und erneut erweitert (violetter Pfeil).
>
> [**STAR** aligner](https://github.com/alexdobin/STAR) ({% cite dobin2013star %}) ist eine schnelle Alternative zum Mapping von RNA-Seq-Reads gegen ein Referenzgenom unter Verwendung eines unkomprimierten [Suffixarrays](https://en.wikipedia.org/wiki/Suffix_array). Es arbeitet in zwei Phasen. In der ersten Phase wird eine Seed-Suche durchgeführt:
>
> ![STAR's seed search](../../images/transcriptomics_images/star.png "STAR's seed search (Abbildung 1 aus {% cite dobin2013star %})")
>
> Hier wird ein Read zwischen zwei aufeinander folgenden Exons aufgeteilt. **STAR** beginnt, nach einem maximal abbildbaren Präfix (MMP) vom Anfang des Reads zu suchen, bis es nicht mehr kontinuierlich übereinstimmen kann. Nach diesem Punkt beginnt es, nach einem MMP für den nicht übereinstimmenden Teil des Reads zu suchen (**a**). Im Falle von Fehlanpassungen (**b**) und nicht ausrichtbaren Regionen (**c**) dienen MMPs als Anker, um Ausrichtungen zu erweitern.
>
> In der zweiten Phase verbindet **STAR** MMPs, um Ausrichtungen auf Read-Ebene zu erzeugen, die (im Gegensatz zu MMPs) Fehlanpassungen und Indels enthalten können. Ein Bewertungsschema wird verwendet, um Stichkombinationen zu bewerten und zu priorisieren sowie Reads zu bewerten, die an mehreren Stellen abgebildet werden. **STAR** ist extrem schnell, erfordert jedoch eine erhebliche Menge an RAM, um effizient zu arbeiten.
>
{: .details}

## Mapping

Wir werden unsere Reads mit **STAR** ({% cite dobin2013star %}) auf das Genom von *Drosophila melanogaster* abgleichen.

> <hands-on-title>Spliced Mapping</hands-on-title>
>
> 1. Importiere die Ensembl-Geneannotation für *Drosophila melanogaster* (`Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf.gz`) aus der Shared Data-Bibliothek, falls verfügbar, oder von [Zenodo]({{ page.zenodo_link }}/files/Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf.gz) in deine aktuelle Galaxy-Historie.
>
>    ```text
>    {{ page.zenodo_link }}/files/Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf.gz
>    ```
>
>    1. Benenne das Dataset bei Bedarf um.
>    2. Überprüfe, ob der Datentyp `gtf` und nicht `gff` ist und dass die Datenbank `dm6` ist.
>
>    > <comment-title>Wie bekomme ich die Annotationsdatei?</comment-title>
>    >
>    > Annotationsdateien von Modellorganismen sind möglicherweise in der Shared Data-Bibliothek verfügbar (der Pfad zu ihnen kann von einem Galaxy-Server zum anderen variieren). Du kannst die Annotationsdatei auch von UCSC (mit dem **UCSC Main**-Tool) abrufen.
>    >
>    > Um diese spezifische Datei zu erstellen, wurde die Annotationsdatei von Ensembl heruntergeladen, die eine umfassendere Datenbank von Transkripten bietet, und weiter angepasst, um mit dem auf kompatiblen Galaxy-Servern installierten dm6-Genom zu arbeiten.
>    >
>    {: .comment}
>
> 2. {% tool [RNA STAR](toolshed.g2.bx.psu.edu/repos/iuc/rgrnastar/rna_star/2.7.10b+galaxy3) %} mit den folgenden Parametern verwenden, um deine Reads auf das Referenzgenom abzugleichen:
>    - *"Single-end or paired-end reads"*: `Paired-end (als Sammlung)`
>       - {% icon param-collection %} *"RNA-Seq FASTQ/FASTA paired reads"*: die `Cutadapt auf Sammlung N: Reads` (Ausgabe von **Cutadapt** {% icon tool %})
>    - *"Custom or built-in reference genome"*: `Verwende einen eingebauten Index`
>       - *"Referenzgenom mit oder ohne Annotation"*: `Verwende das Genomreferenz ohne eingebauten Genmodell, aber gib eine gtf an`
>           - *"Wähle Referenzgenom aus"*: `Fly (Drosophila melanogaster): dm6 Full`
>           - {% icon param-file %} *"Genmodell (gff3,gtf) Datei für Splice Junctions"*: die importierte `Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf.gz`
>           - *"Länge der genomischen Sequenz um annotierte Junctions"*: `36`
>
>               Dieser Parameter sollte die Länge der Reads minus 1 sein.
>    - *"Per gene/transcript output"*: `Per Gene Read Counts (GeneCounts)`
>    - *"Compute coverage"*:
>       - `Ja im Bedgraph-Format`
>
> 3. {% tool [MultiQC](toolshed.g2.bx.psu.edu/repos/iuc/multiqc/multiqc/1.11+galaxy1) %} verwenden, um die STAR-Logs mit den folgenden Parametern zu aggregieren:
>    - In *"Ergebnisse"*:
>        - *"Ergebnisse"*
>            - *"Welches Tool wurde verwendet, um Logs zu erstellen?"*: `STAR`
>                - In *"STAR-Ausgabe"*:
>                    - {% icon param-repeat %} *"STAR-Ausgabe einfügen"*
>                        - *"Art der STAR-Ausgabe?"*: `Log`
>                            - {% icon param-collection %} *"STAR-Log-Ausgabe"*: `RNA STAR auf Sammlung N: log` (Ausgabe von **RNA STAR** {% icon tool %})
>
>    > <question-title></question-title>
>    >
>    > 1. Welcher Prozentsatz der Reads wird für beide Proben genau einmal gemappt?
>    > 2. Welche anderen verfügbaren Statistiken gibt es?
>    >
>    > > <solution-title></solution-title>
>    > >
>    > > 1. Mehr als 83% für `GSM461177_untreat_paired` und 79% für `GSM461180_treat_paired`. Wir können mit der Analyse fortfahren, da nur Prozentsätze unter 70% auf potenzielle Kontamination untersucht werden sollten.
>    > > 2. Wir haben auch Zugriff auf die Anzahl und den Prozentsatz der Reads, die an mehreren Stellen abgebildet, an zu vielen verschiedenen Stellen abgebildet oder nicht abgebildet sind, weil sie zu kurz sind.
>    > >
>    > >    ![STAR Alignment Scores](../../images/ref-based/star_alignment_plot.png "Ausrichtungswerte")
>    > >
>    > >    Wir hätten möglicherweise strenger in Bezug auf die minimale Read-Länge sein können, um diese nicht abgebildeten Reads aufgrund der Länge zu vermeiden.
>    > {: .solution}
>    >
>    {: .question}
{: .hands_on}

Laut dem **MultiQC**-Bericht werden etwa 80% der Reads für beide Proben genau einmal auf das Referenzgenom abgebildet. Wir können mit der Analyse fortfahren, da nur Prozentsätze unter 70% auf potenzielle Kontamination untersucht werden sollten. Beide Proben haben einen niedrigen (weniger als 10%) Prozentsatz von Reads, die an mehreren Stellen im Referenzgenom abgebildet wurden. Dies liegt im normalen Bereich für Illumina-Kurz-Read-Sequenzierung, kann jedoch bei neueren Long-Read-Sequenzierungsdatensätzen, die größere wiederholte Regionen im Referenzgenom umfassen, höher sein und wird höher für 3'-End-Bibliotheken sein.

Die Hauptausgabe von **STAR** ist eine BAM-Datei.

{% include topics/sequence-analysis/tutorials/mapping/bam_explanation.md mapper="RNA STAR" %}

## Inspektion der Mapping-Ergebnisse

Die BAM-Datei enthält Informationen für alle unsere Reads, was es schwierig macht, sie im Textformat zu inspizieren und zu erkunden. Ein leistungsfähiges Werkzeug zur Visualisierung des Inhalts von BAM-Dateien ist der Integrative Genomics Viewer (**IGV**, {% cite robinson2011integrative %}).

> <hands-on-title>Inspektion der Mapping-Ergebnisse</hands-on-title>
>
> 1. Installiere [**IGV**](https://software.broadinstitute.org/software/igv/download) (falls noch nicht installiert)
> 2. Starte IGV lokal
> 3. Klicke auf die Sammlung `RNA STAR auf Sammlung N: mapped.bam` (Ausgabe von **RNA STAR** {% icon tool %})
> 4. Klappe die {% icon param-file %} `GSM461177_untreat_paired` Datei aus.
> 5. Klicke auf das {% icon galaxy-barchart %} Visualisierungs-Icon im `GSM461177` Datei-Block.
> 6. Klicke im mittleren Panel auf `local` in `Anzeige mit IGV (lokal, D. melanogaster (dm6))`, um die Reads in den IGV-Browser zu laden
>    > <comment-title></comment-title>
>    >
>    > Damit dieser Schritt funktioniert, musst du entweder IGV oder [Java Web Start](https://www.java.com/en/download/faq/java_webstart.xml) auf deinem Computer installiert haben. Die Fragen in diesem Abschnitt können jedoch auch durch Inspektion der IGV-Screenshots unten beantwortet werden.
>    >
>    > Überprüfe die [IGV-Dokumentation](https://software.broadinstitute.org/software/igv/AlignmentData) für weitere Informationen.
>    >
>    {: .comment}
>
> 6. **IGV** {% icon tool %}: Zoome auf `chr4:540,000-560,000` (Chromosom 4 zwischen 540 kb und 560 kb)
>
>    > <question-title></question-title>
>    >
>    > ![Screenshot der IGV-Ansicht auf Chromosom 4](../../images/transcriptomics_images/junction_igv_screenshot.png "Screenshot von IGV auf Chromosom 4")
>    >
>    > 1. Welche Informationen erscheinen oben als graue Spitzen?
>    > 2. Was zeigen die Verbindungslinien zwischen einigen der ausgerichteten Reads an?
>    >
>    > > <solution-title></solution-title>
>    > >
>    > > 1. Das Coverage-Plot: die Summe der abgebildeten Reads an jeder Position
>    > > 2. Sie zeigen Junction-Ereignisse (oder Splice-Stellen) an, *d.h.* Reads, die über ein Intron abgebildet sind
>    > >
>    > {: .solution}
>    {: .question}
> 7. **IGV** {% icon tool %}: Inspektiere die Splice Junctions mit einem **Sashimi-Diagramm**
>
>    > <comment-title>Erstellung eines Sashimi-Diagramms</comment-title>
>    >
>    > - Klicke mit der rechten Maustaste auf die BAM-Datei (in IGV)
>    > - Wähle **Sashimi Plot** aus dem Menü
>    >
>    {: .comment}
>    >
>    > <question-title></question-title>
>    >
>    > ![Screenshot eines Sashimi-Diagramms von Chromosom 4](../../images/transcriptomics_images/star_igv_sashimi.png "Screenshot eines Sashimi-Diagramms von Chromosom 4")
>    >
>    > 1. Was stellt das vertikale rote Balkendiagramm dar? Was ist mit den Bögen und Zahlen?
>    > 2. Was bedeuten die Zahlen auf den Bögen?
>    > 3. Warum beobachten wir verschiedene gestapelte Gruppen von blauen verbundenen Kästchen am unteren Rand?
>    >
>    > > <solution-title></solution-title>
>    > >
>    > > 1. Die Abdeckung für jede Ausrichtungs-Spur wird als rotes Balkendiagramm dargestellt. Bögen repräsentieren beobachtete Splice Junctions, *d.h.*, Reads, die Introns überbrücken.
>    > > 2. Die Zahlen beziehen sich auf die Anzahl der beobachteten Junction Reads.
>    > > 3. Die verschiedenen Gruppen von verbundenen Kästchen am unteren Rand repräsentieren die verschiedenen Transkripte der Gene an diesem Ort, die in der GTF-Datei vorhanden sind.
>    > >
>    > {: .solution}
>    {: .question}
>    >
>    > <comment-title></comment-title>
>    >
>    > Überprüfe die [IGV-Dokumentation zu Sashimi-Diagrammen](https://software.broadinstitute.org/software/igv/Sashimi) für weitere Hinweise.
>    {: .comment}
>
{: .hands_on}

> <details-title>Weitere Überprüfung der Datenqualität</details-title>
>
> Die Qualität der Daten und des Mappings kann weiter überprüft werden, z.B. durch Inspektion des Dupplikationsniveaus der Reads, der Anzahl der auf jedes Chromosom gemappten Reads, der Abdeckung der Genkörper und der Verteilung der Reads über Features.
>
> *Diese Schritte sind inspiriert von denjenigen im [großen „RNA-Seq reads to counts“-Tutorial]({% link topics/transcriptomics/tutorials/rna-seq-reads-to-counts/tutorial.md %}) und an unsere Datensätze angepasst.*
>
> #### Duplikat-Reads
>
> Im FastQC-Bericht haben wir gesehen, dass einige Reads dupliziert sind:
>
> ![Sequenz-Duplizierungsniveaus](../../images/ref-based/fastqc_sequence_duplication_levels_plot.png "Sequenz-Duplizierungsniveaus")
>
> Duplizierte Reads können von hoch exprimierten Genen stammen, daher werden sie normalerweise in der RNA-Seq-Differenzexpressionsanalyse beibehalten. Ein hoher Prozentsatz an Duplikaten kann jedoch auf ein Problem hindeuten, z.B. Überamplifikation während der PCR eines wenig komplexen Bibliotheks.
>
> **MarkDuplicates** aus der [Picard-Suite](http://broadinstitute.github.io/picard/) untersucht ausgerichtete Aufzeichnungen aus einer BAM-Datei, um doppelte Reads zu finden, d.h. Reads, die am selben Ort (basierend auf der Startposition des Mappings) abgebildet werden.
>
> > <hands-on-title>Überprüfung der Duplikat-Reads</hands-on-title>
> >
> > 1. {% tool [MarkDuplicates](toolshed.g2.bx.psu.edu/repos/devteam/picard/picard_MarkDuplicates/2.18.2.4) %} mit den folgenden Parametern:
> >    - {% icon param-collection %} *"Wähle SAM/BAM-Dataset oder Datensatzsammlung aus"*: `RNA STAR auf Sammlung N: mapped.bam` (Ausgabe von **RNA STAR** {% icon tool %})
> >
> > 2. {% tool [MultiQC](toolshed.g2.bx.psu.edu/repos/iuc/multiqc/multiqc/1.11+galaxy1) %} verwenden, um die MarkDuplicates-Logs mit den folgenden Parametern zu aggregieren:
> >    - In *"Ergebnisse"*:
> >        - *"Ergebnisse"*
> >            - *"Welches Tool wurde verwendet, um Logs zu erstellen?"*: `Picard`
> >                - In *"Picard-Ausgabe"*:
> >                    - {% icon param-repeat %} *"Picard-Ausgabe einfügen"*
> >                        - *"Art der Picard-Ausgabe?"*: `Markdups`
> >                        - {% icon param-collection %} *"Picard-Ausgabe"*: `MarkDuplicates auf Sammlung N: MarkDuplicate metrics` (Ausgabe von **MarkDuplicates** {% icon tool %})
> >
> >    > <question-title></question-title>
> >    >
> >    > Wie hoch sind die Prozentsätze der Duplikat-Reads für jede Probe?
> >    >
> >    > > <solution-title></solution-title>
> >    > >
> >    > > Die Probe `GSM461177_untreat_paired` hat 25,9% duplizierte Reads, während `GSM461180_treat_paired` 27,8% aufweist.
> >    > {: .solution}
> >    {: .question}
> {: .hands_on}
>
> Im Allgemeinen wird bis zu 50% duplizierte Reads als normal angesehen. Beide unsere Proben sind also in Ordnung.
>
> #### Anzahl der Reads, die auf jedes Chromosom gemappt sind
>
> Um die Qualität der Probe zu bewerten (z.B. Übermaß an mitochondrialer Kontamination), können wir das Geschlecht der Proben überprüfen oder sehen, ob Chromosomen hoch exprimierte Gene enthalten, indem wir die Anzahl der auf jedes Chromosom gemappten Reads mit **IdxStats** aus der **Samtools**-Suite überprüfen.
>
> > <hands-on-title>Überprüfung der Anzahl der Reads, die auf jedes Chromosom gemappt sind</hands-on-title>
> >
> > 1. {% tool [Samtools idxstats](toolshed.g2.bx.psu.edu/repos/devteam/samtools_idxstats/samtools_idxstats/2.0.4) %} mit den folgenden Parametern:
> >    - {% icon param-collection %} *"BAM-Datei"*: `RNA STAR auf Sammlung N: mapped.bam` (Ausgabe von **RNA STAR** {% icon tool %})
> >
> > 2. {% tool [MultiQC](toolshed.g2.bx.psu.edu/repos/iuc/multiqc/multiqc/1.11+galaxy1) %} verwenden, um die idxstats-Logs mit den folgenden Parametern zu aggregieren:
> >    - In *"Ergebnisse"*:
> >        - *"Ergebnisse"*
> >            - *"Welches Tool wurde verwendet, um Logs zu erstellen?"*: `Samtools`
> >                - In *"Samtools-Ausgabe"*:
> >                    - {% icon param-repeat %} *"Samtools-Ausgabe einfügen"*
> >                        - *"Art der Samtools-Ausgabe?"*: `idxstats`
> >                            - {% icon param-collection %} *"Samtools idxstats-Ausgabe"*: `Samtools idxstats auf Sammlung N` (Ausgabe von **Samtools idxstats** {% icon tool %})
> >
> >    > <question-title></question-title>
> >    >
> >    > ![Samtools idxstats](../../images/ref-based/samtools-idxstats-mapped-reads-plot.png)
> >    >
> >    > 1. Wie viele Chromosomen hat das *Drosophila*-Genom?
> >    > 2. Auf welche Chromosomen wurden die Reads hauptsächlich gemappt?
> >    > 3. Können wir das Geschlecht der Proben bestimmen?
> >    >
> >    > > <solution-title></solution-title>
> >    > >
> >    > > 1. Das Genom von *Drosophila* hat 4 Chromosomenpaare: X/Y, 2, 3 und 4.
> >    > > 2. Die Reads wurden hauptsächlich auf Chromosom 2 (chr2L und chr2R), 3 (chr3L und chr3R) und X gemappt. Nur wenige Reads wurden auf Chromosom 4 gemappt, was zu erwarten ist, da dieses Chromosom sehr klein ist.
> >    > > 3. Judging by the percentage of X+Y reads, most of the reads map to X and only a few to Y. This indicates there are probably not many genes on Y, so the samples are probably both female.
> >    > >
> >    > >    ![Samtools idxstats](../../images/ref-based/samtools-idxstats-xy-plot.png)
> >    > {: .solution}
> >    {: .question}
> {: .hands_on}
> #### Abdeckung des Genkörpers
>
> Die verschiedenen Regionen eines Gens bilden den Genkörper. Es ist wichtig zu überprüfen, ob die Abdeckung der Reads im gesamten Genkörper gleichmäßig ist. Zum Beispiel könnte eine Bias zu den 5'-Enden der Gene auf eine Zersetzung der RNA hindeuten. Alternativ könnte eine 3'-Bias darauf hindeuten, dass die Daten von einem 3'-Assay stammen. Um dies zu bewerten, können wir das **Gene Body Coverage**-Tool aus der RSeQC ({% cite wang2012rseqc %})-Tool-Suite verwenden. Dieses Tool skaliert alle Transkripte auf 100 Nukleotide (unter Verwendung einer bereitgestellten Annotationsdatei) und berechnet die Anzahl der Reads, die jede (skalierte) Nukleotidposition abdecken. Da dieses Tool sehr langsam ist, werden wir die Abdeckung nur für 200.000 zufällige Reads berechnen.
>
> > <hands-on-title>Überprüfung der Abdeckung des Genkörpers</hands-on-title>
> >
> > 1. {% tool [Samtools view](toolshed.g2.bx.psu.edu/repos/iuc/samtools_view/samtools_view/1.15.1+galaxy0) %} mit den folgenden Parametern:
> >    - {% icon param-collection %} *"SAM/BAM/CRAM-Datensatz"*: `mapped_reads` (Ausgabe von **RNA STAR** {% icon tool %})
> >    - *"Was möchten Sie ansehen?"*: `Eine gefilterte/untersampelte Auswahl von Reads`
> >        - In *"Subsampling konfigurieren"*:
> >            - *"Alignment unterschneiden"*: `Zielanzahl von Reads angeben`
> >                - *"Zielanzahl von Reads"*: `200000`
> >                - *"Saatgut für Zufallszahlengenerator"*: `1`
> >        - *"Was möchten Sie gemeldet haben?"*: `Alle nach Filterung und Untersampling behaltenen Reads`
> >            - *"Ausgabeformat"*: `BAM (-b)`
> >    - *"Referenzsequenz verwenden"*: `Nein`
> >
> > 2. {% tool [Convert GTF to BED12](toolshed.g2.bx.psu.edu/repos/iuc/gtftobed12/gtftobed12/357) %} zur Konvertierung der GTF-Datei in BED:
> >    - {% icon param-file %} *"GTF-Datei konvertieren"*: `Drosophila_melanogaster.BDGP6.32.109.gtf.gz`
> >
> > 3. {% tool [Gene Body Coverage (BAM)](toolshed.g2.bx.psu.edu/repos/nilesh/rseqc/rseqc_geneBody_coverage/5.0.1+galaxy2) %} mit den folgenden Parametern:
> >    - *"Jedes Sample einzeln ausführen oder mehrere Samples in einem Diagramm kombinieren"*: `Jedes Sample einzeln ausführen`
> >        - {% icon param-collection %} *"Eingabe .bam-Datei"*: Ausgabe von **Samtools view** {% icon tool %}
> >    - {% icon param-file %} *"Referenz-Genmodell"*: `Convert GTF to BED12 on data N: BED12` (Ausgabe von **Convert GTF to BED12** {% icon tool %})
> >
> > 4. {% tool [MultiQC](toolshed.g2.bx.psu.edu/repos/iuc/multiqc/multiqc/1.11+galaxy1) %} zur Aggregierung der RSeQC-Ergebnisse mit den folgenden Parametern:
> >    - In *"Ergebnisse"*:
> >        - *"Ergebnisse"*
> >            - *"Welches Tool wurde verwendet, um Logs zu erstellen?"*: `RSeQC`
> >                - In *"RSeQC-Ausgabe"*:
> >                    - {% icon param-repeat %} *"RSeQC-Ausgabe einfügen"*
> >                        - *"Art der RSeQC-Ausgabe?"*: `gene_body_coverage`
> >                            - {% icon param-collection %} *"RSeQC gene_body_coverage-Ausgabe"*: `Gene Body Coverage (BAM) auf Sammlung N (Text)` (Ausgabe von **Gene Body Coverage (BAM)** {% icon tool %})
> >
> >    > <question-title></question-title>
> >    >
> >    > ![Abdeckung des Genkörpers](../../images/ref-based/rseqc_gene_body_coverage_plot.png)
> >    >
> >    > Wie ist die Abdeckung über den Genkörper verteilt? Sind die Proben in 3' oder 5' biased?
> >    >
> >    > > <solution-title></solution-title>
> >    > >
> >    > > Bei beiden Proben gibt es eine ziemlich gleichmäßige Abdeckung von 5' bis 3' Ende (trotz einiger Störungen in der Mitte). Es gibt also keine offensichtliche Bias in beiden Proben.
> >    > {: .solution}
> >    {: .question}
> {: .hands_on}
>
> #### Verteilung der Reads über Features
>
> Bei RNA-Seq-Daten erwarten wir, dass die meisten Reads auf Exons und nicht auf Introns oder intergenen Regionen gemappt werden. Bevor wir mit der Zählung und der Differenzexpressionsanalyse fortfahren, kann es interessant sein, die Verteilung der Reads über bekannte Genfeatures (Exons, CDS, 5' UTR, 3' UTR, Introns, intergenische Regionen) zu überprüfen. Eine hohe Anzahl von Reads, die auf intergenische Regionen gemappt sind, kann auf das Vorhandensein von DNA-Kontamination hinweisen.
>
> Hier verwenden wir das **Read Distribution**-Tool aus der RSeQC ({% cite wang2012rseqc %})-Tool-Suite, das die Annotationsdatei verwendet, um die Position der verschiedenen Genfeatures zu identifizieren.
>
> > <hands-on-title>Überprüfung der Anzahl der Reads, die auf jedes Chromosom gemappt sind</hands-on-title>
> >
> > 1. {% tool [Read Distribution](toolshed.g2.bx.psu.edu/repos/nilesh/rseqc/rseqc_read_distribution/5.0.1+galaxy2) %} mit den folgenden Parametern:
> >    - {% icon param-collection %} *"Eingabe .bam/.sam-Datei"*: `RNA STAR auf Sammlung N: mapped.bam` (Ausgabe von **RNA STAR** {% icon tool %})
> >    - {% icon param-file %} *"Referenz-Genmodell"*: BED12-Datei (Ausgabe von **Convert GTF to BED12** {% icon tool %})
> >
> > 2. {% tool [MultiQC](toolshed.g2.bx.psu.edu/repos/iuc/multiqc/multiqc/1.11+galaxy1) %} zur Aggregierung der Read Distribution-Ergebnisse mit den folgenden Parametern:
> >    - In *"Ergebnisse"*:
> >        - *"Ergebnisse"*
> >            - *"Welches Tool wurde verwendet, um Logs zu erstellen?"*: `RSeQC`
> >                - In *"RSeQC-Ausgabe"*:
> >                    - {% icon param-repeat %} *"RSeQC-Ausgabe einfügen"*
> >                        - *"Art der RSeQC-Ausgabe?"*: `read_distribution`
> >                            - {% icon param-collection %} *"RSeQC read_distribution-Ausgabe"*: `Read Distribution auf Sammlung N` (Ausgabe von **Read Distribution** {% icon tool %})
> >
> >    > <question-title></question-title>
> >    >
> >    > ![Read Distribution](../../images/ref-based/rseqc_read_distribution_plot.png)
> >    >
> >    > Was halten Sie von der Read-Verteilung?
> >    >
> >    > > <solution-title></solution-title>
> >    > >
> >    > > Die meisten Reads sind auf Exons gemappt (>80%), nur ~2% auf Introns und ~5% auf intergenische Regionen, was unseren Erwartungen entspricht. Es bestätigt, dass unsere Daten RNA-Seq-Daten sind und dass das Mapping erfolgreich war.
> >    > {: .solution}
> >    {: .question}
> {: .hands_on}
>
> Jetzt, da wir die Ergebnisse des Read-Mappings überprüft haben, können wir mit der nächsten Phase der Analyse fortfahren.
{: .details}
Nach der Ausrichtung haben wir nun Informationen darüber, wo sich die Reads auf dem Referenzgenom befinden und wie gut sie ausgerichtet wurden. Der nächste Schritt in der RNA-Seq-Datenanalyse ist die Quantifizierung der Anzahl der auf genomische Features (Gene, Transkripte, Exons, ...) gemappten Reads.

> <comment-title></comment-title>
>
> Die Quantifizierung hängt sowohl vom Referenzgenom (der FASTA-Datei) als auch von den zugehörigen Annotationen (der GTF-Datei) ab. Es ist extrem wichtig, eine Annotationsdatei zu verwenden, die zur gleichen Version des Referenzgenoms gehört, die Sie für die Ausrichtung verwendet haben (z. B. `dm6` hier), da die chromosomalen Koordinaten der Gene normalerweise zwischen verschiedenen Versionen des Referenzgenoms unterschiedlich sind.
{: .comment}

Hier konzentrieren wir uns auf die Gene, da wir die unterscheiden möchten, die aufgrund der Pasilla-Gen-Knockdown unterschiedlich exprimiert sind.

# Zählung der Anzahl der Reads pro annotiertem Gen

Um die Expression einzelner Gene zwischen verschiedenen Bedingungen (*z.B.* mit oder ohne PS-Depletion) zu vergleichen, ist ein wesentlicher erster Schritt die Quantifizierung der Anzahl der Reads pro Gen, oder genauer gesagt, der Anzahl der Reads, die auf die Exons jedes Gens gemappt sind.

![Zählung der Anzahl der Reads pro annotiertem Gen](../../images/transcriptomics_images/gene_counting.png "Zählung der Anzahl der Reads pro annotiertem Gen")

> <question-title></question-title>
>
> Im vorherigen Bild,
>
> 1. Wie viele Reads werden für die verschiedenen Exons gefunden?
> 2. Wie viele Reads werden für die verschiedenen Gene gefunden?
>
> > <solution-title></solution-title>
> >
> > 1. Anzahl der Reads pro Exon
> >
> >     Exon | Anzahl der Reads
> >     --- | ---
> >     gene1 - exon1 | 3
> >     gene1 - exon2 | 2
> >     gene2 - exon1 | 3
> >     gene2 - exon2 | 4
> >     gene2 - exon3 | 3
> >
> > 2. Gene1 hat 4 Reads, nicht 5, wegen des Splicings des letzten Reads (gene1 - exon1 + gene1 - exon2). Gene2 hat 6 Reads, 3 davon sind gespliced.
> {: .solution}
{: .question}

Es stehen zwei Haupttools zur Verfügung, um Reads zu zählen: [**HTSeq-count**](http://htseq.readthedocs.io/en/release_0.9.1/count.html) ({% cite anders2015htseq %}) oder **featureCounts** ({% cite liao2013featurecounts %}). Darüber hinaus ermöglicht **STAR** das Zählen von Reads während der Ausrichtung: seine Ergebnisse sind identisch mit denen von **HTSeq-count**. Während dieses Ergebnis für die meisten Analysen ausreicht, bietet **featureCounts** mehr Anpassungsmöglichkeiten bei der Zählung der Reads (minimale Mapping-Qualität, Zählen von Reads anstelle von Fragmenten, Zählen von Transkripten anstelle von Genen usw.).

Prinzipiell ist das Zählen der Reads, die mit genomischen Features überlappen, eine ziemlich einfache Aufgabe. Aber die Strängigkeit der Bibliothek muss bestimmt werden. Tatsächlich ist dies ein Parameter von **featureCounts**. Im Gegensatz dazu bewertet **STAR** die Counts in die drei möglichen Strängigkeiten, aber Sie benötigen diese Information immer noch, um die Counts zu extrahieren, die Ihrer Bibliothek entsprechen.

## Schätzung der Strängigkeit

RNAs, die typischerweise in RNA-Seq-Experimenten angesprochen werden, sind einzelsträngig (*z.B.*, mRNAs) und haben daher Polarität (5'- und 3'-Enden, die funktional unterschiedlich sind). Während eines typischen RNA-Seq-Experiments geht die Information über die Strängigkeit verloren, nachdem beide Stränge von cDNA synthetisiert, größenselektiert und in eine Sequenzierungsbibliothek umgewandelt wurden. Diese Information kann jedoch für den Schritt der Reads-Zählung ziemlich nützlich sein, insbesondere für Reads, die sich im Überlappungsbereich von 2 Genen befinden, die sich auf unterschiedlichen Strängen befinden.

![Warum Strängigkeit?](../../images/ref-based/strandness_why.png "Wenn die Strängigkeitsinformation während der Bibliotheksvorbereitung verloren ging, wird Read1 dem Gen1 auf dem Vorwärtsstrang zugewiesen, aber Read2 ist 'mehrdeutig', da es entweder Gen1 (Vorwärtsstrang) oder Gen2 (Rückwärtsstrang) zugewiesen werden kann.")

Einige Bibliotheksvorbereitungsprotokolle erstellen sogenannte *stranded* RNA-Seq-Bibliotheken, die die Stränginformation bewahren ({% cite levin2010comprehensive %} bietet einen ausgezeichneten Überblick). In der Praxis werden Sie mit Illumina RNA-Seq-Protokollen wahrscheinlich nicht alle in diesem Artikel beschriebenen Möglichkeiten begegnen. Sie werden höchstwahrscheinlich entweder mit:

- Unstranded RNA-Seq-Daten
- Stranded RNA-Seq-Daten, die durch die Verwendung spezialisierter RNA-Isolationskits während der Probenvorbereitung erzeugt wurden

> <details-title>Weitere Details zur Strängigkeit</details-title>
>
> ![Beziehung zwischen DNA- und RNA-Orientierung](../../images/transcriptomics_images/dna_rna.png "Beziehung zwischen DNA- und RNA-Orientierung")
>
> Die Auswirkung von stranded RNA-Seq ist, dass Sie unterscheiden können, ob die Reads von vorwärts- oder rückwärts-kodierten Transkripten stammen. Im folgenden Beispiel können die Counts für das Gen Mrpl43 nur effizient in einer stranded Bibliothek geschätzt werden, da der Großteil davon das Gen Peo1 in der Rückwärtsorientierung überlappt:
>
> ![Stranded RNA-Seq-Daten sehen so aus](../../images/ref-based/igv_stranded_screenshot.png "Nicht-stranded (oben) vs. rückwärtsstrang-spezifische (unten) RNA-Seq-Read-Ausrichtung (mit IGV, Vorwärts-Mapping-Reads sind rot und Rückwärts-Mapping-Reads sind blau)")
>
> Abhängig vom Ansatz und davon, ob ein Single-End- oder Paired-End-Sequencing durchgeführt wird, gibt es mehrere Möglichkeiten, wie die Ergebnisse der Mapping dieser Reads auf das Genom interpretiert werden können:
>
> ![Auswirkungen der RNA-Seq-Bibliothekstypen](../../images/transcriptomics_images/rnaseq_library_type.png "Auswirkungen der RNA-Seq-Bibliothekstypen (Abbildung angepasst von Sailfish-Dokumentation)")
{: .details}

Diese Information sollte mit Ihren FASTQ-Dateien bereitgestellt werden. Fragen Sie Ihre Sequenzierungsstelle! Wenn nicht, versuchen Sie, sie auf der Seite zu finden, von der Sie die Daten heruntergeladen haben, oder in der entsprechenden Publikation.

![Wie schätzt man die Strängigkeit ein?](../../images/ref-based/strandness_cases.png "In einer stranded forward Bibliothek sind die Reads hauptsächlich auf demselben Strang wie die Gene gemappt. Bei einer stranded reverse Bibliothek sind die Reads hauptsächlich auf dem gegenüberliegenden Strang gemappt. Bei einer unstranded Bibliothek werden die Reads unabhängig von der Orientierung des Gens auf beide Stränge der Gene gemappt (Beispiel für eine Single-End-Read-Bibliothek).")

Es gibt 4 Möglichkeiten, die Strängigkeit anhand der **STAR**-Ergebnisse zu schätzen (wählen Sie die, die Sie bevorzugen):

1. Wir können eine visuelle Inspektion der Read-Stränge auf IGV durchführen (bei einem Paired-End-Datensatz ist dies weniger einfach als bei einem Single-Read und wenn Sie viele Proben haben, kann dies mühsam sein).

    > <hands-on-title>Strängigkeit mit IGV für eine Paired-End-Bibliothek schätzen</hands-on-title>
    >
    > 1. Gehen Sie zurück zu Ihrer IGV-Sitzung mit dem `GSM461177_untreat_paired` BAM geöffnet.
    >
    >    > <tip-title>Falls Sie es nicht haben</tip-title>
    >    >
    >    > Kein Problem, Sie müssen nur die vorherigen Schritte wiederholen:
    >    >
    >    > 1. Starten Sie IGV lokal
    >    > 2. Klicken Sie auf die Sammlung `RNA STAR on collection N: mapped.bam` (Ausgabe von **RNA STAR** {% icon tool %})
    >    > 3. Erweitern Sie die {% icon param-file %} `GSM461177_untreat_paired` Datei.
    >    > 4. Klicken Sie auf `local` in `display with IGV local D. melanogaster (dm6)`, um die Reads in den IGV-Browser zu laden
    >    >
    >    {: .tip}
    >
    > 2. **IGV** {% icon tool %}
    >    1. Zoomen Sie auf `chr3R:9,445,000-9,448,000` (Chromosom 4 zwischen 540 kb und 560 kb), auf dem `mapped.bam` Track
    >    2. Klicken Sie mit der rechten Maustaste und wählen Sie `Färbe Ausrichtungen nach` -> `first-in-pair Strand`
    >    3. Klicken Sie mit der rechten Maustaste und wählen Sie `Squished`
    >
    {: .hands_on}

    > <question-title></question-title>
    >
    > ![Screenshot der IGV-Ansicht auf ps](../../images/ref-based/group_strand_igv_screenshot.png "Screenshot von IGV auf ps")
    >
    > 1. Sind die Reads gleichmäßig zwischen den 2 Gruppen (NEGATIVE und POSITIVE) verteilt?
    > 2. Was ist der Typ der Bibliothekssträngigkeit?
    >
    > > <solution-title></solution-title>
    > >
    > > 1. Ja, wir sehen die gleiche Anzahl von Reads in beiden Gruppen.
    > > 2. Das bedeutet, dass die Bibliothek unstranded war.
    > >
    > > > <comment-title>Wie wäre es, wenn die Bibliothek stranded wäre?</comment-title>
> > >
> > > ![Screenshot von IGV für stranded vs non-stranded](../../images/ref-based/group_strand_igv_screenshot_RSvsUS.png "Screenshot von IGV für nicht-stranded (oben) vs. reverse strand-specific (unten)")
> > >
> > > Beachten Sie, dass es für die reverse strand-specific keine Reads in der POSITIVE-Gruppe gibt.
> > {: .comment}
> {: .solution}
> {: .question}

2. Alternativ können Sie anstelle der BAM-Datei die stranded Coverage verwenden, die von **STAR** generiert wurde. Mit **pyGenomeTracks** können wir die Coverage für jeden Strang für jede Probe visualisieren. Dieses Tool bietet viele Parameter zur Anpassung Ihrer Plots.

    > <hands-on-title>Strängigkeit mit pyGenometracks aus STAR-Coverage schätzen</hands-on-title>
    >
    > 1. {% tool [pyGenomeTracks](toolshed.g2.bx.psu.edu/repos/iuc/pygenometracks/pygenomeTracks/3.8+galaxy1) %}:
    >    - *"Region des Genoms zur Eingrenzung der Operation"*: `chr4:540,000-560,000`
    >    - In *"Include tracks in your plot"*:
    >        - {% icon param-repeat %} *"Include tracks in your plot einfügen"*
    >            - *"Stil des Tracks wählen"*: `Bedgraph track`
    >                - *"Plot-Titel"*: Dieses Feld muss leer bleiben, damit der Titel im Plot der Name der Probe ist.
    >                - {% icon param-collection %} *"Track-Datei(en) im Bedgraph-Format"*: Wählen Sie `RNA STAR on collection N: Coverage Uniquely mapped strand 1`.
    >                - *"Farbe des Tracks"*: Wählen Sie eine Farbe Ihrer Wahl, zum Beispiel blau.
    >                - *"Minimaler Wert"*: `0`
    >                - *"Höhe"*: `3`
    >                - *"Visualisierung des Datenbereichs anzeigen"*: `Ja`
    >        - {% icon param-repeat %} *"Include tracks in your plot einfügen"*
    >            - *"Stil des Tracks wählen"*: `Bedgraph track`
    >                - *"Plot-Titel"*: Dieses Feld muss leer bleiben, damit der Titel im Plot der Name der Probe ist.
    >                - {% icon param-collection %} *"Track-Datei(en) im Bedgraph-Format"*: Wählen Sie `RNA STAR on collection N: Coverage Uniquely mapped strand 2`.
    >                - *"Farbe des Tracks"*: Wählen Sie eine andere Farbe als die erste, zum Beispiel rot.
    >                - *"Minimaler Wert"*: `0`
    >                - *"Höhe"*: `3`
    >                - *"Visualisierung des Datenbereichs anzeigen"*: `Ja`
    >        - {% icon param-repeat %} *"Include tracks in your plot einfügen"*
    >            - *"Stil des Tracks wählen"*: `Gene track / Bed track`
    >                - *"Plot-Titel"*: `Gene`
    >                - *"Höhe"*: `5`
    >                - {% icon param-file %} *"Track-Datei(en) im Bed- oder GTF-Format"*: Wählen Sie `Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf.gz`
    {: .hands_on}

    > <question-title></question-title>
    >
    > ![pyGenomeTracks](../../images/ref-based/pyGenomeTracks.png "STAR-Coverage für Strang 1 in Blau und Strang 2 in Rot")
    >
    > 1. Welches Gen betrachten wir? Auf welchem Strang befindet es sich?
    > 2. Wie hoch ist die durchschnittliche Coverage für jeden Strang?
    > 3. Was ist die Strängigkeit der Bibliothek?
    >
    > > <solution-title></solution-title>
    > >
    > > 1. Wir sehen 3 Transkripte namens Thd1-RC, Thd1-RB und Thd1-RA des Gens Thd1. Das Gen befindet sich auf dem Rückwärtsstrang.
    > > 2. Die Skala reicht bis 1,5-2 in den 4 Profilen. Die durchschnittliche Coverage sollte etwa 1,2-1,5 betragen.
    > > 3. Wir schließen daraus, dass die Bibliothek unstranded ist.
    > >
    > > > <comment-title>Wie wäre es, wenn die Bibliothek stranded wäre?</comment-title>
    > > >
    > > > ![pyGenomeTracks USvsRS](../../images/ref-based/pyGenomeTracks_USvsRS.png "STAR-Coverage für Strang 1 in Blau und Strang 2 in Rot für unstranded und reverse stranded Bibliothek")
    > > > Beachten Sie, dass die Coverage auf Strang 1 für das stranded_PE-Probe sehr niedrig ist, während das Gen vorwärtsgerichtet ist.
    > > > Dies bedeutet, dass die Bibliothek von stranded_PE rückwärtsgerichtet ist.
    > > > Im Gegensatz dazu ist die Skala für unstranded_PE vergleichbar für beide Stränge.
    > > {: .comment}
    > {: .solution}
    >
    {: .question}

3. Sie können die Ausgabe von **STAR** mit den Counts verwenden. Wie bereits erklärt, bewertet **STAR** die Anzahl der Reads auf Genen für die drei möglichen Szenarien: unstranded Bibliothek, stranded forward oder stranded reverse. Die Bedingung, die mehr Reads auf das Gen verteilt, muss die Bedingung sein, die Ihrer Bibliothek entspricht.

    > <hands-on-title>Strängigkeit mit STAR-Countern schätzen</hands-on-title>
    >
    > 1. {% tool [MultiQC](toolshed.g2.bx.psu.edu/repos/iuc/multiqc/multiqc/1.11+galaxy1) %} um die STAR-Counter mit den folgenden Parametern zu aggregieren:
    >    - In *"Results"*:
    >        - *"Results"*
    >            - *"Welches Tool wurde verwendet, um Protokolle zu erstellen?"*: `STAR`
    >                - In *"STAR-Ausgabe"*:
    >                    - {% icon param-repeat %} *"STAR-Ausgabe einfügen"*
    >                        - *"Art der STAR-Ausgabe?"*: `Gene counts`
    >                            - {% icon param-collection %} *"STAR-Gene-Zähl-Ausgabe"*: `RNA STAR on collection N: reads per gene` (Ausgabe von **RNA STAR** {% icon tool %})
    >
    {: .hands_on}

    > <question-title></question-title>
    >
    > 1. Wie hoch ist der Prozentsatz der Reads, die den Genen zugeordnet werden, wenn die Bibliothek unstranded/same stranded/reverse stranded ist?
    > 2. Was ist die Strängigkeit der Bibliothek?
    >
    > > <solution-title></solution-title>
    > >
    > > ![STAR Gene counts unstranded](../../images/ref-based/star_gene_counts_unstranded.png "Gene counts unstranded")
    > > ![STAR Gene counts same stranded](../../images/ref-based/star_gene_counts_same.png "Gene counts same stranded")
    > > ![STAR Gene counts reverse stranded](../../images/ref-based/star_gene_counts_reverse.png "Gene counts reverse stranded")
    > >
    > > 1. Etwa 75% der Reads werden Genen zugeordnet, wenn die Bibliothek unstranded ist, während es in den anderen Fällen etwa 40% sind.
    > > 2. Dies deutet darauf hin, dass die Bibliothek unstranded ist.
    > >
    > > > <comment-title>Wie wäre es, wenn die Bibliothek stranded wäre?</comment-title>
    > > >
    > > > ![STAR Gene counts unstranded USvsRS](../../images/ref-based/star_gene_counts_unstranded_USvsRS.png "Gene counts unstranded für unstranded und reverse stranded Bibliothek")
    > > > ![STAR Gene counts same stranded USvsRS](../../images/ref-based/star_gene_counts_same_USvsRS.png "Gene counts same stranded für unstranded und reverse stranded Bibliothek")
    > > > ![STAR Gene counts reverse stranded USvsRS](../../images/ref-based/star_gene_counts_reverse_USvsRS.png "Gene counts reverse stranded für unstranded und reverse stranded Bibliothek")
    > > > Beachten Sie, dass sehr wenige Reads den Genen für same stranded zugeordnet sind.
    > > > Die Zahlen sind zwischen unstranded und reverse stranded vergleichbar, da wirklich wenige Gene auf gegenüberliegenden Strängen überlappen, aber es reicht von 63,6% (unstranded) bis 65% (reverse stranded).
    > > {: .comment}
    > {: .solution}
    >
    {: .question}
4. Eine weitere Möglichkeit besteht darin, diese Parameter mit einem Tool namens **Infer Experiment** aus der RSeQC ({% cite wang2012rseqc %}) Tool-Suite zu schätzen.

    Dieses Tool verwendet die BAM-Dateien aus der Mapping-Phase, wählt eine Unterstichprobe der Reads aus und vergleicht deren Genom-Koordinaten und Stränge mit denen des Referenz-Genmodells (aus einer Annotationsdatei). Basierend auf dem Strang der Gene kann es beurteilen, ob das Sequenzieren strangspezifisch ist und wenn ja, wie die Reads gerichtet sind (vorwärts oder rückwärts).

    > <hands-on-title>Bestimmung der Strängigkeit der Bibliothek mit Infer Experiment</hands-on-title>
    >
    > 1. {% tool [Convert GTF to BED12](toolshed.g2.bx.psu.edu/repos/iuc/gtftobed12/gtftobed12/357) %} zur Umwandlung der GTF-Datei in BED:
    >    - {% icon param-file %} *"GTF-Datei zur Konvertierung"*: `Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf.gz`
    >
    >    Möglicherweise haben Sie diese `BED12`-Datei bereits aus dem `Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf.gz`-Datensatz erstellt, falls Sie den detaillierten Teil zur Qualitätskontrolle durchgeführt haben. In diesem Fall müssen Sie es nicht ein zweites Mal machen.
    >
    > 2. {% tool [Infer Experiment](toolshed.g2.bx.psu.edu/repos/nilesh/rseqc/rseqc_infer_experiment/5.0.1+galaxy2) %} zur Bestimmung der Strängigkeit der Bibliothek mit den folgenden Parametern:
    >    - {% icon param-collection %} *"Input .bam file"*: `RNA STAR on collection N: mapped.bam` (Ausgabe von **RNA STAR** {% icon tool %})
    >    - {% icon param-file %} *"Reference gene model"*: BED12-Datei (Ausgabe von **Convert GTF to BED12** {% icon tool %})
    >    - *"Anzahl der Reads, die aus der SAM/BAM-Datei entnommen werden (Standard = 200000)"*: `200000`
    {: .hands_on}

    {% tool [Infer Experiment](toolshed.g2.bx.psu.edu/repos/nilesh/rseqc/rseqc_infer_experiment/2.6.4.1) %} Tool erzeugt eine Datei mit Informationen über:
    - Paired-End- oder Single-End-Bibliothek
    - Anteil der Reads, die nicht bestimmt werden konnten
    - 2 Zeilen
        - Für Single-End
            - `Fraction of reads explained by "++,--"`: der Anteil der Reads, der dem Vorwärtsstrang zugeordnet ist
            - `Fraction of reads explained by "+-,-+"`: der Anteil der Reads, der dem Rückwärtsstrang zugeordnet ist
        - Für Paired-End
            - `Fraction of reads explained by "1++,1--,2+-,2-+"`: der Anteil der Reads, der dem Vorwärtsstrang zugeordnet ist
            - `Fraction of reads explained by "1+-,1-+,2++,2--"`: der Anteil der Reads, der dem Rückwärtsstrang zugeordnet ist

    Wenn die beiden "Fraction of reads explained by"-Zahlen nahe beieinander liegen, schließen wir daraus, dass die Bibliothek kein strangspezifisches Dataset ist (oder unstranded).

    > <question-title></question-title>
    >
    > 1. Wie lauten die "Fraction of reads explained by"-Ergebnisse für `GSM461177_untreat_paired`?
    > 2. Glauben Sie, dass der Bibliothekstyp der 2 Proben stranded oder unstranded ist?
    >
    > > <solution-title></solution-title>
    > >
    > > 1. Ergebnisse für `GSM461177_untreat_paired`:
    > >
    > >    {% snippet faqs/galaxy/analysis_results_may_vary.md %}
    > >
    > >    ```text
    > >    Dies ist PairEnd-Daten
    > >    Anteil der Reads, die nicht bestimmt werden konnten: 0.1013
    > >    Anteil der Reads erklärt durch "1++,1--,2+-,2-+": 0.4626
    > >    Anteil der Reads erklärt durch "1+-,1-+,2++,2--": 0.4360
    > >    ```
    > >
    > >    Somit sind 46,26% der Reads dem Vorwärtsstrang und 43,60% dem Rückwärtsstrang zugeordnet.
    > >
    > > 2. Ähnliche Statistiken finden sich für `GSM461180_treat_paired`, sodass die Bibliothek für beide Proben wahrscheinlich unstranded ist.
    > >
    > > > <comment-title>Wie wäre es, wenn die Bibliothek stranded wäre?</comment-title>
    > > >
    > > > Nochmals am Beispiel der beiden BAMs: Für unstranded erhalten wir:
    > > >
    > > > ```text
    > > > Dies ist PairEnd-Daten
    > > > Anteil der Reads, die nicht bestimmt werden konnten: 0.0382
    > > > Anteil der Reads erklärt durch "1++,1--,2+-,2-+": 0.4847
    > > > Anteil der Reads erklärt durch "1+-,1-+,2++,2--": 0.4771
    > > > ```
    > > >
    > > > Und für reverse stranded:
    > > >
    > > > ```text
    > > > Dies ist PairEnd-Daten
    > > > Anteil der Reads, die nicht bestimmt werden konnten: 0.0504
    > > > Anteil der Reads erklärt durch "1++,1--,2+-,2-+": 0.0061
    > > > Anteil der Reads erklärt durch "1+-,1-+,2++,2--": 0.9435
    > > > ```
    > > >
    > > {: .comment}
    > {: .solution}
    {: .question}

> <details-title>Strängigkeit und Software-Einstellungen</details-title>
>
> Da es manchmal schwierig ist, die entsprechenden Einstellungen anderer Programme zu finden, kann die folgende Tabelle hilfreich sein, um den Bibliothekstyp zu identifizieren:
>
> Bibliothekstyp | **Infer Experiment** | **TopHat** | **HISAT2** | **HTSeq-count** | **featureCounts**
> --- | --- | --- | --- | --- | ---
> Paired-End (PE) - SF | 1++,1--,2+-,2-+ | FR Second Strand | Second Strand F/FR | ja | Forward (1)
> PE - SR | 1+-,1-+,2++,2-- | FR First Strand | First Strand R/RF | reverse | Reverse (2)
> Single-End (SE) - SF | ++,-- | FR Second Strand | Second Strand F/FR | ja | Forward (1)
> SE - SR | +-,-+ | FR First Strand | First Strand R/RF | reverse | Reverse (2)
> PE, SE - U | undecided | FR Unstranded | default | nein | Unstranded (0)
>
{: .details}
## Zählen der Reads pro Gen

{% include _includes/cyoa-choices.html option1="featureCounts" option2="STAR" default="featureCounts" text="Um die Anzahl der Reads pro Gen zu zählen, bieten wir ein paralleles Tutorial für die 2 Methoden (STAR und featureCounts) an, die sehr ähnliche Ergebnisse liefern. Welche Methode bevorzugen Sie?" disambiguation="tool"%}

<div class="featureCounts" markdown="1">

Da Sie sich entschieden haben, die featureCounts-Variante des Tutorials zu verwenden, führen wir nun **featureCounts** aus, um die Anzahl der Reads pro annotiertem Gen zu zählen.

> <hands-on-title>Zählen der Anzahl der Reads pro annotiertem Gen</hands-on-title>
>
> 1. {% tool [featureCounts](toolshed.g2.bx.psu.edu/repos/iuc/featurecounts/featurecounts/2.0.3+galaxy1) %} mit den folgenden Parametern zum Zählen der Anzahl der Reads pro Gen:
>    - {% icon param-collection %} *"Alignmentsdatei"*: `RNA STAR on collection N: mapped.bam` (Ausgabe von **RNA STAR** {% icon tool %})
>    - *"Stranginformationen angeben"*: `Unstranded`
>    - *"Gen-Annotationsdatei"*: `in Ihrer Historie`
>        - {% icon param-file %} *"Gen-Annotationsdatei"*: `Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf.gz`
>    - *"GFF-Feature-Typ-Filter"*: `exon`
>    - *"GFF-Gen-Identifikator"*: `gene_id`
>    - *"Ausgabeformat"*: `Gene-ID "\t" read-count (MultiQC/DESeq2/edgeR/limma-voom-kompatibel)`
>    - *"Erstelle Gen-Längen-Datei"*: `Ja`
>    - *"Hat die Eingabe Lese-Paare"*: `Ja, paired-end und als 1 einzelnes Fragment zählen`
>    - In *"Read-Filter-Optionen"*:
>        - *"Minimale Mapping-Qualität pro Read"*: `10`
>
> 2. {% tool [MultiQC](toolshed.g2.bx.psu.edu/repos/iuc/multiqc/multiqc/1.11+galaxy1) %} zur Aggregation der Berichte mit den folgenden Parametern:
>    - In *"Ergebnisse"*:
>        - *"Ergebnisse"*
>            - *"Welches Tool wurde zur Erstellung der Protokolle verwendet?"*: `featureCounts`
>                - {% icon param-collection %} *"Ausgabe von FeatureCounts"*: `featureCounts on collection N: Summary` (Ausgabe von **featureCounts** {% icon tool %})
>
>    > <question-title></question-title>
>    >
>    > 1. Wie viele Reads wurden einem Gen zugewiesen?
>    > 2. Wann sollten wir uns um die Zuordnungsrate Sorgen machen? Was sollten wir tun?
>    >
>    > > <solution-title></solution-title>
>    > >
>    > > 1. Etwa 63% der Reads wurden Genen zugewiesen: Diese Menge ist ausreichend.
>    > >
>    > >    ![featureCounts-Zuordnung](../../images/ref-based/featureCounts_assignment_plot.png "Zuordnungen mit featureCounts")
>    > >
>    > >    Einige Reads werden nicht zugewiesen, weil sie mehrfach gemappt wurden; andere wurden keinem Feature oder nur mehrdeutigen Features zugewiesen.
>    > >
>    > > 2. Wenn der Prozentsatz unter 50% liegt, sollten Sie untersuchen, wo Ihre Reads gemappt werden (innerhalb von Genen oder nicht, mit IGV) und überprüfen, ob die Annotation mit der korrekten Referenzgenom-Version übereinstimmt.
>    > >
>    > {: .solution}
>    {: .question}
>
{: .hands_on}

Die Hauptausgabe von **featureCounts** ist eine Tabelle mit den Zählungen, d. h. der Anzahl der Reads (oder Fragmente im Fall von paired-end Reads), die jedem Gen (in Zeilen, mit ihrer ID in der ersten Spalte) in der bereitgestellten Annotation zugeordnet sind. **FeatureCounts** erzeugt auch die **Feature-Längen**-Ausgabedatensätze. Diese Datei benötigen wir später, wenn wir das **goseq**-Tool ausführen.

</div>

<div class="STAR" markdown="1">

Da Sie sich entschieden haben, die STAR-Variante des Tutorials zu verwenden, werden wir **STAR** zum Zählen der Reads verwenden.

Wie oben geschrieben, hat **STAR** während des Mappings Reads für jedes Gen gezählt, das in der Gen-Annotationsdatei angegeben ist (dies wurde durch die Option `Per gene read counts (GeneCounts)` erreicht). Diese Ausgabe enthält jedoch einige Statistiken zu Beginn und die Zählungen für jedes Gen je nach Bibliothek (unstranded ist Spalte 2, stranded forward ist Spalte 3 und stranded reverse ist Spalte 4).

> <hands-on-title>STAR-Ausgabe inspizieren</hands-on-title>
>
> 1. Inspizieren Sie die Zählungen von `GSM461177_untreat_paired` in der Sammlung `RNA STAR on collection N: reads per gene`
{: .hands_on}
>
> <question-title></question-title>
>
> 1. Wie viele Reads sind unmapped/multi-mapped?
> 2. Ab welcher Zeile beginnen die Gen-Zählungen?
> 3. Was sind die verschiedenen Spalten?
> 4. Welche Spalten sind für unser Dataset am interessantesten?
>
> > <solution-title></solution-title>
> >
> > 1. Es gibt 1.190.029 unmapped Reads und 571.324 multi-mapped Reads.
> > 2. Es beginnt bei Zeile 5 mit dem Gen `FBgn0250732`.
> > 3. Es gibt 4 Spalten:
> >    1. Gene ID
> >    2. Zählungen für unstranded RNA-seq
> >    3. Zählungen für das 1. Read-Strand ausgerichtet mit RNA
> >    4. Zählungen für das 2. Read-Strand ausgerichtet mit RNA
> > 4. Wir benötigen die Gene-ID-Spalte und die 2. Spalte aufgrund der Unstrandedheit unserer Daten.
> >
> {: .solution}
>
{: .question}

Wir werden die Ausgabe von **STAR** umformatieren, um sie ähnlich der Ausgabe von **featureCounts** (oder anderen Zählsoftwares) zu machen, die nur 2 Spalten haben: eine mit IDs und eine andere mit Zählungen.

> <hands-on-title>STAR-Ausgabe umformatieren</hands-on-title>
>
> 1. {% tool [Select last](toolshed.g2.bx.psu.edu/repos/bgruening/text_processing/tp_tail_tool/1.1.0) %} Zeilen aus einem Datensatz auswählen (tail), um die ersten 4 Zeilen mit den folgenden Parametern zu entfernen:
>    - {% icon param-collection %} *"Textdatei"*: `RNA STAR on collection N: reads per gene` (Ausgabe von **RNA STAR** {% icon tool %})
>    - *"Operation"*: `Alles ab dieser Zeile behalten`
>    - *"Anzahl der Zeilen"*: `5`
>
> 2. {% tool [Cut](Cut1) %} Spalten aus einer Tabelle ausschneiden mit den folgenden Parametern:
>    - *"Spalten ausschneiden"*: `c1,c2`
>    - *"Getrennt durch"*: `Tabulator`
>    - {% icon param-collection %} *"Von"*: `Select last on collection N` (Ausgabe von **Select last** {% icon tool %})
>
> 3. Benennen Sie die Sammlung in `FeatureCount-ähnliche Dateien` um.
{: .hands_on}

Später im Tutorial müssen wir die Größe jedes Gens ermitteln. Dies ist eine der Ausgaben von **FeatureCounts**, aber wir können es auch direkt aus der Gen-Annotationsdatei beziehen. Da dies ziemlich lang ist, empfehlen wir, es jetzt zu starten.
> <hands-on-title>Genlängen ermitteln</hands-on-title>
>
> 1. {% tool [Gene length and GC content](toolshed.g2.bx.psu.edu/repos/iuc/length_and_gc_content/length_and_gc_content/0.1.2) %} mit den folgenden Parametern:
>    - *"Wählen Sie eine integrierte GTF-Datei oder eine aus Ihrer Historie"*: `GTF aus Historie verwenden`
>      - {% icon param-file %} *"Wählen Sie eine GTF-Datei aus"*: `Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf.gz`
>    - *"Durchzuführende Analyse"*: `nur Genlängen`
>
>    > <warning-title>Überprüfen Sie die Version des Tools unten</warning-title>
>    >
>    > Dies funktioniert nur mit Version 0.1.2 oder höher
>    >
>    > {% snippet faqs/galaxy/tools_change_version.md %}
>    >
>    {: .warning}
{: .hands_on}

</div>

> <question-title></question-title>
>
> Welches Feature hat die meisten Counts in beiden Proben? (Hinweis: Verwenden Sie das Sortierwerkzeug)
>
> > <solution-title></solution-title>
> >
> > Um das am häufigsten nachgewiesene Feature anzuzeigen, müssen wir die Tabelle der Zählungen sortieren. Dies kann wie folgt durchgeführt werden:
> >
> > 1. {% tool [Sort](toolshed.g2.bx.psu.edu/repos/bgruening/text_processing/tp_sort_header_tool/1.1.1) %} mit den folgenden Parametern:
> >    - {% icon param-collection %} *"Sortierabfrage"*: <span class="featureCounts" markdown="1">`featureCounts on collection N: Counts` (Ausgabe von **featureCounts** {% icon tool %})</span><span class="STAR" markdown="1">Verwenden Sie die Sammlung `FeatureCount-like files`</span>
> >    - *"Anzahl der Kopfzeilen"*: <span class="featureCounts" markdown="1">`1`</span><span class="STAR" markdown="1">`0`</span>
> >    - In *"1: Spaltenauswahl"*:
> >      - *"in Spalte"*: `Spalte: 2`
> >
> >        Diese Spalte enthält die Anzahl der Reads = Zählungen
> >
> >      - *"in"*: `Absteigender Reihenfolge`
> >
> > 2. Untersuchen Sie das Ergebnis
> >
> >    Das Ergebnis der Sortierung der Tabelle nach Spalte 2 zeigt, dass FBgn0284245 das Feature mit den meisten Zählungen ist (etwa 128.740 in `GSM461177_untreat_paired` und 127.400 in `GSM461180_treat_paired`).
> >
> >    Der Vergleich verschiedener Ausgabedateien ist einfacher, wenn wir mehr als einen Datensatz gleichzeitig anzeigen können. Die Scratchbook-Funktion ermöglicht es uns, eine Sammlung von Datensätzen zusammenzustellen, die auf dem Bildschirm angezeigt werden.
> >
> >    > <hands-on-title>(Optional) Sortierte Zählungen mit Scratchbook anzeigen</hands-on-title>
> >    >
> >    > 1. Das **Scratchbook** wird aktiviert, indem auf das Neun-Block-Icon rechts in der oberen Menüleiste von Galaxy geklickt wird:
> >    >
> >    >    ![scratchbook icon](../../images/ref-based/menubarWithScratchbook.png "Menüleiste mit Scratchbook-Icon")
> >    >
> >    > 2. Wenn das Scratchbook **aktiviert** ist, werden die angezeigten Datensätze (durch Klicken auf das Augensymbol) zur Scratchbook-Ansicht hinzugefügt:
> >    >
> >    >    ![Scratchbook icon enabled](../../images/ref-based/menubarWithScratchbookEnabled.png "Menüleiste mit aktiviertem Scratchbook-Icon")
> >    >
> >    > 3. Klicken Sie auf das {% icon galaxy-eye %} (Augen)-Symbol, um eine der **sortierten Zählungen**-Dateien anzuzeigen. Anstatt die gesamte mittlere Leiste einzunehmen, wird die Datensatzansicht nun als Overlay angezeigt:
> >    >
> >    >    ![Scratchbook one dataset shown](../../images/ref-based/scratchbookOneDataset.png "Scratchbook zeigt ein Dataset als Overlay")
> >    >
> >    > 4. Klicken Sie als Nächstes auf das {% icon galaxy-eye %} (Augen)-Symbol der **zweiten sortierten Zählungen**-Datei. Der zweite Datensatz wird über den ersten gelegt, aber Sie können das Fenster verschieben, um die beiden Datensätze nebeneinander zu sehen:
> >    >
> >    >    ![Scratchbook two datasets shown](../../images/ref-based/scratchbookTwoDatasetsShown.png "Scratchbook zeigt zwei nebeneinanderliegende Datensätze")
> >    >
> >    > 5. Um den Scratchbook-Auswahlmodus zu **verlassen**, klicken Sie erneut auf das **Scratchbook-Icon**. Sie können entscheiden, ob Sie die Fenster schließen oder sie minimieren möchten, um sie später anzuzeigen.
> >    >
> >    {: .hands_on}
> >
> {: .solution}
{: .question}

Hier haben wir die Reads gezählt, die Genen zugeordnet sind, für zwei Proben. Es ist wirklich interessant, dasselbe Verfahren auf die anderen Datensätze anzuwenden, insbesondere um zu überprüfen, wie sich die Parameter je nach Art der Daten (single-end vs. paired-end) unterscheiden.

> <hands-on-title>(Optional) Wiederholung auf anderen Datensätzen</hands-on-title>
>
> Sie können denselben Prozess auf die anderen Sequenzdateien anwenden, die auf [Zenodo]({{ page.zenodo_link }}) und in der Datenbibliothek verfügbar sind.
>
> - Paired-end-Daten
>   - `GSM461178_1` und `GSM461178_2`, die Sie als `GSM461178_untreat_paired` kennzeichnen können
>   - `GSM461181_1` und `GSM461181_2`, die Sie als `GSM461181_treat_paired` kennzeichnen können
> - Single-end-Daten
>   - `GSM461176`, das Sie als `GSM461176_untreat_single` kennzeichnen können
>   - `GSM461179`, das Sie als `GSM461179_treat_single` kennzeichnen können
>   - `GSM461182`, das Sie als `GSM461182_untreat_single` kennzeichnen können
>
> Die Links zu diesen Dateien finden Sie unten:
>
> ```text
> {{ page.zenodo_link }}/files/GSM461178_1.fastqsanger
> {{ page.zenodo_link }}/files/GSM461178_2.fastqsanger
> {{ page.zenodo_link }}/files/GSM461181_1.fastqsanger
> {{ page.zenodo_link }}/files/GSM461181_2.fastqsanger
> {{ page.zenodo_link }}/files/GSM461176.fastqsanger
> {{ page.zenodo_link }}/files/GSM461179.fastqsanger
> {{ page.zenodo_link }}/files/GSM461182.fastqsanger
> ```
>
> Für die Single-end-Daten ist es nicht notwendig, die Sammlung vor **FastQC** zu glätten. Die Parameter aller Tools sind gleich, außer bei **STAR**, wo Sie die `Länge der genomischen Sequenz um annotierte Junctions` auf 74 setzen können, da ein Datensatz Reads von 75 bp hat (andere sind 44 bp und 45 bp) und bei **FeatureCount**, wo Ihre Daten nicht mehr paired sind.
{: .hands_on}

# Analyse der differentiellen Genexpression

## Identifizierung der differentiell exprimierten Merkmale

Um die durch die PS-Depletion induzierte differentielle Genexpression zu identifizieren, müssen alle Datensätze (3 behandelt und 4 unbehandelt) nach demselben Verfahren analysiert werden. Um Zeit zu sparen, haben wir die vorherigen Schritte für Sie durchgeführt. Wir haben dann 7 Dateien mit den Zählungen für jedes Gen von *Drosophila* für jede Probe erhalten.

> <hands-on-title>Importieren aller Zählungsdateien</hands-on-title>
>
> 1. Erstellen Sie eine neue leere Historie
> 2. Importieren Sie die sieben Zählungsdateien von [Zenodo]({{ page.zenodo_link }}) oder der Shared Data-Bibliothek:
>
>    - `GSM461176_untreat_single_featureCounts.counts`
>    - `GSM461177_untreat_paired_featureCounts.counts`
>    - `GSM461178_untreat_paired_featureCounts.counts`
>    - `GSM461179_treat_single_featureCounts.counts`
>    - `GSM461180_treat_paired_featureCounts.counts`
>    - `GSM461181_treat_paired_featureCounts.counts`
>    - `GSM461182_untreat_single_featureCounts.counts`
>
>    ```text
>    {{ page.zenodo_link }}/files/GSM461176_untreat_single_featureCounts.counts
>    {{ page.zenodo_link }}/files/GSM461177_untreat_paired_featureCounts.counts
>    {{ page.zenodo_link }}/files/GSM461178_untreat_paired_featureCounts.counts
>    {{ page.zenodo_link }}/files/GSM461179_treat_single_featureCounts.counts
>    {{ page.zenodo_link }}/files/GSM461180_treat_paired_featureCounts.counts
>    {{ page.zenodo_link }}/files/GSM461181_treat_paired_featureCounts.counts
>    {{ page.zenodo_link }}/files/GSM461182_untreat_single_featureCounts.counts
>    ```
>
{: .hands_on}
> Vielleicht denken Sie, dass wir die Zählwerte in den Dateien direkt vergleichen und das Ausmaß der differentiellen Genexpression berechnen können. Es ist jedoch nicht so einfach.
>
> Stellen wir uns vor, wir haben RNA-Seq-Zählungen von 3 Proben für ein Genom mit 4 Genen:
>
> Gene | Probe 1 Zählungen | Probe 2 Zählungen | Probe 3 Zählungen
> --- | --- | --- | ---
> A (2kb) | 10 | 12 | 30
> B (4kb) | 20 | 25 | 60
> C (1kb) | 5 | 8 | 15
> D (10kb) | 0 | 0 | 1
>
> Probe 3 hat mehr Reads als die anderen Replikate, unabhängig vom Gen. Sie hat eine höhere Sequenzierungstiefe als die anderen Replikate. Gen B ist doppelt so lang wie Gen A: Das könnte erklären, warum es doppelt so viele Reads hat, unabhängig von den Replikaten.
>
> Die Anzahl der sequenzierten Reads, die einem Gen zugeordnet sind, hängt daher von folgenden Faktoren ab:
>
> - Der **Sequenzierungstiefe** der Proben
>
>   Proben mit größerer Sequenzierungstiefe haben mehr Reads, die auf jedes Gen gemappt werden.
>
> - Der **Länge des Gens**
>
>   Längere Gene haben mehr Reads, die ihnen zugeordnet werden.
>
> Um Proben oder Genexpressionen zu vergleichen, müssen die Genzählungen normalisiert werden. Wir könnten TPM (Transcripts Per Kilobase Million) verwenden.
>
> > <details-title>RPKM, FPKM und TPM?</details-title>
> >
> > Diese drei Metriken werden verwendet, um Zähltabellen für:
> >
> > - Sequenzierungstiefe (den „Millionen“-Teil)
> > - Genlänge (den „Kilobase“-Teil)
> >
> > zu normalisieren. Lassen Sie uns das vorherige Beispiel verwenden, um RPK, FPKM und TPM zu erklären.
> >
> > Für **RPKM** (Reads Per Kilobase Million):
> >
> > 1. Berechnen Sie den "pro Million"-Skalierungsfaktor: Summieren Sie die Gesamtanzahl der Reads in einer Probe und teilen Sie diese Zahl durch 1.000.000.
> >
> >    Gene | Probe 1 Zählungen | Probe 2 Zählungen | Probe 3 Zählungen
> >    --- | --- | --- | ---
> >    A (2kb) | 10 | 12 | 30
> >    B (4kb) | 20 | 25 | 60
> >    C (1kb) | 5 | 8 | 15
> >    D (10kb) | 0 | 0 | 1
> >    **Gesamtanzahl der Reads** | 35 | 45 | 106
> >    **Skalierungsfaktor** | 3,5 | 4,5 | 10,6
> >
> >    *Aufgrund der kleinen Werte im Beispiel verwenden wir „pro Zehner“ statt „pro Million“ und teilen daher die Summe durch 10 statt 1.000.000.*
> >
> > 2. Teilen Sie die Zählungen durch den "pro Million"-Skalierungsfaktor
> >
> >    Dies normalisiert die Sequenzierungstiefe und ergibt Reads pro Million (RPM)
> >
> >    Gene | Probe 1 RPM | Probe 2 RPM | Probe 3 RPM
> >    --- | --- | --- | ---
> >    A (2kb) | 2,86 | 2,67 | 2,83
> >    B (4kb) | 5,71 | 5,56 | 5,66
> >    C (1kb) | 1,43 | 1,78 | 1,43
> >    D (10kb) | 0 | 0 | 0,09
> >
> >    *Im Beispiel verwenden wir den „pro Zehner“-Skalierungsfaktor und erhalten Reads pro Zehner*
> >
> > 3. Teilen Sie die RPM-Werte durch die Länge des Gens in Kilobasen.
> >
> >    Gene | Probe 1 RPKM | Probe 2 RPKM | Probe 3 RPKM
> >    --- | --- | --- | ---
> >    A (2kb) | 1,43 | 1,33 | 1,42
> >    B (4kb) | 1,43 | 1,39 | 1,42
> >    C (1kb) | 1,43 | 1,78 | 1,42
> >    D (10kb) | 0 | 0 | 0,009
> >
> > **FPKM** (Fragments Per Kilobase Million) ist sehr ähnlich wie RPKM. RPKM wird für Single-End RNA-Seq verwendet, während FPKM für Paired-End RNA-Seq verwendet wird. Bei Single-End RNA-Seq entspricht jeder Read einem einzelnen Fragment, das sequenziert wurde. Bei Paired-End RNA-Seq werden zwei Reads eines Paares von einem einzelnen Fragment gemappt, oder wenn ein Read des Paares nicht gemappt wurde, kann ein Read einem einzelnen Fragment entsprechen (falls wir uns entscheiden, diese zu behalten). FPKM verfolgt Fragmente, sodass ein Fragment mit 2 Reads nur einmal gezählt wird.
> >
> > **TPM** (Transcripts Per Kilobase Million) ist sehr ähnlich wie RPKM und FPKM, jedoch in anderer Reihenfolge der Operationen:
> >
> > 1. Teilen Sie die Zählungen durch die Länge jedes Gens in Kilobasen
> >
> >    Dies ergibt die Reads pro Kilobase (RPK).
> >
> >    Gene | Probe 1 RPK | Probe 2 RPK | Probe 3 RPK
> >    --- | --- | --- | ---
> >    A (2kb) | 5 | 6 | 15
> >    B (4kb) | 5 | 6,25 | 15
> >    C (1kb) | 5 | 8 | 15
> >    D (10kb) | 0 | 0 | 0,1
> >
> > 2. Berechnen Sie den "pro Million"-Skalierungsfaktor: Summieren Sie alle RPK-Werte in einer Probe und teilen Sie diese Zahl durch 1.000.000
> >
> >    Gene | Probe 1 RPK | Probe 2 RPK | Probe 3 RPK
> >    --- | --- | --- | ---
> >    A (2kb) | 5 | 6 | 15
> >    B (4kb) | 5 | 6,25 | 15
> >    C (1kb) | 5 | 8 | 15
> >    D (10kb) | 0 | 0 | 0,1
> >    **Gesamt RPK** | 15 | 20,25 | 45,1
> >    **Skalierungsfaktor** | 1,5 | 2,03 | 4,51
> >
> >    *Wie oben, aufgrund der kleinen Werte im Beispiel, verwenden wir „pro Zehner“ statt „pro Million“ und teilen daher die Summe durch 10 statt 1.000.000.*
> >
> > 3. Teilen Sie die RPK-Werte durch den "pro Million"-Skalierungsfaktor
> >
> >    Gene | Probe 1 TPM | Probe 2 TPM | Probe 3 TPM
> >    --- | --- | --- | ---
> >    A (2kb) | 3,33 | 2,96 | 3,33
> >    B (4kb) | 3,33 | 3,09 | 3,33
> >    C (1kb) | 3,33 | 3,95 | 3,33
> >    D (10kb) | 0 | 0 | 0,1
> >
> >
> > Im Gegensatz zu RPKM und FPKM normalisieren wir beim Berechnen von TPM zuerst nach Genlänge und dann nach Sequenzierungstiefe. Die Auswirkungen dieses Unterschieds sind jedoch recht tiefgreifend, wie wir bereits im Beispiel gesehen haben.
> >
> > Die Summen jeder Spalte sind sehr unterschiedlich:
> >
> > 1. RPKM
> >
> >    Gene | Probe 1 RPKM | Probe 2 RPKM | Probe 3 RPKM
> >    --- | --- | --- | ---
> >    A (2kb) | 1,43 | 1,33 | 1,42
> >    B (4kb) | 1,43 | 1,39 | 1,42
> >    C (1kb) | 1,43 | 1,78 | 1,42
> >    D (10kb) | 0 | 0 | 0,009
> >    **Gesamt** | 4,29 | 4,5 | 4,25
> >
> > 2. TPM
> >
> >    Gene | Probe 1 TPM | Probe 2 TPM | Probe 3 TPM
> >    --- | --- | --- | ---
> >    A (2kb) | 3,33 | 2,96 | 3,33
> >    B (4kb) | 3,33 | 3,09 | 3,33
> >    C (1kb) | 3,33 | 3,95 | 3,33
> >    D (10kb) | 0 | 0 | 0,1
> >    **Gesamt** | 10 | 10 | 10
> Die Summe aller TPMs in jeder Probe ist gleich. Dies erleichtert den Vergleich des Anteils der Reads, die auf ein Gen in jeder Probe gemappt wurden. Im Gegensatz dazu kann bei RPKM und FPKM die Summe der normalisierten Reads in jeder Probe unterschiedlich sein, was den direkten Vergleich der Proben erschwert.
>
> Im Beispiel beträgt TPM für Gen A in Probe 1 3,33 und in Probe 2 ebenfalls 3,33. Der gleiche Anteil der Gesamtreads wird dann in beiden Proben auf Gen A gemappt (hier 0,33). Da die Summe der TPMs in beiden Proben dieselbe Zahl ergibt (hier 10), ist der Nenner zur Berechnung der Anteile in beiden Proben derselbe, und somit beträgt der Anteil der Reads für Gen A (3,33/10 = 0,33) in beiden Proben.
>
> Bei RPKM oder FPKM ist es schwieriger, den Anteil der Gesamtreads zu vergleichen, da die Summe der normalisierten Reads in jeder Probe unterschiedlich sein kann (4,29 für Probe 1 und 4,25 für Probe 2). Wenn also RPKM für Gen A in Probe 1 1,43 und in Probe 2 ebenfalls 1,43 beträgt, wissen wir nicht, ob der gleiche Anteil der Reads in Probe 1 auf Gen A gemappt wurde wie in Probe 2.
>
> Da RNA-Seq darauf abzielt, die relative Verteilung der Reads zu vergleichen, scheint TPM besser geeignet als RPKM/FPKM.
{: .details}

RNA-Seq wird oft verwendet, um einen Gewebetyp mit einem anderen zu vergleichen, zum Beispiel Muskel- vs. Epithelgewebe. Es könnte sein, dass viele muskel-spezifische Gene im Muskel transkribiert werden, jedoch nicht im Epithelgewebe. Dies nennen wir **Unterschiede in der Bibliothekszusammensetzung**.

Es ist auch möglich, Unterschiede in der Bibliothekszusammensetzung im gleichen Gewebetyp nach dem Knockout eines Transkriptionsfaktors zu sehen.

Stellen wir uns vor, wir haben RNA-Seq-Zählungen von 2 Proben (gleiche Bibliotheksgröße: 635 Reads) für ein Genom mit 6 Genen. Die Gene haben in beiden Proben dieselbe Expression, außer einem: Nur Probe 1 transkribiert Gen D in hoher Menge (563 Reads). Da die Bibliotheksgröße für beide Proben gleich ist, hat Probe 2 563 zusätzliche Reads, die auf die Gene A, B, C, E und F verteilt werden.

Gene | Probe 1 | Probe 2
--- | --- | --- | ---
A | 30 | 235
B | 24 | 188
C | 0 | 0
D | 563 | 0
E | 5 | 39
F | 13 | 102
**Gesamt** | 635 | 635

Infolge dessen ist die Read-Zahl für alle Gene außer C und D in Probe 2 wirklich hoch. Dennoch ist das einzige differentiell exprimierte Gen Gen D.

TPM, RPKM oder FPKM berücksichtigen diese Unterschiede in der Bibliothekszusammensetzung während der Normalisierung nicht, aber komplexere Werkzeuge wie DESeq2 tun dies.

[**DESeq2**](https://bioconductor.org/packages/release/bioc/html/DESeq2.html) ({% cite love2014moderated %}) ist ein hervorragendes Werkzeug zur Verarbeitung von RNA-Seq-Daten und zur Durchführung von Differentieller Genexpression (DGE)-Analysen. Es nimmt Read-Count-Dateien von verschiedenen Proben, kombiniert sie in eine große Tabelle (mit Genen in den Zeilen und Proben in den Spalten) und wendet Normalisierungen für **Sequenzierungstiefe** und **Bibliothekszusammensetzung** an. Eine Normalisierung nach Genlänge ist nicht erforderlich, da wir die Zählungen zwischen Stichproben für dasselbe Gen vergleichen.

> <details-title>Normalisierung in DESeq2</details-title>
> 
> Lassen Sie uns ein Beispiel verwenden, um zu veranschaulichen, wie DESeq2 die verschiedenen Proben skaliert:
> 
> Gene | Probe 1 | Probe 2 | Probe 3
> A | 0 | 10 | 4
> B | 2 | 6 | 12
> C | 33 | 55 | 200
> 
> Das Ziel ist es, einen Skalierungsfaktor für jede Probe zu berechnen, der die Read-Tiefe und die Bibliothekszusammensetzung berücksichtigt.
> 
> 1. Nehmen Sie den natürlichen Logarithmus aller Werte:
> 
>     Gene | log(Probe 1) | log(Probe 2) | log(Probe 3)
>     A | -Inf | 2,3 | 1,4
>     B | 0,7 | 1,8 | 2,5
>     C | 3,5 | 4,0 | 5,3
> 
> 2. Berechnen Sie den Durchschnitt jeder Zeile:
> 
>     Gene | Durchschnitt der Log-Werte
>     A | -Inf
>     B | 1,7
>     C | 4,3
> 
>     Der Durchschnitt der Log-Werte (auch als geometrischer Durchschnitt bekannt) wird hier verwendet, da er nicht leicht von Ausreißern (z.B. Gen C mit seinem Ausreißer in Probe 3) beeinflusst wird.
> 
> 3. Filterung von Genen mit Unendlichkeit als Wert:
> 
>     Gene | Durchschnitt der Log-Werte
>      |
>     B | 1,7
>     C | 4,3
> 
>     Hier filtern wir Gene ohne Leseanzahlen in mindestens 1 Probe heraus, z.B. Gene, die nur in einem Gewebe transkribiert werden, wie Gen D im vorherigen Beispiel. Dies hilft, die Skalierungsfaktoren auf Gene zu konzentrieren, die auf ähnlichen Ebenen transkribiert werden, unabhängig von der Bedingung.
> 
> 4. Subtrahieren Sie den durchschnittlichen Log-Wert von den Log-Zählungen:
> 
>     Gene | log(Probe 1) | log(Probe 2) | log(Probe 3)
>      |  |  |
>     B | -1,0 | 0,1 | 0,8
>     C | -0,8 | -0,3 | 1,0
> 
>     $$\text{log}(\text{Zählungen für Gen X}) - \text{Durchschnitt}(\text{Log-Werte für Zählungen für Gen X}) = \text{log}\left(\frac{\text{Zählungen für Gen X}}{\text{Durchschnitt für Gen X}}\right)$$
> 
>     Dieser Schritt vergleicht das Verhältnis der Zählungen in jeder Probe zum Durchschnitt über alle Proben.
> 
> 5. Berechnen Sie die Medianwerte der Verhältnisse für jede Probe:
> 
>     Gene | log(Probe 1) | log(Probe 2) | log(Probe 3)
>      |  |  |
>     B | -1,0 | 0,1 | 0,8
>     C | -0,8 | -0,3 | 1,0
>     **Median** | -0,9 | -0,1 | 0,9
> 
>     Der Median wird hier verwendet, um extreme Gene (wahrscheinlich seltene) davon abzuhalten, den Wert zu stark in eine Richtung zu beeinflussen. Dies hilft, mehr Gewicht auf mäßig exprimierte Gene zu legen.
> 
> 6. Berechnen Sie den Skalierungsfaktor, indem Sie die Exponentialfunktion der Mediane nehmen:
> 
>     Gene | Probe 1 | Probe 2 | Probe 3
>     **Median** | -0,9 | -0,1 | 0,9
>     **Skalierungsfaktoren** | 0,4 | 0,9 | 2,5
> 
> 7. Berechnen Sie die normalisierten Zählungen: Teilen Sie die ursprünglichen Zählungen durch die Skalierungsfaktoren:
> 
>     Gene | Probe 1 | Probe 2 | Probe 3
>     A | 0 | 11,11 | 1,6
>     B | 5 | 6,67 | 4,8
>     C | 83 | 61,11 | 80
> 
> *Diese Erklärung ist eine Transkription und Anpassung des [StatQuest-Videos zur Erklärung der Bibliotheksnormalisierung in DESeq2](https://www.youtube.com/watch?v=UFB993xufUU&t=35s)*.
> 
{: .details}
DESeq2 führt auch die Analyse der differentiellen Genexpression (DGE) durch, die zwei grundlegende Aufgaben hat:

- Schätzung der biologischen Varianz anhand der Replikate für jede Bedingung
- Schätzung der Signifikanz von Expressionsunterschieden zwischen zwei Bedingungen

Diese Expressionsanalyse wird aus den Read-Zählungen geschätzt und versucht, die Variabilität in den Messungen mithilfe von Replikaten zu korrigieren, die für genaue Ergebnisse absolut unerlässlich sind. Für Ihre eigene Analyse empfehlen wir, mindestens 3, aber vorzugsweise 5 biologische Replikate pro Bedingung zu verwenden. Es ist möglich, unterschiedliche Zahlen von Replikaten pro Bedingung zu haben.

> <details-title>Technische vs. biologische Replikate</details-title>
>
> Ein technisches Replikat ist ein Experiment, das einmal durchgeführt, aber mehrfach gemessen wird (z.B. mehrfaches Sequenzieren derselben Bibliothek). Ein biologisches Replikat ist ein Experiment, das mehrfach durchgeführt (und ebenfalls gemessen) wird.
>
> In unseren Daten haben wir 4 biologische Replikate (hier als Proben bezeichnet) ohne Behandlung und 3 biologische Replikate mit Behandlung (*Pasilla*-Gen durch RNAi ausgeschaltet).
>
> Wir empfehlen, die Zähltabellen für verschiedene technische Replikate (aber nicht für biologische Replikate) vor der Differentiellen Expressionsanalyse zu kombinieren (siehe [DESeq2-Dokumentation](http://bioconductor.org/packages/devel/bioc/vignettes/DESeq2/inst/doc/DESeq2.html#collapsing-technical-replicates))
{: .details}

Mehrere Faktoren mit mehreren Ebenen können dann in die Analyse einbezogen werden, um bekannte Quellen der Variation zu beschreiben (z.B. Behandlung, Gewebetyp, Geschlecht, Chargen), wobei zwei oder mehr Ebenen die Bedingungen für jeden Faktor darstellen. Nach der Normalisierung können wir die Reaktion der Expression eines jeden Gens auf das Vorhandensein verschiedener Ebenen eines Faktors auf statistisch zuverlässige Weise vergleichen.

In unserem Beispiel haben wir Proben mit zwei variablen Faktoren, die zu Unterschieden in der Genexpression beitragen können:

- Behandlung (entweder behandelt oder unbehandelt)
- Sequenzierungstyp (paired-end oder single-end)

Hier ist die Behandlung der primäre Faktor, an dem wir interessiert sind. Der Sequenzierungstyp ist weitere Information, die wir über die Daten wissen, die die Analyse beeinflussen könnte. Die Multifaktor-Analyse ermöglicht es uns, den Effekt der Behandlung zu bewerten und dabei den Sequenzierungstyp zu berücksichtigen.

> <comment-title></comment-title>
>
> Wir empfehlen, alle Faktoren hinzuzufügen, von denen Sie glauben, dass sie die Genexpression in Ihrem Experiment beeinflussen könnten. Dies kann der Sequenzierungstyp wie hier sein, aber auch die Manipulation (wenn verschiedene Personen an der Bibliotheksvorbereitung beteiligt sind), andere Batch-Effekte usw.
{: .comment}

Wenn Sie nur ein oder zwei Faktoren mit wenigen biologischen Replikaten haben, ist das grundlegende Setup von **DESeq2** ausreichend. Im Falle eines komplexen experimentellen Setups mit einer großen Anzahl biologischer Replikate sind tag-basierte Sammlungen geeignet. Beide Ansätze liefern dieselben Ergebnisse. Der tag-basierte Ansatz erfordert ein paar zusätzliche Schritte vor dem Ausführen des **DESeq2**-Tools, aber es wird sich lohnen, wenn Sie mit einem komplexen experimentellen Setup arbeiten.

{% include _includes/cyoa-choices.html option1="Basic" option2="Tag-based" default="Basic" text="Welchen Ansatz möchten Sie verwenden?" disambiguation="deseq"%}

<div class="Basic" markdown="1">

Wir können jetzt **DESeq2** ausführen:

> <hands-on-title>Bestimmen der differentiell exprimierten Merkmale</hands-on-title>
>
> 1. {% tool [DESeq2](toolshed.g2.bx.psu.edu/repos/iuc/deseq2/deseq2/2.11.40.7+galaxy2) %} mit den folgenden Parametern:
>    - *"how"*: `Select datasets per level`
>        - In *"Factor"*:
>           - *"Specify a factor name, e.g. effects_drug_x or cancer_markers"*: `Treatment`
>           - In *"1: Factor level"*:
>               - *"Specify a factor level, typical values could be 'tumor', 'normal', 'treated' or 'control'"*: `treated`
>               - In *"Count file(s)"*: `Wählen Sie alle behandelten Zähldateien aus (GSM461179, GSM461180, GSM461181)`
>           - In *"2: Factor level"*:
>               - *"Specify a factor level, typical values could be 'tumor', 'normal', 'treated' or 'control'"*: `untreated`
>               - In *"Count file(s)"*: `Wählen Sie alle unbehandelten Zähldateien aus (GSM461176, GSM461177, GSM461178, GSM461182)`
>       - {% icon param-repeat %} *"Insert Factor"*
>           - *"Specify a factor name, e.g. effects_drug_x or cancer_markers"*: `Sequencing`
>               - In *"Factor level"*:
>                    - {% icon param-repeat %} *"Insert Factor level"*
>                        - *"Specify a factor level, typical values could be 'tumor', 'normal', 'treated' or 'control'"*: `PE`
>                        - In *"Count file(s)"*: `Wählen Sie alle paired-end Zähldateien aus (GSM461177, GSM461178, GSM461180, GSM461181)`
>                    - {% icon param-repeat %} *"Insert Factor level"*
>                        - *"Specify a factor level, typical values could be 'tumor', 'normal', 'treated' or 'control'"*: `SE`
>                        - In *"Count file(s)"*: `Wählen Sie alle single-end Zähldateien aus (GSM461176, GSM461179, GSM461182)`
>    - *"Files have header?"*: `Ja`
>    - *"Choice of Input data"*: `Zähldaten (z.B. von HTSeq-count, featureCounts oder StringTie)`
>    - In *"Output options"*:
>        - *"Output selector"*: `Plots zur Visualisierung der Analyseergebnisse erstellen`, `Normalisierte Zählungen ausgeben`
>
{: .hands_on}

</div>

<div class="Tag-based" markdown="1">

DESeq2 erfordert, dass für jeden Faktor die Zählungen der Proben in jeder Kategorie angegeben werden. Wir werden daher Tags an unserer Sammlung von Zählungen verwenden, um alle Proben, die zur gleichen Kategorie gehören, einfach auszuwählen. Weitere Informationen zu alternativen Möglichkeiten, Gruppentags festzulegen, finden Sie in [diesem Tutorial]({% link topics/galaxy-interface/tutorials/group-tags/tutorial.md %}).

> <hands-on-title>Tags zu Ihrer Sammlung für jeden dieser Faktoren hinzufügen</hands-on-title>
>
> 1. Erstellen Sie eine Sammlungsliste mit allen diesen Zählungen, die Sie `all counts` benennen. Benennen Sie jedes Element so um, dass es nur die GSM-ID, die Behandlung und die Bibliothek enthält, z.B. `GSM461176_untreat_single`.
>
>    {% snippet faqs/galaxy/collections_build_list.md %}
>
> 2. {% tool [Extract element identifiers](toolshed.g2.bx.psu.edu/repos/iuc/collection_element_identifiers/collection_element_identifiers/0.0.2) %} mit den folgenden Parametern:
>    - {% icon param-collection %} *"Dataset collection"*: `all counts`
>
>    Wir werden nun die Faktoren aus den Namen extrahieren:
>
> 3. {% tool [Replace Text in entire line](toolshed.g2.bx.psu.edu/repos/bgruening/text_processing/tp_replace_in_line/1.1.2) %}
>      - {% icon param-file %} *"File to process"*: Ausgabe von **Extract element identifiers** {% icon tool %}
>      - In *"Replacement"*:
>         - In *"1: Replacement"*
>            - *"Find pattern"*: `(.*)_(.*)_(.*)`
>            - *"Replace with"*: `\1_\2_\3\tgroup:\2\tgroup:\3`
>
>     Dieser Schritt erstellt 2 zusätzliche Spalten mit der Art der Behandlung und Sequenzierung, die mit dem {% tool [Tag elements from file](__TAG_FROM_FILE__) %} Tool verwendet werden können
>
> 4. Ändern Sie den Datentyp in `tabular`
>
>    {% snippet faqs/galaxy/datasets_change_datatype.md datatype="tabular" %}
>
> 5. {% tool [Tag elements](__TAG_FROM_FILE__) %}
>      - {% icon param-collection %} *"Input Collection"*: `all counts`
>      - {% icon param-file %} *"Tag collection elements according to this file"*: Ausgabe von **Replace Text** {% icon tool %}
>
> 6. Überprüfen Sie die neue Sammlung
>
>    > <tip-title>Sie sehen die Änderungen nicht?</tip-title>
>    >
>    > Sie sehen sie möglicherweise nicht auf den ersten Blick, da die Namen gleich sind. Wenn Sie jedoch auf eines klicken und auf {% icon galaxy-tags %} **Dataset tags bearbeiten** klicken, sollten Sie 2 Tags sehen, die mit 'group:' beginnen. Dieses Schlüsselwort ermöglicht die Verwendung dieser Tags in **DESeq2**.
>     >
>     {: .tip}
>
{: .hands_on}
Wir können jetzt **DESeq2** ausführen:

> <hands-on-title>Bestimmen der differentiell exprimierten Merkmale</hands-on-title>
>
> 1. {% tool [DESeq2](toolshed.g2.bx.psu.edu/repos/iuc/deseq2/deseq2/2.11.40.7+galaxy2) %} mit den folgenden Parametern:
>    - *"how"*: `Wählen Sie Gruppentags entsprechend den Ebenen`
>        - {% icon param-collection %} *"Zähl-Dateien Sammlung"*: Ausgabe von **Tag elements** {% icon tool %}
>        - In *"Faktor"*:
>            - {% icon param-repeat %} *"Faktor einfügen"*
>                - *"Geben Sie einen Faktornamen an, z.B. effects_drug_x oder cancer_markers"*: `Behandlung`
>                - In *"Faktor Ebene"*:
>                    - {% icon param-repeat %} *"Faktor Ebene einfügen"*
>                        - *"Geben Sie eine Faktorebene an, typische Werte könnten 'tumor', 'normal', 'treated' oder 'control' sein"*: `behandelt`
>                        - *"Wählen Sie Gruppen aus, die dieser Faktorebene entsprechen"*: `Tags: treat`
>                    - {% icon param-repeat %} *"Faktor Ebene einfügen"*
>                        - *"Geben Sie eine Faktorebene an, typische Werte könnten 'tumor', 'normal', 'treated' oder 'control' sein"*: `unbehandelt`
>                        - *"Wählen Sie Gruppen aus, die dieser Faktorebene entsprechen"*: `Tags: untreat`
>            - {% icon param-repeat %} *"Faktor einfügen"*
>                - *"Geben Sie einen Faktornamen an, z.B. effects_drug_x oder cancer_markers"*: `Sequenzierung`
>                - In *"Faktor Ebene"*:
>                    - {% icon param-repeat %} *"Faktor Ebene einfügen"*
>                        - *"Geben Sie eine Faktorebene an, typische Werte könnten 'tumor', 'normal', 'treated' oder 'control' sein"*: `PE`
>                        - *"Wählen Sie Gruppen aus, die dieser Faktorebene entsprechen"*: `Tags: paired`
>                    - {% icon param-repeat %} *"Faktor Ebene einfügen"*
>                        - *"Geben Sie eine Faktorebene an, typische Werte könnten 'tumor', 'normal', 'treated' oder 'control' sein"*: `SE`
>                        - *"Wählen Sie Gruppen aus, die dieser Faktorebene entsprechen"*: `Tags: single`
>    - *"Dateien haben Kopfzeilen?"*: `Ja`
>    - *"Wahl der Eingabedaten"*: `Zähldaten (z.B. von HTSeq-count, featureCounts oder StringTie)`
>    - In *"Ausgabeoptionen"*:
>        - *"Auswahl der Ausgaben"*: `Plots zur Visualisierung der Analyseergebnisse erstellen`, `Normalisierte Zählungen ausgeben`
>
{: .hands_on}

**DESeq2** hat 3 Ausgaben erzeugt:

- Eine Tabelle mit den normalisierten Zählungen für jedes Gen (Zeilen) in den Proben (Spalten)
- Eine grafische Zusammenfassung der Ergebnisse, die nützlich ist, um die Qualität des Experiments zu bewerten:

    1. Ein Plot der ersten 2 Dimensionen einer Hauptkomponentenanalyse ([PCA](https://en.wikipedia.org/wiki/Principal_component_analysis)), durchgeführt auf den normalisierten Zählungen der Proben

        > <details-title>Was ist eine PCA?</details-title>
        >
        > Stellen Sie sich vor, wir haben einige Bierflaschen hier auf dem Tisch stehen. Wir können jedes Bier nach seiner Farbe, seinem Schaum, seiner Stärke und so weiter beschreiben. Wir könnten eine ganze Liste verschiedener Merkmale jedes Biers in einem Biergeschäft erstellen. Viele dieser Merkmale messen jedoch verwandte Eigenschaften und sind daher redundant. Wenn das der Fall ist, sollten wir in der Lage sein, jedes Bier mit weniger Merkmalen zusammenzufassen. Das ist, was PCA oder Hauptkomponentenanalyse macht.
        >
        > Bei der PCA wählen wir nicht einfach einige interessante Merkmale aus und verwerfen die anderen. Stattdessen erstellen wir neue Merkmale, die unsere Liste von Bieren gut zusammenfassen. Diese neuen Merkmale werden unter Verwendung der alten erstellt. Zum Beispiel könnte ein neues Merkmal berechnet werden, z.B. Schaumgröße minus pH-Wert des Biers. Diese sind lineare Kombinationen.
        >
        > Tatsächlich findet die PCA die bestmöglichen Merkmale, die die Liste der Biere zusammenfassen. Diese Merkmale können verwendet werden, um Ähnlichkeiten zwischen Bieren zu finden und sie zu gruppieren.
        >
        > Zurück zu den Lesezählern: Die PCA wird auf den normalisierten Zählungen aller Proben durchgeführt. Hier möchten wir die Proben basierend auf der Expression der Gene beschreiben. Die Merkmale sind die Anzahl der Lesevorgänge, die auf jedes Gen abgebildet sind. Wir verwenden sie und lineare Kombinationen davon, um die Proben und ihre Ähnlichkeiten darzustellen.
        >
        > *Die Bieranalogie wurde [einer Antwort auf StackExchange](https://stats.stackexchange.com/questions/2691/making-sense-of-principal-component-analysis-eigenvectors-eigenvalues) entnommen.*
        >
        {: .details}

        Sie zeigt die Proben in der 2D-Ebene, die von ihren ersten beiden Hauptkomponenten aufgespannt wird. Jede Replikatprobe wird als einzelner Datenpunkt dargestellt. Diese Art von Plot ist nützlich, um den Gesamteffekt von experimentellen Kovariaten und Batch-Effekten zu visualisieren.

        > <question-title></question-title>
        >
        > ![DESeq PCA](../../images/ref-based/deseq2_pca.png "Hauptkomponentenplot der Proben")
        >
        > 1. Was trennt die erste Dimension (PC1)?
        > 2. Und die zweite Dimension (PC2)?
        > 3. Was können wir über das DESeq-Design (Faktoren, Ebenen) schließen, das wir gewählt haben?
        >
        > > <solution-title></solution-title>
        > >
        > > 1. Die erste Dimension trennt die behandelten Proben von den unbehandelten Proben.
        > > 2. Die zweite Dimension trennt die Single-End-Datensätze von den Pair-End-Datensätzen.
        > > 3. Die Datensätze sind entsprechend den Ebenen der beiden Faktoren gruppiert. Es scheint keinen versteckten Effekt auf den Daten zu geben. Wenn unerwünschte Variationen in den Daten vorhanden sind (z.B. Batch-Effekte), wird empfohlen, diese zu korrigieren, was in DESeq2 erreicht werden kann, indem bekannte Batch-Variablen im Design berücksichtigt werden.
        > {: .solution}
        {: .question}

    2. Ein Heatmap der Distanzmatrix zwischen den Proben (mit Clusterung) basierend auf den normalisierten Zählungen.

        Das Heatmap gibt einen Überblick über Ähnlichkeiten und Unterschiede zwischen Proben: Die Farbe stellt die Distanz zwischen den Proben dar. Dunkelblau bedeutet kürzere Distanz, d.h. nähere Proben basierend auf den normalisierten Zählungen.

        > <question-title></question-title>
        >
        > ![Heatmap der Probenabstände](../../images/ref-based/deseq2_sample_sample_distance_heatmap.png "Heatmap der Probenabstände")
        >
        > Wie sind die Proben gruppiert?
        >
        > > <solution-title></solution-title>
        > >
        > > Sie sind zuerst nach der Behandlung (dem ersten Faktor) und dann nach dem Sequenzierungstyp (dem zweiten Faktor) gruppiert, wie im PCA-Plot.
        > >
        > {: .solution}
        {: .question}

    3. Schätzungen der Dispersion: gen-spezifische Schätzungen (schwarz), die angepassten Werte (rot) und die endgültigen Maximum-a-posteriori-Schätzungen, die für die Tests verwendet werden (blau)

        Dieser Dispersion-Plot ist typisch, wobei die endgültigen Schätzungen von den gen-spezifischen Schätzungen in Richtung der angepassten Schätzungen geschrumpft sind. Einige gen-spezifische Schätzungen werden als Ausreißer markiert und nicht in Richtung der angepassten Werte geschrumpft. Der Grad der Schrumpfung kann mehr oder weniger als hier dargestellt sein, abhängig von der Stichprobengröße, der Anzahl der Koeffizienten, dem Mittelwert der Zeilen und der Variabilität der gen-spezifischen Schätzungen.

    4. Histogramm der *p*-Werte für die Gene im Vergleich zwischen den 2 Ebenen des ersten Faktors

    5. Ein [MA-Plot](https://en.wikipedia.org/wiki/MA_plot):

        Dies zeigt die globale Ansicht der Beziehung zwischen der Expressionsänderung der Bedingungen (log-Ratios, M), der durchschnittlichen Expressionsstärke der Gene (durchschnittlicher Mittelwert, A) und der Fähigkeit des Algorithmus, differenzielle Genexpression zu erkennen. Die Gene, die den Signifikanzschwellenwert (angepasster p-Wert < 0.1) überschreiten, sind rot eingefärbt.

- Eine Zusammenfassungsdatei mit folgenden Werten für jedes Gen:

    1. Genbezeichner
    2. Mittelwert der normalisierten Zählungen, gemittelt über alle Proben beider Bedingungen
    3. Fold-Änderung in log2 (Logarithmus zur Basis 2)

       Die log2-Fold-Änderungen basieren auf der primären Faktorebene 1 gegenüber Faktorebene 2, daher ist die Eingabereihenfolge der Faktorebenen wichtig. Hier berechnet DESeq2 die Fold-Änderungen von 'behandelten' Proben gegenüber 'unbehandelten' aus dem ersten Faktor 'Behandlung', *d.h.* die Werte entsprechen der Hoch- oder Herunterregulierung von Genen in behandelten Proben.

    4. Schätzung des Standardfehlers für die Schätzung der log2-Fold-Änderung
    5. [Wald](https://en.wikipedia.org/wiki/Wald_test) Statistik
    6. *p*-Wert für die statistische Signifikanz dieser Änderung
    7. *p*-Wert, angepasst für multiple Tests mit dem Benjamini-Hochberg-Verfahren, das die Fehlerrate bei Entdeckungen ([FDR](https://en.wikipedia.org/wiki/False_discovery_rate)) kontrolliert

    > <tip-title>Was sind p-Werte und wofür werden sie verwendet?</tip-title>
    >
    > Der p-Wert ist ein Maß, das häufig verwendet wird, um zu bestimmen, ob eine bestimmte Beobachtung statistische Signifikanz aufweist oder nicht. Streng genommen ist der p-Wert die Wahrscheinlichkeit, dass die Daten zufällig entstanden sind, vorausgesetzt, die Nullhypothese ist korrekt. Im konkreten Fall von RNA-Seq ist die Nullhypothese, dass keine differenzielle Genexpression vorliegt. Ein p-Wert von 0,13 für ein bestimmtes Gen bedeutet also, dass es bei diesem Gen, vorausgesetzt, es ist nicht differenziell exprimiert, eine 13%ige Chance gibt, dass eine scheinbare differenzielle Expression einfach durch zufällige Variation in den experimentellen Daten verursacht werden könnte.
    >
    > 13% ist immer noch ziemlich hoch, sodass wir uns nicht wirklich sicher sein können, dass eine differenzielle Genexpression vorliegt. Die häufigste Methode, die Wissenschaftler verwenden, ist es, einen Schwellenwert festzulegen (häufig 0,05, manchmal auch andere Werte wie 0,01) und die Nullhypothese nur für p-Werte unter diesem Wert abzulehnen. Daher können wir für Gene mit p-Werten unter 0,05 sicher sagen, dass eine differenzielle Genexpression eine Rolle spielt. Es sollte beachtet werden, dass jeder solche Schwellenwert willkürlich ist und es keinen wesentlichen Unterschied zwischen einem p-Wert von 0,049 und 0,051 gibt, auch wenn wir die Nullhypothese nur im ersten Fall ablehnen.
    >
    > Leider werden p-Werte in der wissenschaftlichen Forschung oft stark missbraucht, sodass Wikipedia [einen speziellen Artikel](https://en.wikipedia.org/wiki/Misuse_of_p-values) zu diesem Thema hat. Siehe auch [diesen Artikel](https://fivethirtyeight.com/features/not-even-scientists-can-easily-explain-p-values/) (gerichtet an ein allgemeines, nicht-wissenschaftliches Publikum).
    {: .tip}
Für weitere Informationen zu **DESeq2** und seinen Ausgaben können Sie die [**DESeq2**-Dokumentation](https://www.bioconductor.org/packages/release/bioc/manuals/DESeq2/man/DESeq2.pdf) einsehen.

> <question-title></question-title>
>
> 1. Ist das Gen FBgn0003360 aufgrund der Behandlung differentiell exprimiert? Wenn ja, wie stark?
> 2. Wird das *Pasilla*-Gen (ps, FBgn0261552) durch die RNAi-Behandlung herunterreguliert?
> 3. Wir könnten hypothetisch auch am Effekt der Sequenzierung (oder anderen sekundären Faktoren in anderen Fällen) interessiert sein. Wie könnten wir die aufgrund des Sequenzierungstyps differentiell exprimierten Gene herausfinden?
> 4. Wir möchten die Wechselwirkung zwischen der Behandlung und der Sequenzierung analysieren. Wie könnten wir das tun?
>
> > <solution-title></solution-title>
> >
> > 1. FBgn0003360 ist aufgrund der Behandlung differentiell exprimiert: Es hat einen signifikanten angepassten p-Wert ($$2.8 \cdot 10^{-171} << 0.05$$). Es wird weniger exprimiert (`-` in der Spalte log2FC) in behandelten Proben im Vergleich zu unbehandelten Proben, mit einem Faktor von ~8 ($$2^{log2FC} = 2^{2.99542318410271}$$).
> >
> > 2. Sie können manuell nach `FBgn0261552` in der ersten Spalte suchen oder {% tool [Filter data on any column using simple expressions](Filter1) %}
> >   - {% icon param-file %} *"Filter"*: die `DESeq2-Ergebnisdatei` (Ausgabe von **DESeq2** {% icon tool %})
> >   - *"With following condition"*: `c1 == "FBgn0261552"`
> >
> >    Der log2-Fold-Change ist negativ, daher wird das Gen tatsächlich herunterreguliert und der angepasste p-Wert liegt unter 0,05, sodass es zu den signifikant veränderten Genen gehört.
> >
> > 3. DESeq2 in Galaxy liefert den Vergleich zwischen den verschiedenen Ebenen des ersten Faktors nach Korrektur für die Variabilität aufgrund des zweiten Faktors. In unserem aktuellen Fall wird der Vergleich zwischen behandelten und unbehandelten Proben für jeden Sequenzierungstyp durchgeführt. Um Sequenzierungstypen zu vergleichen, sollten wir DESeq2 erneut ausführen und die Faktoren umschalten: Faktor 1 (Behandlung) wird zu Faktor 2 und Faktor 2 (Sequenzierung) wird zu Faktor 1.
> >
> > 4. Um die Interaktion zwischen zwei Faktoren (z.B. behandelte Proben für Pair-End-Daten vs. unbehandelte Proben für Single-End-Daten) zu analysieren, sollten wir DESeq2 ein weiteres Mal ausführen, aber nur mit einem Faktor mit den folgenden 4 Ebenen:
> >    - treated-PE
> >    - untreated-PE
> >    - treated-SE
> >    - untreated-SE
> >
> >    Durch Auswahl von *"Output all levels vs all levels of primary factor (use when you have >2 levels for primary factor)"* auf `Ja`, können wir dann behandelte-PE vs unbehandelte-SE vergleichen.
> >
> {: .solution}
{: .question}

## Annotation der DESeq2-Ergebnisse

Die ID für jedes Gen ist etwas wie FBgn0003360, was eine ID aus der entsprechenden Datenbank, hier Flybase ({% cite thurmond2018flybase %}), ist. Diese IDs sind einzigartig, aber manchmal bevorzugen wir die Gen-Namen, auch wenn diese nicht immer auf ein einzigartiges Gen verweisen (z.B. dupliziert nach der Neuannotation). Aber Gen-Namen können bereits auf eine Funktion hinweisen oder helfen, gewünschte Kandidaten zu finden. Wir möchten auch den Standort dieser Gene im Genom anzeigen. Wir können solche Informationen aus der Annotierungsdatei extrahieren, die wir für das Mapping und Zählen verwendet haben.

> <hands-on-title>Annotation der DESeq2-Ergebnisse</hands-on-title>
>
> 1. Importieren Sie die Ensembl-Genannotation für *Drosophila melanogaster* (`Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf.gz`) aus der vorherigen Historie, oder aus der Shared Data-Bibliothek oder von Zenodo:
>
>    ```text
>    {{ page.zenodo_link }}/files/Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf.gz
>    ```
>
> 2. {% tool [Annotate DESeq2/DEXSeq output tables](toolshed.g2.bx.psu.edu/repos/iuc/deg_annotate/deg_annotate/1.1.0) %} mit:
>    - {% icon param-file %} *"Tabellarische Ausgabe von DESeq2/edgeR/limma/DEXSeq"*: die `DESeq2 Ergebnisdatei` (Ausgabe von **DESeq2** {% icon tool %})
>    - *"Eingabedateityp"*: `DESeq2/edgeR/limma`
>    - {% icon param-file %} *"Referenzannotation im GFF/GTF-Format"*: importierte gtf `Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf.gz`
>
{: .hands_on}

Die erzeugte Ausgabe ist eine Erweiterung der vorherigen Datei:

1. Genbezeichner
2. Durchschnittliche normalisierte Zählungen über alle Proben
3. Log2-Fold-Änderung
4. Schätzung des Standardfehlers für die Schätzung der log2-Fold-Änderung
5. Wald-Statistik
6. *p*-Wert für die Wald-Statistik
7. *p*-Wert, angepasst für multiple Tests mit dem Benjamini-Hochberg-Verfahren für die Wald-Statistik
8. Chromosom
9. Start
10. Ende
11. Strang
12. Merkmal
13. Genname

> <question-title></question-title>
>
> 1. Wo befindet sich das am stärksten über-exprimierte Gen?
> 2. Wie heißt das Gen?
> 3. Wo befindet sich das *Pasilla*-Gen (FBgn0261552)?
>
> > <solution-title></solution-title>
> >
> > 1. FBgn0025111 (das am höchsten eingestufte Gen mit dem höchsten positiven log2FC-Wert) befindet sich auf dem umgekehrten Strang von Chromosom X, zwischen 10.778.953 bp und 10.786.907 bp.
> > 2. Aus der Tabelle erhalten wir das Gen-Symbol: Ant2. Nach einigen Recherchen in den [online biologischen Datenbanken](https://www.ncbi.nlm.nih.gov/gene/32008) finden wir heraus, dass Ant2 für Adenin-Nukleotid-Translokase 2 steht.
> > 3. Das *Pasilla*-Gen befindet sich auf dem Vorwärtsstrang von Chromosom 3R, zwischen 9.417.939 bp und 9.455.500 bp.
> {: .solution}
{: .question}

Die annotierte Tabelle enthält keine Spaltennamen, was das Lesen erschwert. Wir möchten sie hinzufügen, bevor wir weitermachen.
> <hands-on-title>Spaltennamen hinzufügen</hands-on-title>
>
> 1. Erstellen Sie eine neue Datei (`header`) aus der folgenden Zeile (Header der DESeq2-Ausgabe):
>
>    ```text
>    GeneID	Base mean	log2(FC)	StdErr	Wald-Stats	P-value	P-adj	Chromosome	Start	End	Strand	Feature	Gene name
>    ```
>
>    {% snippet faqs/galaxy/datasets_create_new_file.md name="header" format="tabular" %}
>
> 2. {% tool [Datenmengen zusammenfügen](cat1) %} um diese Header-Zeile zur **Annotate**-Ausgabe hinzuzufügen:
>    - {% icon param-file %} *"Concatenate Dataset"*: das `header`-Dataset
>    - *"Dataset"*
>       - Klicken Sie auf {% icon param-repeat %} *"Dataset einfügen"*
>         - {% icon param-file %} *"auswählen"*: Ausgabe von **Annotate** {% icon tool %}
>
> 3. Benennen Sie die Ausgabe in `Annotierte DESeq2 Ergebnisse` um.
{: .hands_on}

## Extraktion und Annotation der differentiell exprimierten Gene

Nun möchten wir die am stärksten differentiell exprimierten Gene aufgrund der Behandlung extrahieren, wobei der Fold Change > 2 (oder < 1/2) betragen soll.

> <hands-on-title>Extraktion der am stärksten differentiell exprimierten Gene</hands-on-title>
>
> 1. {% tool [Daten nach beliebigen Spalten mit einfachen Ausdrücken filtern](Filter1) %} um Gene mit signifikanten Änderungen in der Genexpression (angepasster *p*-Wert unter 0.05) zwischen behandelten und unbehandelten Proben zu extrahieren:
>    - {% icon param-file %} *"Filter"*: `Annotierte DESeq2 Ergebnisse`
>    - *"Mit folgender Bedingung"*: `c7<0.05`
>    - *"Anzahl der zu überspringenden Header-Zeilen"*: `1`
>
> 2. Benennen Sie die Ausgabe in `Gene mit signifikantem adj p-Wert` um.
>
>    > <question-title></question-title>
>    >
>    > Wie viele Gene haben eine signifikante Änderung der Genexpression zwischen diesen Bedingungen?
>    >
>    > > <solution-title></solution-title>
>    > >
>    > > Wir erhalten 966 (967 Zeilen einschließlich eines Headers) Gene (4,04%) mit einer signifikanten Änderung der Genexpression zwischen behandelten und unbehandelten Proben.
>    > >
>    > {: .solution}
>    {: .question}
>    >
>    > <comment-title></comment-title>
>    >
>    > Die Datei mit den unabhängig gefilterten Ergebnissen kann für die weitere Analyse verwendet werden, da sie Gene mit nur wenigen Lesezahlen ausschließt, da diese Gene nicht als signifikant differentiell exprimiert betrachtet werden.
>    {: .comment}
>
>    Wir werden nun nur die Gene mit einem Fold Change (FC) > 2 oder FC < 0,5 auswählen. Beachten Sie, dass die DESeq2-Ausgabedatei $$log_{2} FC$$ enthält und nicht FC selbst, daher filtern wir nach $$abs(log_{2} FC) > 1$$ (was FC > 2 oder FC < 0,5 impliziert).
>
> 3. {% tool [Daten nach beliebigen Spalten mit einfachen Ausdrücken filtern](Filter1) %} um Gene mit $$abs(log_{2} FC) > 1$$ zu extrahieren:
>    - {% icon param-file %} *"Filter"*: `Gene mit signifikantem adj p-Wert`
>    - *"Mit folgender Bedingung"*: `abs(c3)>1`
>    - *"Anzahl der zu überspringenden Header-Zeilen"*: `1`
>
> 4. Benennen Sie die Ausgabe in `Gene mit signifikantem adj p-Wert & abs(log2(FC)) > 1` um.
>
>    > <question-title></question-title>
>    >
>    > 1. Wie viele Gene wurden beibehalten?
>    > 2. Ist das *Pasilla*-Gen (ps, FBgn0261552) in dieser Tabelle zu finden?
>    >
>    > > <solution-title></solution-title>
>    > >
>    > > 1. Wir erhalten 113 Gene (114 Zeilen einschließlich eines Headers), oder 11,79% der signifikant differentiell exprimierten Gene.
>    > > 2. Das *Pasilla*-Gen kann mit einer schnellen Suche (oder sogar unter Verwendung von {% tool [Daten nach beliebigen Spalten mit einfachen Ausdrücken filtern](Filter1) %} ) gefunden werden.
>    > {: .solution}
>    {: .question}
>
{: .hands_on}

Wir haben jetzt eine Tabelle mit 113 Zeilen und einem Header, die den am stärksten differentiell exprimierten Genen entspricht. Für jedes Gen haben wir seine ID, die durchschnittlichen normalisierten Zählungen (durchschnittlich über alle Proben aus beiden Bedingungen), seinen $$log_{2} FC$$ und weitere Informationen einschließlich Genname und Position.

## Visualisierung der Expression der differentiell exprimierten Gene

Wir könnten den $$log_{2} FC$$ für die extrahierten Gene plotten, aber hier möchten wir ein Heatmap der Expression dieser Gene in den verschiedenen Proben betrachten. Dazu müssen wir die normalisierten Zählungen für diese Gene extrahieren.

Wir gehen dabei in mehreren Schritten vor:

- Extraktion und Darstellung der normalisierten Zählungen für diese Gene für jede Probe mit einem Heatmap, unter Verwendung der von DESeq2 erzeugten normalisierten Zählungsdatei
- Berechnung, Extraktion und Darstellung des Z-Scores der normalisierten Zählungen

> <comment-title>Erweiterte Tutorials zur Visualisierung</comment-title>
>
> In diesem Tutorial werden einige mögliche Visualisierungen schnell erklärt. Für weitere Details schauen Sie sich bitte die zusätzlichen Tutorials zur Visualisierung von RNA-Seq-Ergebnissen an:
>
> - [Visualisierung von RNA-Seq-Ergebnissen mit Heatmap2]({% link topics/transcriptomics/tutorials/rna-seq-viz-with-heatmap2/tutorial.md %})
> - [Visualisierung von RNA-Seq-Ergebnissen mit Volcano Plot]({% link topics/transcriptomics/tutorials/rna-seq-viz-with-volcanoplot/tutorial.md %})
>
{: .comment}

### Visualisierung der normalisierten Zählungen

Um die normalisierten Zählungen für die interessanten Gene zu extrahieren, verbinden wir die normalisierte Zählungstabelle, die von DESeq2 erzeugt wurde, mit der Tabelle, die wir gerade erstellt haben. Wir werden dann nur die Spalten mit den normalisierten Zählungen behalten.

> <hands-on-title>Extraktion der normalisierten Zählungen der am stärksten differentiell exprimierten Gene</hands-on-title>
>
> 1. {% tool [Zwei Datensätze nebeneinander anhand eines angegebenen Feldes zusammenführen](join1) %} mit den folgenden Parametern:
>    - {% icon param-file %} *"Join"*: die `Normalisierte Zählungen`-Datei (Ausgabe von **DESeq2** {% icon tool %})
>    - *"using column"*: `Spalte: 1`
>    - {% icon param-file %} *"with"*: `Gene mit signifikantem adj p-Wert & abs(log2(FC)) > 1`
>    - *"and column"*: `Spalte: 1`
>    - *"Behalte Zeilen des ersten Eingangs, die sich nicht mit dem zweiten Eingangs verbinden"*: `Nein`
>    - *"Behalte die Header-Zeilen"*: `Ja`
>
>    Die erzeugte Datei hat mehr Spalten als wir für das Heatmap benötigen: durchschnittliche normalisierte Zählungen, $$log_{2} FC$$ und andere Annotierungsinformationen. Wir müssen die zusätzlichen Spalten entfernen.
>
> 2. {% tool [Spalten aus einer Tabelle ausschneiden](Cut1) %} mit den folgenden Parametern, um die Spalten mit den Gen-IDs und normalisierten Zählungen zu extrahieren:
>    - *"Spalten ausschneiden"*: `c1-c8`
>    - *"Getrennt durch"*: `Tabulator`
>    - {% icon param-file %} *"Von"*: der zusammengeführte Datensatz (Ausgabe von **Zwei Datensätze zusammenführen** {% icon tool %})
>
> 3. Benennen Sie die Ausgabe in `Normalisierte Zählungen für die am stärksten differentiell exprimierten Gene` um.
>
{: .hands_on}
Wir haben jetzt eine Tabelle mit 114 Zeilen (die 113 am stärksten differentiell exprimierten Gene und ein Header) und den normalisierten Zählungen für diese Gene über die 7 Proben.

> <hands-on-title>Heatmap der normalisierten Zählungen dieser Gene für die Proben plotten</hands-on-title>
>
> 1. {% tool [heatmap2](toolshed.g2.bx.psu.edu/repos/iuc/ggplot2_heatmap2/ggplot2_heatmap2/3.1.3+galaxy0) %} zum Plotten der Heatmap:
>    - {% icon param-file %} *"Input should have column headers"*: `Normalisierte Zählungen für die am stärksten differentiell exprimierten Gene`
>    - *"Datenumwandlung"*: `Log2(Wert+1) transformiere meine Daten`
>    - *"Datenclustering aktivieren"*: `Ja`
>    - *"Beschriftung von Spalten und Zeilen"*: `Spalten beschriften, keine Zeilen`
>    - *"Art der Farbkarte"*: `Gradient mit 2 Farben`
>
{: .hands_on}

Sie sollten etwas Ähnliches erhalten wie:

![Heatmap mit den normalisierten Zählungen für die am stärksten differentiell exprimierten Gene](../../images/ref-based/heatmap2_normalized_counts.png "Normalisierte Zählungen für die am stärksten differentiell exprimierten Gene")

> <question-title></question-title>
>
> 1. Was stellt die X-Achse der Heatmap dar? Was ist mit der Y-Achse?
> 2. Beobachten Sie etwas beim Clustering der Proben und der Gene?
> 3. Was ändert sich, wenn Sie die Heatmap erneut erstellen, diesmal mit der Auswahl `Daten wie sie sind plotten` in *"Datenumwandlung"*?
> 4. Warum können wir `Log2(Wert) transformiere meine Daten` in *"Datenumwandlung"* nicht verwenden?
> 5. Wie könnten Sie eine Heatmap der normalisierten Zählungen für alle hochregulierten Gene mit einem Fold Change > 2 erstellen?
>
> > <solution-title></solution-title>
> > >
> > > 1. Die X-Achse zeigt die 7 Proben, zusammen mit einem Dendrogramm, das die Ähnlichkeit zwischen deren Genexpressionsniveaus darstellt. Die Y-Achse zeigt die 113 differentiell exprimierten Gene, ebenfalls mit einem Dendrogramm, das die Ähnlichkeit zwischen den Genexpressionsniveaus darstellt.
> > > 2. Die Proben gruppieren sich nach Behandlung.
> > > 3. Die Skala ändert sich und wir sehen nur wenige Gene.
> > > 4. Weil die normalisierte Expression des Gens `FBgn0013688` in `GSM461180_treat_paired` bei `0` liegt.
> > > 5. Extrahieren Sie die Gene mit $$log_{2} FC$$ > 1 (filtern Sie nach Genen mit `c3>1` in der Zusammenfassung der differentiell exprimierten Gene) und führen Sie **heatmap2** {% icon tool %} auf der generierten Tabelle aus.
> > {: .solution}
> {: .question}

### Visualisierung des Z-Scores

Um die Genexpression über die Proben hinweg zu vergleichen, könnten wir auch den Z-Score verwenden, der in Veröffentlichungen häufig dargestellt wird.

Der Z-Score gibt die Anzahl der Standardabweichungen an, um die ein Wert vom Mittelwert aller Werte in derselben Gruppe (hier dasselbe Gen) abweicht. Ein Z-Score von -2 für das Gen X in Probe A bedeutet, dass dieser Wert 2 Standardabweichungen unter dem Mittelwert der Werte für Gen X in allen Proben (A, B, C, usw.) liegt.

Der Z-Score $$z_{i,j}$$ für ein Gen $$i$$ in einer Probe $$j$$ bei der normalisierten Zählung $$x_{i,j}$$ wird berechnet als $$z_{i,j} = \frac{x_{i,j}- \overline{x_i}}{s_i}$$ mit $$\overline{x_i}$$ dem Mittelwert und $$s_i$$ der Standardabweichung der normalisierten Zählungen für das Gen $$i$$ über alle Proben.

> <details-title>Z-Score für alle Gene berechnen</details-title>
>
> Wir benötigen oft den Z-Score für einige Visualisierungen. Um den Z-Score zu berechnen, teilen wir den Prozess in 2 Schritte auf:
>
> 1. Ziehen Sie jeden Wert vom Mittelwert der Zeile ab (d.h. $$x_{i,j}- \overline{x_i}$$) unter Verwendung der Tabelle der normalisierten Zählungen
> 2. Teilen Sie die vorherigen Werte durch die Standardabweichung der Werte der Zeile, unter Verwendung von 2 Tabellen (den normalisierten Zählungen und der in Schritt 1 berechneten Tabelle)
>
> > <hands-on-title>Z-Score aller Gene berechnen</hands-on-title>
> >
> > 1. {% tool [Tabelle berechnen](toolshed.g2.bx.psu.edu/repos/iuc/table_compute/table_compute/1.2.4+galaxy0) %} mit den folgenden Parametern, um zuerst die Mittelwerte pro Zeile abzuziehen:
> >    - *"Eingabetabellen"*: `Einzelne Tabelle`
> >      - {% icon param-file %} *"Tabelle"*: `Datei mit normalisierten Zählungen und andere` (Ausgabe von **DESeq2** {% icon tool %})
> >      - *"Art der Tabellenoperation"*: `Führen Sie eine vollständige Tabellenoperation durch`
> >        - *"Operation"*: `Benutzerdefiniert`
> >          - *"Benutzerdefinierter Ausdruck auf 'Tabelle', entlang der 'Achse' (0 oder 1)"*: `table.sub(table.mean(1), 0)`
> >
> >            Der Ausdruck `table.mean(1)` berechnet den Mittelwert für jede Zeile (hier die Gene) und `table.sub(table.mean(1), 0)` zieht jeden Wert vom Mittelwert der Zeile (berechnet mit `table.mean(1)`) ab.
> >
> > 2. {% tool [Tabelle berechnen](toolshed.g2.bx.psu.edu/repos/iuc/table_compute/table_compute/1.2.4+galaxy0) %} mit den folgenden Parametern:
> >    - *"Eingabetabellen"*: `Mehrere Tabellen`
> >      - Klicken Sie auf {% icon param-repeat %} *"Tabelle einfügen"*
> >      - In *"1: Tabellen"*:
> >        - {% icon param-file %} *"Tabelle"*: `Datei mit normalisierten Zählungen und andere` (Ausgabe von **DESeq2** {% icon tool %})
> >      - Klicken Sie auf {% icon param-repeat %} *"Tabelle einfügen"*
> >      - In *"2: Tabellen"*:
> >        - {% icon param-file %} *"Tabelle"*: Ausgabe der ersten **Tabelle berechnen** {% icon tool %}
> >      - *"Benutzerdefinierter Ausdruck auf 'tableN'"*: `table2.div(table1.std(1),0)`
> >
> >        Der Ausdruck `table1.std(1)` berechnet die Standardabweichungen jeder Zeile auf der 1. Tabelle (normalisierte Zählungen) und `table2.div` teilt die Werte der 2. Tabelle (zuvor berechnet) durch diese Standardabweichungen.
> >
> > 3. Benennen Sie die Ausgabe in `Z-Scores` um
> > 4. Untersuchen Sie die Ausgabedatei
> {: .hands_on}
>
> Wir haben jetzt eine Tabelle mit dem Z-Score für alle Gene in den 7 Proben.
>
> > <question-title></question-title>
> >
> > 1. Wie lautet der Bereich des Z-Scores?
> > 2. Warum sind einige Zeilen leer?
> > 3. Was können wir über die Z-Scores für die differentiell exprimierten Gene (zum Beispiel `FBgn0037223`) sagen?
> > 4. Können wir den Z-Score verwenden, um die Stärke der differentiellen Expression eines Gens zu schätzen?
> >
> > > <solution-title></solution-title>
> > >
> > > 1. Der Z-Score reicht von -3 Standardabweichungen bis +3 Standardabweichungen. Er kann auf einer Normalverteilungskurve eingeordnet werden: -3 ist der weit links gelegene Punkt auf der Normalverteilungskurve und +3 der weit rechts gelegene Punkt.
> > > 2. Wenn alle Zählungen identisch sind (meist auf 0), ist die Standardabweichung 0, der Z-Score kann für diese Gene nicht berechnet werden.
> > > 3. Wenn ein Gen zwischen zwei Gruppen (hier behandelt und unbehandelt) differentiell exprimiert ist, werden die Z-Scores für dieses Gen überwiegend positiv für die Proben in einer Gruppe und überwiegend negativ für die Proben in der anderen Gruppe sein.
> > > 4. Der Z-Score ist ein Signal-Rausch-Verhältnis. Große absolute Z-Scores, d.h. große positive oder negative Werte, sind keine direkte Schätzung des Effekts, d.h. der Stärke der differentiellen Expression. Ein gleicher großer Z-Score kann unterschiedliche Bedeutungen haben, abhängig vom Rauschen:
> > >    - bei starkem Rauschen: ein sehr großer Effekt
> > >    - bei mittlerem Rauschen: ein ziemlich großer Effekt
> > >    - bei wenig Rauschen: ein ziemlich kleiner Effekt
> > >    - bei fast keinem Rauschen: ein winziger Effekt
> > >
> > >    Das Problem ist, dass "Rauschen" hier nicht nur Rauschen aus der Messung ist. Es kann auch mit der "Stärke" der Genregulationskontrolle zusammenhängen. Nicht streng kontrollierte Gene, d.h. deren Expression in einer breiten Spanne über Proben variieren kann, können erheblich induziert oder repressiv sein. Ihr absoluter Z-Score wird klein sein, da die Variationen über die Proben groß sind. Im Gegensatz dazu können Gene, die streng kontrolliert werden, nur sehr kleine Änderungen in ihrer Expression aufweisen, ohne biologische Auswirkungen. Der absolute Z-Score wird für diese Gene groß sein.
> > >
> > {: .solution}
> {: .question}
Wir möchten nun eine Heatmap für die Z-Scores erstellen:

![Heatmap mit den Z-Scores für die am stärksten differentiell exprimierten Gene](../../images/ref-based/z-score-heatmap.png "Z-Scores für die am stärksten differentiell exprimierten Gene")

> <hands-on-title>Heatmap der Z-Scores der am stärksten differentiell exprimierten Gene plotten</hands-on-title>
>
> 1. {% tool [heatmap2](toolshed.g2.bx.psu.edu/repos/iuc/ggplot2_heatmap2/ggplot2_heatmap2/3.1.3+galaxy0) %} zum Plotten der Heatmap:
>    - {% icon param-file %} *"Input should have column headers"*: `Z-Scores für die am stärksten differentiell exprimierten Gene`
>    - *"Datenumwandlung"*: `Plot die Daten wie sie sind`
>    - *"Z-Scores vor dem Clustering berechnen"*: `Berechnen auf Zeilen`
>    - *"Datenclustering aktivieren"*: `Ja`
>    - *"Beschriftung von Spalten und Zeilen"*: `Spalten beschriften, keine Zeilen`
>    - *"Art der Farbkarte"*: `Gradient mit 3 Farben`
> {: .hands_on}

### Funktionelle Anreicherungsanalyse der differentiell exprimierten Gene

Wir haben Gene extrahiert, die in behandelten (PS-Gen-depletierten) Proben im Vergleich zu unbehandelten Proben differentiell exprimiert sind. Nun möchten wir herausfinden, ob die differentiell exprimierten Gene in häufigeren oder spezifischeren Kategorien angereichert sind, um biologische Funktionen zu identifizieren, die möglicherweise betroffen sind.

#### Gene Ontologie Analyse

[Gene Ontology (GO)](http://www.geneontology.org/) Analysen werden häufig verwendet, um Komplexität zu reduzieren und biologische Prozesse in genomweiten Expressionsstudien hervorzuheben. Standardmethoden liefern jedoch aufgrund der Überdetektion der differentiellen Expression von langen und hoch exprimierten Transkripten oft verzerrte Ergebnisse für RNA-Seq-Daten.

[**goseq**](https://bioconductor.org/packages/release/bioc/vignettes/goseq/inst/doc/goseq.pdf) ({% cite young2010gene %}) bietet Methoden zur Durchführung von GO-Analysen von RNA-Seq-Daten unter Berücksichtigung der Längenverzerrung. **goseq** kann auch auf andere kategorie-basierte Tests von RNA-Seq-Daten, wie KEGG-Pfadanalysen, angewendet werden, wie in einem weiteren Abschnitt besprochen.

**goseq** benötigt 2 Dateien als Eingaben:

- Eine tabellarische Datei mit den differentiell exprimierten Genen aus allen in der RNA-Seq-Experiment untersuchten Genen mit 2 Spalten:
  - den Gen-IDs (einzigartig innerhalb der Datei), in Großbuchstaben
  - ein boolescher Wert, der angibt, ob das Gen differentiell exprimiert ist oder nicht (`True`, wenn differentiell exprimiert oder `False`, wenn nicht)
- Eine Datei mit Informationen über die Länge eines Gens, um potenzielle Längenverzerrungen in differentiell exprimierten Genen zu korrigieren

> <hands-on-title>Erste Datensatz für goseq vorbereiten</hands-on-title>
>
> 1. {% tool [Compute](toolshed.g2.bx.psu.edu/repos/devteam/column_maker/Add_a_column1/2.0) %} auf Zeilen mit folgenden Parametern:
>    - {% icon param-file %} *"Input file"*: die `DESeq2 Ergebnisdatei` (Ausgabe von **DESeq2** {% icon tool %})
>    - In *"Expressions"*:
>      - {% icon param-text %} *"Add expression"*: `bool(float(c7)<0.05)`
>      - {% icon param-select %} *"Mode of the operation?"*: `Append`
>    - Unter *"Error handling"*:
>      - {% icon param-toggle %} *"Autodetect column types"*: `No`
>      - {% icon param-select %} *"If an expression cannot be computed for a row"*: `Fill in a replacement value`
>      - {% icon param-select %} *"Replacement value"*: `False`
>
> 2. {% tool [Cut](Cut1) %} Spalten aus einer Tabelle ausschneiden mit folgenden Parametern:
>    - *"Cut columns"*: `c1,c8`
>    - *"Delimited by"*: `Tab`
>    - {% icon param-file %} *"From"*: die Ausgabe von **Compute** {% icon tool %}
>
> 3. {% tool [Change Case](ChangeCase) %} mit:
>    - {% icon param-file %} *"From"*: die Ausgabe des vorherigen **Cut** {% icon tool %}
>    - *"Change case of columns"*: `c1`
>    - *"Delimited by"*: `Tab`
>    - *"To"*: `Upper case`
>
> 4. Benennen Sie die Ausgabe in `Gene IDs and differential expression` um
> {: .hands_on}

Wir haben nun die erste Eingabedatei für **goseq** erstellt. Als zweite Eingabe für **goseq** benötigen wir die Genlängen. Hier können wir die von **featureCounts** generierten Genlängen verwenden oder **Gene length and GC content** und die Gen-IDs formatieren.

> <hands-on-title>Genlängen-Datei vorbereiten</hands-on-title>
>
> <div class="featureCounts" markdown="1">
> 1. Kopieren Sie die Feature-Längen-Sammlung, die zuvor von **featureCounts** {% icon tool %} erstellt wurde, in diese Historie
>
>    {% snippet faqs/galaxy/histories_copy_dataset.md %}
>
> 2. {% tool [Extract Dataset](__EXTRACT_DATASET__) %} mit:
>    - {% icon param-collection %} *"Input List"*: `featureCounts on collection N: Feature lengths`
>    - *"How should a dataset be selected?"*: `The first dataset`
> </div>
>
> <div class="STAR" markdown="1">
> 1. Kopieren Sie die Ausgabe von **Gene length and GC content** {% icon tool %} (`Gene length`) in diese Historie
>
>    {% snippet faqs/galaxy/histories_copy_dataset.md %}
> </div>
>
> 2. {% tool [Change Case](ChangeCase) %} mit folgenden Parametern:
>
>    - {% icon param-file %} *"From"*: <span class="featureCounts" markdown="1">`GSM461177_untreat_paired` (Ausgabe von **Extract Dataset** {% icon tool %})</span><span class="STAR" markdown="1">`Gene length`</span>
>    - *"Change case of columns"*: `c1`
>    - *"Delimited by"*: `Tab`
>    - *"To"*: `Upper case`
>
> 3. Benennen Sie die Ausgabe in `Gene IDs and length` um
> {: .hands_on}

Wir haben nun die beiden erforderlichen Eingabedateien für goseq.

> <hands-on-title>GO-Analyse durchführen</hands-on-title>
>
> 1. {% tool [goseq](toolshed.g2.bx.psu.edu/repos/iuc/goseq/goseq/1.44.0+galaxy0) %} mit:
>    - *"Differentially expressed genes file"*: `Gene IDs and differential expression`
>    - *"Gene lengths file"*: `Gene IDs and length`
>    - *"Gene categories"*: `Get categories`
>       - *"Select a genome to use"*: `Fruit fly (dm6)`
>       - *"Select Gene ID format"*: `Ensembl Gene ID`
>       - *"Select one or more categories"*: `GO: Cellular Component`, `GO: Biological Process`, `GO: Molecular Function`
>    - In *"Output Options"*
>      - *"Output Top GO terms plot?"*: `Yes`
>      - *"Extract the DE genes for the categories (GO/KEGG terms)?"*: `Yes`
> {: .hands_on}

**goseq** erzeugt mit diesen Parametern 3 Ausgaben:

1. Eine Tabelle (`Ranked category list - Wallenius method`) mit folgenden Spalten für jeden GO-Term:
    1. `category`: GO-Kategorie
    2. `over_rep_pval`: *p*-Wert für die Überrepräsentation des Terms in den differentiell exprimierten Genen
    3. `under_rep_pval`: *p*-Wert für die Unterrepräsentation des Terms in den differentiell exprimierten Genen
    4. `numDEInCat`: Anzahl der differentiell exprimierten Gene in dieser Kategorie
    5. `numInCat`: Anzahl der Gene in dieser Kategorie
    6. `term`: Detail des Terms
    7. `ontology`: MF (Molecular Function - molekulare Aktivitäten von Genprodukten), CC (Cellular Component - Orte der Aktivität von Genprodukten), BP (Biological Process - Wege und größere Prozesse, die aus den Aktivitäten mehrerer Genprodukte bestehen)
    8. `p.adjust.over_represented`: *p*-Wert für die Überrepräsentation des Terms in den differentiell exprimierten Genen, angepasst für mehrere Tests mit dem Benjamini-Hochberg-Verfahren
    9. `p.adjust.under_represented`: *p*-Wert für die Unterrepräsentation des Terms in den differentiell exprimierten Genen, angepasst für mehrere Tests mit dem Benjamini-Hochberg-Verfahren

Um Kategorien zu identifizieren, die signifikant angereichert oder unterrepräsentiert sind, sollten Sie den angepassten *p*-Wert verwenden.
### KEGG-Pfadanalyse

**goseq** kann auch verwendet werden, um interessante KEGG-Pfade zu identifizieren. Die KEGG-Pfad-Datenbank ist eine Sammlung von Pfadkarten, die aktuelles Wissen über molekulare Interaktions-, Reaktions- und Beziehungsnetzwerke darstellen. Eine Karte kann viele Entitäten integrieren, einschließlich Gene, Proteine, RNAs, chemische Verbindungen, Glykane und chemische Reaktionen, sowie Krankheitsgene und Wirkstoffziele.

Zum Beispiel repräsentiert der Pfad `dme00010` den Glykolyse-Prozess (Umwandlung von Glucose in Pyruvat mit der Erzeugung kleiner Mengen ATP und NADH) für *Drosophila melanogaster*:

![dme00010 KEGG-Pfad](../../images/ref-based/dme00010_empty.png)

> <hands-on-title>KEGG-Pfad-Analyse durchführen</hands-on-title>
>
> 1. {% tool [goseq](toolshed.g2.bx.psu.edu/repos/iuc/goseq/goseq/1.44.0+galaxy0) %} mit:
>    - *"Differentially expressed genes file"*: `Gene IDs and differential expression`
>    - *"Gene lengths file"*: `Gene IDs and length`
>    - *"Gene categories"*: `Get categories`
>       - *"Select a genome to use"*: `Fruit fly (dm6)`
>       - *"Select Gene ID format"*: `Ensembl Gene ID`
>       - *"Select one or more categories"*: `KEGG`
>    - In *"Output Options"*
>      - *"Output Top GO terms plot?"*: `No`
>      - *"Extract the DE genes for the categories (GO/KEGG terms)?"*: `Yes`
> {: .hands_on}

**goseq** erzeugt mit diesen Parametern 2 Ausgaben:

1. Eine große Tabelle mit den KEGG-Terms und einigen Statistiken

    > <question-title></question-title>
    >
    > 1. Wie viele KEGG-Pfadbegriffe wurden identifiziert?
    > 2. Wie viele KEGG-Pfadbegriffe sind mit einem adjustierten p-Wert < 0,05 überrepräsentiert?
    > 3. Welche KEGG-Pfadbegriffe sind überrepräsentiert?
    > 4. Wie viele KEGG-Pfadbegriffe sind mit einem adjustierten p-Wert < 0,05 unterrepräsentiert?
    >
    > > <solution-title></solution-title>
    > >
    > > 1. Die Datei enthält 128 Zeilen einschließlich einer Kopfzeile, daher wurden 127 KEGG-Pfade identifiziert.
    > > 2. 2 KEGG-Pfade (2,34%) sind überrepräsentiert. Verwenden Sie {% tool [Filter data on any column using simple expressions](Filter1) %} auf c6 (adjustierter p-Wert für überrepräsentierte KEGG-Pfade).
    > > 3. Die 2 überrepräsentierten KEGG-Pfade sind `01100` und `00010`. Durch die Suche in der [KEGG-Datenbank](https://www.genome.jp/kegg/kegg2.html) können Sie weitere Informationen zu diesen Pfaden finden: `01100` entspricht allen Stoffwechselwegen und `00010` dem Glykolyse / Gluconeogenese-Weg.
    > > 4. Kein KEGG-Pfad ist unterrepräsentiert. Verwenden Sie {% tool [Filter data on any column using simple expressions](Filter1) %} auf c7 (adjustierter p-Wert für unterrepräsentierte KEGG-Pfade).
    > {: .solution}
    {: .question}

2. Eine Tabelle mit den differentiell exprimierten Genen (aus der Liste, die wir bereitgestellt haben), die den KEGG-Pfaden zugeordnet sind (`DE genes for categories (GO/KEGG terms)`)

Wir könnten untersuchen, welche Gene in welchen Pfaden beteiligt sind, indem wir die zweite Datei betrachten, die von **goseq** erstellt wurde. Dies kann jedoch mühsam sein und wir möchten die Pfade wie im vorherigen Bild dargestellt sehen. **Pathview** ({% cite luo2013pathview %}) kann helfen, ähnliche Bilder wie das vorherige automatisch zu erstellen und zusätzliche Informationen über die Gene (z.B. Expression) in unserer Studie hinzuzufügen.

Dieses Tool benötigt 2 Haupt-Eingaben:

- Pfad-ID(s) zum Plotten, entweder als einzelne ID oder als Datei mit einer Spalte mit den Pfad-IDs
- Eine tabellarische Datei mit den Genen im RNA-Seq-Experiment mit 2 (oder mehr) Spalten:
  - die Gen-IDs (einzigartig innerhalb der Datei)
  - einige Informationen über die Gene

    Dies kann z.B. ein p-Wert oder eine Fold-Änderung sein. Diese Informationen werden zum Pfadplot hinzugefügt: Der Knoten des entsprechenden Gens wird basierend auf dem Wert eingefärbt. Wenn es verschiedene Spalten gibt, werden die unterschiedlichen Informationen nebeneinander auf dem Knoten dargestellt.

Hier möchten wir die 2 KEGG-Pfade visualisieren: den überrepräsentierten `00010` (Glykolyse / Gluconeogenese) und den am meisten unterrepräsentierten (aber nicht signifikanten) `03040` (Spliceosom). Wir möchten, dass die Genknoten nach Log2-Fold-Änderung für die differentiell exprimierten Gene eingefärbt werden.

> <hands-on-title>Log2FC auf KEGG-Pfad überlagern</hands-on-title>
>
> 1. {% tool [Cut](Cut1) %} Spalten aus einer Tabelle ausschneiden mit folgenden Parametern:
>    - *"Cut columns"*: `c1,c3`
>    - *"Delimited by"*: `Tab`
>    - {% icon param-file %} *"From"*: `Genes with significant adj p-value`
>
> 2. Umbenennen in `Genes with significant adj p-value and their Log2 FC`
>
>    Wir haben die ID und den Log2 Fold Change für die Gene extrahiert, die einen signifikanten adjustierten p-Wert haben.
>
> 3. Erstellen Sie eine neue tabellarische Datei aus den folgenden (IDs der Pfade, die geplottet werden sollen) namens `KEGG pathways to plot`
>
>    ```text
>    00010
>    03040
>    ```
4. {% tool [Pathview](toolshed.g2.bx.psu.edu/repos/iuc/pathview/pathview/1.34.0+galaxy0) %} mit:
   - *"Number of pathways to plot"*: `Multiple`
     - {% icon param-file %} *"KEGG pathways"*: `KEGG pathways to plot`
     - *"Does the file have header (a first line with column names)?"*: `No`
   - *"Species to use"*: `Fly`
   - *"Provide a gene data file?"*: `Yes`
     - {% icon param-file %} *"Gene data"*: `Genes with significant adj p-value and their Log2 FC`
     - *"Does the file have header (a first line with column names)?"*: `Yes`
     - *"Format for gene data"*: `Ensembl Gene ID`
   - *"Provide a compound data file?"*: `No`
   - In *"Output Options"*
     - *"Output for pathway"*: `KEGG native`
       - *"Plot on same layer?"*: `Yes`
{: .hands_on}

**Pathview** erzeugt eine Sammlung mit der KEGG-Visualisierung: eine Datei pro Pfad.

> <question-title></question-title>
>
> `dme00010` KEGG-Pfad von **Pathview**
>
> ![KEGG-Pfad](../../images/ref-based/dme00010.png)
>
> 1. Was sind die farbigen Kästchen?
> 2. Was ist der Farbcode?
>
> > <solution-title></solution-title>
> >
> > 1. Die farbigen Kästchen sind Gene im Pfad, die differentiell exprimiert sind.
> > 2. Beachten Sie, dass der Farbcode kontraintuitiv ist: Grün steht für Werte unter 0, das bedeutet für Gene mit log2FC < 0 und Rot für Gene mit log2FC > 0.
> >
> {: .solution}
{: .question}

{% comment %}

# Inferierung der differentiellen Exon-Nutzung

Als nächstes möchten wir die differenzielle Exon-Nutzung zwischen behandelten (PS-depletierten) und unbehandelten Proben mit RNA-Seq-Exon-Zählungen untersuchen. Wir werden die Mapping-Ergebnisse, die wir zuvor erstellt haben, neu bearbeiten.

Wir werden [DEXSeq](https://www.bioconductor.org/packages/release/bioc/html/DEXSeq.html) verwenden. DEXSeq erkennt hochsensitive Gene und in vielen Fällen Exons, die einer differentiellen Exon-Nutzung unterliegen. Aber zuerst, wie bei der differentiellen Genexpression, müssen wir die Anzahl der Reads zählen, die auf die Exons abgebildet sind.

## Anzahl der Reads pro Exon zählen

Dieser Schritt ist ähnlich wie der Schritt des [Zählens der Anzahl der Reads pro annotiertem Gen](#count-the-number-of-reads-per-annotated-gene), nur dass wir anstelle von HTSeq-count **DEXSeq-Count** verwenden.

> <hands-on-title>Anzahl der Reads pro Exon zählen</hands-on-title>
>
> 1. {% tool [DEXSeq-Count](toolshed.g2.bx.psu.edu/repos/iuc/dexseq/dexseq_count/1.28.1.0) %}: Verwenden Sie **DEXSeq-Count**, um die *Drosophila*-Annotationen vorzubereiten, um nur Exons mit entsprechenden Gen-IDs zu extrahieren
>    - *"Mode of operation"*: `Prepare annotation`
>      - {% icon param-file %} *"GTF file"*: `Drosophila_melanogaster.BDGP6.32.109_UCSC.gtf.gz`
>
>    Das Ergebnis ist erneut eine GTF-Datei, die bereit ist, zum Zählen verwendet zu werden.
>
> 2. {% tool [DEXSeq-Count](toolshed.g2.bx.psu.edu/repos/iuc/dexseq/dexseq_count/1.28.1.0) %}: Zählen Sie Reads mit **DEXSeq-Count** mit
>    - *"Mode of operation"*: `Count reads`
>      - {% icon param-files %} *"Input bam file"*: die von **RNA STAR** generierten `BAM`-Dateien
>      - {% icon param-file %} *"DEXSeq compatible GTF file"*: die von **DEXSeq-Count** generierte GTF-Datei
>      - *"Is library paired end?"*: `Yes`
>      - *"Is library strand specific?"*: `No`
>      - *"Skip all reads with alignment quality lower than the given minimum value"*: `10`
>
{: .hands_on}

DEXSeq erzeugt eine Zählertabelle, die der von featureCounts ähnelt, jedoch mit Zählungen für Exons.

> <question-title></question-title>
>
> 1. Welches Exon hat die meisten zugeordneten Reads für beide Proben?
> 2. Zu welchem Gen gehört dieses Exon?
> 3. Gibt es eine Verbindung zum vorherigen Ergebnis, das mit featureCounts erhalten wurde?
>
> > <solution-title></solution-title>
> >
> > FBgn0284245:005 ist das Exon mit den meisten zugeordneten Reads für beide Proben. Es ist Teil von FBgn0284245, dem Feature mit den meisten Reads (von featureCounts).
> >
> {: .solution}
>
{: .question}

## Differenzielle Exon-Nutzung

Die Nutzung von DEXSeq ist ähnlich wie bei DESeq2. Es verwendet ähnliche Statistiken, um differentiell genutzte Exons zu finden.

Wie bei DESeq2 haben wir im vorherigen Schritt nur Reads gezählt, die auf Exons auf Chromosom 4 abgebildet sind und nur für eine Probe. Um differenzielle Exon-Nutzung, die durch PS-Depletion induziert wird, identifizieren zu können, müssen alle Datensätze (3 behandelte und 4 unbehandelte) nach dem gleichen Verfahren analysiert werden. Um Zeit zu sparen, haben wir das für Sie erledigt. Die Ergebnisse sind auf [Zenodo]({{ page.zenodo_link }}) verfügbar:

- Die Ergebnisse der Ausführung von DEXSeq-count im Modus 'Prepare annotation'
- Sieben Zähl-Dateien, die im Modus 'Count reads' generiert wurden

> <hands-on-title></hands-on-title>
>
> 1. Erstellen Sie eine neue Historie.
> 2. Importieren Sie die sieben Zähl-Dateien von [Zenodo]({{ page.zenodo_link }}) oder aus der Shared Data-Bibliothek (wenn verfügbar):
>
>    - `Drosophila_melanogaster.BDGP6.87.dexseq.gtf`
>    - `GSM461176_untreat_single.exon.counts`
>    - `GSM461177_untreat_paired.exon.counts`
>    - `GSM461178_untreat_paired.exon.counts`
>    - `GSM461179_treat_single.exon.counts`
>    - `GSM461180_treat_paired.exon.counts`
>    - `GSM461181_treat_paired.exon.counts`
>    - `GSM461182_untreat_single.exon.counts`
>
>    ```text
>    {{ page.zenodo_link }}/files/Drosophila_melanogaster.BDGP6.87.dexseq.gtf
>    {{ page.zenodo_link }}/files/GSM461176_untreat_single.exon.counts
>    {{ page.zenodo_link }}/files/GSM461177_untreat_paired.exon.counts
>    {{ page.zenodo_link }}/files/GSM461178_untreat_paired.exon.counts
>    {{ page.zenodo_link }}/files/GSM461179_treat_single.exon.counts
>    {{ page.zenodo_link }}/files/GSM461180_treat_paired.exon.counts
>    {{ page.zenodo_link }}/files/GSM461181_treat_paired.exon.counts
>    {{ page.zenodo_link }}/files/GSM461182_untreat_single.exon.counts
>    ```
>
> 3. {% tool [DEXSeq](toolshed.g2.bx.psu.edu/repos/iuc/dexseq/dexseq/1.28.1+galaxy1) %}: Führen Sie **DEXSeq** aus mit:
>    - {% icon param-file %} *"GTF file created from DEXSeq-Count tool"*: `Drosophila_melanogaster.BDGP6.87.dexseq.gtf`
>    - In *"Factor"*:
>       - In "1: Factor"
>           - *"Specify a factor name"*: `condition`
>           - In *"Factor level"*:
>               - In *"1: Factor level"*:
>                   - *"Specify a factor level"*: `treated`
>                   - {% icon param-files %} *"Counts file(s)"*: die 3 Exon-Zähl-Dateien mit `treated` im Namen
>               - In *"2: Factor level"*:
>                   - *"Specify a factor level"*: `untreated`
>                   - {% icon param-files %} *"Counts file(s)"*: die 4 Exon-Zähl-Dateien mit `untreated` im Namen
>       - Klicken Sie auf *"Insert Factor"* (nicht auf "Insert Factor level")
>       - In "2: Factor"
>           - *"Specify a factor name"* zu `sequencing`
>           - In *"Factor level"*:
>               - In *"1: Factor level"*:
>                   - *"Specify a factor level"*: `PE`
>                   - {% icon param-files %} *"Counts file(s)"*: die 4 Exon-Zähl-Dateien mit `paired` im Namen
>               - In *"2: Factor level"*:
>                   - *"Specify a factor level"*: `SE`
>                   - {% icon param-files %} *"Counts file(s)"*: die 3 Exon-Zähl-Dateien mit `single` im Namen
>
>    > <comment-title></comment-title>
>    >
>    > Im Gegensatz zu DESeq2 erlaubt DEXSeq keine flexiblen Primärfaktornamen. Verwenden Sie immer Ihren Primärfaktornamen als "condition".
>    {: .comment}
Ähnlich wie DESeq2 erzeugt DEXSeq eine Tabelle mit:

1. Exon-Identifikatoren
2. Gen-Identifikatoren
3. Exon-Identifikatoren im Gen
4. Mittelwert der normalisierten Zählungen, gemittelt über alle Proben beider Bedingungen
5. Logarithmus (zur Basis 2) des Fold Changes

   Die log2 Fold Changes basieren auf Primärfaktor-Stufe 1 vs. Faktor-Stufe 2. Die Reihenfolge der Faktor-Stufen ist dann wichtig. Zum Beispiel berechnet DESeq2 Fold Changes von 'behandelten' Proben im Vergleich zu 'unbehandelten', d.h., die Werte entsprechen den Hoch- oder Herabregulierungen von Genen in behandelten Proben.

6. Schätzung des Standardfehlers für die Schätzung des log2 Fold Changes
7. *p*-Wert für die statistische Signifikanz dieser Änderung
8. *p*-Wert angepasst für multiple Tests mit dem Benjamini-Hochberg-Verfahren, das die False Discovery Rate ([FDR](https://en.wikipedia.org/wiki/False_discovery_rate)) kontrolliert

> <hands-on-title></hands-on-title>
>
> 1. {% tool [Filter data on any column using simple expressions](Filter1) %} um Exons mit einer signifikanten differentiellen Nutzung (angepasster *p*-Wert gleich oder kleiner als 0.05) zwischen behandelten und unbehandelten Proben zu extrahieren.
>
> > <question-title></question-title>
> >
> > Wie viele Exons zeigen eine signifikante Veränderung in der Nutzung zwischen diesen Bedingungen?
> >
> > > <solution-title></solution-title>
> > >
> > > Es wurden 38 Exons (12,38%) mit einer signifikanten Nutzungsänderung zwischen behandelten und unbehandelten Proben gefunden.
> > >
> {: .solution}
{: .question}

# Fazit

In diesem Tutorial haben wir echte RNA-Sequenzierungsdaten analysiert, um nützliche Informationen zu extrahieren, wie welche Gene durch die Depletion des *Pasilla*-Gens hoch- oder herunterreguliert werden und welche GO-Termine oder KEGG-Pfade an ihnen beteiligt sind. Um diese Fragen zu beantworten, haben wir RNA-Sequenzdatensätze unter Verwendung eines referenzbasierten RNA-Seq-Datenanalyseansatzes analysiert. Dieser Ansatz kann wie folgt zusammengefasst werden:

![Zusammenfassung des verwendeten Analyseablaufs](../../images/ref-based/tutorial-scheme.png "Zusammenfassung des verwendeten Analyseablaufs")
