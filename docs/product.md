# Fuori — requisiti di prodotto

## Obiettivo

Fuori aiuta persone già collegate a incontrarsi: mostra eventi pubblici, eventi privati su invito e gli amici che hanno scelto di rendere visibile la propria partecipazione. La prima area è Torino e provincia. La prima app sarà Flutter web/PWA; iOS e Android potranno usare la stessa base in seguito.

Il personaggio personalizzabile è parte centrale dell'identità visiva. La UI di riferimento è in `design/reference/`. La tecnologia e gli asset definitivi dell'avatar sono ancora da scegliere.

## Percorsi principali

1. Una persona crea l'account, sceglie nome e personaggio, legge le regole di visibilità e aggiunge un primo amico tramite link o QR.
2. Le amicizie nascono solo dopo richiesta e accettazione. Non è prevista una ricerca globale delle persone.
3. Un evento contiene luogo, data, orari, organizzatore, descrizione e link utili. Può essere pubblico oppure accessibile tramite invito revocabile. Ogni utente registrato può creare un evento pubblico; soltanto chi lo ha creato può modificarne il contenuto. Le persone possono rispondere con “partecipo”, “forse” o “non partecipo”.
4. Un evento privato compare agli invitati; chi riceve un invito valido vede anche gli altri invitati. I “piani personali” del precedente prototipo non fanno parte del prodotto.
5. Stati brevi come “sto arrivando” o “sono qui” sono opzionali e scadono automaticamente.
6. Profilo e impostazioni permettono di modificare l'avatar, gestire amicizie, visibilità, blocchi e dati personali.

## Regole di privacy

- In un evento pubblico si può vedere il totale dei partecipanti. L'identità di una persona compare solo a chi è suo amico e solo se la sua visibilità lo consente.
- Un evento privato richiede un invito valido. L'organizzatore e gli invitati autenticati possono vedere chi altro è stato invitato; un estraneo non riceve l'elenco. Il semplice possesso di un link non rivela i nomi prima che l'invito sia associato a un account. Un invito revocato non dà più accesso all'evento né all'elenco.
- Presenze e stati hanno scadenza automatica. Non esiste una cronologia pubblica degli spostamenti né una localizzazione continua.
- L'utente può nascondersi, rimuovere un amico, bloccare, segnalare ed eliminare i propri dati.
- Queste regole devono essere applicate dal backend sui dati restituiti, oltre che rappresentate nell'interfaccia. Il riferimento HTML le simula soltanto.

## Primo rilascio utilizzabile

Il primo MVP comprende account, profilo, avatar personalizzabile, inviti e amicizie con accettazione, luoghi iniziali di Torino, eventi pubblici e privati, RSVP, conteggi, stati brevi e impostazioni di privacy. Deve funzionare su web mobile e desktop.

Il primo rilascio è riservato alle persone maggiorenni (18+). La registrazione richiede una casella obbligatoria, inizialmente non selezionata, con il testo «Confermo di avere almeno 18 anni», anche per chi accede con Google. Il backend registra la dichiarazione e impedisce l'uso delle funzioni riservate finché manca. Non raccogliere la data di nascita completa per questo controllo iniziale. La dichiarazione non prova da sola l'età: prima della pubblicazione valutare e documentare se è adeguata ai rischi del servizio.

Restano fuori dal primo MVP chat privata, ricerca globale, geolocalizzazione continua, mappa live, feed infinito, marketplace e matching con sconosciuti.

Il MVP è verificabile con almeno due account reali: un'amicizia nasce tramite richiesta, un evento viene creato e scade correttamente, un estraneo non riceve identità o dati privati non autorizzati, e un invito revocato smette di funzionare.

## Dati e sicurezza

Le entità previste sono utente, richiesta di amicizia, amicizia, luogo, evento, partecipazione, stato e link evento. Inviti e richieste richiedono token non indovinabili, revoca e limiti d'uso. Servono validazione degli URL, limiti alle richieste e strumenti minimi di segnalazione e blocco.

La direzione scelta per il backend è Supabase: Supabase Auth per le sessioni e PostgreSQL per i dati. L'accesso previsto è tramite email e password, con Google come alternativa facoltativa. La registrazione con email richiede la verifica dell'indirizzo; sono previsti recupero password e gestione della sessione. Le configurazioni OAuth e i relativi segreti restano fuori dal client e dalla repository.

Lo schema prevederà una tabella `user_roles` con i ruoli `user` e `admin`, assegnati soltanto da un percorso amministrativo lato server. Il ruolo `admin` è inizialmente solo una struttura dati: non abilita schermate, pulsanti o operazioni. Le eventuali azioni sugli eventi pubblici saranno definite e autorizzate lato server in una fase successiva.

## Decisioni aperte

- Metodo di controllo dell'età adeguato al rilascio 18+ e gestione degli account che risultino appartenere a minori.
- Visibilità delle risposte RSVP individuali negli eventi privati: l'elenco degli invitati è visibile, ma lo stato di risposta di ciascuno non è ancora deciso.
- Asset originali o licenziati per l'avatar, resa 2D o 3D e pipeline su web/mobile.
- Notifiche e moderazione degli eventi pubblici, inclusa la differenza tra nascondere, annullare ed eliminare un evento.
- Elenco iniziale dei luoghi e comportamento degli eventi ricorrenti.
