# Account e accesso ai dati (M2)

Il client Flutter usa solo URL del progetto e chiave **publishable**. Non inserire nel client la chiave `service_role`, la chiave segreta, il token della CLI o le credenziali Google. Le migrazioni sono in `supabase/migrations/`.

## Flusso attuale

1. La registrazione email richiede la spunta 18+ prima della richiesta a Supabase Auth. Il progetto deve avere **Confirm email** attivo; dopo il link di verifica, l'utente accede.
2. L'accesso Google usa Supabase OAuth. Poiché un primo accesso Google può creare un account, la dichiarazione 18+ viene richiesta anche dopo il ritorno da Google se non è già nel database.
3. L'app registra la dichiarazione in `adult_declarations`, con data e versione impostate dal database. Senza questa riga il profilo non è leggibile o scrivibile tramite API.
4. Dopo la dichiarazione, l'utente crea o aggiorna il proprio profilo. Gli eventi e le amicizie mostrati restano dati dimostrativi fino alle milestone M4 e M6.

La spunta è una **autodichiarazione**, non una verifica dell'età. Prima del rilascio M8 va confermato se è adeguata al servizio.

## Matrice di accesso M2

| Risorsa | Proprietario con dichiarazione 18+ | Proprietario senza dichiarazione | Altro account | Visitante |
| --- | --- | --- | --- | --- |
| Dichiarazione 18+ | Legge la propria; inserisce una volta | Inserisce la propria | Nessun accesso | Nessun accesso |
| Profilo | Legge, crea, aggiorna nome e preferenze avatar | Nessun accesso | Nessun accesso | Nessun accesso |
| `user_roles` | Nessun accesso client | Nessun accesso client | Nessun accesso client | Nessun accesso client |

Il ruolo `user` viene assegnato dal trigger sul server alla creazione dell'account. Il ruolo `admin` è previsto nello schema, ma non abilita alcuna funzione e non può essere assegnato dal client. Amici, estranei e persone bloccate hanno gli stessi diritti sul profilo in M2: nessuno. M4 e M5 estenderanno questa matrice prima di rendere visibile qualsiasi dato fra utenti.

## Configurazione e verifica

1. Creare un progetto Supabase, attivare **Confirm email** e impostare Site URL e redirect URL per l'origine web usata da Flutter. Per lo sviluppo locale usare una porta fissa, per esempio `http://127.0.0.1:4174`.
2. Applicare la migrazione con la CLI o il deploy GitHub Actions descritti in [Migrazioni Supabase](database-migrations.md). Prima di usare un progetto già popolato, confrontare lo schema remoto con le migrazioni locali. Evitare l'esecuzione manuale nel SQL Editor per mantenere la cronologia coerente.
3. Configurare il provider Google in Supabase e nella console Google usando il callback URL mostrato da Supabase. Client secret e credenziali OAuth restano nel provider, mai nel repository.
4. Copiare `config/supabase.example.json` in `config/supabase.local.json`, inserendo URL e chiave **publishable** del progetto. Il file locale è ignorato da Git.
5. Avviare con `flutter run -d chrome --web-port=4174 --dart-define-from-file=config/supabase.local.json`. Senza configurazione, l'app apre soltanto l'anteprima dimostrativa.

Per chiudere M2 servono due account reali: verificare registrazione email, Google, recupero password, logout, persistenza del profilo e sessione. Ripetere le richieste direttamente all'API con sessione propria, dell'altro account e senza sessione: il profilo altrui e `user_roles` devono restare inaccessibili, anche se si tenta un aggiornamento diretto. Verificare inoltre che un account senza dichiarazione non legga il proprio profilo e che non possa assegnarsi `admin`.
