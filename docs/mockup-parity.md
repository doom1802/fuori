# Corrispondenza fra riferimento e app Flutter

Il riferimento HTML è una simulazione locale. Questa tabella evita di confondere una schermata dimostrativa con una funzione collegata a utenti reali.

| Percorso | App Flutter oggi | Da completare |
| --- | --- | --- |
| Navigazione In giro / Eventi / Amici / Il mio io | Presente | Dati e sessioni reali |
| Eventi pubblici, dettagli e risposta | Anteprima locale | RSVP salvato e autorizzato dal server |
| Filtri Tutti / Parteciperò / Forse | Presenti, basati sulle risposte nella sessione | Risposte persistenti per account |
| Eventi privati e altri invitati | Esempio locale per un invitato | Verifica dell'invito sul server, revoca e controllo dell'elenco |
| Creazione eventi pubblici o su invito | Form e nuovo evento nella sessione | Salvataggio, date complete, modifica del creatore, link evento revocabile |
| QR personale, Scan / Show, condivisione link e richiesta di amicizia | Vista a scorrimento, condivisione nativa e scansione; la richiesta è simulata | Token per account, accettazione, scadenza, revoca e limiti d'uso |
| Guardaroba | Anteprima vettoriale, colori, occhiali, saluto | Asset finali, varianti di modello, rotazione e salvataggio account |
| Benvenuto, impostazioni, stati brevi e visibilità | Solo nel riferimento HTML | Percorsi Flutter e backend |
| Account email/password, Google e dichiarazione 18+ | Assenti | Supabase Auth e regole lato server |

I “piani personali” del precedente prototipo sono stati rimossi: il prodotto comprende eventi pubblici ed eventi privati su invito. Il QR dimostrativo usa l'origine corrente dell'anteprima; un link generato su `127.0.0.1` non è utilizzabile da un altro dispositivo. Nessuna funzione dimostrativa assegna accesso a dati privati reali.
