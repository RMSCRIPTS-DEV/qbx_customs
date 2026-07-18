const app = document.getElementById('app');
const panel = document.getElementById('panel');
const titleEl = document.getElementById('title');
const subtitleEl = document.getElementById('subtitle');
const listEl = document.getElementById('list');
const toolbar = document.getElementById('toolbar');
const crumb = document.getElementById('crumb');
const helpBar = document.getElementById('helpBar');
const helpPrompts = document.getElementById('helpPrompts');

let state = {
  visible: false,
  title: 'RM-CUSTOMS',
  subtitle: 'Customize your vehicle',
  canGoBack: false,
  crumb: '',
  items: [],
  activeIndex: 0,
};

function iconSvg(kind) {
  const icons = {
    performance: '<path d="M13 2 3 14h9l-1 8 10-12h-9l1-8z"/>',
    parts: '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>',
    colors: '<path d="M12 22a1 1 0 0 1 0-20 10 7 0 0 1 10 9 5 5 0 0 1-5 5h-2.25a1.75 1.75 0 0 0-1.4 2.8l.3.4a1.75 1.75 0 0 1-1.4 2.8z"/><circle cx="13.5" cy="6.5" r=".5" fill="currentColor"/><circle cx="17.5" cy="10.5" r=".5" fill="currentColor"/><circle cx="6.5" cy="12.5" r=".5" fill="currentColor"/><circle cx="8.5" cy="7.5" r=".5" fill="currentColor"/>',
    extras: '<rect width="7" height="7" x="3" y="3" rx="1"/><rect width="7" height="7" x="14" y="3" rx="1"/><rect width="7" height="7" x="14" y="14" rx="1"/><rect width="7" height="7" x="3" y="14" rx="1"/>',
    repair: '<path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/>',
    wheels: '<circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="3"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3"/>',
    paint: '<path d="m14.622 17.897-10.68-2.913"/><path d="M18.376 2.622a1 1 0 1 1 3.002 3.002L17.36 9.643a.5.5 0 0 0 0 .707l.944.944a2.41 2.41 0 0 1 0 3.408l-.944.944a.5.5 0 0 1-.707 0L8.354 7.348a.5.5 0 0 1 0-.707l.944-.944a2.41 2.41 0 0 1 3.408 0l.944.944a.5.5 0 0 0 .707 0z"/><path d="M9 8c-1.804 2.71-3.915 3.501-6 3.493a.986.986 0 0 0 .63.887C4.89 13.088 6 14.652 6 17c0 1.093.564 2.06 1.276 3"/>',
    neon: '<path d="M9.937 15.5A2 2 0 0 0 8.5 14.063l-6.135-1.582a.5.5 0 0 1 0-.962L8.5 9.936A2 2 0 0 0 9.937 8.5l1.582-6.135a.5.5 0 0 1 .963 0L14.063 8.5A2 2 0 0 0 15.5 9.937l6.135 1.581a.5.5 0 0 1 0 .964L15.5 14.063a2 2 0 0 0-1.437 1.437l-1.582 6.135a.5.5 0 0 1-.963 0z"/>',
    default: '<path d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.4 2.9A3.7 3.7 0 0 0 2 12v4c0 .6.4 1 1 1h2"/><circle cx="7" cy="17" r="2"/><path d="M9 17h6"/><circle cx="17" cy="17" r="2"/>',
  };
  const path = icons[kind] || icons.default;
  return `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">${path}</svg>`;
}

function chevronSvg() {
  return `<svg class="customs-item__chevron" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>`;
}

function setVisible(visible) {
  state.visible = visible;
  if (visible) {
    app.classList.add('app--visible');
    app.setAttribute('aria-hidden', 'false');
    requestAnimationFrame(() => panel.classList.add('customs-panel--open'));
  } else {
    panel.classList.remove('customs-panel--open');
    app.setAttribute('aria-hidden', 'true');
    setTimeout(() => {
      if (!state.visible) app.classList.remove('app--visible');
    }, 300);
  }
}

function currentValueLabel(item) {
  if (!item.values || !item.values.length) return '';
  const idx = Math.max(0, Math.min(item.values.length - 1, (item.selected || 1) - 1));
  return item.values[idx] || '';
}

function valueProgress(item) {
  if (!item.values || !item.values.length) return { text: '', current: 0, total: 0, pct: 0 };
  const total = item.values.length;
  const current = Math.max(1, Math.min(total, item.selected || 1));
  const pct = total > 1 ? ((current - 1) / (total - 1)) * 100 : 100;
  return {
    text: `${current} / ${total}`,
    current,
    total,
    pct,
  };
}

function escapeHtml(value) {
  return String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function scrollActiveIntoView() {
  const active = listEl.querySelector('.customs-item--active');
  if (active) {
    active.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
  }
}

function render() {
  titleEl.textContent = state.title || 'RM-CUSTOMS';
  subtitleEl.textContent = state.subtitle || 'Customize your vehicle';

  if (state.canGoBack) {
    toolbar.classList.remove('hidden');
    crumb.textContent = state.crumb || '';
  } else {
    toolbar.classList.add('hidden');
  }

  listEl.innerHTML = '';

  if (!state.items.length) {
    const empty = document.createElement('div');
    empty.className = 'customs-empty';
    empty.textContent = 'No options available';
    listEl.appendChild(empty);
    return;
  }

  state.items.forEach((item, index) => {
    const card = document.createElement('div');
    const isActive = state.activeIndex === index;
    const isCategory = item.type === 'nav';
    const isRepair = item.type === 'repair';
    const hasValues = !isCategory && !isRepair && item.values && item.values.length;
    const progress = hasValues ? valueProgress(item) : null;

    card.className = 'customs-item';
    if (isCategory) card.classList.add('customs-item--category');
    if (isRepair) card.classList.add('customs-item--repair');
    if (isActive) card.classList.add('customs-item--active');

    let meta = '';
    if (isCategory) meta = 'Press ENTER to open';
    else if (isRepair) meta = 'Press ENTER to repair';
    else if (hasValues) meta = currentValueLabel(item);
    else meta = item.price || '';

    card.innerHTML = `
      <div class="customs-item__row">
        <div class="customs-item__select-bar" aria-hidden="true"></div>
        <div class="customs-item__icon">${iconSvg(item.icon || item.type || 'default')}</div>
        <div class="customs-item__body">
          <div class="customs-item__info">
            <p class="customs-item__name">${escapeHtml(item.label)}</p>
            <p class="customs-item__meta">${escapeHtml(meta)}</p>
          </div>
          ${item.price ? `<span class="customs-item__price">${escapeHtml(item.price)}</span>` : ''}
          ${isCategory ? chevronSvg() : ''}
        </div>
      </div>
      ${hasValues && isActive ? `
        <div class="customs-item__controls">
          <div class="customs-item__variant">
            <div class="customs-item__variant-top">
              <span class="customs-item__variant-label">Variant</span>
              <span class="customs-item__variant-count">${escapeHtml(progress.text)}</span>
            </div>
            <div class="customs-item__variant-track">
              <div class="customs-item__variant-fill" style="width:${progress.pct}%"></div>
            </div>
          </div>
          <div class="customs-item__selector">
            <span class="customs-item__arrow-label">A</span>
            <div class="customs-item__value">
              <span class="customs-item__value-text">${escapeHtml(currentValueLabel(item))}</span>
            </div>
            <span class="customs-item__arrow-label">D</span>
          </div>
          <div class="customs-item__buy-hint">
            <span class="customs-panel__kbd">ENTER</span>
            <span>Purchase</span>
          </div>
        </div>
      ` : ''}
      ${isRepair && isActive ? `
        <div class="customs-item__controls">
          <div class="customs-item__buy-hint customs-item__buy-hint--repair">
            <span class="customs-panel__kbd">ENTER</span>
            <span>Repair vehicle</span>
          </div>
        </div>
      ` : ''}
    `;

    listEl.appendChild(card);
  });

  requestAnimationFrame(scrollActiveIntoView);
}

function applyView(data) {
  state.title = data.title || 'RM-CUSTOMS';
  state.subtitle = data.subtitle || 'Customize your vehicle';
  state.canGoBack = Boolean(data.canGoBack);
  state.crumb = data.crumb || '';
  state.items = Array.isArray(data.items) ? data.items : [];
  state.activeIndex = Math.max(0, (data.activeIndex || 1) - 1);
  render();
}

function applySelection(data) {
  if (Array.isArray(data.items)) {
    state.items = data.items;
  }
  if (data.activeIndex != null) {
    state.activeIndex = Math.max(0, data.activeIndex - 1);
  }
  render();
}

function applyItemUpdate(data) {
  const index = (data.index || 1) - 1;
  if (data.item && state.items[index]) {
    state.items[index] = data.item;
  }
  if (data.activeIndex != null) {
    state.activeIndex = Math.max(0, data.activeIndex - 1);
  }
  render();
}

function setHelp(data = {}) {
  const visible = Boolean(data.visible);
  const prompts = Array.isArray(data.prompts) ? data.prompts : [];

  helpPrompts.innerHTML = '';
  prompts.forEach((prompt) => {
    const key = String(prompt.key || '');
    const wide = key.length > 3;
    const el = document.createElement('div');
    el.className = 'help-bar__prompt';
    el.innerHTML = `
      <span class="help-bar__key${wide ? ' help-bar__key--wide' : ''}">${escapeHtml(key)}</span>
      <span class="help-bar__label">${escapeHtml(prompt.label || '')}</span>
    `;
    helpPrompts.appendChild(el);
  });

  if (visible) {
    helpBar.classList.add('help-bar--open');
    helpBar.setAttribute('aria-hidden', 'false');
  } else {
    helpBar.classList.remove('help-bar--open');
    helpBar.setAttribute('aria-hidden', 'true');
  }
}

window.addEventListener('message', (event) => {
  const { action, data } = event.data || {};
  if (action === 'setVisible') {
    setVisible(Boolean(data));
    return;
  }
  if (action === 'setView') {
    applyView(data || {});
    if (!state.visible) setVisible(true);
    return;
  }
  if (action === 'setSelection') {
    applySelection(data || {});
    return;
  }
  if (action === 'updateItem') {
    applyItemUpdate(data || {});
    return;
  }
  if (action === 'setHelp') {
    setHelp(data || {});
  }
});
