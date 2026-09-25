# Direzione grafica

Il riferimento visivo corrente è [l'interfaccia navigabile](../design/reference/index.html). È la base per portare la UI in Flutter; la grafica piace nella sua forma attuale e andrà mantenuta durante il primo lavoro di implementazione.

## Struttura

- Una colonna mobile larga circa 320–420 px, leggibile anche su desktop.
- Quattro destinazioni principali: **In giro**, **Eventi**, **Amici**, **Il mio io**.
- Nella Home, evento in evidenza, lista per giorno e una sola azione principale per creare un evento.
- Nella settimana, distinguere esplicitamente gli **eventi pubblici** dagli **eventi privati su invito**; mostrare gli elementi di ogni giorno in ordine di ora. Il filtro **Tutti / Parteciperò / Forse** usa la risposta dell'utente per entrambi i tipi di evento. La locandina dimostrativa deve corrispondere al titolo dell'evento mostrato.
- La schermata Amici e il pulsante QR della testata aprono entrambi il percorso d'invito. La vista QR si apre su **Show**; **Scan** è raggiungibile con uno scorrimento orizzontale o con il selettore in basso. **Condividi** nella barra alta apre direttamente la condivisione del link, con copia come ripiego. La fotocamera si attiva solo su richiesta. Nell'anteprima Flutter le richieste restano simulate; con account reali saranno gestite lato server.
- Gerarchia chiara fra numero totale dei partecipanti e identità degli amici visibili, secondo `product.md`.
- Nella schermata dell'evento privato, mostrare l'elenco degli altri invitati per chi ha un invito valido. Il riferimento HTML e l'anteprima Flutter usano nomi dimostrativi; l'accesso reale sarà verificato lato server.
- Guardaroba con anteprima del personaggio, categorie semplici, bozza e conferma.

## Linguaggio visivo

Superfici chiare e calde, accento corallo, area guardaroba lilla e adattamento al tema scuro. Manrope è usato per i titoli e DM Sans per i testi, con fallback di sistema. La copertina dell'evento è tipografica e costruita in CSS nel riferimento. Controlli e testi devono restare leggibili e usabili a dimensione reale di telefono.

Il riferimento usa sprite Habbo caricati da un servizio esterno: sono un segnaposto visivo soggetto ai limiti indicati in [avatar.md](avatar.md). L'implementazione Flutter deve prevedere la sostituzione con asset distribuibili.

Nella prima UI Flutter il guardaroba mostra le sei categorie, varianti di colore, occhiali e posa di saluto su un'illustrazione vettoriale originale. La bozza resta solo nella sessione dell'anteprima. La rotazione e le varianti di modello richiedono asset finali; i relativi comandi restano inattivi. La settimana raggruppa gli eventi per giorno.
