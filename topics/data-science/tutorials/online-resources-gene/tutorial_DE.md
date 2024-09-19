---
layout: tutorial_hands_on
title: Lernen über ein Gen anhand biologischer Ressourcen und Formate
level: Einführend
draft: true
zenodo_link: https://zenodo.org/record/8304465
questions:
- Wie kann man bioinformatische Ressourcen nutzen, um eine bestimmte Protein-Familie (Opsine) zu untersuchen?
- Wie navigierst Du im Genome Data Viewer, um Opsine im menschlichen Genom zu finden?
- Wie identifizierst Du Gene, die mit Opsinen assoziiert sind, und analysierst deren Chromosomenorte?
- Wie kannst Du Literatur und klinische Kontexte für das OPN1LW-Gen erkunden?
- Wie nutzt Du Proteinsequenzdateien, um Ähnlichkeitssuchen mit BLAST durchzuführen?
objectives:
- Ausgehend von einer Textsuche mehrere Web-Ressourcen nutzen, um verschiedene Informationen über ein Gen zu prüfen, die in verschiedenen Dateiformaten bereitgestellt werden.
time_estimation: 1H
key_points:
- Du kannst Gene und Proteine anhand spezifischer Texte im NCBI-Genom suchen.
- Sobald Du ein relevantes Gen oder Protein gefunden hast, kannst Du seine Sequenz und Annotation in verschiedenen Formaten von NCBI abrufen.
- Du kannst auch Informationen über die Chromosomenlage und die Exon-Intron-Zusammensetzung des interessierenden Gens erfahren.
- NCBI bietet ein BLAST-Tool zur Durchführung von Ähnlichkeitssuchen mit Sequenzen an.
- Du kannst die im Tutorial enthaltenen Ressourcen weiter erkunden, um mehr über genassoziierte Bedingungen und Varianten zu erfahren.
- Du kannst eine FASTA-Datei mit einer interessierenden Sequenz für BLAST-Suchen eingeben.
contributions:
  authorship:
    - lisanna
    - bebatut
    - teresa-m
  funding:
    - biont
---

Wenn Du eine bioinformatische Analyse durchführst, z.B. RNA-seq, könntest Du mit einer Liste von Genen enden. Dann musst Du diese Gene untersuchen. Aber wie machst Du das? Welche Ressourcen stehen dafür zur Verfügung? Und wie navigierst Du durch diese?

Das Ziel dieses Tutorials ist es, Dich damit vertraut zu machen, am Beispiel der menschlichen Opsine.

Menschliche Opsine befinden sich in den Zellen Deiner Retina. Opsine fangen Licht ein und beginnen die Folge von Signalen, die zur Vision führen. Wir werden damit beginnen, Fragen zu Opsinen und Opsin-Genen zu stellen und dann verschiedene bioinformatische Datenbanken und Ressourcen nutzen, um diese zu beantworten.

> <comment-title></comment-title>
> Dieses Tutorial ist etwas untypisch: Wir werden nicht in Galaxy arbeiten, sondern hauptsächlich außerhalb davon, indem wir Datenbanken und Werkzeuge über deren eigene Webschnittstellen navigieren. Der Zweck dieses Tutorials ist es, verschiedene Quellen biologischer Daten in unterschiedlichen Dateiformaten zu veranschaulichen und verschiedene Informationen darzustellen.
{: .comment}

> <agenda-title></agenda-title>
>
> In diesem Tutorial werden wir uns mit folgenden Themen beschäftigen:
>
> 1. TOC
> {:toc}
{: .agenda}

# Suche nach menschlichen Opsinen

Um menschliche Opsine zu suchen, beginnen wir mit dem [NCBI Genome Data Viewer](https://www.ncbi.nlm.nih.gov/genome/gdv). Der NCBI Genome Data Viewer (GDV) ({% cite rangwala2021accessing %}) ist ein Genom-Browser, der die Erkundung und Analyse annotierter eukaryotischer Genomassemblierungen unterstützt. Der GDV-Browser zeigt biologische Informationen, die einem Genom zugeordnet sind, einschließlich Genannotationen, Variationsdaten, BLAST-Ausrichtungen und experimentelle Studiendaten aus den NCBI GEO- und dbGaP-Datenbanken. GDV-Release-Notizen beschreiben neue Funktionen dieses Browsers.

> <hands-on-title>Öffne den NCBI Genome Data Viewer</hands-on-title>
>
> 1. Öffne den NCBI Genome Data Viewer unter [www.ncbi.nlm.nih.gov/genome/gdv](https://www.ncbi.nlm.nih.gov/genome/gdv/)
>
{: .hands-on}

Die Startseite enthält einen einfachen "Stammbaum des Lebens", bei dem der menschliche Knoten hervorgehoben ist, da es sich um das Standardorganismus handelt, nach dem gesucht wird. Du kannst das im *Search organisms*-Feld ändern, aber wir lassen es vorerst so, da wir an menschlichen Opsinen interessiert sind.

![Screenshot der Homepage des Genome Data Viewers, das Wort "opsin" ist in das Suchfeld geschrieben und das Ergebnis wird angezeigt.](./images/GenomeDataViewerpage.png "Genome Data Viewer Startseite")

Das Panel auf der rechten Seite zeigt mehrere Assemblierungen des interessierenden Genoms und eine Karte der Chromosomen dieses Genoms an. Wir können dort nach Opsinen suchen.

> <hands-on-title>Nach Opsinen suchen</hands-on-title>
>
> 1. Gib `opsin` in das *Search in genome*-Feld ein
> 2. Klicke auf das Lupensymbol oder drücke <kbd>Enter<kbd>
>
{: .hands-on}

Unter dem Feld wird jetzt eine Tabelle mit Genen angezeigt, die mit Opsin in Zusammenhang stehen, zusammen mit ihren Namen und Standorten, d.h. der Chromosomenzahl sowie dem Start- und Endpunkt

In der Liste der Gene, die mit dem Suchbegriff Opsin in Zusammenhang stehen, befinden sich das Rhodopsin-Gen (RHO) und drei Cone-Pigmente, kurz-, mittel- und langwellenempfindliche Opsine (zum Nachweis von Blau-, Grün- und Rotlicht). Es gibt auch andere Entitäten, z.B. eine -LCR (Locus Control Region), putative Gene und Rezeptoren.

Mehrere Treffer befinden sich auf dem X-Chromosom, einem der geschlechtsbestimmenden Chromosomen.

> <question-title></question-title>
>
> 1. Wie viele Gene wurden auf Chromosom X gefunden?
> 2. Wie viele davon sind protein-codierende Gene?
>
> > <solution-title></solution-title>
> >
> > 1. Die Treffer auf ChrX sind: 
> > - OPSIN-LCR
> > - OPN1LW
> > - OP1MW
> > - OPN1MW2
> > - OPN1MW3
> >
> > 2. Wenn Du über jedes Gen fährst, öffnet sich ein Feld, und Du kannst auf *Details* klicken, um mehr über jedes Gen zu erfahren. Dann erfährst Du, dass das erste (OPSIN-LCR) kein protein-codierendes Gen, sondern eine Genregulationsregion ist, während die anderen protein-codierende Gene sind. Es gibt also 4 protein-codierende Gene, die mit Opsinen auf Chromosom X in Zusammenhang stehen. Insbesondere enthält Chromosom X ein rotes Pigment-Gen (OPN1LW) und drei grüne Pigment-Gene (OPN1MW, OPN1MW2 und OPN1MW3 in der Referenzgenomassemblierung).
> >
> {: .solution}
{: .question}

Lass uns nun auf ein spezifisches Opsin konzentrieren, das Gen OPN1LW.

> <hands-on-title>Öffne den Genom-Browser für das Gen OPN1LW</hands-on-title>
>
> 1. Klicke auf den blauen Pfeil, der in der Ergebnistabelle erscheint, wenn Du Deine Maus auf die Zeile OPN1LW bewegst
>
{: .hands-on}

Du solltest auf [dieser Seite](https://www.ncbi.nlm.nih.gov/genome/gdv/browser/genome/?id=GCF_000001405.40) gelandet sein, die die Genomansicht des Gens OPN1LW zeigt.

![Genome Data Viewer des Gens OPN1LW, Screenshot der beiden Hauptpanels des Viewers, mit Chromosomen auf der linken Seite und dem Feature-Viewer auf der rechten Seite.](./images/GenomeDataViewerofgeneOPN1LW.png "Genome Data Viewer des Gens OPN1LW")

Es gibt viele Informationen auf dieser Seite, konzentrieren wir uns nacheinander auf eine Sektion.

1. Der Genome Data Viewer zeigt oben an, dass wir die Daten des Organismus `Homo sapiens`, Assembly `GRCh38.p14` betrachten, und speziell auf `Chr X` (Chromosom X). Jede dieser Informationen hat eine einzigartige ID.
2. Das gesamte Chromosom wird direkt darunter dargestellt, und die Positionen entlang der kurzen (`p`) und langen (`q`) Arme sind hervorgehoben.
3. Darunter hebt ein blauer Kasten hervor, dass wir uns jetzt auf die Region konzentrieren, die dem Gen `OPN1LW` entspricht.

    Es gibt mehrere Möglichkeiten, mit dem Viewer zu interagieren. Versuche zum Beispiel, mit der Maus über die Punkte zu fahren, die Exons im blauen Kasten darstellen.

4. Im Diagramm darunter ist die Gen-Sequenz als grüne Linie dargestellt, wobei die Exons (protein-codierende Fragmente) durch grüne Rechtecke repräsentiert sind.

    Fahre mit der Maus über die grüne Linie, die `NM_020061.6` (unser Gene von Interesse) entspricht, um detailliertere Informationen zu erhalten.


> <question-title></question-title>
>
> 1. Was ist der Standort des OPN1LW-Segments?
> 2. Wie lang ist das OPN1LW-Segment?
> 3. Was sind Introns und Exons?
> 4. Wie viele Exons und Introns befinden sich im OPN1LW-Gen?
> 5. Wie lang ist die gesamte kodierende Region?
> 6. Wie ist die Verteilung zwischen kodierenden und nicht-kodierenden Bereichen? Was bedeutet das biologisch?
> 7. Wie lang ist das Protein in der Anzahl der Aminosäuren?
>
> > <solution-title></solution-title>
> >
> > 1. Von 154.144.243 bis 154.159.032
> > 2. 14.790 Nukleotide, gefunden unter *Span on 14790 nt, nucleotides)*
> > 3. Eukaryotische Gene werden oft durch nicht-kodierende Bereiche unterbrochen, die als Introns bezeichnet werden. Die kodierenden Bereiche werden Exons genannt.
> > 4. Aus diesem Diagramm kannst Du sehen, dass das OPN1LW-Gen aus 6 Exons und 5 Introns besteht und dass die Introns deutlich größer sind als die Exons.
> > 5. Die Länge der CDS beträgt 1.095 Nukleotide.
> > 6. Von den 14.790 nt im Gen kodieren nur 1.095 nt für das Protein, was bedeutet, dass weniger als 8 % der Basenpaare den Code enthalten. Wenn dieses Gen in Zellen der menschlichen Netzhaut exprimiert wird, wird eine RNA-Kopie des gesamten Gens synthetisiert. Anschließend werden die Intron-Bereiche herausgeschnitten und die Exon-Bereiche zusammengefügt, um die reife mRNA (ein Prozess namens Spleißen) zu erzeugen, die dann von den Ribosomen übersetzt wird, während sie das rote Opsin-Protein bilden. In diesem Fall werden 92 % des ursprünglichen RNA-Transkripts verworfen, sodass nur der reine Proteincode übrig bleibt.
> > 7. Die Länge des resultierenden Proteins beträgt 364 Aminosäuren.
> {: .solution}
{: .question}

Aber wie lautet die Sequenz dieses Gens? Es gibt verschiedene Möglichkeiten, diese Information zu erhalten. Wir werden uns eine davon anschauen, die wir für besonders intuitiv halten.

> <hands-on-title>Öffne den Genome Browser für das OPN1LW-Gen</hands-on-title>
>
> 1. Klicke im rechten oberen Bereich des Kastens, der das Gen zeigt, auf den Abschnitt {% icon tool %} *Tools*.
> 2. Klicke auf *Sequence Text View*.
{: .hands-on}

Dieses Panel zeigt die DNA-Sequenz der Introns (in Grün) sowie die der Exons (in Pink, einschließlich der darunter stehenden übersetzten Proteinsequenz).

![Screenshot der Sequenzansicht der NHI-Ressource, der Text ist in verschiedenen Farben hervorgehoben.](./images/SequenceTextView.png "Sequence Text View")

Dieser Sequenzkasten zeigt momentan nicht das gesamte Gen an, sondern nur einen Ausschnitt davon. Du kannst mit den Pfeilen *Prev Page* und *Next Page* im genetischen Code nach oben und unten navigieren oder mit der Schaltfläche *Go To Position* von einer bestimmten Position aus starten. Wir empfehlen, mit dem Start der kodierenden Region des Gens zu beginnen, die wir bereits gelernt haben, sich an der Position 154.144.243 befindet.

> <hands-on-title>Gehe zu einer spezifischen Position in der Sequenzansicht</hands-on-title>
>
> 1. Klicke auf *Go To Position*.
> 2. Gib `154144243` ein.
> 
>    Du musst die Kommas entfernen, um den Wert zu validieren.
{: .hands-on}

Die hier in Lila hervorgehobene Sequenz signalisiert eine regulatorische Region.

> <question-title></question-title>
>
> 1. Was ist die erste Aminosäure des resultierenden Proteinprodukts?
> 2. Was ist die letzte?
> 3. Kannst Du Dir die ersten drei und letzten drei Aminosäuren dieses Proteins notieren?
>
> > <solution-title></solution-title>
> >
> > 1. Das entsprechende Protein beginnt mit Methionin, M (das tun sie alle).
> > 2. Die letzte Aminosäure des letzten Exons (zu finden auf der 2. Seite) ist Alanin (A). Danach folgt das Stop-Codon TGA, das nicht in eine Aminosäure übersetzt wird.
> > 3. Die ersten drei Aminosäuren sind: M, A, Q; die letzten drei: S, P, A.
> >
> {: .solution}
{: .question}

Du kannst jetzt die *Sequence View* schließen.

Von dieser Ressource aus kannst Du auch Dateien in verschiedenen Formaten herunterladen, die das Gen beschreiben. Sie sind im *Download*-Abschnitt verfügbar.

1. *Download FASTA* ermöglicht es Dir, die einfachste Dateiform darzustellen, die die Nukleotidsequenz des gesamten sichtbaren Bereichs des Genoms (mehr als nur das Gen) repräsentiert.
2. *Download GenBank flat file* ermöglicht Dir den Zugriff auf die auf dieser Seite verfügbaren Anmerkungen (und darüber hinaus) in einem einfachen Textformat.
3. *Download Track Data* erlaubt Dir, zwei der Dateiformate, die wir in den Folien vorgestellt haben, zu inspizieren: die GFF (GFF3) und BED-Formate. Wenn Du die Tracks änderst, können diese Formate verfügbar oder nicht verfügbar sein.

# Mehr Informationen über unser Gen finden

Lass uns nun einen Überblick über die Informationen bekommen, die wir (in der Literatur) über unser Gen haben, indem wir die NCBI-Ressourcen nutzen.

> <hands-on-title>Gehe zu einer spezifischen Position in der Sequenzansicht</hands-on-title>
>
> 1. Öffne die NCBI-Suche unter [www.ncbi.nlm.nih.gov/search](https://www.ncbi.nlm.nih.gov/search/)
> 2. Gib `OPN1LW` in das *Search NCBI* Suchfeld ein.
> 
{: .hands-on}

![Screenshot der NIH-Ergebnisseite, mit Karten namens Literatur, Gene, Proteine, Genome, Klinisches und PubChem](./images/NIHresults.png "Ergebnisse bei der Suche nach `OPN1LW` auf NCBI").

## Literatur

Beginnen wir mit der Literatur und insbesondere den Ergebnissen von *PubMed* oder *PubMed Central*.

> <details-title>Was ist der Unterschied zwischen PubMed und PubMed Central? </details-title>
>
> PubMed ist eine biomedizinische Literaturdatenbank, die die Abstracts von Publikationen enthält.
>
> PubMed Central ist ein Volltext-Repository, das den gesamten Text von Publikationen in der Datenbank enthält.
>
> Während die genaue Anzahl der Treffer im Laufe der Zeit variieren kann, sollte jeder Genname mehr Treffer in PubMed Central (durchsucht die Volltexte von Publikationen) als in PubMed (durchsucht nur die Abstracts) haben.
>
{: .details}

> <hands-on-title>Öffne PubMed</hands-on-title>
>
> 1. Klicke auf *PubMed* in der *Literatur*-Box.
> 
{: .hands-on}

Du hast PubMed betreten, eine kostenlose Datenbank wissenschaftlicher Literatur, und siehst die Ergebnisse einer vollständigen Suche nach Artikeln, die direkt mit diesem Gen-Lokus verbunden sind.

Indem Du auf den Titel jedes Artikels klickst, kannst Du die Abstracts des Artikels einsehen. Wenn Du Dich auf einem Universitätscampus befindest, auf dem Du Zugang zu bestimmten Zeitschriften hast, kannst Du möglicherweise auch Links zu vollständigen Artikeln sehen. PubMed ist Dein Einstieg in eine Vielzahl wissenschaftlicher Literatur im Bereich der Lebenswissenschaften. Auf der linken Seite jeder PubMed-Seite findest Du Links zu einer Beschreibung der Datenbank, Hilfe und Tutorials zur Suche.

> <question-title></question-title>
>
> 1. Kannst Du erraten, mit welchen Arten von Erkrankungen dieses Gen in Verbindung steht?
>
> > <solution-title></solution-title>
> >
> > 1. Wir werden diese Frage später beantworten.
> >
> {: .solution}
{: .question}

> <hands-on-title>Zurück zur NCBI-Suchseite</hands-on-title>
>
> 1. Gehe zurück zur [NCBI-Suchseite](https://www.ncbi.nlm.nih.gov/search/all/?term=OPN1LW)
> 
{: .hands-on}

## Klinisches

Konzentrieren wir uns nun auf das Feld *Klinisches* und insbesondere auf *OMIM*. OMIM, das Online Mendelian Inheritance in Man (und Frau!), ist ein Katalog menschlicher Gene und genetischer Störungen.

> <hands-on-title>Öffne OMIM</hands-on-title>
>
> 1. Klicke auf *OMIM* im *Klinisches*-Feld.
> 
{: .hands-on}

Jeder OMIM-Eintrag beschreibt eine genetische Störung (hier meist verschiedene Arten von Farbenblindheit), die mit Mutationen in diesem Gen in Verbindung steht.

> <hands-on-title>Lies so viel, wie Dein Interesse es erlaubt</hands-on-title>
>
> 1. Folge den Links, um mehr Informationen zu jedem Eintrag zu erhalten.
> 
{: .hands-on}

> <comment-title>Lies so viel, wie Dein Interesse es erlaubt</comment-title>
>
> Für weitere Informationen über OMIM selbst, klicke auf das OMIM-Logo oben auf der Seite. OMIM bietet eine Fülle von Informationen zu zahllosen Genen im menschlichen Genom, und alle Informationen sind durch Verweise auf die neuesten Forschungsartikel gestützt.
> 
{: .comment}

Wie beeinflussen Variationen im Gen das Proteinprodukt und seine Funktionen? Kehren wir zur NIH-Seite zurück und untersuchen die Liste der Einzelnukleotid-Polymorphismen (SNPs), die in Genetikstudien in diesem Gen entdeckt wurden.

> <hands-on-title>Öffne dbSNP</hands-on-title>
>
> 1. Gehe zurück zur [NCBI-Suchseite](https://www.ncbi.nlm.nih.gov/search/all/?term=OPN1LW)
> 2. Klicke auf *dbSNP* im *Klinisches*-Feld.
> 
{: .hands-on}

![Screenshot der dbSNP-Seite über das Gen OPN1LW. Drei Hauptbereiche: links zur Filterung der Suche basierend auf Tags, in der Mitte die Ergebnisse, rechts eine detaillierte und programmatische Suche.](./images/dbSNPs.png "dbSNP in OPN1LW")

> <question-title></question-title>
>
> 1. Was ist die klinische Bedeutung von rs5986963 und rs5986964 (die ersten zwei Varianten, die zum Zeitpunkt der Erstellung dieses Tutorials aufgeführt sind)?
> 2. Was ist die funktionale Konsequenz von rs104894912?
> 3. Was ist die funktionale Konsequenz von rs104894913?
>
> > <solution-title></solution-title>
> >
> > 1. Die klinische Bedeutung ist `benign` (gutartig), was darauf hindeutet, dass sie keinen Einfluss auf das endgültige Proteinprodukt haben.
> > 2. Die Mutation rs104894912 führt zu einer `stop_gained`-Variante, die das resultierende Protein zu früh abbricht und daher `pathogen` ist.
> > 3. Die Mutation rs104894913 führt zu einer `missense_variant`, ebenfalls `pathogen`.
> >
> {: .solution}
{: .question}

Lass uns mehr über die rs104894913-Variante herausfinden.

> <hands-on-title>Erfahre mehr über eine Variante in dbSNP</hands-on-title>
>
> 1. Klicke auf `rs104894913`, um die [dedizierte Seite](https://www.ncbi.nlm.nih.gov/snp/rs104894913) zu öffnen.
> 2. Klicke auf *Klinische Bedeutung*.
>
>    > <question-title></question-title>
>    > 
>    > Welche Art von Erkrankung ist mit der rs104894913-Variante verbunden?
>    > 
>    > > <solution-title></solution-title>
>    > >
>    > > Der Name der assoziierten Krankheit ist "Protan-Defekt". Eine kurze Internetsuche mit Deiner Suchmaschine zeigt, dass dies eine Art von Farbenblindheit ist.
>    > >
>    > {: .solution}
>    {: .question}
>
> 3. Klicke auf die *Variantendetails*.
>
>    > <question-title></question-title>
>    > 
>    > 1. Welche Substitution ist mit dieser Variante verbunden?
>    > 2. Was ist die Auswirkung dieser Substitution in Bezug auf das Codon und die Aminosäure?
>    > 3. An welcher Position des Proteins findet diese Substitution statt?
>    > 
>    > > <solution-title></solution-title>
>    > >
>    > > 1. Die Substitution `NC_000023.10:g.153424319G>A` entspricht der Änderung von Guanin (G) zu Adenin (A).
>    > > 2. Diese Substitution ändert das Codon `GGG`, eine Glycin, in `GAG`, eine Glutamin.
>    > > 3. `p.Gly338Glu` bedeutet, dass die Substitution an Position 338 des Proteins stattfindet.
>    > {: .solution}
>    {: .question}
{: .hands-on}

Was bedeutet diese Substitution für das Protein? Lass uns einen genaueren Blick auf dieses Protein werfen.

## Protein

> <hands-on-title>Öffne Protein</hands-on-title>
>
> 1. Gehe zurück zur [NCBI-Suchseite](https://www.ncbi.nlm.nih.gov/search/all/?term=OPN1LW)
> 2. Klicke auf *Protein* im *Proteine*-Feld
> 3. Klicke auf `OPN1LW – opsin 1, langwellenempfindlich` im oberen Feld
> 
{: .hands-on}

![Screenshot der Opsin 1 NIH Protein-Seite, zwei Hauptbereiche. Der linke Bereich enthält Informationen über das Gen, der rechte eine Inhaltsübersicht und Links zu weiteren Ressourcen](./images/Opsin1NIH.png "Opsin 1 NIH Protein-Seite")

Diese Seite präsentiert erneut einige Daten, die uns bereits vertraut sind (z.B. die Verteilung der Exons entlang der Gensequenz).

> <hands-on-title>Lade die Proteinsequenzen herunter</hands-on-title>
>
> 1. Klicke auf *Datasets herunterladen*
> 2. Wähle 
>    - `Gensequenzen (FASTA)`
>    - `Transkriptsequenzen (FASTA)`
>    - `Proteinsequenzen (FASTA)`
> 3. Klicke auf den *Download*-Button
> 4. Öffne die heruntergeladene ZIP-Datei
{: .hands-on}

> <question-title></question-title>
>
> 1. Was enthält der Ordner?
> 2. Denkst Du, dass sie gute Datenpraktiken angewendet haben?
>
> > <solution-title></solution-title>
> >
> > 1. Der Ordner enthält
> >    - einen Ordner `ncbi_datasets` mit verschiedenen Unterordnern, die einige Datendateien (mehrere Formate) enthalten,
> >    - eine `README.md` (eine Markdown-Datei), die dafür gedacht ist, "mit den Daten zu reisen" und zu erklären, wie die Daten abgerufen wurden, wie die Struktur des Daten-Unterordners aussieht und wo umfangreiche Dokumentationen zu finden sind.
> > 2. Es ist auf jeden Fall eine gute Datenmanagement-Praxis, Benutzer (nicht nur Deine Mitarbeiter, sondern auch Dich selbst in naher Zukunft, wenn Du vergessen hast, woher diese Datei in Deinem Downloads-Ordner stammt) zur Datenquelle und Datenstruktur zu leiten.
> >
> {: .solution}
{: .question}

# Suche nach Sequenzen

Was können wir mit diesen Sequenzen, die wir gerade heruntergeladen haben, machen? Nehmen wir an, wir haben gerade die Transkripte sequenziert, die wir durch ein Experiment isoliert haben – also kennen wir die Sequenz unseres interessanten Objekts, wissen aber nicht, was es ist. Was wir in diesem Fall tun müssen, ist, die gesamte Datenbank der bekannten Sequenzen in der Wissenschaft zu durchsuchen und unser unbekanntes Objekt mit einem Eintrag abzugleichen, der eine Annotation hat. Los geht's.

> <hands-on-title>Suche die Proteinsequenz gegen alle Proteinsequenzen</hands-on-title>
>
> 1. Öffne (mit dem einfachsten Texteditor, den Du installiert hast) die Datei `protein.faa`, die Du gerade heruntergeladen hast.
> 2. Kopiere deren Inhalt
> 3. Öffne BLAST [blast.ncbi.nlm.nih.gov](https://blast.ncbi.nlm.nih.gov/Blast.cgi)
> 4. Klicke auf `Protein BLAST, protein > protein`
> 
>     Wir werden tatsächlich eine Proteinsequenz verwenden, um in einer Proteindatenbank zu suchen.
>
> 5. Füge die Proteinsequenz in das große Textfeld ein
> 6. Überprüfe die restlichen Parameter
> 7. Klicke auf den blauen Button `BLAST`
{: .hands-on}

Diese Phase wird einige Zeit in Anspruch nehmen, denn schließlich gibt es irgendwo einen Server, der alle bekannten Sequenzen mit Deinem Ziel vergleicht. Wenn die Suche abgeschlossen ist, sollte das Ergebnis ähnlich wie unten aussehen:

![Screenshot der BLAST-Ergebnisse, ein großer Kopfbereich oben und die Ergebnisse als Tabelle unten](./images/BLASTresults.png "BLAST Ergebnisse")

> <hands-on-title>Grafische Zusammenfassung der Proteinsequenzen</hands-on-title>
>
> 1. Klicke auf den Tab *Grafische Zusammenfassung*
{: .hands-on}

Wir greifen auf ein Feld mit vielen farbigen Linien zu. Jede Linie repräsentiert einen Treffer Deiner Blast-Suche. Wenn Du auf eine rote Linie klickst, gibt das schmale Feld direkt über dem Feld eine kurze Beschreibung des Treffers.

> <hands-on-title>Beschreibungen der Proteinsequenzen</hands-on-title>
>
> 1. Klicke auf den Tab *Beschreibungen*
{: .hands-on}

> <question-title></question-title>
>
> 1. Was ist der erste Treffer? Ist er zu erwarten?
> 2. Was sind die anderen Treffer? Für welche Organismen?
>
> > <solution-title></solution-title>
> >
> > 1. Der erste Treffer ist unser rotes Opsin. Das ist ermutigend, denn der beste Treffer sollte die Abfrage-Sequenz selbst sein, und Du hast diese Sequenz aus diesem Genseintrag erhalten.
> > 2. Andere Treffer sind andere Opsine. Sie beinhalten Einträge von anderen Primaten (z.B. `Pan troglodytes`).
> >
> >
> {: .solution}
{: .question}

Die Treffer sind für unser rotes Opsin im Menschen, aber auch für andere Opsine in anderen Primaten. Das könnte gewünscht sein, zum Beispiel, wenn wir diese Daten verwenden wollten, um einen phylogenetischen Baum zu erstellen. Wenn wir stattdessen ziemlich sicher sind, dass unsere interessierende Sequenz menschlich ist, könnten wir die Suche auch nur auf menschliche Sequenzen filtern.

> <hands-on-title>BLAST-Suche filtern</hands-on-title>
>
> 1. Klicke auf *Suche bearbeiten*
> 2. Gib `Homo sapiens` im Feld *Organismus* ein
> 3. Klicke auf den blauen Button `BLAST`
{: .hands-on}

Mit dieser neuen Suche finden wir die anderen Opsine (grün, blau, Stäbchenzell-Pigment) in der Liste. Andere Treffer haben weniger übereinstimmende Reste. Wenn du auf eine der farbigen Linien in der *Grafischen Zusammenfassung* klickst, öffnest du weitere Informationen über diesen Treffer, und du kannst sehen, wie ähnlich jeder Treffer dem roten Opsin ist, unserer ursprünglichen Abfragesequenz. Je weiter du in der Liste nach unten gehst, desto weniger haben die nachfolgenden Sequenzen mit dem roten Opsin gemeinsam. Jede Sequenz wird im Vergleich zum roten Opsin in einer sogenannten paarweisen Sequenz-Ausrichtung angezeigt. Später wirst du multiple Sequenz-Ausrichtungen erstellen, aus denen du Beziehungen zwischen Genen ableiten kannst.

> <details-title>Mehr Details zu BLAST-Scores</details-title>
>
> Die Anzeigen enthalten zwei wichtige Maße für die Signifikanz eines Treffers:
>
> 1. Der BLAST-Score - beschriftet als Score (bits)
>
>    Der BLAST-Score gibt die Qualität der besten Ausrichtung zwischen der Abfragesequenz und der gefundenen Sequenz (Treffer) an. Je höher der Score, desto besser die Ausrichtung. Scores werden durch Fehlpaarungen und Lücken in der besten Ausrichtung verringert. Die Berechnung des Scores ist komplex und basiert auf einer Substitutionsmatrix, die jedem Paar von ausgerichteten Resten einen Wert zuweist. Die am häufigsten verwendete Matrix für die Proteinausrichtung ist als BLOSUM62 bekannt.
>
> 2. Der Erwartungswert (beschriftet als Expect oder E)
>
>    Der Erwartungswert E eines Treffers zeigt an, ob der Treffer wahrscheinlich das Ergebnis einer zufälligen Ähnlichkeit zwischen Treffer und Abfrage ist, oder ob er auf eine gemeinsame Abstammung von Treffer und Abfrage zurückzuführen ist.
>
>     > <comment-title>BLAST-Suche filtern</comment-title>
>     > 
>     > Wenn E kleiner als $$10\mathrm{e}{-100}$$ ist, wird es manchmal als 0,0 angegeben.
>     {: .comment}
>
>     Der Erwartungswert gibt an, wie viele Treffer man zufällig erwarten würde, wenn man seine Sequenz in einem zufälligen Genom in der Größe des menschlichen Genoms durchsuchen würde.
>
>      $$E = 25$$ bedeutet, dass du erwarten könntest, 25 Übereinstimmungen in einem Genom dieser Größe zu finden, rein zufällig. Ein Treffer mit $$E = 25$$ ist wahrscheinlich eine zufällige Übereinstimmung und impliziert nicht, dass die Treffersequenz eine gemeinsame Abstammung mit deiner Suchsequenz hat.
>
>      Erwartungswerte um 0,1 könnten biologisch signifikant sein, müssen es aber nicht (andere Tests wären notwendig, um das zu entscheiden).
>
>      Sehr kleine E-Werte hingegen bedeuten, dass der Treffer biologisch signifikant ist. Die Übereinstimmung zwischen deiner Suchsequenz und diesem Treffer muss aus einer gemeinsamen Abstammung der Sequenzen resultieren, da die Wahrscheinlichkeit zu gering ist, dass die Übereinstimmung zufällig entstanden sein könnte. Zum Beispiel bedeutet $$E = 10\mathrm{e}{-18}$$ für einen Treffer im menschlichen Genom, dass man nur eine zufällige Übereinstimmung in einer Milliarde Milliarden verschiedener Genome der gleichen Größe wie das menschliche Genom erwarten würde.
>
>      Der Grund, warum wir glauben, dass wir alle von gemeinsamen Vorfahren abstammen, ist, dass massive Sequenzähnlichkeiten in allen Organismen einfach zu unwahrscheinlich sind, um durch Zufall zu entstehen. Jede Familie von ähnlichen Sequenzen in vielen Organismen muss sich aus einer gemeinsamen Sequenz in einem fernen Vorfahren entwickelt haben.
>
{: .details}

> <hands-on-title>Herunterladen</hands-on-title>
>
> 1. Klicke auf den Tab *Descriptions*
> 2. Klicke auf einen beliebigen Sequenztreffer
> 3. Klicke auf *Download*
> 4. Wähle `FASTA (aligned sequences)`
{: .hands-on}

Es wird eine neue, leicht abweichende Dateityp heruntergeladen: eine ausgerichtete FASTA-Datei. Wenn du möchtest, kannst du sie vor dem nächsten Abschnitt erkunden.

Während wir in den vorherigen Abschnitten dieses Tutorials umfangreich die Weboberflächen der Werkzeuge (genomische Viewer, schnelle Literatursuche, Annotationslesen usw.) verwendet haben, ist diese BLAST-Suche ein Beispiel für einen Schritt, den du vollständig mit Galaxy automatisieren könntest.

> <hands-on-title>Ähnlichkeitssuche mit BLAST in Galaxy</hands-on-title>
>
> 1. Erstelle eine neue Historie für diese Analyse
>
>    {% snippet faqs/galaxy/histories_create_new.md %}
>
> 2. Benenne die Historie um
>
>    {% snippet faqs/galaxy/histories_rename.md %}
>
> 3. Importiere die Proteinsequenz über den Link von [Zenodo]({{ page.zenodo_link }}) oder aus den Galaxy Shared Data Libraries:
>
>    ```text
>    {{ page.zenodo_link }}/files/protein.faa
>    ```
>
>    {% snippet faqs/galaxy/datasets_import_via_link.md %}
>
>    {% snippet faqs/galaxy/datasets_import_from_data_library.md %}
>
> 1. {% tool [NCBI BLAST+ blastp](toolshed.g2.bx.psu.edu/repos/devteam/ncbi_blast_plus/ncbi_blastp_wrapper/2.10.1+galaxy2) %} mit den folgenden Parametern:
>    - *"Protein query sequence(s)"*: `protein.faa`
>    - *"Subject database/sequences"*: `Locally installed BLAST database`
>    - *"Protein BLAST database"*: `SwissProt`
>
>      Um nur nach annotierten Sequenzen in UniProt zu suchen, müssen wir die neueste Version von `SwissProt` auswählen.
>
>    - *"Set expectation value cutoff"*: `0.001`
>    - *"Output format"*: `Tabular (extended 25 columns)` 
>
{: .hands_on}

> <question-title></question-title>
>
> Denkst du, wir sehen genau die gleichen Ergebnisse wie bei unserer ursprünglichen Suche nach `Opsin` auf [www.ncbi.nlm.nih.gov/genome/gdv](https://www.ncbi.nlm.nih.gov/genome/gdv/)? Warum?
>
> > <solution-title></solution-title>
> >
> > Die Ergebnisse könnten ähnlich sein, aber es gibt definitiv einige Unterschiede. Tatsächlich ist nicht nur die Textsuche anders als die Sequenzsuche in Bezug auf die Methode, sondern in dieser zweiten Runde haben wir mit der Sequenz eines spezifischen Opsins begonnen, also einem Ast des gesamten Protein-Stammbaums. Einige Mitglieder der Familie sind einander ähnlicher, sodass dieser Suchtyp die ganze Familie aus einer eher voreingenommenen Perspektive betrachtet.
> >
> {: .solution}
{: .question}

# Mehr Informationen über unser Protein

Bisher haben wir diese Informationen über Opsine untersucht:
- Wie man herausfindet, welche Proteine eines bestimmten Typs in einem Genom existieren,
- Wie man herausfindet, wo sie sich im Genom befinden,
- Wie man mehr Informationen über ein bestimmtes Gen erhält,
- Wie man ihre Sequenzen in verschiedenen Formaten herunterlädt,
- Wie man diese Dateien verwendet, um eine Ähnlichkeitssuche durchzuführen.

Vielleicht bist du neugierig, wie du mehr über die Proteine erfahren kannst, die sie codieren. Wir haben bereits einige Informationen gesammelt (z.B. assoziierte Krankheiten), aber in den nächsten Schritten werden wir sie mit Daten zur Proteinstruktur, Lokalisation, Interaktoren, Funktionen usw. verknüpfen.

Das Portal, um alle Informationen über ein Protein zu erhalten, ist [UniProt](https://www.uniprot.org/). Wir können es über eine Textsuche, oder durch den Gen- oder Proteinnamen durchsuchen. Lass uns wie gewohnt `OPN1LW` als Suchbegriff verwenden.

> <hands-on-title>Suche auf UniProt</hands-on-title>
>
> 1. Öffne [UniProt](https://www.uniprot.org/)
> 2. Gib `OPN1LW` in die Suchleiste ein
> 3. Wähle die Kartenansicht aus
{: .hands-on}

Der erste Treffer sollte `P04000 · OPSR_HUMAN` sein. Bevor du die Seite öffnest, gibt es zwei Dinge zu beachten:

1. Der Name des Proteins `OPSR_HUMAN` ist anders als der Genname, ebenso wie ihre IDs.
2. Dieser Eintrag hat einen goldenen Stern, was bedeutet, dass er manuell annotiert und kuratiert wurde.

> <hands-on-title>Ein Ergebnis auf UniProt öffnen</hands-on-title>
>
> 1. Klicke auf `P04000 · OPSR_HUMAN`
{: .hands-on}

![Screenshot der Kopfzeile der UniProt-Eintragsseite](./images/UniProt.png "UniProt-Seite")

Dies ist eine lange Seite mit vielen Informationen. Wir haben ein [komplettes Tutorial]({% link topics/data-science/tutorials/online-resources-protein/tutorial.md %}) entwickelt, um sie durchzugehen.
