# Avatar Fuori C

Il renderer corrente usa il [catalogo componibile](catalog/README.md), con tutti i modelli approvati su entrambe le basi. I file nella directory superiore sono i precedenti atlanti originali della C e delle due basi, conservati come riferimento artistico; non sono caricati dal renderer corrente.

# Avatar C — versione 1

Asset originali generati con OpenAI ImageGen per Fuori, il 26 settembre 2026.
Direzione artistica scelta dal proprietario: proposta C, personaggio in pixel art con testa squadrata, capelli spettinati, felpa lilla, pantaloni scuri e scarpe crema. Nessuno sprite Habbo è importato in questi file.

La generazione delle varianti usa come riferimento esclusivamente la proposta originale e gli atlanti generati per Fuori. Prompt: mantenere lo stesso personaggio e le proporzioni, produrre otto orientamenti su fondo trasparente; nelle varianti aggiungere solamente occhiali rettangolari oppure una mano alzata in saluto.

- `fuori-c-directions-v1.png`: posa normale.
- `fuori-c-glasses-v1.png`: posa normale con occhiali.
- `fuori-c-wave-v1.png`: posa statica di saluto.
- `fuori-c-wave-glasses-v1.png`: saluto con occhiali.

Ogni atlante ha quattro colonne e due righe. Ordine: tre quarti destro, destra, tre quarti posteriore destro, schiena, tre quarti posteriore sinistro, sinistra, tre quarti sinistro, fronte. Il renderer legge le dimensioni effettive del file.

Gli asset sono forniti con la licenza MIT del progetto; sono output generativi originali, senza asset di terzi forniti come input. Questo non costituisce una garanzia di esclusività o registrabilità dell'immagine. La revisione visiva finale resta parte di M3.

I colori vengono applicati dallo shader `avatar_palette.frag` per gruppi cromatici. Questa prima versione storica cambiava colori e occhiali. È stata sostituita dal catalogo componibile. Le pose sono statiche. Le otto viste sono generate e possono avere piccole differenze di allineamento.

## Basi e pelata — 26 settembre 2026

Aggiunti con ImageGen integrato, usando solo gli originali Fuori e la preview delle due basi approvata dal proprietario:

- `fuori-c-female-v1.png`: base femminile con capelli spettinati.
- `fuori-c-male-bald-v1.png`: base maschile completamente pelata.
- `fuori-c-female-bald-v1.png`: base femminile completamente pelata.

Prompt comune: preservare il dettaglio pixel art della C, felpa lilla, pantaloni scuri e sneakers crema; base femminile con spalle più strette e viso morbido; variante pelata senza capelli né rasatura. Atlante trasparente con 8 colonne (direzioni nell'ordine già indicato) e 4 righe: normale, occhiali, saluto, saluto con occhiali. Alcune viste posteriori/laterali rendono la mano del saluto poco visibile. La scelta della base è estetica e indipendente dai colori.
