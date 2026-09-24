# Contribuire a Fuori

Fuori è all'inizio dell'implementazione Flutter. Il lavoro corrente è ordinato nel [piano di implementazione](docs/implementation-plan.md); [prodotto](docs/product.md) e [design](docs/design.md) descrivono i requisiti. Il riferimento HTML serve per confrontare la grafica.

## Proporre una modifica

1. Apri una issue circoscritta, indicando milestone, risultato visibile, criteri di accettazione e verifica. Il modello **Attività per agente** contiene i campi utili.
2. Prepara una pull request che affronti quella issue e descriva le scelte fatte. Se un requisito è ancora aperto, discutilo nell'issue prima di aggiungere dipendenze o regole di privacy.
3. Esegui i controlli pertinenti e riporta il risultato nel modello di pull request. Per il riferimento HTML: `python3 scripts/check.py`. Quando il progetto Flutter sarà presente: `flutter analyze`, `flutter test` e i controlli indicati nella CI.
4. Per la UI, controlla almeno 320 e 420 px; per funzioni con dati privati, verifica le autorizzazioni lato server con account distinti.

Leggi anche [AGENTS.md](AGENTS.md) se usi un agente di coding. Mantieni i cambi piccoli e verificabili, e aggiorna i documenti quando cambia il comportamento.

## Materiale da non aggiungere

Non inviare segreti, dati personali reali, archivi di browser o asset di terzi privi di diritti di distribuzione. Gli sprite Habbo mostrati dal riferimento sono caricati da un servizio esterno e non fanno parte degli asset del progetto; vedi [avatar](docs/avatar.md). Contribuisci solo materiale che hai il diritto di distribuire secondo la licenza della repository.
