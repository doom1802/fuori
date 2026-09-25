# Fuori

Fuori è un'app in sviluppo per organizzare eventi pubblici e privati su invito e incontrare amici già collegati. La prima destinazione è web/PWA con Flutter; iOS e Android sono previsti in seguito.

La prima bozza Flutter traduce il linguaggio visivo del riferimento navigabile. Le quattro sezioni usano dati dimostrativi separati dai widget tramite interfacce di repository. Il QR personale, la scansione, le richieste di amicizia, la creazione eventi e le risposte sono percorsi di anteprima: non creano amicizie o eventi reali. M2 aggiunge il codice per account, profilo e regole di accesso con Supabase; questi percorsi richiedono un progetto Supabase configurato e la migrazione applicata. Il link QR locale funziona soltanto sulla stessa origine dell'anteprima; per invitare altre persone servirà un dominio e un backend.

## Avviare l'app Flutter

Serve Flutter 3.47.5 o una versione compatibile del canale stable, con supporto web e Chrome. Dalla radice della repository:

```sh
flutter pub get
flutter run -d chrome
```

Controlli locali:

```sh
flutter analyze
flutter test
flutter build web
```

La UI è progettata per 320–420 px e viene centrata in una colonna larga al massimo 420 px su desktop. Il personaggio attuale è un segnaposto vettoriale originale; gli sprite Habbo del riferimento non sono inclusi nell'app. Le icone PWA originali si rigenerano su macOS con `swift scripts/make-web-icons.swift`.

## Account e database (M2)

L'avvio senza configurazione continua a mostrare l'anteprima dimostrativa. Per usare un progetto Supabase, copia `config/supabase.example.json` in `config/supabase.local.json`, inserisci l'URL del progetto e la sua chiave **publishable**, poi avvia:

```sh
flutter run -d chrome --web-port=4174 --dart-define-from-file=config/supabase.local.json
```

Il file locale è ignorato da Git. La migrazione in `supabase/migrations/` va applicata al progetto prima di accedere; email da confermare, URL di ritorno e provider Google richiedono configurazione nella dashboard. La chiave `service_role` e il client secret Google non devono comparire nell'app o nel repository. Il flusso account, le regole di accesso e le verifiche con due utenti sono descritti in [Account e accesso ai dati](docs/account-access.md). Eventi, QR e amicizie restano dimostrativi durante M2.

## Dove iniziare

- [Prodotto](docs/product.md): funzioni, privacy, primo rilascio e decisioni aperte.
- [Direzione grafica](docs/design.md): struttura e stile dell'interfaccia da portare in Flutter.
- [Corrispondenza mockup–Flutter](docs/mockup-parity.md): percorsi già navigabili e funzioni ancora da collegare al backend.
- [Account e accesso ai dati](docs/account-access.md): configurazione M2, ruoli e matrice di accesso.
- [Avatar](docs/avatar.md): dipendenza temporanea dagli sprite Habbo e requisiti per gli asset di produzione.
- [Piano di implementazione](docs/implementation-plan.md): milestone, criteri di completamento e ordine del lavoro.
- [Riferimento grafico](design/reference/index.html): versione HTML navigabile della UI corrente.
- [Contribuire](CONTRIBUTING.md): issue, pull request e verifiche.

## Aprire il riferimento grafico

Servono Python 3, un browser moderno e una connessione Internet:

```sh
python3 -m http.server 4173 --bind 127.0.0.1 --directory design/reference
```

Aprire <http://127.0.0.1:4173/>. Su un telefono nella stessa rete Wi-Fi usare `./scripts/preview-phone.sh`. Le immagini degli avatar arrivano da Habbo Imaging; icone, QR e font possono richiedere jsDelivr e Google Fonts.

Con Python 3 e Node.js, `python3 scripts/check.py` verifica sintassi JavaScript e link locali del riferimento HTML. Il controllo gira anche nelle pull request. La CI esegue inoltre `flutter analyze`, `flutter test` e `flutter build web`.

## Licenza e contenuti esterni

Il codice e la documentazione originali di Fuori sono distribuiti con [licenza MIT](LICENSE). La licenza non copre contenuti di terzi caricati da servizi esterni.

Gli sprite Habbo/Sulake sono caricati da un servizio esterno e non sono inclusi qui. Prima di pubblicare l'app servono asset originali o con licenza adatta; dettagli in [Avatar](docs/avatar.md). Il riferimento usa anche librerie e font caricati da CDN, soggetti alle rispettive licenze. L'app Flutter include [Manrope e DM Sans](assets/fonts/README.md) con licenza SIL OFL 1.1.
