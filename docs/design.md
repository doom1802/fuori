# Direzione grafica

Il riferimento visivo corrente è [l'interfaccia navigabile](../design/reference/index.html). È la base per portare la UI in Flutter; la grafica piace nella sua forma attuale e andrà mantenuta durante il primo lavoro di implementazione.

## Struttura

- Una colonna mobile larga circa 320–420 px, leggibile anche su desktop.
- Quattro destinazioni principali: **In giro**, **Piani**, **Amici**, **Il mio io**.
- Nella Home, programma in evidenza, lista per giorno e una sola azione principale per creare un piano o evento.
- Gerarchia chiara fra numero totale dei partecipanti e identità degli amici visibili, secondo `product.md`.
- Guardaroba con anteprima del personaggio, categorie semplici, bozza e conferma.

## Linguaggio visivo

Superfici chiare e calde, accento corallo, area guardaroba lilla e adattamento al tema scuro. Manrope è usato per i titoli e DM Sans per i testi, con fallback di sistema. La copertina dell'evento è tipografica e costruita in CSS nel riferimento. Controlli e testi devono restare leggibili e usabili a dimensione reale di telefono.

Il riferimento usa sprite Habbo caricati da un servizio esterno: sono un segnaposto visivo soggetto ai limiti indicati in [avatar.md](avatar.md). L'implementazione Flutter deve prevedere la sostituzione con asset distribuibili.
