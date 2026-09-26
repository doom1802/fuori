# Avatar nel riferimento grafico

`design/reference/habbo-avatar.js` carica immagini da Habbo Imaging e le mostra nella UI di riferimento. Espone il componente `<habbo-avatar>` e `FuoriHabbo` per configurare look, direzione e URL. Il guardaroba usa indumento, capelli, scarpe, accessorio, colori e otto direzioni. Le pose sono immagini statiche, non animazioni o modelli 3D.

Il componente invia al servizio solo la configurazione estetica richiesta; non invia nomi, eventi o dati degli amici. Il browser effettua comunque richieste HTTP al servizio. Se l'immagine non è disponibile, il riferimento mostra un segnaposto o un messaggio di errore.

Gli sprite appartengono a Habbo/Sulake e non sono inclusi nella repository. La [Fansite Policy di Habbo](https://help.habbo.com/hc/en-us/articles/360011512480-Habbo-Fansite-Policy) concede permessi limitati ai fansite; non concede una licenza generale per usare gli sprite in Fuori. Il riferimento serve a fissare la direzione visiva. Prima di distribuire l'app vanno scelti asset originali o con licenza adatta e una pipeline controllata dal progetto.

Per ogni futuro asset va registrata almeno provenienza, autore, licenza, permesso d'uso commerciale e versione. Il proprietario ha scelto sprite 2D originali, proposta C, per Flutter. Provenienza e varianti sono documentate in `assets/avatar/README.md`.

## Implementazione della C

Il guardaroba Flutter usa asset originali in pixel art, composti da livelli separati. Offre due basi, maschile e femminile, e tutti i modelli delle cinque tavole approvate: otto vestiti, otto acconciature (H4 completamente pelata), otto pantaloni, otto scarpe e otto extra. Tutti i modelli sono disponibili per entrambe le basi. Colori di vestiti, capelli, pantaloni, scarpe e pelle sono personalizzabili. La prima scelta conserva il colore originale del modello. La pelata nasconde il selettore di colore dei capelli, conservandone la preferenza.

Gli extra si combinano: un modello di occhiali, un cappello, cuffie, zainetto e tracolla. Un nuovo paio di occhiali sostituisce quello precedente; cappellino e berretto si sostituiscono. Cuffie e borse sono selezioni indipendenti. Premere un elemento selezionato lo toglie. Modello, base, colori ed extra vengono salvati in `profiles.avatar_preferences`, schema JSON versione 3. I look versione 1 e 2 vengono letti mantenendo colori e scelte compatibili. Un errore di salvataggio conserva la bozza e permette di riprovare. Orientamento e saluto sono controlli di anteprima, non preferenze persistenti.

Provenienza, prompt, catalogo e formato degli asset: `assets/avatar/catalog/README.md`. Gli atlanti precedenti nella directory superiore documentano l'evoluzione della C; il renderer corrente carica gli elementi componibili.

Verifiche: serializzazione di tutti gli 8.192 abbinamenti dei quattro modelli su due basi, combinazione/sostituzione degli extra, indicizzazione delle otto direzioni, errori di salvataggio e ripristino delle preferenze precedenti. Nel browser locale il salvataggio di un look completo è stato verificato su Supabase locale e riletto dopo il ricaricamento. La revisione artistica delle combinazioni resta parte di M3.

La composizione protegge il viso dai capelli, allinea occhiali e mani per orientamento e nasconde la pelle coperta dai pantaloni. I metadati escludono i frammenti degli oggetti vicini nelle tavole. Un confronto dei pixel renderizzati verifica che gli occhi restino intatti cambiando acconciatura su entrambe le basi e nelle cinque viste del volto.

Controlli dell’integrazione: 21 test Flutter superati; build web riuscita. Layout ispezionato nel browser a 320, 420 e 1280 px con combinazioni su entrambe le basi, saluto e vista posteriore. La UI mostra i colori vicino alle categorie e le otto alternative con miniature. La correzione degli incastri è stata verificata anche su una tavola di rendering con il look segnalato nelle otto direzioni e tutti i modelli in posa normale e saluto.
