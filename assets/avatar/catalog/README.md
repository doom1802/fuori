# Guardaroba componibile C — v1

Asset originali prodotti per Fuori il 26 settembre 2026 con OpenAI ImageGen integrato. Input: esclusivamente la C e le tavole originali approvate dal proprietario, senza sprite Habbo o altri asset di terzi. Si applica la licenza MIT del progetto; gli output generativi non sono accompagnati da una garanzia di esclusività.

## Catalogo approvato

| Categoria | Modelli, nell'ordine delle righe |
|---|---|
| Vestiti | V1 felpa, V2 t-shirt, V3 bomber, V4 denim, V5 maglione a righe, V6 camicia aperta, V7 giacca sportiva, V8 cardigan |
| Capelli | H1 spettinati, H2 corti sfumati, H3 ricci, H4 pelata, H5 lunghi mossi, H6 coda alta, H7 treccine, H8 rasati |
| Pantaloni | P1 scuri, P2 jeans, P3 cargo, P4 joggers, P5 shorts, P6 larghi, P7 gonna midi, P8 salopette |
| Scarpe | S1 sneakers, S2 sneakers alte, S3 skate, S4 running, S5 anfibi, S6 Chelsea boots, S7 mocassini, S8 sandali |
| Extra | E1 occhiali rettangolari, E2 tondi, E3 da sole, E4 cappellino, E5 berretto, E6 cuffie, E7 zainetto, E8 tracolla |

Entrambe le basi condividono il catalogo. Si può scegliere un modello di occhiali (E1–E3), un cappello (E4–E5), e aggiungere indipendentemente cuffie (E6), zainetto (E7) e tracolla (E8); premere un elemento selezionato lo rimuove.

## Prompt e file

Prompt comune: produrre esclusivamente elementi indossabili separati su PNG trasparente nello stile pixel art della C, con contorni scuri e ombreggiatura contenuta. Otto colonne per orientamento: tre quarti destro, destra, tre quarti posteriore destro, schiena, tre quarti posteriore sinistro, sinistra, tre quarti sinistro, fronte. Otto righe per i modelli sopra elencati. Non includere figure complete, etichette, loghi, sfondi o pavimenti. Il prompt di H4 richiede una riga vuota: la testa pelata è nella base.

- `body-v1.png`: pezzi visibili della pelle, testa pelata, mani e gambe. Quattro righe: maschile, femminile, maschile in saluto, femminile in saluto. La base femminile ha il viso più morbido; il renderer adatta la larghezza degli indumenti.
- `hair-v1.png`, `tops-v1.png`, `bottoms-v1.png`, `footwear-v1.png`, `extras-v1.png`: elementi del catalogo.
- `tops-wave-v1.png`: stessi vestiti con una manica sollevata in saluto.
- `index-v1.json`: rettangoli sorgente misurati tramite il canale alfa, escludendo i frammenti degli elementi vicini che sconfinano nelle celle. Le mani sono indicizzate separatamente. Il renderer posiziona gli elementi in uno spazio comune 128×256. Le scarpe sono elementi singoli e vengono disegnate per entrambi i piedi.

La generazione non garantisce una griglia di registrazione perfetta: i rettangoli sono indicizzati separatamente e gli elementi allineati in Flutter, senza modificare i PNG. `scripts/index_avatar_atlases.py` ricalcola soltanto i metadati usando Pillow; non scrive immagini. Il renderer campiona al centro dei pixel, elimina le frange semitrasparenti ed applica i colori quando richiesti. La prima opzione di colore conserva il disegno originale.

I capelli sono disegnati dietro la testa e davanti alla fronte, proteggendo occhi, guance e mandibola nelle viste frontali e laterali. Gli occhiali seguono l'altezza degli occhi per ogni orientamento. Collo e vestiti condividono l'aggancio superiore; le mani seguono i bordi delle maniche anche di profilo e in saluto. La pelle delle gambe è esposta solo con shorts e gonna. Il taglio rasato aderisce alla testa. Un test sui pixel renderizzati verifica che ogni acconciatura conservi la zona degli occhi sulle due basi nelle cinque viste che mostrano il volto.

Le pose sono statiche. La resa degli incastri fra modelli è da rifinire con la revisione visiva del proprietario; le verifiche automatiche di selezione e persistenza non sostituiscono il controllo artistico delle combinazioni.

Il raccordo fra mano e manica è completato dal renderer con avambracci ancorati alle maniche, per la t-shirt e la posa di saluto. Gli extra del viso vengono nascosti nelle viste posteriori; lo zainetto viene disegnato davanti al busto quando visto da dietro.
