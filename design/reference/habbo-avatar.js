/* Habbo Imaging adapter for the visual reference. No framework or 3D engine.
 * Images are served by Habbo/Sulake; they are not original Fuori artwork.
 * See docs/avatar.md for the component API and production limitations.
 */
(() => {
  const endpoint = 'https://www.habbo.com/habbo-imaging/avatarimage';
  const defaults = Object.freeze({
    top: '#ac94b3', bottom: '#595959', skin: '#e3ae7d', hair: '#5c4332',
    hairstyle: 'side', garment: 'hoodie', shoes: 'sneakers', accessory: 'none', pose: 'idle'
  });
  // A small, verified subset of Habbo's figuredata palettes, not arbitrary tinting.
  const colors = {
    top: [['Lilla', '#ac94b3', 75], ['Burro', '#f3e1af', 89], ['Cobalto', '#6d80bb', 78], ['Corallo', '#ed5c50', 72]],
    bottom: [['Grafite', '#595959', 64], ['Denim', '#4f7aa2', 82], ['Sabbia', '#c69f71', 1409], ['Oliva', '#89906e', 1334]],
    hair: [['Castano', '#5c4332', 45], ['Nero', '#2d2d2d', 61], ['Rame', '#d1803a', 33], ['Biondo', '#f6d059', 35]],
    skin: [['Miele', '#e3ae7d', 2], ['Ambra', '#ae7748', 4], ['Bruna', '#6e482c', 6], ['Chiara', '#ffdbc1', 10]]
  };
  const choices = {
    garment: [['jacket', 'Camicia'], ['hoodie', 'Felpa'], ['tee', 'T-shirt']],
    hairstyle: [['side', 'Ciuffo'], ['bob', 'Mossi'], ['spiky', 'Spettinati']],
    shoes: [['sneakers', 'Sneakers'], ['slippers', 'Ciabatte'], ['runners', 'Da corsa'], ['boots', 'Stivali']],
    accessory: [['none', 'Nessuno'], ['cap', 'Cappellino'], ['glasses', 'Occhiali'], ['phones', 'Cuffie']]
  };
  const rgb = hex => hex.slice(1).match(/../g).map(c => parseInt(c, 16));
  function nearestColor(key, value) {
    const target = rgb(/^#[\da-f]{6}$/i.test(value) ? value : defaults[key]);
    return colors[key].reduce((best, swatch) => {
      const distance = rgb(swatch[1]).reduce((sum, c, i) => sum + (c - target[i]) ** 2, 0);
      return distance < best.distance ? { swatch, distance } : best;
    }, { distance: Infinity }).swatch;
  }
  function normalize(outfit = {}) {
    const result = { ...defaults };
    for (const key of Object.keys(colors)) result[key] = nearestColor(key, outfit[key])[1];
    for (const key of Object.keys(choices)) {
      if (choices[key].some(([value]) => value === outfit[key])) result[key] = outfit[key];
    }
    if (['idle', 'wave', 'sit'].includes(outfit.pose)) result.pose = outfit.pose;
    return result;
  }
  function figure(outfit = {}) {
    const o = normalize(outfit), color = key => nearestColor(key, o[key])[2];
    const parts = [
      `hd-180-${color('skin')}`, `hr-${{ side: 155, bob: 828, spiky: 115 }[o.hairstyle]}-${color('hair')}`,
      `ch-${{ jacket: 230, hoodie: 255, tee: 215 }[o.garment]}-${color('top')}`,
      `lg-285-${color('bottom')}`,
      { sneakers: 'sh-906-92', slippers: 'sh-295-91', runners: 'sh-906-64', boots: 'sh-905-110' }[o.shoes]
    ];
    const accessory = { cap: 'ha-1002-72', glasses: 'ea-1403-110', phones: 'he-1604' }[o.accessory];
    if (accessory) parts.push(accessory);
    return parts.join('.');
  }
  const direction = value => {
    const number = Number(value);
    return Number.isFinite(number) ? ((Math.round(number) % 8) + 8) % 8 : 2;
  };
  function url(options = {}) {
    const look = /^(?:[a-z]{2}-\d+(?:-\d+)*)(?:\.[a-z]{2}-\d+(?:-\d+)*)*$/.test(options.figure)
      ? options.figure : figure(options.outfit);
    const facing = direction(options.direction ?? 2);
    const params = new URLSearchParams({
      figure: look, size: 'l', direction: String(facing), head_direction: String(facing),
      action: ({ idle: 'std', wave: 'wav', sit: 'sit' })[options.pose] || 'std',
      gesture: options.gesture === 'smile' ? 'sml' : 'std', img_format: 'png'
    });
    if (options.headOnly) params.set('headonly', '1');
    return endpoint + '?' + params;
  }
  globalThis.FuoriHabbo = { defaults, colors, choices, normalize, figure, url, direction };
  if (customElements.get('habbo-avatar')) return;

  class HabboAvatar extends HTMLElement {
    static observedAttributes = ['figure', 'direction', 'pose', 'gesture', 'head-only', 'label'];
    constructor() {
      super();
      this._revision = 0;
      this.attachShadow({ mode: 'open' }).innerHTML = `
        <style>
          :host{--avatar-scale:1;display:inline-block;position:relative;width:calc(128px * var(--avatar-scale));height:calc(220px * var(--avatar-scale));flex:none;vertical-align:bottom}
          :host([head-only]){width:48px;height:48px}
          .picture{position:absolute;inset:0;display:grid;place-items:end center}
          img{display:block;width:100%;height:100%;object-fit:contain;image-rendering:pixelated}
          .status{position:absolute;inset:20% 0 0;display:flex;align-items:center;justify-content:center;flex-direction:column;gap:8px;text-align:center;color:inherit;font:12px/1.4 system-ui,sans-serif}
          button{font:inherit;color:inherit;background:transparent;border:1px solid currentColor;border-radius:10px;min-height:44px;padding:5px 12px;cursor:pointer}
          [hidden]{display:none!important}
          :host([head-only]) .status{inset:0;font-size:11px}
        </style>
        <span class="picture"></span>
        <span class="status" role="status"><span class="message">Caricamento…</span><button type="button" hidden>Riprova</button></span>`;
      this._picture = this.shadowRoot.querySelector('.picture');
      this._status = this.shadowRoot.querySelector('.status');
      this._message = this.shadowRoot.querySelector('.message');
      this._retry = this.shadowRoot.querySelector('button');
      this._retry.addEventListener('click', () => this.render(true));
    }
    connectedCallback() { this._source = null; this.scheduleRender(); }
    disconnectedCallback() { this._revision++; this.cancelPending(); }
    attributeChangedCallback(name, oldValue, value) {
      if (oldValue !== value && this.isConnected) this.scheduleRender();
    }
    set outfit(value) { this._outfit = normalize(value); this.scheduleRender(); }
    get outfit() { return { ...(this._outfit || defaults) }; }
    scheduleRender() {
      if (this._scheduled) return;
      this._scheduled = true;
      queueMicrotask(() => { this._scheduled = false; if (this.isConnected) this.render(); });
    }
    cancelPending() {
      clearTimeout(this._timeout);
      if (this._pending) {
        this._pending.onload = this._pending.onerror = null;
        this._pending.removeAttribute('src');
        this._pending = null;
      }
    }
    render(force = false) {
      const label = this.getAttribute('label') || 'Personaggio Habbo';
      const source = url({
        figure: this.getAttribute('figure'), outfit: this._outfit,
        direction: this.getAttribute('direction') ?? 2,
        pose: this.getAttribute('pose') || this._outfit?.pose,
        gesture: this.getAttribute('gesture'), headOnly: this.hasAttribute('head-only')
      });
      const current = this._picture.querySelector('img');
      if (current) current.alt = label;
      if (this._pending) this._pending.alt = label;
      if (!force && this._source === source) return;
      this.cancelPending();
      const revision = ++this._revision;
      this._source = source;
      this.dataset.state = 'loading';
      this.setAttribute('aria-busy', 'true');
      this._status.hidden = false;
      this._message.textContent = this.hasAttribute('head-only') ? '…' : 'Caricamento…';
      this._retry.hidden = true;
      // Preserve the previous sprite while a new look loads; only the newest request may replace it.
      if (current) this._status.hidden = true;
      const img = new Image();
      img.alt = label;
      img.decoding = 'async';
      img.referrerPolicy = 'no-referrer';
      const finish = loaded => {
        if (revision !== this._revision || !this.isConnected) return;
        clearTimeout(this._timeout);
        this._pending = null;
        img.onload = img.onerror = null;
        this.removeAttribute('aria-busy');
        this.dataset.state = loaded ? 'loaded' : 'error';
        this._status.hidden = loaded;
        if (loaded) {
          this._picture.replaceChildren(img);
        } else {
          img.removeAttribute('src');
          this._picture.replaceChildren();
          this._message.textContent = this.hasAttribute('head-only') ? '—' : 'Avatar non disponibile';
          this._retry.hidden = this.hasAttribute('head-only');
        }
        this.dispatchEvent(new CustomEvent(loaded ? 'avatar-load' : 'avatar-error', { bubbles: true }));
      };
      img.onload = () => finish(img.naturalWidth > 0);
      img.onerror = () => finish(false);
      this._pending = img;
      this._timeout = setTimeout(() => finish(false), 25000);
      img.src = source;
    }
  }
  customElements.define('habbo-avatar', HabboAvatar);
})();
