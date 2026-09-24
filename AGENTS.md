# Indicazioni per gli agenti

Fuori è un'app Flutter in avvio. Il primo target è web/PWA; iOS e Android seguiranno. `docs/product.md` è il riferimento per funzioni e privacy, `docs/design.md` per la UI, `docs/implementation-plan.md` per milestone e criteri di completamento. Consulta le sezioni pertinenti al lavoro; le decisioni indicate come aperte richiedono una scelta di prodotto.

`design/reference/index.html` è il riferimento grafico navigabile. La sua struttura HTML/JS non determina l'architettura Flutter. Mantieni la direzione visiva finché il proprietario non chiede di cambiarla.

## Verifica

- Per il riferimento HTML: `python3 scripts/check.py`; per vederlo: `python3 -m http.server 4173 --bind 127.0.0.1 --directory design/reference`.
- Quando il progetto Flutter esiste, esegui `flutter analyze` e i test Flutter pertinenti. Aggiungi la relativa verifica in CI nella stessa modifica che introduce il progetto.
- Per modifiche alla UI controlla una larghezza di 320–420 px e descrivi il risultato. Per cambi di comportamento aggiorna i documenti pertinenti.
- Mantieni le attività circoscritte, con criteri di accettazione verificabili; riporta verifiche e limiti nel risultato o nella pull request.

## Vincoli

- Il riferimento grafico usa dati dimostrativi. Nessun account, amicizia, invito o regola di visibilità è ancora applicato da un backend. Nell'app reale la privacy va applicata lato server, secondo `docs/product.md`.
- Non inserire dati personali reali, segreti, esportazioni di browser o asset di terzi senza permessi nella repository.
- Gli sprite del riferimento arrivano da Habbo Imaging e appartengono a Habbo/Sulake. Non scaricarli, non committarli e non assumerli come asset distribuibili; leggi `docs/avatar.md` per il limite.
- La repository è destinata a essere pubblica e open source con licenza MIT per il lavoro originale. Questa licenza non concede diritti sugli sprite Habbo o su altri materiali di terzi. Non pubblicare l'app o il sito senza una decisione esplicita del proprietario del progetto.
