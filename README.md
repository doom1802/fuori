# Fuori

Fuori è un'app in sviluppo per condividere piani temporanei, organizzare eventi e scoprire quando amici già collegati saranno nello stesso posto. La prima destinazione è web/PWA con Flutter; iOS e Android sono previsti in seguito.

Questa repository è la base dell'implementazione. Contiene requisiti di prodotto, regole di privacy e un unico riferimento grafico navigabile da tradurre in Flutter. La prima milestone genera il progetto Flutter. I dati visibili nel riferimento sono dimostrativi e non rappresentano utenti o eventi reali.

## Dove iniziare

- [Prodotto](docs/product.md): funzioni, privacy, primo rilascio e decisioni aperte.
- [Direzione grafica](docs/design.md): struttura e stile dell'interfaccia da portare in Flutter.
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

Con Python 3 e Node.js, `python3 scripts/check.py` verifica sintassi JavaScript e link locali del riferimento HTML. Il controllo gira anche nelle pull request. Quando il progetto Flutter sarà presente, le verifiche dell'app saranno `flutter analyze` e `flutter test`.

## Licenza e contenuti esterni

Il codice e la documentazione originali di Fuori sono distribuiti con [licenza MIT](LICENSE). La licenza non copre contenuti di terzi caricati da servizi esterni.

Gli sprite Habbo/Sulake sono caricati da un servizio esterno e non sono inclusi qui. Prima di pubblicare l'app servono asset originali o con licenza adatta; dettagli in [Avatar](docs/avatar.md). Il riferimento usa anche librerie e font caricati da CDN, soggetti alle rispettive licenze.
