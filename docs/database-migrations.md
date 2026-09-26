# Migrazioni Supabase

Lo schema si aggiorna tramite file versionati in `supabase/migrations/`. La CLI registra nel database le migrazioni applicate e `db push` esegue quelle pendenti in ordine. Una migrazione applicata non va modificata: ogni cambiamento successivo ha un nuovo file.

## Deploy automatico

Il workflow `Migrazioni database` verifica le migrazioni su PostgreSQL locale nelle pull request. Dopo il merge su `main`, verifica di nuovo e applica le migrazioni al progetto Supabase configurato. Non pubblica l'app Flutter e non configura Google OAuth.

In **GitHub → doom1802/fuori → Settings → Secrets and variables → Actions**, creare i repository secrets:

| Secret | Valore |
| --- | --- |
| `SUPABASE_ACCESS_TOKEN` | Personal access token creato nelle impostazioni dell'account Supabase |
| `SUPABASE_DB_PASSWORD` | Password del database del progetto |
| `SUPABASE_PROJECT_ID` | Reference del progetto, presente nell'URL della dashboard |

Questi valori non vanno inseriti nel client, in chat o nel repository. URL e chiave publishable dell'app rimangono in `config/supabase.local.json` per lo sviluppo locale.

Il deploy è serializzato e parte soltanto da `main`. È disponibile anche l'avvio manuale del workflow da `main`, per esempio dopo aver aggiunto i secrets. Se uno dei secrets manca, il deploy fallisce con il nome della configurazione mancante, senza stamparne il valore. Il workflow deve essere presente su `main` per poterlo avviare dalla dashboard Actions.

## CLI locale

Serve Node.js 20 o successivo. La versione usata anche in CI è 2.118.0:

```sh
npx --yes supabase@2.118.0 login
npx --yes supabase@2.118.0 link --project-ref <project-reference>
npx --yes supabase@2.118.0 migration list
npx --yes supabase@2.118.0 db push --dry-run
npx --yes supabase@2.118.0 db push
```

La CLI richiede la password del database quando necessaria. Verificare il progetto collegato e le migrazioni pendenti prima di confermare il primo deploy. `db reset --local` è riservato al database locale di sviluppo.

Per creare un cambiamento:

```sh
npx --yes supabase@2.118.0 migration new descrizione_modifica
```

Scrivere lo SQL nel nuovo file, aprire una PR e controllare il job `verify`. Le credenziali remote non sono disponibili nei job delle PR.

## Se lo SQL è già stato applicato dalla dashboard

Non rilanciare alla cieca la stessa migrazione. Confrontare prima lo schema remoto con il file e verificare che tutti gli oggetti, le policy e i grant siano presenti. Solo se coincidono, registrare la versione come applicata:

```sh
npx --yes supabase@2.118.0 migration repair 20260925090000 --status applied
npx --yes supabase@2.118.0 migration list
```

`migration repair` aggiorna soltanto la cronologia: non esegue lo SQL e non corregge uno schema incompleto.

Riferimento: [workflow ufficiale Supabase](https://supabase.com/docs/guides/deployment/managing-environments).
