# whip_inventory_compact — "Tall Twin Columns"

Skin per l'inventario di WHIP. **Non sostituisce il renderer**: `whip_core` continua a disegnare
slot, drag & drop, tooltip, menu, pesi e validazione lato server. Questa risorsa aggiunge un
`theme.css` (applicato a tutti tramite `SetActiveTheme`) e un piccolo `client.lua` che annulla il
blur di gioco mentre l'inventario è aperto. Nessun file esistente è stato modificato.

Pacchetto pronto per GitHub: licenza MIT, changelog, screenshot e **5 lingue** (IT, EN, ES, FR, DE)
con lo stesso meccanismo a una riga di `whip_clothingwheel`.

Documentazione: [Italiano](README.md) · [English](README.en.md) · [Español](README.es.md) ·
[Français](README.fr.md) · [Deutsch](README.de.md)

## Cosa fa

- **Due colonne della stessa larghezza (420px sullo schermo a 1080p)**, con un margine minimo di
  24px ai lati e 20px in alto/in basso; l'insieme è centrato verticalmente.
  - a sinistra **una sola scheda continua**, senza soluzioni di continuità: in cima il nome del
    player e la capacità di peso (il margine nativo di 14px è stato azzerato, quindi è attaccato
    al resto), poi i 5 slot accessori (Telefono, Contanti, 3 chiavi) grandi come quelli
    dell'inventario, un divisore, la griglia del giocatore con gli slot rapidi 1-5 evidenziati,
    un divisore, la zona **Terra / Nearby** su 2 righe e, in fondo, la **legenda dei tasti**.
    I divisori sono **linee corte da 1px, centrate e rientrate di 40px per parte** (480px interni
    su 560px di scheda): niente contorno attorno alla finestra, solo sopra e sotto.
  - a destra le finestre che WHIP apre per borse, baule, portabagagli o portafoglio: sono
    **impilate in verticale** (contenitore + portafoglio, per esempio) invece di sovrapporsi,
    **centrate verticalmente come gruppo** sia con uno sia con più contenitori aperti, con quella
    aperta per prima in cima (è il primo figlio nel DOM di WHIP). Alte quanto basta ai contenuti,
    senza spazi vuoti. Niente trascinamento: è solo CSS.
- **Tutte le griglie hanno 5 colonne per riga**, con slot quadrati da 72px sullo schermo.
- Il **centro dello schermo resta libero**.
- Le **ombre pesanti tra i pannelli sono state tolte**: restano solo bordi piatti sottili.
- **Apertura e chiusura animate**: la finestra sale di 10px e si assesta in 0.26s.
  Tutto arriva **insieme**: il ritardo nativo di 0.07s sulla barra accessori è stato annullato,
  quindi telefono/contanti/chiavi non seguono più l'inventario ma entrano con esso, in un unico
  blocco. La chiusura è animata davvero con `ease-in` su 0.24s (WHIP lascia `.open` per 250ms).
  **Nessun tremolio**: (1) l'overlay non sfida più insieme alla finestra — scatta a opacità 1 e
  l'unica fade è quella del guscio; (2) il `scale()` è stato rimosso: su un elemento con
  `zoom:0.75` ridisegnava slot e testo a pixel frazionari; (3) l'easing è `--skin-ease`
  (`cubic-bezier(.25,.8,.25,1)`) invece dell'`--ui-ease` di WHIP, che faceva fare il 60% del
  movimento nel primo frame.
- **Nessuno scurimento dello schermo**: il `#inv-wash` viene forzato a `background: transparent`
  (vince anche sul colore inline scritto da `inventory.js`), verificato con `getComputedStyle`.
- **Comparsa dei contenitori animata**: pannelli di borse/baule/portafoglio entrano con
  `skinPanelIn` (0.26s, sale di 8px e si assesta, senza `scale`), anche quando vengono aperti a
  inventario già visibile.
- Il **tooltip dell'oggetto è più grande**: 285×96px sullo schermo invece di 225×80px, con testo
  20/15/13px interni. Ha una **comparsa animata con ritardo di 0.32s**: se il mouse passa veloce
  sopra un oggetto non appare, compare solo dopo un istante di permanenza, con un leggero
  sollevamento. L'animazione sta sull'`.inv-pop` interno, così le coordinate `left/top` scritte da
  `positionTooltip()` restano intatte. Il `transform` di spostamento è stato **rimosso**: prima
  spostava la card di `-50%/-100%` *dopo* i clamp nativi, quindi un oggetto vicino al bordo sinistro
  o alto la mandava fuori schermo. Ora i clamp di WHIP (che leggono la card dopo il ridimensionamento
  del tema) funzionano di nuovo su tutti e quattro i lati.
- La **barra rapida di Tab** usa la stessa lingua visiva dell'inventario: superficie scura solida,
  linee bianche sottili, raggio 14px come i pannelli, nessuna ombra e nessun accento blu. Solo lo
  stato attivo cambia (bordo/tasto chiaro). Dopo il rilascio di Tab **resta visibile per almeno
  2 secondi** (2s di attesa + 0.2s di fade): WHIP la nasconde subito alla keyup, quindi il ritardo è
  sulla transizione dello stato di riposo, lasciando la comparsa immediata. Vale anche quando il
  segmento è fuso nella barra degli hint. Il comportamento (1-5, conteggi, slot attivo) resta quello
  di WHIP.
- **Nomi e etichette leggibili**: WHIP riservava 82px dei 96px interni dello slot al contatore,
  lasciando al nome 14px (una sola lettera). Ora il nome usa tutto lo spazio fino al contatore e le
  scritte più lunghe vanno in ellipsis. Le etichette Telefono / Contanti / Chiave 1-3 sono passate
  da 10px a 15px interni, piene e con contorno scuro; la **legenda dei tasti** da 11px a 15px, con
  keycap da 14px.
- Zoom ridotto (`--ui-zoom-inventory: 1` invece di 1.32): molto meno "a tutto schermo".
- **Nessun blur di sfondo**: WHIP chiama `TriggerScreenblurFadeIn(200)` all'apertura
  (`whip_core/client/inventory.lua:1062`); essendo una native di FiveM e non CSS, il `theme.css`
  non può annullarlo. Lo fa quindi il nostro `client.lua`: si registra sugli stessi eventi di rete
  con cui WHIP apre l'inventario (i nostri handler girano subito dopo i suoi, nello stesso tick,
  quindi non si vede nemmeno un frame), e intanto controlla l'export pubblico
  `exports.whip_core:IsInventoryOpen()` (riga 2724) ogni frame per le aperture locali (F2 con
  cache, radiale, pad). Richiama `TriggerScreenblurFadeOut(1)` solo mentre l'inventario è aperto.
  Le altre schermate che usano blur restano intatte.

Nota: WHIP di default nasconde "Nearby" quando apri un contenitore (lo stile inline `display:none`
viene scritto da `setPanels`). Il tema lo forza a restare visibile. I suoi riquadri sono disegnati
con un SVG in background che **copia esattamente uno slot vuoto nativo** (96px interni, raggio
11px, `rgba(255,255,255,.03)`, nessun bordo visibile): sono quindi identici a quelli
dell'inventario e ci sono anche quando WHIP non rende alcuno slot (scena `stash` con Terra vuota).
Quando gli slot nativi ci sono, si allineano esattamente sopra.

Nota sui "tooltip in fondo": li ho letti come **legenda dei tasti** (l'unica barra fissa che WHIP
disegna), messa in fondo alla scheda sinistra e fusa con essa. In questa versione è anche più
grande (testo 15px interni, keycap 14px), così si legge senza avvicinarsi allo schermo. Il tooltip
dell'oggetto resta ancorato al cursore ma, non essendo più traslato, non può più uscire dai bordi.

## Installazione

La cartella è già qui:

```
resources/[custom]/whip_inventory_compact/
```

Avvia la risorsa in uno dei due modi:

- aggiungi una riga `ensure whip_inventory_compact` in `server.cfg`; **oppure**
- avviala da txAdmin → Resources → Start.

All'avvio la risorsa applica da sé il tema a tutti i giocatori connessi. Non serve toccare
`whip_core/config.lua` né impostare convar.

## Lingue (IT / EN / ES / FR / DE)

Come nella clothingwheel, la lingua si sceglie da **una sola riga** in `config.lua`:

```lua
Config.Locale = 'it' -- it, en, es, fr, de
```

Dopo averla cambiata, esegui `restart whip_inventory_compact`: `server.lua` ricompila
`locales/active.css` dalle label di `Config.Locales`, e `theme.css` lo importa come prima regola.
Il client non legge Lua, quindi è questo il ponte tra config e CSS. Il file generato è incluso
nel repo con i valori italiani: se il server non può scriverlo, la skin resta in italiano e
stampa un avviso in console invece di rompersi.

| Codice | Lingua | Telefono | Contanti | Chiavi |
|---|---|---|---|---|
| `it` | Italiano | Telefono | Contanti | Chiave 1/2/3 |
| `en` | English | Phone | Cash | Key 1/2/3 |
| `es` | Español | Teléfono | Efectivo | Llave 1/2/3 |
| `fr` | Français | Téléphone | Argent | Clé 1/2/3 |
| `de` | Deutsch | Telefon | Bargeld | Schlüssel 1/2/3 |

`shared/locale.lua` usa la stessa logica della clothingwheel: ricerca con chiavi in notazione
puntata (`accessory.phone`), fallback `en` → `it` → nome della chiave, e segnaposto
`string.format` per i messaggi di console. Vengono tradotte le etichette dei 5 slot accessori e i
messaggi che la risorsa scrive in console. Il resto dei testi dell'inventario (Nearby, legenda,
nomi degli oggetti) è disegnato da `whip_core` e resta nella sua lingua: non è modificabile da un
tema CSS senza riscrivere il renderer.

## Comandi utili

| Comando | Effetto |
|---|---|
| `start whip_inventory_compact` | applica la skin a **tutti** i giocatori connessi (e a chi entra dopo) |
| `restart whip_inventory_compact` | ricarica `theme.css` e rigenera `locales/active.css` da `config.lua` per **tutti** |
| `stop whip_inventory_compact` | rimuove l'override e torna all'aspetto base di WHIP |
| `/whip_theme whip_inventory_compact` | riapplica il link CSS in live **solo a te** (serve `whip.devtools`) |
| `/whip_theme none` | tolga il tema **solo a te** in live |

### Chi riceve cosa

- **Modifichi `theme.css` sul disco?** Nessuno se ne accorge da solo: il browser ha già il
  `<link>` caricato. Serve `restart whip_inventory_compact` per tutti, oppure `/whip_theme
  whip_inventory_compact` per provare solo tu.
- Richiamare `SetActiveTheme` con lo **stesso** nome non fa nulla: il registro non ribroadcasta
  un valore identico. Per questo il comando giusto è `restart`, non un nuovo `start`/`ensure`.
- `/whip_theme <resource>` è uno strumento di preview **per singolo client** (vedi
  `server/devtools.lua`), non un'impostazione globale.

### Renderla il tema di default (senza toccare file)

1. `stop whip_inventory_compact` — finché l'override è attivo vince lui.
2. In game apri `/whip` → **Settings** → **Theme** → `whip_inventory_compact`.

Il valore viene salvato su file da WHIP e `Settings.onChange('Theme')` lo applica subito a tutti;
d'ora in poi è il tema fisso, anche per i nuovi joiner, e non serve più tenere avviata la risorsa
come override. In alternativa classica si può cambiare `Config.Theme` in `whip_core/config.lua`
(riga 1797, ora `whip_inventory_compact`), ma richiede il restart di `whip_core`.

## Pacchetto GitHub

La cartella è autonoma, non contiene file del server o di `whip_core` ed è pronta per un
`git init` + push (non ho creato il `.git` per non annidare un repository dentro `resources/`):

```
whip_inventory_compact/
├── .gitignore
├── LICENSE              MIT
├── README.md
├── CHANGELOG.md
├── config.lua           lingua + label
├── fxmanifest.lua
├── server.lua           genera locales/active.css e applica il tema
├── client.lua           annulla il blur nativo
├── theme.css            layout + import del CSS lingua
├── shared/locale.lua    loader con fallback
├── locales/active.css   generato (default: italiano)
└── docs/screenshots/
    ├── pockets.png
    └── stash.png
```

Prima di pubblicare, aggiungi il tuo URL in `fxmanifest.lua` con
`repository 'https://github.com/<tuo-utente>/whip_inventory_compact'`. Il `CHANGELOG.md` usa SemVer:
questa release è `1.2.0`.

![Inventario — tasche](docs/screenshots/pockets.png)

![Inventario — contenitore e portafoglio](docs/screenshots/stash.png)

## Verifica fatta

Preview headless di WHIP a 1920x1080 con il tema iniettato:

- margini schermo: **24px a sinistra e 24px a destra** (wrapper 1872px), 89px in alto/in basso;
- entrambe le colonne larghe 420px (560px interni × 0.75 di zoom);
- scheda sinistra **senza alcun bordo laterale** (verificato: `border-left/right: 0` su titolo,
  accessori, griglia, Nearby e legenda). Titolo (y=89, alta 44px) **attaccato** agli accessori
  (y=133, alta 101px), che a loro volta toccano l'inventario (y=234): zero gap. Poi Terra (y=730),
  legenda (y=955);
- tre divisori da 1px, tutti `background-image` con `background-size: 480px 1px` e
  `no-repeat` centrato (sotto il titolo, sotto gli accessori, sopra la Terra): righe corte e
  rientrate, non un contorno; nome e peso verificati («John Framework 13.95 / 80 kg»);
- slot accessori, giocatore, Terra e contenitore tutti 72×72px sullo schermo (96px interni);
- 5 colonne per riga in ogni griglia; Nearby 390×152px (5×2 riquadri). Gli slot vuoti nativi e
  quelli disegnati dall'SVG hanno valori identici: sfondo `rgba(255,255,255,.03)`, bordo
  trasparente, raggio 11px (confrontato via `getComputedStyle`);
- nessuna ombra sui pannelli;
- tooltip sull'oggetto: con hover su uno slot a (300,300) il box finisce a x=316, y=284
  (`left/top` inline di WHIP, senza transform). Dimensione **285×96px** (era 225×80px); nome 20px,
  descrizione 15px, righe 13px. I quattro margini sono stati provati con `mousemove` a
  (20,300), (1900,300), (300,10), (300,1070): il box resta sempre dentro 1920×1080
  (rispettivamente x=36, x=1599+285=1884, y=26, bottom=1072);
- animazione: tracciata la sequenza esatta di `showOverlay()` frame per frame. L'overlay scatta a
  `opacity:1` (nessuna seconda fade) e il guscio sale da `translateY(10px)` a 0 con opacità
  0.29 → 0.61 → 0.93 → 1, posizione y 94.2 → 91.7 → 89.3 → 88.8: rampa monotona, nessun salto.
  Nessun `scale()` (solo `translate`), quindi nessun pixel frazionario su `zoom:0.75`.
  Togliendo `.visible` la chiusura resta animata. L'accessorio ha `opacity:1`, `transform:none`,
  `transition:none` in entrambi gli stati: arriva insieme al resto;
- wash: con `.on` e colore inline `rgba(10,12,18,.55)` scritto da JS, il calcolato è
  `background: rgba(0,0,0,0)` → nessuno scurimento;
- pannello contenitore: `animation-name: skinPanelIn`, durata 0.26s (comparsa verificata);
- tooltip: delay 0.32s + 0.18s di animazione. Subito dopo `.visible` e a +200ms l'`.inv-pop` è a
  `opacity:0`, a +340ms è a 0.58, a +580ms è a 1 con `transform` identità. Il box esterno ha
  `transform: none` e `animation-name: none`, quindi i `left/top` inline di WHIP non vengono
  alterati;
- nomi oggetti: il nome «Phone» nello slot 72px è largo 27px sullo schermo (prima 9px, cioè la
  sola «P»), con `max-width: calc(100% - 42px)`. Etichette accessori a 15px interni, colore
  `var(--ui-text)` pieno, e legenda a 15px / keycap 14px (prima 10px e 11px);
- lingue: con `locales/active.css` in italiano il `::after` degli slot accessori restituisce
  `"Telefono"`, `"Contanti"`, `"Chiave 1"`…; sostituendo il file con i valori EN e poi ES (con
  accenti) le etichette diventano `"Phone"/"Cash"/"Key 1"` e `"Teléfono"/"Efectivo"/"Llave 1"`,
  lette da `getComputedStyle` — quindi l'`@import` e le varianti UTF-8 funzionano nel CEF di WHIP;
- hotbar di Tab: dopo la rimozione di `.visible` l'opacità resta **1 a 0 e a 1900ms**, a 2050ms è
  0.28 e a 2200ms è 0 → pienamente visibile per 2 secondi, poi fade di 0.2s. Capsula con sfondo
  `rgba(13,18,26,.9)`, bordo `rgba(255,255,255,.1)`, raggio 14px, senza ombra; keycap con sfondo
  `rgba(255,255,255,.1)` e lo stesso bordo — nessun blu. Vale anche per il segmento nei hint;
- scena `pockets`: scheda sinistra come sopra, centro libero;
- scena `stash`: contenitore a destra (x=1476, y=188, 420×543) e portafoglio sotto
  (x=1476, y=740, 420×152): il gruppo è **centrato verticalmente** (105px sopra e 106px sotto),
  **zero sovrapposizioni** (verificato con bounding box); Terra ancora presente a sinistra.
- La barra di debug che si vede nelle anteprime è del tool di preview di WHIP (`#whip-preview-bar`):
  non esiste in game e si nasconde con `F9` nel preview (nei miei screenshot è rimossa).

Per il blur la verifica è sul sorgente, non sul preview headless (che non esegue le native):
`TriggerScreenblurFadeIn` / `FadeOut` in `inventory.lua:1062` / `:1358`, i tre eventi di rete
che aprono l'UI (`:1485`, `:1708`, `:1760`) e l'export `IsInventoryOpen` alla riga 2724.
Il lampo di un frame è stato eliminato registrando i nostri handler sugli stessi eventi: girano
dopo quelli di WHIP perché la risorsa ha `dependency 'whip_core'`. **Va confermato in game** con
`restart whip_inventory_compact` (serve il restart, non solo il ricaricamento del CSS).

## Se qualcosa non torna

- La skin è fail-soft: se `theme.css` non viene servito, WHIP resta con l'aspetto base e lo
  scrive nella console F8.
- Due sole regole usano `!important` perché devono battere stili inline scritti da `inventory.js`:
  il colore di `#inv-wash` e il `display` di `#inv-ground-panel`. Sono mirate a quegli elementi,
  non globali. Il tooltip, invece, non usa `!important`: lascia stare `left`/`top` di JS e si limita
  a `transform: none` + `animation: none`, così i clamp di posizione di WHIP restano validi.
- Le colonne si regolano in `theme.css` alla regola `.inv-wrapper` → `grid-template-columns`
  (valori in pixel "interni", poi moltiplicati per lo zoom di WHIP). La larghezza è
  `--skin-card-w`, la dimensione degli slot è `--skin-slot`, entrambe in cima al file.
- Se cambi `Config.Locale` ma le etichette non cambiano: controlla in console F8 il messaggio
  `[whip_inventory_compact] Lingua attiva: ...`. Se c'è un errore di scrittura, il server non può
  aggiornare `locales/active.css` (permessi di cartella): dai permessi di scrittura alla risorsa
  oppure modifica a mano `locales/active.css` con le label volute. In entrambi i casi serve
  `restart whip_inventory_compact`, non solo `/whip_theme`.
