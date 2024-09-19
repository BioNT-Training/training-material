
---
layout: tutorial_hands_on
title: Ein Protein auf der UniProt-Seite
level: Einführend
draft: true
zenodo_link: ''
questions:
- Wie kannst du Proteine anhand von Text, Gen- oder Protein-Namen suchen?
- Wie interpretierst du die Informationen oben auf der UniProt-Eintragsseite?
- Welche Arten von Informationen kannst du aus verschiedenen Download-Formaten wie FASTA und JSON erwarten?
- Wie wird die Funktion eines Proteins, wie z.B. Opsine, im Abschnitt „Funktion“ beschrieben?
- Welche strukturierten Informationen findest du in den Abschnitten „Namen und Taxonomie“, „Subzelluläre Lokalisation“, „Krankheit & Varianten“, „PTM/Verarbeitung“?
- Wie kannst du etwas über die Protein-Expression, Interaktionen, Struktur, Familie, Sequenz und ähnliche Proteine erfahren?
- Wie helfen die Tabs „Variant viewer“ und „Feature viewer“ bei der Kartierung von Protein-Informationen entlang der Sequenz?
- Was listet der Tab „Publikationen“ und wie kannst du Publikationen filtern?
- Was ist die Bedeutung der Verfolgung von Eintragsanmerkungsänderungen im Laufe der Zeit?
objectives:
- Durch das Erkunden von Proteineinträgen in UniProtKB, die Funktion, Taxonomie, Struktur, Interaktionen, Varianten und mehr von Proteinen interpretieren.
- Verwende eindeutige Identifikatoren, um Datenbanken zu verknüpfen, Gen- und Protein-Daten herunterzuladen, Sequenzmerkmale zu visualisieren und zu vergleichen.
time_estimation: 1H
key_points:
  - Wie man UniProtKB-Einträge navigiert und umfassende Details über Proteine zugreift, wie deren Funktionen, Taxonomie und Interaktionen.
  - Der Variant und Feature Viewer sind deine Werkzeuge, um Proteinvarianten, Domänen, Modifikationen und andere wichtige Sequenzmerkmale visuell zu erkunden.
  - Erweitere dein Verständnis durch die Nutzung externer Links, um Daten zu verknüpfen und komplexe Beziehungen aufzudecken.
  - Erkunde den Verlaufstab für den Zugriff auf frühere Versionen der Eintragsanmerkungen.
requirements:
-
  type: "internal"
  topic_name: data-science
  tutorials:
  - online-resources-gene
contributions:
  authorship:
    - lisanna
    - bebatut
  funding:
    - biont
---

Wenn du eine biologische Datenanalyse durchführst, kannst du auf einige interessante Proteine stoßen, die du genauer untersuchen möchtest. Aber wie kannst du das machen? Welche Ressourcen gibt es dafür? Und wie navigierst du durch sie?

Das Ziel dieses Tutorials ist es, uns damit vertraut zu machen, indem wir menschliche Opsine als Beispiel verwenden.

> <comment-title></comment-title>
> Dieses Tutorial ist etwas ungewöhnlich: Wir arbeiten nicht in Galaxy, sondern hauptsächlich außerhalb davon, auf den Seiten der [UniProt](https://uniprot.org)-Datenbank.
{: .comment}

> <comment-title></comment-title>
> Dieses Tutorial ist als Fortsetzung des Tutorials ["Ein Gen in verschiedenen Dateiformaten"]({% link topics/data-science/tutorials/online-resources-gene/tutorial.md %}) gedacht, kann aber auch als eigenständiges Modul konsultiert werden.
{: .comment}

Opsine befinden sich in den Zellen deiner Netzhaut. Sie fangen Licht ein und leiten die Signalkette ein, die letztlich zum Sehen führt. Deshalb sind sie, wenn sie beeinträchtigt sind, mit Farbenblindheit und anderen Sehstörungen verbunden.

> <comment-title>Quellen der Informationen aus diesem Tutorial</comment-title>
>
> Das Tutorial, das du konsultierst, wurde hauptsächlich unter Verwendung von UniProtKB-Ressourcen entwickelt, insbesondere dem [Erkunden eines UniProtKB-Eintrags](https://www.uniprot.org/help/explore_uniprotkb_entry)-Tutorial.
> Einige Sätze wurden von dort ohne Änderungen übernommen.
>
> Darüber hinaus wurde das Thema basierend auf Gale Rhodes' [Bioinformatics Tutorial](https://spdbv.unil.ch/TheMolecularLevel/Matics/index.html) ausgewählt. Obwohl das Tutorial nicht mehr Schritt für Schritt befolgt werden kann, da sich die erwähnten Ressourcen im Laufe der Zeit geändert haben, könnte es zusätzliche Einblicke in Opsine bieten, insbesondere wie man strukturelle Modelle von Proteinen basierend auf evolutionären Informationen erstellen kann.
>
{: .comment}

> <agenda-title></agenda-title>
>
> In diesem Tutorial werden wir uns mit folgenden Themen beschäftigen:
>
> 1. TOC
> {:toc}
{: .agenda}

# Die UniProtKB-Eintragsseite

Das Portal, um alle Informationen über ein Protein zu erhalten, ist [UniProtKB](https://www.uniprot.org/). Wir können es durch eine Textsuche oder nach dem Gen- oder Protein-Namen durchsuchen. Versuchen wir es zunächst mit einer Reihe von generischen Stichwörtern, wie `Human opsin`.

> <hands-on-title>Suche nach Human Opsin auf UniProtKB</hands-on-title>
>
> 1. Öffne [UniProtKB](https://www.uniprot.org/)
> 2. Gib `Human opsin` in die Suchleiste ein
> 3. Starte die Suche
>
{: .hands-on}

> <question-title></question-title>
>
> Wie viele Ergebnisse haben wir erhalten?
>
> > <solution-title></solution-title>
> >
> > 410 Ergebnisse (zum Zeitpunkt der Vorbereitung dieses Tutorials)
> >
> {: .solution}
{: .question}

Diese 410 Ergebnisse geben uns das Gefühl, dass wir spezifischer werden müssen (obwohl – Spoiler – unser eigentliches Ziel unter den ersten Treffern ist).

Um spezifisch genug zu sein, schlagen wir vor, einen eindeutigen Identifikator zu verwenden. Aus dem [vorherigen Tutorial]({% link topics/data-science/tutorials/online-resources-gene/tutorial.md %}) wissen wir den Gen-Namen des gesuchten Proteins, `OPN1LW`.

> <hands-on-title>Suche nach OPN1LW auf UniProtKB</hands-on-title>
>
> 1. Gib `OPN1LW` in die obere Suchleiste ein
> 2. Starte die Suche
>
{: .hands-on}

> <question-title></question-title>
>
> 1. Wie viele Ergebnisse haben wir erhalten?
> 2. Was sollten wir tun, um diese Zahl zu verringern?
>
> > <solution-title></solution-title>
> >
> > 1. Mehr als 200 Ergebnisse (zum Zeitpunkt der Vorbereitung dieses Tutorials)
> > 2. Wir müssen klarstellen, wonach wir suchen: Human OPN1LW
> {: .solution}
{: .question}

Wir müssen `Human` hinzufügen, um zu klären, wonach wir suchen.

> <hands-on-title>Suche nach Human OPN1LW auf UniProtKB</hands-on-title>
>
> 1. Gib `Human OPN1LW` in die obere Suchleiste ein
> 2. Starte die Suche
>
{: .hands-on}

> <question-title></question-title>
>
> 1. Wie viele Ergebnisse haben wir erhalten?
> 2. Haben wir ein Ergebnis, das OPN1LW als Gen-Namen enthält?
>
> > <solution-title></solution-title>
> >
> > 1. 7 Ergebnisse (zum Zeitpunkt der Vorbereitung dieses Tutorials)
> > 2. Das erste Ergebnis ist mit `Gene: OPN1LW (RCP)` beschriftet.
> {: .solution}
{: .question}

Das erste Ergebnis, das mit `Gene: OPN1LW (RCP)` gekennzeichnet ist, ist unser Ziel, `P04000 · OPSR_HUMAN`. Bevor wir die Seite öffnen, gibt es zwei Dinge zu beachten:

1. Der Name des Proteins `OPSR_HUMAN` ist anders als der Gen-Name, ebenso wie ihre IDs.
2. Dieser Eintrag hat einen goldenen Stern, was bedeutet, dass er manuell annotiert und kuratiert wurde.

# Untersuchung eines UniProt-Eintrags

> <hands-on-title>Öffne ein Ergebnis auf UniProt</hands-on-title>
>
> 1. Klicke auf `P04000 · OPSR_HUMAN`
{: .hands-on}

![Screenshot der UniProt-Eintragsseite](./images/UniProt.png "UniProt-Seite")

Um durch diese lange Seite zu navigieren, wird das Menü (Navigationsleiste) auf der linken Seite äußerst nützlich sein. Schon allein daraus verstehen wir, dass diese Datenbank Informationen über den Eintrag enthält zu:
- den bekannten Funktionen,
- der Taxonomie,
- dem Standort,
- Varianten und damit verbundenen Krankheiten,
- Posttranslationalen Modifikationen (PTMs),
- der Expression,
- den Interaktionen,
- der Struktur,
- den Domänen und deren Klassifikation,
- den Sequenzen,
- ähnlichen Proteinen.

Die Navigationsleiste bleibt an derselben Stelle auf dem Bildschirm, während du in einem Eintrag nach oben und unten scrollst, sodass du schnell zu interessanten Abschnitten navigieren kannst. Wir werden alle genannten Abschnitte separat konsultieren, aber lass uns zuerst auf die Kopfzeilen links fokussieren.

Oben auf der Seite kannst du die UniProt-Eintragsnummer und den Namen, den Namen des Proteins und des Gens, den Organismus, ob der Proteineintrag manuell von einem UniProt-Kurator überprüft wurde, seine Annotationsbewertung und die Evidenzstufe für seine Existenz sehen.

Unter der Hauptüberschrift findest du eine Reihe von Tabs (*Eintrag*, *Variant viewer*, *Feature viewer*, *Publikationen*, *Externe Links*, *Historie*). Die Tabs ermöglichen es dir, zwischen dem Eintrag, einer grafischen Ansicht der Sequenzmerkmale (Feature viewer), Publikationen und externen Links zu wechseln, aber ignoriere sie für den Moment und bleib im *Eintrag*-Tab.

## Eintrag

Das nächste Menü ist bereits Teil des *Eintrag*-Tabs. Es ermöglicht uns, eine BLAST-Sequenzähnlichkeitssuche auf dem Eintrag durchzuführen, ihn mit all seinen Isoformen auszurichten, den Eintrag in verschiedenen Formaten herunterzuladen oder ihn für später in den Warenkorb zu legen.

> <question-title></question-title>
>
> 1. Welche Formate sind im *Download*-Dropdown-Menü verfügbar?
> 2. Welche Art von Informationen würdest du durch diese Dateiformate herunterladen?
>
> > <solution-title></solution-title>
> > 
> > 1. Die Formate sind: `Text`, `FASTA (kanonisch)`, `FASTA (kanonisch & Isoform`, `JSON`, `XML`, `RDF/XML`, `GFF`
> > 2. Die `FASTA`-Formate sollten dir bereits bekannt sein (nach dem vorläufigen Tutorial) und beinhalten die Proteinsequenz, eventuell mit ihren Isoformen (in diesem Fall handelt es sich um eine Multi-FASTA). Abgesehen davon sind alle anderen Formate nicht protein- oder gar biologiespezifisch. Dies sind allgemeine Dateiformate, die von Websites häufig verwendet werden, um die auf der Seite enthaltenen Informationen darzustellen. Daher würden wir, wenn wir die Datei als `text` (oder noch besser als `json`) herunterladen, dieselbe Annotation herunterladen, auf die wir auf dieser Seite zugreifen, aber in einem Format, das programmatisch einfacher zu parsen ist.
> >
> {: .solution}
{: .question}

Lass uns nun die Eintragsseite Abschnitt für Abschnitt durchgehen.

### Funktion

Dieser Abschnitt fasst die Funktionen dieses Proteins wie folgt zusammen:

Visuelle Pigmente sind die lichtabsorbierenden Moleküle, die das Sehen vermitteln. Sie bestehen aus einem Apoprotein, Opsin, das kovalent an cis-Retinal gebunden ist.

Unabhängig von den Details, die du verstehst (abhängig von deinem Hintergrund), ist dies beeindruckend kurz und präzise angesichts der enormen Menge an Literatur und Studien, die über die Bestimmung einer Proteinfunktion existieren. Auf jeden Fall hat jemand die Arbeit für uns erledigt, und dieses Protein ist bereits vollständig in der Gene Ontology (GO) klassifiziert, die die molekulare Funktion, den biologischen Prozess und die zelluläre Komponente jedes klassifizierten Proteins beschreibt.

GO ist ein perfektes Beispiel für eine Datenbank/Ressource, die auf einem sehr komplexen Wissensuniversum aufbaut und es in einen einfacheren Graphen übersetzt, auf Kosten des Verlusts von Details. Dies hat den großen Vorteil, die Informationen zu organisieren, sie zählbar und analysierbar zu machen und programmatisch zugänglich zu machen, was es letztlich ermöglicht, diese langen Übersichtsseiten und Wissensbasen zu erstellen.

> <question-title></question-title>
>
> 1. Mit welchen molekularen Funktionen ist dieses Protein annotiert?
> 2. Mit welchen zellulären Komponenten ist dieses Protein annotiert?
> 3. Mit welchen biologischen Prozessen ist dieses Protein annotiert?
>
> > <solution-title></solution-title>
> > 
> > 1. Photorezeptor-Protein, G-Protein-gekoppelter Rezeptor
> > 2. Photorezeptor-Scheibenmembran
> > 3. Sensorische Transduktion, Sehen
> >
> {: .solution}
{: .question}

### Namen und Taxonomie

Weitere Beispiele für strukturierte Informationen sind im nächsten Abschnitt zu finden, z. B. in der Taxonomie. Dieser Abschnitt enthält auch andere eindeutige Identifikatoren, die auf dieselbe biologische Einheit oder auf verknüpfte Einheiten verweisen (z. B. assoziierte Krankheiten im Menü `MIM`).

> <question-title></question-title>
>
> 1. Was ist der taxonomische Identifikator, der mit diesem Protein verbunden ist?
> 2. Was ist der Proteom-Identifikator, der mit diesem Protein verbunden ist?
>
> > <solution-title></solution-title>
> > 
> > 1. 9606, also Homo sapiens
> > 2. UP000005640, Bestandteil von Chromosom X
> {: .solution}
{: .question}

### Subzelluläre Lokalisation

Wir wissen bereits, wo sich unser Protein im menschlichen Körper befindet (in der Netzhaut, wie in der Funktionsübersicht angegeben), aber wo befindet es sich in der Zelle?

> <question-title></question-title>
>
> 1. Wo befindet sich unser Protein in der Zelle?
> 2. Ist dies konsistent mit der zuvor beobachteten GO-Annotation?
>
> > <solution-title></solution-title>
> > 
> > 1. Der Abschnitt erklärt, dass es sich um ein „Mehrfach-pass-Membranprotein“ handelt, was bedeutet, dass es ein Protein ist, das in die Zellmembran eingefügt ist und diese mehrmals durchquert.
> > 2. Die GO-Annotation oben erwähnt, dass wir uns insbesondere auf die Membran der Photorezeptorzelle beziehen.
> {: .solution}
{: .question}

Der Abschnitt zur subzellulären Lokalisation enthält auch einen *Feature*-Bereich, in dem die Abschnitte entlang der Proteinsequenz detailliert beschrieben sind, die in die Membran eingefügt sind (Transmembran) und welche nicht (Topologische Domäne).

> <question-title></question-title>
>
> Wie viele Transmembran-Domänen und topologische Domänen gibt es?
>
> > <solution-title></solution-title>
> > 
> > 8 Transmembran- und 7 topologische Domänen
> {: .solution}
{: .question}

### Krankheit & Varianten

Wie wir aus dem vorherigen Tutorial wissen, ist dieses Gen/Protein mit mehreren Krankheiten assoziiert. Dieser Abschnitt beschreibt diese Assoziationen auch unter Angabe der spezifischen Varianten, die als krankheitsbezogen identifiziert wurden.

> <question-title></question-title>
>
> Welche Arten von wissenschaftlichen Studien ermöglichen die Bewertung der Assoziation einer genetischen Variante mit Krankheiten?
>
> > <solution-title></solution-title>
> > 
> > Drei gängige Methoden zur Bewertung der Assoziation einer genetischen Variante mit einer Krankheit sind:
> > 
> > - Genomweite Assoziationsstudien (GWAS)
> >
> >   GWAS werden häufig verwendet, um häufige genetische Varianten zu identifizieren, die mit Krankheiten assoziiert sind. Sie beinhalten das Scannen des gesamten Genoms einer großen Anzahl von Individuen, um Varianten zu identifizieren, die mit einer bestimmten Krankheit oder einem bestimmten Merkmal in Verbindung stehen.
> > 
> > - Fall-Kontroll-Studien
> >
> >   Fall-Kontroll-Studien vergleichen häufig Personen mit einer Krankheit mit solchen ohne sie und konzentrieren sich auf das Vorhandensein oder die Häufigkeit spezifischer genetischer Varianten in beiden Gruppen.
> > 
> > - Familienstudien
> >
> >   Familienbasierte Studien analysieren genetische Varianten innerhalb von Familien, in denen mehrere Mitglieder von einer Krankheit betroffen sind. Durch das Studium der Vererbungsmuster genetischer Varianten und deren Assoziation mit der Krankheit innerhalb der Familie können Forscher potenzielle krankheitsassoziierte Gene identifizieren.
> > 
> > Diese Art von Studien würde eine umfangreiche Nutzung von Dateitypen zur Verwaltung von Genomdaten beinhalten, wie z. B.: SAM (Sequence Alignment Map), BAM (Binary Alignment Map), VCF (Variant Calling Format) usw.
> >
> {: .solution}
{: .question}

Dieser Abschnitt enthält auch einen *Feature*-Bereich, in dem die natürlichen Varianten entlang der Sequenz abgebildet sind. Weiter unten wird auch darauf hingewiesen, dass eine detailliertere Ansicht der Merkmale entlang der Sequenz im Tab *Krankheit & Varianten* zu finden ist, aber lassen wir diesen für den Moment geschlossen.

### PTM/Verarbeitung

Eine posttranslationale Modifikation (PTM) ist ein kovalentes Verarbeitungsvorgang, der durch proteolytische Spaltung oder durch das Hinzufügen einer modifizierenden Gruppe an eine Aminosäure entsteht.

> <question-title></question-title>
>
> Was sind die posttranslationalen Modifikationen für unser Protein?
>
> > <solution-title></solution-title>
> > 
> > Kette, Glykosylierung, Disulfidbrücke, modifizierter Rest
> {: .solution}
{: .question}

### Expression

Wir wissen bereits, wo sich das Protein in der Zelle befindet, aber für menschliche Proteine haben wir oft Informationen darüber, wo es sich im menschlichen Körper befindet, d. h. in welchen Geweben. Diese Informationen stammen aus dem Human [ExpressionAtlas](https://www.ebi.ac.uk/gxa/home) oder ähnlichen Ressourcen.

> <question-title></question-title>
>
> In welchem Gewebe ist das Protein zu finden?
>
> > <solution-title></solution-title>
> > 
> > Die drei Farbpigmente befinden sich in den Zapfen-Photorezeptorzellen.
> {: .solution}
{: .question}

### Interaktion

Proteine erfüllen ihre Funktion durch ihre Interaktion mit der Umgebung, insbesondere mit anderen Proteinen. Dieser Abschnitt listet die Interaktionspartner unseres interessierenden Proteins in einer Tabelle auf, die wir auch nach subzellulärer Lokalisation, Krankheiten und Interaktionstyp filtern können.

Die Quelle dieser Informationen sind Datenbanken wie STRING, und die Eintragsseite für unser Protein ist direkt aus diesem Abschnitt verlinkt.

> <hands-on-title>Suche nach Human OPN1LW auf UniProtKB</hands-on-title>
>
> 1. Klicke auf den [STRING-Link](https://string-db.org/network/9606.ENSP00000358967) in einem anderen Tab
>
{: .hands-on}

> <question-title></question-title>
>
> 1. Wie viele verschiedene Dateiformate kannst du dort herunterladen?
> 2. Welche Art von Informationen wird in jeder Datei enthalten sein?
>
> > <solution-title></solution-title>
> > 
> > 
### Struktur

Interessierst du dich für die komplizierten dreidimensionalen Strukturen von Proteinen? Der Abschnitt *Struktur* auf der UniProtKB-Eintragsseite ist dein Zugang zur faszinierenden Welt der Proteinarchitektur.

In diesem Abschnitt findest du Informationen über experimentell bestimmte Proteinstrukturen. Diese Strukturen liefern wichtige Einblicke in die Funktionsweise von Proteinen und ihre Wechselwirkungen mit anderen Molekülen. Du wirst interaktive Ansichten der Proteinstruktur entdecken, die du direkt innerhalb des UniProtKB-Eintrags erkunden kannst. Dieses Feature bietet eine ansprechende Möglichkeit, durch die Domänen des Proteins, Bindungsstellen und andere funktionelle Regionen zu navigieren. Indem du dich in den Abschnitt *Struktur* vertiefst, wirst du ein tieferes Verständnis für die physikalischen Grundlagen der Proteinfunktion gewinnen und die Fülle an Informationen entdecken, die strukturelle Daten freisetzen können.

> <question-title></question-title>
>
> 1. Welche Variante ist mit Farbenblindheit assoziiert?
> 2. Kannst du diese spezifische Aminosäure in der Struktur finden?
> 3. Kannst du eine Vermutung anstellen, warum diese Mutation störend ist?
>
> > <solution-title></solution-title>
> > 
> > 1. Im Abschnitt *Krankheit & Varianten* finden wir heraus, dass die Änderung von Glycin (G) zu Glutaminsäure (E) an Position 338 entlang der Proteinsequenz mit Farbenblindheit assoziiert ist.
> > 2. Im Struktur-Viewer können wir das Molekül drehen und die Maus über die Struktur bewegen, um die Aminosäure an Position 338 zu finden. Es könnte einige Zeit dauern, den Verlauf durch die mehreren helikalen Anordnungen dieser Strukturen zu verfolgen. Das Glycin an Position 338 befindet sich nicht in einer Helix, sondern in einer Schleife, kurz vor einem Bereich mit geringer Vorhersagesicherheit in der Struktur.
> > 3. Basierend auf den bisher gesammelten Informationen könnten wir eine Hypothese darüber aufstellen, warum diese Mutation störend ist. Es befindet sich nicht in einer Helix (normalerweise sind Helices in transmembranen Proteinen in der Membran eingebettet), daher befindet es sich wahrscheinlich in einer der größeren Domänen, die aus der Membran herausragen, entweder in oder aus der Zelle. Diese Mutation stört wahrscheinlich nicht die Struktur in den intramembranen Segmenten, sondern eher eine der funktionalen Domänen. Wenn du tiefer graben möchtest, kannst du überprüfen, ob dies das extra- oder intrazelluläre Segment im **Feature viewer** ist.
> >
> {: .solution}
{: .question}

Woher stammen die Informationen im Struktur-Viewer?

> <hands-on-title>Suche nach Human OPN1LW auf UniProtKB</hands-on-title>
>
> 1. Klicke auf das Download-Symbol unter der Struktur
> 2. Überprüfe die heruntergeladene Datei
>
{: .hands-on}

Dies ist eine PDB (Protein Data Bank)-Datei, die es dir ermöglicht, die Anordnung der Atome und Aminosäuren des Proteins zu visualisieren und zu analysieren.

Es gibt jedoch keinen Hinweis auf die PDB-Datenbank in den Links unter den *3D-Struktur-Datenbanken*. Stattdessen verweist der erste Link auf die AlphaFoldDB. Die AlphaFold-Datenbank ist eine umfassende Ressource, die vorhergesagte 3D-Strukturen für eine Vielzahl von Proteinen bereitstellt. Durch den Einsatz von Deep-Learning-Techniken und evolutionären Informationen sagt AlphaFold die räumliche Anordnung von Atomen innerhalb eines Proteins genau vorher und trägt so zum Verständnis der Proteinfunktion und -interaktionen bei.

Daher handelt es sich um eine *Vorhersage* der Struktur und nicht um eine experimentell validierte Struktur. Dies ist der Grund, warum es nach Vertrauensniveau gefärbt ist: Die Abschnitte in Blau sind diejenigen mit einem hohen Vertrauenswert, also die, für die die Vorhersage sehr zuverlässig ist, während die orangefarbenen Abschnitte weniger zuverlässig sind oder eine unordentliche (flexiblere und beweglichere) Struktur haben. Trotzdem wird diese Information in einer PDB-Datei dargestellt, da sie immer noch strukturell ist.

### Familie und Domänen

Der Abschnitt *Familie und Domänen* auf der UniProtKB-Eintragsseite bietet einen umfassenden Überblick über die evolutionären Beziehungen und funktionalen Domänen innerhalb eines Proteins. Dieser Abschnitt bietet Einblicke in die Zugehörigkeit des Proteins zu Proteinfamilien, Superfamilien und Domänen und beleuchtet seine strukturellen und funktionalen Eigenschaften.

Der *Feature*-Bereich bestätigt tatsächlich, dass mindestens eine der beiden Domänen, die aus der Membran herausragen (die N-terminale), unstrukturiert ist. Dieser Bereich enthält normalerweise Informationen über konservierte Regionen, Motive und wichtige Sequenzmerkmale, die zur Rolle des Proteins in verschiedenen biologischen Prozessen beitragen. Der Abschnitt bestätigt erneut, dass wir ein Transmembranprotein betrachten und bietet Links zu mehreren Ressourcen zu phylogenetischen Daten, Proteinfamilien oder Domänen, die uns bei der Analyse helfen, wie Proteine gemeinsame Vorfahren teilen, sich entwickeln und spezialisierte Funktionen erwerben.

### Sequenz

All diese Informationen über die Evolution, Funktion, Struktur des Proteins sind letztlich in seiner Sequenz codiert. Auch in diesem Abschnitt haben wir die Möglichkeit, die FASTA-Datei herunterzuladen, die diese Sequenz transkribiert, sowie auf die Quelle dieser Daten zuzugreifen: die genomischen Sequenzierungsexperimente, die diese Daten erhoben haben. Dieser Abschnitt berichtet auch, wann Isoformen entdeckt wurden.

> <question-title></question-title>
>
> Wie viele potenzielle Isoformen sind diesem Eintrag zugeordnet?
>
> > <solution-title></solution-title>
> >
> > 1: H0Y622
> >
> {: .solution}
{: .question}

### Ähnliche Proteine

Der letzte Abschnitt der UniProt-Eintragsseite listet ähnliche Proteine auf (dies ist im Wesentlichen das Ergebnis eines Clusterings mit Identitätsschwellen von 100%, 90% und 50%).

> <question-title></question-title>
>
> 1. Wie viele ähnliche Proteine gibt es bei 100% Identität?
> 2. Wie viele ähnliche Proteine gibt es bei 90% Identität?
> 3. Wie viele ähnliche Proteine gibt es bei 50% Identität?
>
> > <solution-title></solution-title>
> >
> > 1. 0
> > 2. 83
> > 3. 397
> >
> {: .solution}
{: .question}

Wie du beim Durchsehen dieser Seite vielleicht schon bemerkt hast, besteht ein Großteil der Verarbeitung biologischer Daten über ein Protein tatsächlich darin, verschiedene Arten von Informationen entlang der Sequenz zu kartieren und zu verstehen, wie sie sich gegenseitig beeinflussen. Eine visuelle Kartierung (und eine Tabelle mit denselben Informationen) wird durch die beiden alternativen Tabs zur Ansicht dieses Eintrags bereitgestellt, nämlich den *Variant viewer* und den *Feature viewer*.

## Variant viewer

> <hands-on-title>Variant viewer</hands-on-title>
>
> 1. Klicke auf den *Variant viewer*-Tab
>
{: .hands-on}

Der *Variant viewer* kartiert alle bekannten alternativen Versionen dieser Sequenz. Für einige davon ist die Wirkung (pathogen oder gutartig) bekannt, für andere nicht.

> <question-title></question-title>
>
> Wie viele Varianten sind wahrscheinlich pathogen?
>
> > <solution-title></solution-title>
> >
> > Durch das Herauszoomen im Variant-Viewer sehen wir, dass wir 5 rote Punkte haben, also 5 Varianten, die wahrscheinlich pathogen sind.
> >
> {: .solution}
{: .question}

Die hohe Anzahl an Varianten, die du in diesem Abschnitt findest, deutet darauf hin, dass „Proteinsequenzen“ (ebenso wie Gensequenzen, Proteinstrukturen usw.) tatsächlich weniger feste Entitäten sind, als man vielleicht denkt.

## Feature viewer

> <hands-on-title>Feature viewer</hands-on-title>
>
> 1. Klicke auf den *Feature viewer*-Tab
>
{: .hands-on}

Der *Feature viewer* ist im Grunde eine zusammengeführte Version aller *Feature*-Bereiche, die wir auf der *Eintrags*-Seite gefunden haben, einschließlich *Domänen & Sites*, *Molekülverarbeitung*, *PTMs*, *Topologie*, *Proteomik*, *Varianten*. Wenn du im Viewer auf ein beliebiges Feature klickst, wird der entsprechende Bereich in der Struktur fokussiert, ebenso wie die interessierende Variante.

> <hands-on-title>Variant viewer</hands-on-title>
>
> 1. Erweitere den Abschnitt *Varianten*
> 2. Zoome heraus
> 3. Klicke auf unsere Variante von Interesse (den roten Punkt an Position 338)
>
{: .hands-on}

> <question-title></question-title>
>
> Was ist die Topologie an dieser Position?
>
> > <solution-title></solution-title>
> >
> > Eine topologische zytoplasmatische Domäne
> >
> {: .solution}
{: .question}

Schließlich werfen wir noch einen kurzen Blick auf die anderen Tabs.

## Publikationen

> <hands-on-title>Publikationen</hands-on-title>
>
> 1. Klicke auf den *Publikationen*-Tab
>
{: .hands-on}

Der Tab *Publikationen* listet wissenschaftliche Publikationen auf, die sich auf das Protein beziehen. Diese werden durch die Zusammenführung einer vollständig kuratierten Liste in UniProtKB/Swiss-Prot und automatisch importierten Veröffentlichungen gesammelt. In diesem Tab kannst du die Publikationsliste nach Quelle und Kategorien filtern, die auf der Art der Daten basieren, die eine Publikation über das Protein enthält (wie Funktion, Interaktion, Sequenz usw.), oder nach der Anzahl der Proteine, die in der entsprechenden Studie beschrieben werden ("kleine Skala" vs. "große Skala").

> <question-title></question-title>
>
> 1. Wie viele Publikationen sind mit diesem Protein verbunden?
> 2. Wie viele Publikationen enthalten Informationen über seine Funktion?
>
> > <solution-title></solution-title>
> >
> > 1. 57
> > 2. 23
> >
> {: .solution}
{: .question}

## Externe Links

> <hands-on-title>Externe Links</hands-on-title>
>
> 1. Klicke auf den *Externe Links*-Tab
>
{: .hands-on}

Der Tab *Externe Links* fasst alle Verweise auf externe Datenbanken und Informationsquellen zusammen, die wir in jedem Abschnitt der Eintragsseite gefunden haben. Die Linktexte geben häufig die eindeutigen Identifikatoren an, die dieselbe biologische Einheit in anderen Datenbanken darstellen. Um ein Gefühl für diese Komplexität zu bekommen, sieh dir das folgende Bild an (das bereits teilweise veraltet ist).

![Eine Grafik, die zeigt, wie alle verschiedenen Datenbanken durch eindeutige IDs miteinander verbunden sind, wobei Hauptknoten DBs sind und Pfeile sie mit den IDs (Nebenknoten) verbinden, die sie berichten. Die Karte ist besonders um den UniProt-Eintragsnamen, die Gen-ID und die Ensembl-Gen-ID herum sehr überladen.](./images/complexDB.jpeg "Beste Darstellung der komplexen ID-Verknüpfung: bioDBnet-Netzwerkdiagramm - [Quelle](https://biodbnet-abcc.ncifcrf.gov/dbInfo/netGraph.php)")

## Historie

Schließlich ist der Tab *Historie* auch interessant. Er berichtet und macht alle früheren Versionen der Annotations dieses Eintrags verfügbar, d. h. die „Entwicklung“ seiner Annotation, die in diesem Fall bis ins Jahr 1988 zurückreicht.

> <question-title></question-title>
>
> War dieser Eintrag jemals nicht manuell annotiert?
>
> > <solution-title></solution-title>
> >
> > Um diese Frage zu beantworten, kannst du in der Tabelle zurückscrollen und die Spalte `Datenbank` überprüfen. War dieser Eintrag jemals in TrEMBL anstatt in Swiss-Prot? Nein, dieser Eintrag wurde seit seinem Beginn manuell annotiert.
> >
> {: .solution}
{: .question}
