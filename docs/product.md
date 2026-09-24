# Fuori — requisiti di prodotto

## Obiettivo

Fuori aiuta persone già collegate a incontrarsi: mostra piani temporanei, eventi e gli amici che hanno scelto di rendere visibile la propria partecipazione. La prima area è Torino e provincia. La prima app sarà Flutter web/PWA; iOS e Android potranno usare la stessa base in seguito.

Il personaggio personalizzabile è parte centrale dell'identità visiva. La UI di riferimento è in `design/reference/`. La tecnologia e gli asset definitivi dell'avatar sono ancora da scegliere.

## Percorsi principali

1. Una persona crea l'account, sceglie nome e personaggio, legge le regole di visibilità e aggiunge un primo amico tramite link o QR.
2. Le amicizie nascono solo dopo richiesta e accettazione. Non è prevista una ricerca globale delle persone.
3. Un piano personale indica luogo, giorno e orari, pubblico scelto e scadenza. Chi lo crea può modificarne la visibilità o eliminarlo.
4. Un evento contiene luogo, data, orari, organizzatore, descrizione e link utili. Può essere pubblico oppure accessibile tramite invito revocabile. Le persone possono rispondere con “partecipo”, “forse” o “non partecipo”.
5. Stati brevi come “sto arrivando” o “sono qui” sono opzionali e scadono automaticamente.
6. Profilo e impostazioni permettono di modificare l'avatar, gestire amicizie, visibilità, blocchi e dati personali.

## Regole di privacy

- In un evento pubblico si può vedere il totale dei partecipanti. L'identità di una persona compare solo a chi è suo amico e solo se la sua visibilità lo consente.
- Un evento privato richiede un invito valido. Il riferimento grafico mostra solo il totale; la possibile lista degli altri invitati è una decisione di prodotto ancora aperta.
- I piani personali del primo rilascio sono privati o visibili agli amici. La visibilità pubblica dei piani non è prevista all'inizio.
- Presenze e stati hanno scadenza automatica. Non esiste una cronologia pubblica degli spostamenti né una localizzazione continua.
- L'utente può nascondersi, rimuovere un amico, bloccare, segnalare ed eliminare i propri dati.
- Queste regole devono essere applicate dal backend sui dati restituiti, oltre che rappresentate nell'interfaccia. Il riferimento HTML le simula soltanto.

## Primo rilascio utilizzabile

Il primo MVP comprende account, profilo, avatar personalizzabile, inviti e amicizie con accettazione, luoghi iniziali di Torino, piani temporanei, eventi pubblici e privati, RSVP, conteggi, stati brevi e impostazioni di privacy. Deve funzionare su web mobile e desktop.

Restano fuori dal primo MVP chat privata, ricerca globale, geolocalizzazione continua, mappa live, feed infinito, marketplace e matching con sconosciuti.

Il MVP è verificabile con almeno due account reali: un'amicizia nasce tramite richiesta, un evento e un piano sono creati e scadono correttamente, un estraneo non riceve identità o dati privati non autorizzati, e un invito revocato smette di funzionare.

## Dati e sicurezza

Le entità previste sono utente, richiesta di amicizia, amicizia, luogo, piano, evento, partecipazione, stato e link evento. Inviti e richieste richiedono token non indovinabili, revoca e limiti d'uso. Servono validazione degli URL, limiti alle richieste e strumenti minimi di segnalazione e blocco.

Il backend e il fornitore di autenticazione devono ancora essere scelti. PostgreSQL e Supabase sono candidati della pianificazione iniziale, non dipendenze già adottate.

## Decisioni aperte

- Modalità di accesso, età minima e trattamento dei minori.
- Regola finale sulla visibilità dei partecipanti a eventi privati.
- Asset originali o licenziati per l'avatar, resa 2D o 3D e pipeline su web/mobile.
- Backend, autenticazione, notifiche e moderazione degli eventi pubblici.
- Elenco iniziale dei luoghi e comportamento dei piani ricorrenti.
