# Avatar nel riferimento grafico

`design/reference/habbo-avatar.js` carica immagini da Habbo Imaging e le mostra nella UI di riferimento. Espone il componente `<habbo-avatar>` e `FuoriHabbo` per configurare look, direzione e URL. Il guardaroba usa indumento, capelli, scarpe, accessorio, colori e otto direzioni. Le pose sono immagini statiche, non animazioni o modelli 3D.

Il componente invia al servizio solo la configurazione estetica richiesta; non invia nomi, piani o dati degli amici. Il browser effettua comunque richieste HTTP al servizio. Se l'immagine non è disponibile, il riferimento mostra un segnaposto o un messaggio di errore.

Gli sprite appartengono a Habbo/Sulake e non sono inclusi nella repository. La [Fansite Policy di Habbo](https://help.habbo.com/hc/en-us/articles/360011512480-Habbo-Fansite-Policy) concede permessi limitati ai fansite; non concede una licenza generale per usare gli sprite in Fuori. Il riferimento serve a fissare la direzione visiva. Prima di distribuire l'app vanno scelti asset originali o con licenza adatta e una pipeline controllata dal progetto.

Per ogni futuro asset va registrata almeno provenienza, autore, licenza, permesso d'uso commerciale e versione. La scelta tecnica fra sprite 2D e modello 3D per Flutter è ancora aperta.
