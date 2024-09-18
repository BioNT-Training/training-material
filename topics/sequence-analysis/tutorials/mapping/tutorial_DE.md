---
layout: tutorial_hands_on

title: "Mapping"
zenodo_link: "https://doi.org/10.5281/zenodo.1324070"
questions:
  - Was ist Mapping?
  - Was sind zwei wichtige Dinge für ein korrektes Mapping?
  - Was ist BAM?
objectives:
  - Führe ein Tool aus, um Reads auf ein Referenzgenom zu mappen
  - Erkläre, was eine BAM-Datei ist und was sie enthält
  - Verwende den Genom-Browser, um deine Daten zu verstehen
time_estimation: "1h"
key_points:
  - Kenne deine Daten!
  - Mapping ist nicht trivial
  - Es gibt viele Mapping-Algorithmen, es hängt von deinen Daten ab, welchen du wählen solltest
requirements:
  -
    type: "internal"
    topic_name: sequence-analysis
    tutorials:
      - quality-control
follow_up_training:
  -
    type: "internal"
    topic_name: transcriptomics
    tutorials:
      - ref-based
  -
    type: "internal"
    topic_name: epigenetics
    tutorials:
      - formation_of_super-structures_on_xi
level: Einführend
edam_ontology: 
  - topic_0102 # Mapping
contributors:
  - joachimwolff
  - bebatut
  - hexylena
---

Sequenzierung erzeugt eine Sammlung von Sequenzen ohne genomischen Kontext. Wir wissen nicht, zu welchem Teil des Genoms die Sequenzen gehören. Das Mapping der Reads eines Experiments auf ein Referenzgenom ist ein wesentlicher Schritt in der modernen genomischen Datenanalyse. Durch das Mapping werden die Reads einem bestimmten Ort im Genom zugeordnet, und es können Erkenntnisse wie das Expressionsniveau von Genen gewonnen werden.

Die Reads enthalten keine Positionsinformationen, daher wissen wir nicht, aus welchem Teil des Genoms sie stammen. Wir müssen die Sequenz des Reads selbst verwenden, um die entsprechende Region in der Referenzsequenz zu finden. Da die Referenzsequenz jedoch ziemlich lang sein kann (~3 Milliarden Basen beim Menschen), ist es eine herausfordernde Aufgabe, eine passende Region zu finden. Da unsere Reads kurz sind, gibt es möglicherweise mehrere, gleichermaßen wahrscheinliche Stellen in der Referenzsequenz, von denen sie gelesen worden sein könnten. Dies gilt insbesondere für wiederholte Regionen.

Im Prinzip könnten wir eine BLAST-Analyse durchführen, um herauszufinden, wo die sequenzierten Stücke am besten in das bekannte Genom passen. Das müssten wir für jede der Millionen von Reads in unseren Sequenzierungsdaten tun. Das Ausrichten von Millionen von kurzen Sequenzen auf diese Weise könnte jedoch Wochen dauern. Und es interessiert uns nicht die genaue Basis-zu-Basis-Korrespondenz (Ausrichtung). Was uns interessiert, ist "woher diese Reads stammen". Dieser Ansatz wird als **Mapping** bezeichnet.

Im Folgenden werden wir ein Dataset mit dem Mapper **Bowtie2** verarbeiten und die Daten mit dem Programm **IGV** visualisieren.

> <agenda-title></agenda-title>
>
> In diesem Tutorial werden wir uns mit folgenden Themen beschäftigen:
>
> 1. TOC
> {:toc}
>
{: .agenda}

# Daten vorbereiten

> <hands-on-title>Daten hochladen</hands-on-title>
>
> 1. Erstelle einen neuen Verlauf für dieses Tutorial und gib ihm einen passenden Namen
>
>    {% snippet faqs/galaxy/histories_create_new.md %}
>
>    {% snippet faqs/galaxy/histories_rename.md %}
>
> 2. Importiere `wt_H3K4me3_read1.fastq.gz` und `wt_H3K4me3_read2.fastq.gz` von [Zenodo](https://zenodo.org/record/1324070) oder aus der Datenbibliothek (frage deinen Lehrer)
>
>    ```
>    https://zenodo.org/record/1324070/files/wt_H3K4me3_read1.fastq.gz
>    https://zenodo.org/record/1324070/files/wt_H3K4me3_read2.fastq.gz
>    ```
>
>    {% snippet faqs/galaxy/datasets_import_via_link.md %}
>
>    {% snippet faqs/galaxy/datasets_import_from_data_library.md %}
>
>    Standardmäßig verwendet Galaxy den Link als Namen, also benenne sie um.
>
> 3. Benenne die Dateien in `reads_1` und `reads_2` um
>
>    {% snippet faqs/galaxy/datasets_rename.md %}
>
{: .hands_on}

Wir haben gerade FASTQ-Dateien in Galaxy importiert, die Paarendaten entsprechen, wie wir sie direkt von einer Sequenzierungsstelle erhalten könnten.

Während der Sequenzierung treten Fehler auf, wie zum Beispiel falsche Nukleotide. Sequenzierungsfehler können die Analyse verzerren und zu einer Fehlinterpretation der Daten führen. Der erste Schritt bei jeder Art von Sequenzierungsdaten ist immer, ihre Qualität zu überprüfen.

Es gibt ein spezielles Tutorial für [Qualitätskontrolle]({% link topics/sequence-analysis/tutorials/quality-control/tutorial.md %}) von Sequenzierungsdaten. Wir werden die Schritte dort nicht wiederholen. Du solltest das [Tutorial]({% link topics/sequence-analysis/tutorials/quality-control/tutorial.md %}) befolgen und es auf deine Daten anwenden, bevor du weitermachst.

# Reads auf ein Referenzgenom mappen

Das Read-Mapping ist der Prozess, bei dem die Reads auf ein Referenzgenom gemappt werden. Ein Mapper verwendet als Eingabe ein Referenzgenom und eine Menge von Reads. Ziel ist es, jeden Read in der Menge der Reads auf dem Referenzgenom auszurichten, wobei Abweichungen, Indels und das Clipping einiger kurzer Fragmente an den beiden Enden der Reads zulässig sind:

![Erklärung des Mappings](../../images/mapping/mapping.png "Illustration des Mapping-Prozesses. Die Eingabe besteht aus einer Menge von Reads und einem Referenzgenom. In der Mitte gibt es die Ergebnisse des Mappings: die Positionen der Reads auf dem Referenzgenom. Der erste Read ist an Position 100 gemappt und das Alignment hat zwei Abweichungen. Der zweite Read ist an Position 114 gemappt. Es ist ein lokales Aligment mit Clippings auf der linken und rechten Seite. Der dritte Read ist an Position 123 gemappt. Er besteht aus einer 2-Basen-Einfügung und einer 1-Basen-Deletion.")

Wir benötigen ein Referenzgenom, um die Reads zu mappen.

{% include topics/sequence-analysis/tutorials/mapping/ref_genome_explanation.md answer_3="Diese Daten stammen von der ChIP-seq von Mäusen, daher verwenden wir mm10 (*Mus musculus*)." %}

Derzeit gibt es über 60 verschiedene Mapper, und ihre Anzahl wächst. In diesem Tutorial verwenden wir [Bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/), ein schnelles und speichereffizientes Open-Source-Tool, das besonders gut darin ist, Sequenzierungsreads von etwa 50 bis mehreren Tausend Basen auf relativ langen Genomen auszurichten.

> <hands-on-title>Mapping mit Bowtie2</hands-on-title>
> 1. {% tool [Bowtie2](toolshed.g2.bx.psu.edu/repos/devteam/bowtie2/bowtie2/2.4.2+galaxy0) %} mit den folgenden Parametern
>    - *"Handelt es sich um eine Einzel- oder Paarend-Bibliothek"*: `Paired-end`
>       - {% icon param-file %} *"FASTA/Q-Datei #1"*: `reads_1`
>       - {% icon param-file %} *"FASTA/Q-Datei #2"*: `reads_2`
>       - *"Möchten Sie die Optionen für Paired-end festlegen?"*: `Nein`
>
>           Du solltest dir die Parameter dort genau ansehen, insbesondere die Mate-Orientierung, wenn du sie kennst. Diese können die Qualität des Paired-end-Mappings verbessern.
>
>     - *"Wählen Sie ein Referenzgenom aus Ihrem Verlauf oder verwenden Sie einen integrierten Index?"*: `Verwende einen integrierten Genom-Index`
>       - *"Referenzgenom auswählen"*: `Mouse (Mus musculus): mm10`
>     - *"Analysemodus auswählen"*: `Nur Standardeinstellung`
>
>         Du solltest dir die nicht standardmäßigen Parameter ansehen und versuchen, sie zu verstehen. Sie können Auswirkungen auf das Mapping haben und es verbessern.
>
>     - *"Bowtie2-Mapping-Statistiken im Verlauf speichern"*: `Ja`
>
> 2. Überprüfe die `mapping stats`-Datei, indem du auf das {% icon galaxy-eye %} (Auge)-Symbol klickst
>
{: .hands_on}

> <question-title></question-title>
>
> 1. Welche Informationen werden hier bereitgestellt?
> 2. Wie viele Reads wurden genau einmal gemappt?
> 3. Wie viele Reads wurden mehr als einmal gemappt? Wie ist das möglich? Was sollten wir mit ihnen tun?
> 4. Wie viele Read-Paare wurden nicht gemappt? Was sind die Ursachen?

> <solution-title></solution-title>
> 1. Die hier angegebenen Informationen sind quantitativ. Wir können sehen, wie viele Sequenzen gemappt wurden. Es gibt uns keine Auskunft über die Qualität.
> 2. ~90% der Reads wurden genau einmal gemappt.
> 3. ~7% der Reads wurden mehr als einmal übereinstimmend gemappt. Diese werden als mehrfach zugeordnete Reads bezeichnet. Dies kann aufgrund von Wiederholungen im Referenzgenom (mehrfache Kopien eines Gens zum Beispiel) auftreten, insbesondere wenn die Reads klein sind. Es ist schwierig zu entscheiden, woher diese Sequenzen stammen, und daher ignorieren die meisten Pipelines diese. Überprüfen Sie immer die Statistiken, um sicherzustellen, dass Sie keine wichtigen Informationen in nachgelagerten Analysen verlieren.
> 4. ~3% der Read-Paare wurden nicht zugeordnet, weil
>     - beide Reads im Paar gemappt wurden, aber ihre Positionen nicht übereinstimmen (`aligned discordantly 1 time`)
>     - Reads dieser Paare mehrfach zugeordnet wurden (`aligned >1 times` in `pairs aligned 0 times concordantly or discordantly`)
>     - ein Read dieser Paare zugeordnet wurde, aber der zugehörige Read nicht (`aligned exactly 1 time` in `pairs aligned 0 times concordantly or discordantly`)
>     - der Rest wurden gar nicht zugeordnet
>  {: .solution }
{: .question}

Die Überprüfung der Mapping-Statistiken ist ein wichtiger Schritt, bevor Sie mit weiteren Analysen fortfahren. Es gibt mehrere potenzielle Fehlerquellen beim Mapping, darunter (aber nicht beschränkt auf):

- **Polymerase-Kettenreaktion (PCR)-Artefakte**: Viele Methoden der Hochdurchsatz-Sequenzierung (HTS) beinhalten einen oder mehrere PCR-Schritte. PCR-Fehler erscheinen als Abweichungen in der Ausrichtung, und insbesondere Fehler in frühen PCR-Runden erscheinen in mehreren Reads, was fälschlicherweise genetische Variation in der Probe suggeriert. Ein verwandter Fehler wären PCR-Duplikate, bei denen dasselbe Read-Paar mehrfach vorkommt, was die Deckungsberechnungen in der Ausrichtung verzerrt.
- **Sequenzierungsfehler**: Das Sequenziergerät kann fehlerhafte Aufrufe entweder aus physischen Gründen (z. B. Öl auf einem Illumina-Träger) oder aufgrund der Eigenschaften der sequenzierten DNA (z. B. Homopolymere) machen. Da Sequenzierungsfehler oft zufällig sind, können sie als Einzelreads während der Variantenaufbereitung herausgefiltert werden.
- **Mapping-Fehler**: Der Mapping-Algorithmus kann einen Read an den falschen Ort im Referenzgenom zuordnen. Dies geschieht oft um Wiederholungen oder andere Regionen mit geringer Komplexität.

Wenn die Mapping-Statistiken also nicht gut sind, sollten Sie die Ursache dieser Fehler untersuchen, bevor Sie mit weiteren Analysen fortfahren.

Danach sollten Sie sich die Reads ansehen und die BAM-Datei überprüfen, in der die Read-Mappings gespeichert sind.

# Überprüfung einer BAM-Datei

{% include topics/sequence-analysis/tutorials/mapping/bam_explanation.md mapper="Bowtie2" %}

Die BAM-Datei enthält viele Informationen über jeden Read, insbesondere über die Qualität des Mappings.

> <hands-on-title>Zusammenfassung der Mapping-Qualität</hands-on-title>
> 1. {% tool [Samtools Stats](toolshed.g2.bx.psu.edu/repos/devteam/samtools_stats/samtools_stats/2.0.2+galaxy2) %} mit den folgenden Parametern
>    - {% icon param-file %} *"BAM-Datei"*: `aligned reads` (Ausgabe von **Bowtie2** {% icon tool %})
>    - *"Referenzsequenz verwenden"*: `Lokal zwischengespeichert/Verwenden Sie ein integriertes Genom`
>      - *"Verwendetes Genom"*: `Mouse (Mus musculus): mm10 Full`
>
> 2. Überprüfen Sie die {% icon param-file %} `Stats`-Datei
>
{: .hands_on}

> <question-title></question-title>
>
> 1. Wie hoch ist der Anteil der Fehlanpassungen in den zugeordneten Reads, wenn sie an das Referenzgenom gemappt sind?
> 2. Was stellt die Fehlerrate dar?
> 3. Wie ist die durchschnittliche Qualität? Wie wird sie dargestellt?
> 4. Wie groß ist die durchschnittliche Insert-Größe?
> 5. Wie viele Reads haben eine Mapping-Qualitätsbewertung unter 20?
>
> > <solution-title></solution-title>
> > 1. Es gibt ~21.900 Fehlanpassungen bei ~4.753.900 zugeordneten Basen, was durchschnittlich ~0,005 Fehlanpassungen pro zugeordneter Basis ergibt.
> > 2. Die Fehlerrate ist der Anteil der Fehlanpassungen pro zugeordneter Basis, also das Verhältnis, das gerade zuvor berechnet wurde.
> > 3. Die durchschnittliche Qualität ist die durchschnittliche Qualitätsbewertung des Mappings. Es handelt sich um einen Phred-Score wie der, der in der FASTQ-Datei für jede Nukleotid verwendet wird. Hier ist der Score jedoch nicht pro Nukleotid, sondern pro Read und stellt die Wahrscheinlichkeit der Mapping-Qualität dar.
> > 4. Die Insert-Größe ist der Abstand zwischen den beiden Reads in den Paaren.
> > 5. Um die Informationen zu erhalten:
> >      1. {% tool [Filter BAM](toolshed.g2.bx.psu.edu/repos/devteam/bamtools_filter/bamFilter/2.5.2+galaxy2) %} mit einem Filter, um nur die Reads mit einer Mapping-Qualität >= 20 zu behalten
> >      2. {% tool [Samtools Stats](toolshed.g2.bx.psu.edu/repos/devteam/samtools_stats/samtools_stats/2.0.5) %} auf die Ausgabe von **Filter**
> >
> >    Vor dem Filtern: 95.412 Reads und nach dem Filtern: 89.664 Reads.
>  {: .solution }
{: .question}

# Visualisierung mit einem Genome Browser

## IGV

Der Integrative Genomics Viewer (IGV) ist ein leistungsstarkes Visualisierungstool für die interaktive Erkundung großer, integrierter genomischer Datensätze. Es unterstützt eine Vielzahl von Datentypen, einschließlich Array-basierter und Next-Generation-Sequenzdaten sowie genomischer Annotationen. Im Folgenden werden wir es verwenden, um die zugeordneten Reads zu visualisieren.

{% include topics/sequence-analysis/tutorials/mapping/igv.md tool="Bowtie2" region_to_zoom="chr2:98,666,236-98,667,473" %}

## JBrowse

{% tool [JBrowse](toolshed.g2.bx.psu.edu/repos/iuc/jbrowse/jbrowse/1.16.11+galaxy0) %} ist ein alternatives, webbasiertes Genom-Browser. Während IGV eine Software ist, die heruntergeladen und ausgeführt werden muss, sind JBrowse-Instanzen Websites, die online gehostet werden und eine Schnittstelle zum Durchsuchen genomischer Daten bieten. Wir werden es verwenden, um die zugeordneten Reads zu visualisieren.

{% include topics/sequence-analysis/tutorials/mapping/jbrowse.md tool="Bowtie2" region_to_zoom="chr2:98,666,236-98,667,473" %}

# Fazit

Nach der Qualitätskontrolle ist das Mapping ein wichtiger Schritt der meisten Analysen von Sequenzierungsdaten (RNA-Seq, ChIP-Seq usw.), um zu bestimmen, wo im Genom unsere Reads herstammen, und diese Informationen für nachfolgende Analysen zu nutzen.
