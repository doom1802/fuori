# Piano di implementazione

Fuori nasce come app Flutter. Il primo rilascio è web/PWA; iOS e Android seguiranno sulla stessa base. Il [riferimento HTML](../design/reference/index.html) definisce la direzione visiva, non l'architettura. [Prodotto](product.md) e [design](design.md) restano i riferimenti per requisiti e interfaccia.

Questo piano ordina il lavoro, senza fissare date. Supabase è la direzione scelta per backend e autenticazione; le decisioni di prodotto ancora aperte restano indicate nelle milestone. Ogni milestone si chiude con una funzione verificabile. Le attività più piccole vanno in issue con contesto, criteri di accettazione e comandi di verifica; ogni modifica passa da una pull request e dai controlli in CI.

## M0 — repository pubblica pronta al lavoro

**Risultato:** una base open source chiara, senza versioni storiche del riferimento né materiale privato.

- Pubblicare repository, licenza per il lavoro originale, README, indicazioni per agenti e modelli di issue/PR.
- Tenere un solo riferimento grafico; escludere archivi locali, segreti e sprite di terzi.
- Far eseguire in CI il controllo del riferimento HTML.

**Completata quando:** la repository pubblica contiene solo i file previsti, la licenza è visibile su GitHub e il workflow passa su `main` e nelle pull request.

## M1 — app Flutter e linguaggio visivo

**Risultato:** la prima app eseguibile, con dati dimostrativi espliciti. Il progetto Flutter sta nella radice della repository; configurazione e migrazioni Supabase avranno una propria directory quando inizierà l'integrazione.

- Generare il progetto Flutter per web e predisporre la base condivisa per iOS/Android.
- Tradurre colori, tipografia, componenti e navigazione **In giro**, **Eventi**, **Amici**, **Il mio io** dal riferimento aggiornato. Separare widget, modelli e dati dimostrativi; definire le interfacce dei repository solo per i flussi realizzati, con implementazioni dimostrative sostituibili. Il percorso QR e la distinzione fra eventi pubblici e privati devono restare navigabili già nell'anteprima, con simulazioni dichiarate.
- Usare un segnaposto originale per l'avatar: gli sprite Habbo non entrano negli asset dell'app.
- Aggiungere `flutter analyze`, `flutter test` e compilazione web alla CI nella stessa modifica che introduce Flutter; versionare il lockfile.

**Completata quando:** `flutter run -d chrome` apre le quattro sezioni, la UI è leggibile a 320 e 420 px e su desktop, i controlli Flutter passano localmente e in CI, e il README descrive l'avvio reale.

## M2 — identità e regole di accesso

**Decisioni già prese:** primo rilascio 18+, Supabase Auth con email/password e accesso Google facoltativo, come indicato in [prodotto](product.md).

- Creare account e profilo modificabile; implementare verifica email, recupero password e accesso Google. Richiedere in entrambi i percorsi di registrazione la casella obbligatoria 18+, inizialmente non selezionata, senza raccogliere la data di nascita per questo controllo iniziale. Registrare la dichiarazione lato server e impedire l'uso delle funzioni riservate finché manca. Definire lo schema iniziale dei dati e le regole di autorizzazione lato server.
- Prevedere nello schema la tabella `user_roles` con i ruoli `user` e `admin`, senza concedere ancora al ruolo `admin` azioni o interfacce dedicate. Impedire l'assegnazione del ruolo dal client.
- Distinguere nell'interfaccia caricamento, assenza di dati, errore e sessione scaduta.
- Documentare una matrice di accesso per proprietario, amico, estraneo e persona bloccata, da riutilizzare nei test delle milestone successive.

**Completata quando:** due account separati vedono solo i propri dati privati; le richieste dirette all'API non aggirano le regole; registrazione con dichiarazione 18+ e verifica email, accesso email/password e Google, logout, recupero password e recupero della sessione funzionano su web; un utente non può assegnarsi il ruolo `admin`.

## M3 — inviti e amicizie

- Implementare invito tramite link o QR, richiesta, accettazione, rifiuto, revoca e scadenza.
- Consentire rimozione dell'amicizia e blocco. Non introdurre ricerca globale delle persone.
- Limitare tentativi e uso dei token; mostrare messaggi chiari per link scaduti o revocati.

**Completata quando:** due account diventano amici solo dopo accettazione; un link revocato, scaduto o già consumato non crea amicizie; un estraneo e una persona bloccata non leggono dati riservati.

## M4 — luoghi iniziali

- Inserire un piccolo elenco iniziale di luoghi di Torino e provincia, con dati e provenienza controllati.
- Definire i luoghi da usare nei moduli di creazione evento e verificarne la provenienza.

**Completata quando:** l'elenco di luoghi iniziali è disponibile nel percorso di creazione evento, verificato e documentato.

## M5 — eventi e partecipazioni

**Decisioni già prese:** ogni utente registrato può creare eventi pubblici; soltanto il creatore può modificarli. L'organizzatore e gli invitati autenticati vedono l'elenco degli invitati agli eventi privati.

**Decisioni prima di iniziare:** visibilità delle risposte RSVP individuali negli eventi privati e moderazione degli eventi pubblici.

- Creare eventi pubblici e privati con luogo, data, organizzatore, descrizione e link validati.
- Limitare la modifica del contenuto dell'evento al suo creatore, con verifica lato server.
- Gestire inviti revocabili e risposte **partecipo**, **forse**, **non partecipo**.
- Mostrare i conteggi previsti dal prodotto; negli eventi pubblici rivelare l'identità dei partecipanti solo in base ad amicizia e impostazioni. Negli eventi privati mostrare gli invitati solo all'organizzatore e agli account autenticati con invito valido. Applicare entrambe le regole lato server.

**Completata quando:** con organizzatore, due invitati ed estraneo si verificano conteggi, identità, accesso all'evento privato e revoca dell'invito sia nella UI sia nelle risposte API; un utente diverso dal creatore non può modificare un evento pubblico neppure tramite API.

## M6 — presenza, privacy e gestione dati

- Aggiungere stati brevi opzionali, con scadenza automatica e senza tracciamento continuo.
- Permettere di nascondersi, modificare la visibilità, bloccare e segnalare.
- Rendere disponibili richiesta o eliminazione dei propri dati secondo le decisioni di prodotto e gli obblighi applicabili.

**Completata quando:** la revoca di visibilità si riflette subito nelle risposte server; stati scaduti e dati eliminati non sono accessibili; blocco e segnalazione hanno esiti verificabili.

## M7 — rilascio web/PWA

**Decisioni prima di iniziare:** asset finali dell'avatar, dominio, ambienti, policy privacy, metodo di controllo dell'età e strategia di gestione degli incidenti.

- Sostituire il segnaposto con asset originali o distribuiti con permesso adeguato; registrare provenienza e licenza.
- Verificare installazione PWA, accessibilità, prestazioni e comportamento su telefono e desktop.
- Completare controlli di sicurezza, gestione dei segreti, monitoraggio essenziale e percorso di rollback.

**Completata quando:** il percorso account → amicizia → evento → RSVP funziona con account reali, le regole di privacy sono provate lato server e l'app può essere distribuita senza gli sprite Habbo.

## Dopo il primo rilascio

Preparare iOS e Android dalla base Flutter condivisa, con verifiche e distribuzione specifiche. Chat, ricerca globale, mappa live, feed infinito e matching con sconosciuti restano fuori dall'MVP, come indicato in [prodotto](product.md).

## Regola per le attività degli agenti

Una issue deve indicare la milestone, il risultato osservabile, i file o i flussi pertinenti, i criteri di accettazione e una verifica ripetibile. Se una decisione di prodotto è ancora aperta, l'agente documenta opzioni e impatto prima di introdurre una dipendenza o cambiare le regole di privacy. La pull request riporta ciò che è stato verificato e i limiti rimasti.
