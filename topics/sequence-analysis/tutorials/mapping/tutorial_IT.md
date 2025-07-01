---
layout: tutorial_hands_on
title: Mappatura
zenodo_link: https://doi.org/10.5281/zenodo.1324070
questions:
- What is mapping?
- What two things are crucial for a correct mapping?
- What is BAM?
objectives:
- Run a tool to map reads to a reference genome
- Explain what is a BAM file and what it contains
- Use genome browser to understand your data
time_estimation: 1h
key_points:
- Know your data!
- Mapping is not trivial
- There are many mapping algorithms, it depends on your data which one to choose
subtopic: basics
requirements:
- type: internal
  topic_name: sequence-analysis
  tutorials:
  - quality-control
follow_up_training:
- type: internal
  topic_name: transcriptomics
  tutorials:
  - ref-based
- type: internal
  topic_name: epigenetics
  tutorials:
  - formation_of_super-structures_on_xi
level: Introductory
edam_ontology:
- topic_0102
contributors:
- joachimwolff
- bebatut
- hexylena
recordings:
- captioners:
  - shiltemann
  date: '2021-02-15'
  galaxy_version: '21.01'
  length: 20M
  youtube_id: 1wm-62E2NkY
  speakers:
  - pvanheus
- youtube_id: B-CFWSkZzRc
  length: 24M
  galaxy_version: 24.1.2.dev0
  date: '2024-09-07'
  speakers:
  - DinithiRajapaksha
  captioners:
  - DinithiRajapaksha
  bot-timestamp: 1725707919
lang: it
tags:
  - deutsch
  - english
  - español
translations:
  - de
  - en
  - es
---



Il sequenziamento produce una collezione di sequenze senza contesto genomico. Non
sappiamo a quale parte del genoma corrispondano le sequenze. La mappatura delle letture
di un esperimento su un genoma di riferimento è un passo fondamentale nella moderna
analisi dei dati genomici. Con la mappatura le letture vengono assegnate a una posizione
specifica nel genoma e si possono ottenere informazioni come il livello di espressione
dei geni.

Le letture non vengono fornite con informazioni sulla posizione, quindi non sappiamo da
quale parte del genoma provengano. Dobbiamo usare la sequenza della lettura stessa per
trovare la regione corrispondente nella sequenza di riferimento. Ma la sequenza di
riferimento può essere molto lunga (~3 miliardi di basi per l'uomo), il che rende
difficile trovare una regione corrispondente. Poiché le nostre letture sono brevi, ci
possono essere diversi punti della sequenza di riferimento da cui potrebbero essere
state lette con la stessa probabilità. Ciò è particolarmente vero per le regioni
ripetitive.

In linea di principio, potremmo fare un'analisi BLAST per capire dove i pezzi
sequenziati si inseriscono meglio nel genoma conosciuto. Dovremmo farlo per ciascuno dei
milioni di letture presenti nei nostri dati di sequenziamento. Allineare milioni di
brevi sequenze in questo modo potrebbe tuttavia richiedere un paio di settimane. E non
ci interessa l'esatta corrispondenza base-base (allineamento). Quello che ci interessa è
"da dove provengono queste letture". Questo approccio si chiama **mappatura**.

Di seguito, elaboreremo un set di dati con il mappatore **Bowtie2** e visualizzeremo i
dati con il programma **IGV**.

> <agenda-title></agenda-title>
> 
> In questo tutorial, ci occuperemo di:
> 
> 1. TOC
> {:toc}
> 
{: .agenda}

# Preparare i dati

> <hands-on-title>Caricamento dati</hands-on-title>
> 
> 1. Creare una nuova storia per questa esercitazione e darle un nome appropriato
> 
>    {% snippet faqs/galaxy-it/histories_create_new.md %}
> 
>    {% snippet faqs/galaxy-it/histories_rename.md %}
> 
> 2. Importazione di `wt_H3K4me3_read1.fastq.gz` e `wt_H3K4me3_read2.fastq.gz` da
>    [Zenodo](https://zenodo.org/record/1324070) o dalla libreria di dati (chiedere al
>    proprio docente)
> 
>    ```
>    https://zenodo.org/record/1324070/files/wt_H3K4me3_read1.fastq.gz
>    https://zenodo.org/record/1324070/files/wt_H3K4me3_read2.fastq.gz
>    ```
> 
>    {% snippet faqs/galaxy-it/datasets_import_via_link.md %}
> 
>    {% snippet faqs/galaxy-it/datasets_import_from_data_library.md %}
> 
>    Per impostazione predefinita, Galaxy prende il link come nome, quindi rinominarli.
> 
> 3. Rinominare i file in `reads_1` e `reads_2`
> 
>    {% snippet faqs/galaxy-it/datasets_rename.md %}
> 
{: .hands_on}

Abbiamo semplicemente importato in Galaxy i file FASTQ corrispondenti ai dati paired-end
che abbiamo potuto ottenere direttamente da un centro di sequenziamento.

Durante il sequenziamento vengono introdotti degli errori, come il richiamo di
nucleotidi errati. Gli errori di sequenziamento possono influenzare l'analisi e portare
a un'interpretazione errata dei dati. Il primo passo da compiere per qualsiasi tipo di
dati di sequenziamento è sempre quello di verificarne la qualità.

Esiste un tutorial dedicato al [controllo di qualità] ({% link
topics/sequence-analysis/tutorials/quality-control/tutorial.md %}) dei dati di
sequenziamento. Non ripeteremo i passaggi ivi descritti. È necessario seguire il
[tutorial]({% link topics/sequence-analysis/tutorials/quality-control/tutorial.md %}) e
applicarlo ai propri dati prima di andare avanti.

# Mappare le letture su un genoma di riferimento

La mappatura delle letture è il processo di allineamento delle letture su un genoma di
riferimento. Un mappatore prende in input un genoma di riferimento e un insieme di
letture. Il suo scopo è quello di allineare ogni lettura dell'insieme di letture sul
genoma di riferimento, tenendo conto di mismatch, indel e ritaglio di alcuni brevi
frammenti alle due estremità delle letture:

![Spiegazione della mappatura](../../images/mapping/mapping.png "Illustrazione del processo di mappatura. L'input è costituito da un insieme di letture e da un genoma di riferimento. Al centro sono riportati i risultati della mappatura: le posizioni delle letture sul genoma di riferimento. La prima lettura è allineata alla posizione 100 e l'allineamento presenta due mismatch. La seconda lettura è allineata alla posizione 114. Si tratta di un allineamento locale con ritagli. Si tratta di un allineamento locale con ritagli a sinistra e a destra. La terza lettura è allineata in posizione 123. Consiste in un'inserzione di 2 basi e in una delezione di 1 base")

Abbiamo bisogno di un genoma di riferimento su cui mappare le letture.

{% include topics/sequence-analysis/tutorials/mapping/ref_genome_explanation.md answer_3="Questi dati provengono dal ChIP-seq dei topi, quindi utilizzeremo mm10 (*Mus musculus*)"%}

Attualmente esistono oltre 60 mappatori diversi e il loro numero è in crescita. In
questo tutorial utilizzeremo [Bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/), uno
strumento open-source veloce ed efficiente in termini di memoria, particolarmente adatto
all'allineamento di letture di sequenziamento da circa 50 a 1.000 basi a genomi
relativamente lunghi.

> <hands-on-title>Mappatura con Bowtie2</hands-on-title>
> 1. {% tool [Bowtie2](toolshed.g2.bx.psu.edu/repos/devteam/bowtie2/bowtie2/2.4.2+galaxy0) %} con i seguenti parametri
>    - *"È una libreria singola o accoppiata "*: `Paired-end`
>       - {% icon param-file %} *"File FASTA/Q #1"*: `reads_1`
>       - {% icon param-file %} *"File FASTA/Q #2"*: `reads_2`
>       - *"Vuoi impostare le opzioni paired-end? "*: `No`
> 
>         Dovreste dare un'occhiata ai parametri, in particolare all'orientamento del
>         mate, se lo conoscete. Possono migliorare la qualità della mappatura
>         paired-end.
> 
>     - *"Selezionerete un genoma di riferimento dalla vostra storia o userete un indice
>       incorporato? "*: `Use a built-in genome index`
>       - *"Selezionare il genoma di riferimento "*: `Mouse (Mus musculus): mm10`
>     - *"Selezionare la modalità di analisi "*: `Default setting only`
> 
>       È necessario dare un'occhiata ai parametri non predefiniti e cercare di
>       comprenderli. Possono avere un impatto sulla mappatura e migliorarla.
> 
>     - *"Salva le statistiche di mappatura di bowtie2 nella cronologia "*: `Yes`
> 
> 2. Ispezionare il file `mapping stats` cliccando sull'icona {% icon galaxy-eye %} (occhio)
> 
{: .hands_on}

> <question-title></question-title>
> 
> 1. Quali informazioni sono fornite qui?
> 2. quante letture sono state mappate esattamente 1 volta?
> 3. Quante letture sono state mappate più di una volta? Come è possibile? Cosa dobbiamo
>    fare con loro?
> 4. Quante coppie di letture non sono state mappate? Quali sono le cause?
> 
> > <titolo della soluzione></solution-title>
> > 1. Le informazioni fornite qui sono di tipo quantitativo. Possiamo vedere quante
> >    sequenze sono allineate. Non ci dice nulla sulla qualità.
> > 2. ~90% di letture sono state allineate esattamente 1 volta
> > 3. ~7% di letture sono state allineate in modo concordante >1 volta. Queste sono
> >    chiamate letture multimappate. Può accadere a causa di ripetizioni nel genoma di
> >    riferimento (copie multiple di un gene, per esempio), in particolare quando le
> >    letture sono piccole. È difficile stabilire da dove provengano queste sequenze e
> >    quindi la maggior parte delle pipeline le ignora. Controllare sempre le
> >    statistiche per essere sicuri di non scartare troppe informazioni nelle analisi a
> >    valle.
> > 4. ~3% coppie di letture non sono state mappate perché
> >     - entrambe le letture della coppia sono allineate ma le loro posizioni non
> >       concordano con la coppia di letture (`aligned discordantly 1 time`)
> >     - le letture di queste coppie sono multimappate (`aligned >1 times` in `pairs
> >       aligned 0 times concordantly or discordantly`)
> >     - una lettura di queste coppie è mappata ma non la lettura accoppiata (`aligned
> >       exactly 1 time` in `pairs aligned 0 times concordantly or discordantly`)
> >     - il resto non viene mappato affatto
> > 
> {: .solution }
> 
{: .question}

Il controllo delle statistiche di mappatura è un passo importante da fare prima di
continuare qualsiasi analisi. Esistono diverse fonti potenziali di errore nella
mappatura, tra cui (ma non solo):

- **Arfatti della reazione a catena della polimerasi (PCR)**: Molti metodi di
  sequenziamento ad alta velocità (HTS) prevedono una o più fasi di PCR. Gli errori di
  PCR si manifestano come mismatch nell'allineamento e, in particolare, gli errori nei
  primi cicli di PCR si manifestano con letture multiple, suggerendo falsamente una
  variazione genetica nel campione. Un errore correlato è rappresentato dai duplicati di
  PCR, in cui la stessa coppia di letture si presenta più volte, alterando i calcoli di
  copertura nell'allineamento.
- **Errori di sequenziamento**: La macchina di sequenziamento può effettuare una
  chiamata errata per motivi fisici (ad esempio, olio su un vetrino Illumina) o a causa
  delle proprietà del DNA sequenziato (ad esempio, omopolimeri). Poiché gli errori di
  sequenziamento sono spesso casuali, possono essere filtrati come letture singleton
  durante la chiamata di variante.
- **Errori di mappatura**: L'algoritmo di mappatura può mappare una lettura nella
  posizione sbagliata del riferimento. Ciò accade spesso in prossimità di ripetizioni o
  di altre regioni a bassa complessità.

Pertanto, se le statistiche di mappatura non sono buone, è necessario indagare sulla
causa di questi errori prima di procedere con le analisi.

Dopo di che, è necessario dare un'occhiata alle letture e ispezionare il file BAM in cui
sono memorizzate le mappature delle letture.

# Ispezione di un file BAM

{% include topics/sequence-analysis/tutorials/mapping/bam_explanation_IT.md mapper="Bowtie2" %}

Il file BAM include molte informazioni su ciascuna lettura, in particolare sulla qualità
della mappatura.

> <hands-on-title>Riepilogo della qualità di mappatura</hands-on-title>
> 1. {% tool [Samtools Stats](toolshed.g2.bx.psu.edu/repos/devteam/samtools_stats/samtools_stats/2.0.2+galaxy2) %} con i seguenti parametri
>    - {% icon param-file %} *"File BAM "*: `aligned reads` (output di **Bowtie2** {% icon tool %})
>    - *"Usa sequenza di riferimento "*: `Locally cached/Use a built-in genome`
>      - *"Utilizzo del genoma "*: Mouse (Mus musculus): mm10 Full
> 
> 2. Ispezionare il file {% icon param-file %} file `Stats`
> 
{: .hands_on}

> <question-title></question-title>
> 
> 1. Qual è la percentuale di mismatch nelle letture mappate quando sono allineate al
>    genoma di riferimento?
> 2. Cosa rappresenta il tasso di errore?
> 3. Qual è la qualità media? Come viene rappresentata?
> 4. Qual è la dimensione media degli inserti?
> 5. Quante letture hanno un punteggio di qualità di mappatura inferiore a 20?
> 
> > <titolo della soluzione></solution-title>
> > 1. Ci sono ~21.900 mismatches per ~4.753.900 basi mappate, il che produce in media
> >    ~0,005 mismatches per basi mappate.
> > 2. Il tasso di errore è la proporzione di mismatch per basi mappate, quindi il
> >    rapporto calcolato subito prima.
> > 3. La qualità media è il punteggio medio di qualità della mappatura. Si tratta di un
> >    punteggio Phred come quello utilizzato nel file FASTQ per ciascun nucleotide. Ma
> >    qui il punteggio non è per nucleotide, ma per lettura e rappresenta la
> >    probabilità della qualità della mappatura.
> > 4. La dimensione dell'inserto è la distanza tra le due letture nelle coppie.
> > 5. Per ottenere le informazioni:
> >      1. {% tool [Filter BAM](toolshed.g2.bx.psu.edu/repos/devteam/bamtools_filter/bamFilter/2.5.2+galaxy2) %} con un filtro per mantenere solo le letture con una qualità di mappatura >= 20
> >      2. {% tool [Samtools Stats](toolshed.g2.bx.psu.edu/repos/devteam/samtools_stats/samtools_stats/2.0.5) %} sull'output di **Filtro**
> > 
> >    Prima del filtraggio: 95.412 letture e dopo il filtraggio: 89.664 letture.
> > 
> {: .solution }
> 
{: .question}

# Visualizzazione con il browser del genoma

## IGV

L'Integrative Genomics Viewer (IGV) è uno strumento di visualizzazione ad alte
prestazioni per l'esplorazione interattiva di grandi insiemi di dati genomici integrati.
Supporta un'ampia varietà di tipi di dati, compresi i dati di sequenza basati su array e
di nuova generazione e le annotazioni genomiche. Di seguito, lo utilizzeremo per
visualizzare le letture mappate.

{% include topics/sequence-analysis/tutorials/mapping/igv_IT.md tool="Bowtie2" region_to_zoom="chr2:98,666,236-98,667,473" %}

## JBrowse

{% tool [JBrowse](toolshed.g2.bx.psu.edu/repos/iuc/jbrowse/jbrowse/1.16.11+galaxy0) %} è
un browser genomico alternativo basato sul web. Mentre IGV è un software da scaricare ed
eseguire, le istanze di JBrowse sono siti web ospitati online che forniscono
un'interfaccia per sfogliare i dati genomici. Lo useremo per visualizzare le letture
mappate.

{% include topics/sequence-analysis/tutorials/mapping/jbrowse_IT.md tool="Bowtie2" region_to_zoom="chr2:98,666,236-98,667,473" %}

# Conclusione

Dopo il controllo di qualità, la mappatura è una fase importante della maggior parte
delle analisi dei dati di sequenziamento (RNA-Seq, ChIP-Seq, ecc.) per determinare
l'origine delle letture nel genoma e utilizzare queste informazioni per le analisi a
valle.

