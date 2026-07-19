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
  // Lucide icon paths (https://lucide.dev)
  const icons = {
    performance: '<path d="M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z"/>',
    parts: '<path d="M12 20a8 8 0 1 0 0-16 8 8 0 0 0 0 16Z"/><path d="M12 14a2 2 0 1 0 0-4 2 2 0 0 0 0 4Z"/><path d="M12 2v2"/><path d="M12 22v-2"/><path d="m17 20.66-1-1.73"/><path d="M11 10.27 7 3.34"/><path d="m20.66 17-1.73-1"/><path d="m3.34 7 1.73 1"/><path d="M14 12h8"/><path d="M2 12h2"/><path d="m20.66 7-1.73 1"/><path d="m3.34 17 1.73-1"/><path d="m17 3.34-1 1.73"/><path d="m11 13.73-4 6.93"/>',
    colors: '<circle cx="13.5" cy="6.5" r=".5" fill="currentColor"/><circle cx="17.5" cy="10.5" r=".5" fill="currentColor"/><circle cx="8.5" cy="7.5" r=".5" fill="currentColor"/><circle cx="6.5" cy="12.5" r=".5" fill="currentColor"/><path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10c.926 0 1.648-.746 1.648-1.688 0-.437-.18-.835-.437-1.125-.29-.289-.438-.652-.438-1.125a1.64 1.64 0 0 1 1.668-1.668h1.996c3.051 0 5.555-2.503 5.555-5.554C21.965 6.012 17.461 2 12 2z"/>',
    palette: '<circle cx="13.5" cy="6.5" r=".5" fill="currentColor"/><circle cx="17.5" cy="10.5" r=".5" fill="currentColor"/><circle cx="8.5" cy="7.5" r=".5" fill="currentColor"/><circle cx="6.5" cy="12.5" r=".5" fill="currentColor"/><path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10c.926 0 1.648-.746 1.648-1.688 0-.437-.18-.835-.437-1.125-.29-.289-.438-.652-.438-1.125a1.64 1.64 0 0 1 1.668-1.668h1.996c3.051 0 5.555-2.503 5.555-5.554C21.965 6.012 17.461 2 12 2z"/>',
    extras: '<rect width="7" height="7" x="3" y="3" rx="1"/><rect width="7" height="7" x="14" y="3" rx="1"/><rect width="7" height="7" x="14" y="14" rx="1"/><rect width="7" height="7" x="3" y="14" rx="1"/>',
    repair: '<path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/>',
    checkout: '<rect width="20" height="14" x="2" y="5" rx="2"/><line x1="2" x2="22" y1="10" y2="10"/>',
    cash: '<circle cx="12" cy="12" r="10"/><path d="M16 8h-6a2 2 0 1 0 0 4h4a2 2 0 1 1 0 4H8"/><path d="M12 18V6"/>',
    card: '<rect width="20" height="14" x="2" y="5" rx="2"/><line x1="2" x2="22" y1="10" y2="10"/>',
    wheels: '<circle cx="12" cy="12" r="10"/><path d="M6 12c0-1.7.7-3.2 1.8-4.2"/><circle cx="12" cy="12" r="2"/><path d="M18 12c0 1.7-.7 3.2-1.8 4.2"/>',
    paint: '<path d="m14.622 17.897-10.68-2.913"/><path d="M18.376 2.622a1 1 0 1 1 3.002 3.002L17.36 9.643a.5.5 0 0 0 0 .707l.944.944a2.41 2.41 0 0 1 0 3.408l-.944.944a.5.5 0 0 1-.707 0L8.354 7.348a.5.5 0 0 1 0-.707l.944-.944a2.41 2.41 0 0 1 3.408 0l.944.944a.5.5 0 0 0 .707 0z"/><path d="M9 8c-1.804 2.71-3.915 3.501-6 3.493a.986.986 0 0 0 .63.887C4.89 13.088 6 14.652 6 17c0 1.093.564 2.06 1.276 3"/>',
    neon: '<path d="M9.937 15.5A2 2 0 0 0 8.5 14.063l-6.135-1.582a.5.5 0 0 1 0-.962L8.5 9.936A2 2 0 0 0 9.937 8.5l1.582-6.135a.5.5 0 0 1 .963 0L14.063 8.5A2 2 0 0 0 15.5 9.937l6.135 1.581a.5.5 0 0 1 0 .964L15.5 14.063a2 2 0 0 0-1.437 1.437l-1.582 6.135a.5.5 0 0 1-.963 0z"/><path d="M20 3v4"/><path d="M22 5h-4"/><path d="M4 17v2"/><path d="M5 18H3"/>',
    spoiler: '<path d="M12.83 2.18a2 2 0 0 0-1.66 0L2.6 6.08a1 1 0 0 0 0 1.83l8.58 3.91a2 2 0 0 0 1.66 0l8.58-3.9a1 1 0 0 0 0-1.83z"/><path d="M2 12a1 1 0 0 0 .58.91l8.6 3.91a2 2 0 0 0 1.65 0l8.58-3.9A1 1 0 0 0 22 12"/><path d="M2 17a1 1 0 0 0 .58.91l8.6 3.91a2 2 0 0 0 1.65 0l8.58-3.9A1 1 0 0 0 22 17"/>',
    'bumper-front': '<rect width="18" height="18" x="3" y="3" rx="2"/><path d="M3 15h18"/>',
    'bumper-rear': '<rect width="18" height="18" x="3" y="3" rx="2"/><path d="M3 9h18"/>',
    skirt: '<line x1="3" x2="21" y1="12" y2="12"/><polyline points="8 8 12 4 16 8"/><polyline points="16 16 12 20 8 16"/>',
    exhaust: '<path d="M12.8 19.6A2 2 0 1 0 14 16H2"/><path d="M17.5 8a2.5 2.5 0 1 1 2 4H2"/><path d="M9.8 4.4A2 2 0 1 1 11 8H2"/>',
    cage: '<rect width="18" height="18" x="3" y="3" rx="2"/><path d="M3 9h18"/><path d="M3 15h18"/><path d="M9 3v18"/><path d="M15 3v18"/>',
    grille: '<rect width="7" height="7" x="3" y="3" rx="1"/><rect width="7" height="7" x="14" y="3" rx="1"/><rect width="7" height="7" x="14" y="14" rx="1"/><rect width="7" height="7" x="3" y="14" rx="1"/>',
    hood: '<rect width="18" height="18" x="3" y="3" rx="2"/><path d="M3 12h18"/>',
    'fender-left': '<rect width="18" height="18" x="3" y="3" rx="2"/><path d="M9 3v18"/>',
    'fender-right': '<rect width="18" height="18" x="3" y="3" rx="2"/><path d="M15 3v18"/>',
    roof: '<path d="M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8"/><path d="M3 10a2 2 0 0 1 .709-1.528l7-5.999a2 2 0 0 1 2.582 0l7 5.999A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>',
    engine: '<path d="M12 20a8 8 0 1 0 0-16 8 8 0 0 0 0 16Z"/><path d="M12 14a2 2 0 1 0 0-4 2 2 0 0 0 0 4Z"/><path d="M12 2v2"/><path d="M12 22v-2"/><path d="m17 20.66-1-1.73"/><path d="M11 10.27 7 3.34"/><path d="m20.66 17-1.73-1"/><path d="m3.34 7 1.73 1"/><path d="M14 12h8"/><path d="M2 12h2"/><path d="m20.66 7-1.73 1"/><path d="m3.34 17 1.73-1"/><path d="m17 3.34-1 1.73"/><path d="m11 13.73-4 6.93"/>',
    brakes: '<circle cx="12" cy="12" r="10"/><rect x="9" y="9" width="6" height="6" rx="1"/>',
    transmission: '<line x1="6" x2="6" y1="3" y2="15"/><circle cx="18" cy="6" r="3"/><circle cx="6" cy="18" r="3"/><path d="M18 9a9 9 0 0 1-9 9"/>',
    horns: '<path d="m3 11 18-5v12L3 14v-3z"/><path d="M11.6 16.8a3 3 0 1 1-5.8-1.6"/>',
    suspension: '<path d="m21 16-4 4-4-4"/><path d="M17 20V4"/><path d="m3 8 4-4 4 4"/><path d="M7 4v16"/>',
    armor: '<path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"/>',
    nitrous: '<path d="M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z"/>',
    turbo: '<path d="M10.827 16.379a6.082 6.082 0 0 1-8.618-7.002l5.412 1.45a6.082 6.082 0 0 1 7.002-8.618l-1.45 5.412a6.082 6.082 0 0 1 8.618 7.002l-5.412-1.45a6.082 6.082 0 0 1-7.002 8.618l1.45-5.412Z"/><path d="M12 12v.01"/>',
    subwoofer: '<rect width="16" height="20" x="4" y="2" rx="2"/><path d="M12 6h.01"/><circle cx="12" cy="14" r="4"/><path d="M12 14h.01"/>',
    hydraulics: '<path d="M12 2v20"/><path d="m8 18 4 4 4-4"/><path d="m8 6 4-4 4 4"/>',
    plate: '<rect width="20" height="12" x="2" y="6" rx="2"/><path d="M12 12h.01"/><path d="M17 12h.01"/><path d="M7 12h.01"/>',
    vanity: '<rect width="20" height="14" x="2" y="5" rx="2"/><line x1="2" x2="22" y1="10" y2="10"/>',
    trim: '<line x1="22" x2="2" y1="6" y2="6"/><line x1="22" x2="2" y1="18" y2="18"/><line x1="6" x2="6" y1="2" y2="22"/><line x1="18" x2="18" y1="2" y2="22"/>',
    'trim-b': '<line x1="21" x2="14" y1="4" y2="4"/><line x1="10" x2="3" y1="4" y2="4"/><line x1="21" x2="12" y1="12" y2="12"/><line x1="8" x2="3" y1="12" y2="12"/><line x1="21" x2="16" y1="20" y2="20"/><line x1="12" x2="3" y1="20" y2="20"/><line x1="14" x2="14" y1="2" y2="6"/><line x1="8" x2="8" y1="10" y2="14"/><line x1="16" x2="16" y1="18" y2="22"/>',
    ornament: '<path d="M6 3h12l4 6-10 13L2 9Z"/><path d="M11 3 8 9l4 13 4-13-3-6"/><path d="M2 9h20"/>',
    dashboard: '<rect width="7" height="9" x="3" y="3" rx="1"/><rect width="7" height="5" x="14" y="3" rx="1"/><rect width="7" height="9" x="14" y="12" rx="1"/><rect width="7" height="5" x="3" y="16" rx="1"/>',
    dial: '<path d="m12 14 4-4"/><path d="M3.34 19a10 10 0 1 1 17.32 0"/>',
    'door-speaker': '<path d="M11 4.702a.705.705 0 0 0-1.203-.498L6.413 7.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298z"/><path d="M16 9a5 5 0 0 1 0 6"/><path d="M19.364 18.364a9 9 0 0 0 0-12.728"/>',
    seats: '<path d="M19 9V6a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2v3"/><path d="M3 16a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-5a2 2 0 0 0-4 0v1.5a.5.5 0 0 1-.5.5h-9a.5.5 0 0 1-.5-.5V11a2 2 0 0 0-4 0z"/><path d="M5 18v2"/><path d="M19 18v2"/>',
    steering: '<circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="1"/>',
    shifter: '<circle cx="12" cy="12" r="3"/><line x1="3" x2="9" y1="12" y2="12"/><line x1="15" x2="21" y1="12" y2="12"/>',
    plaque: '<path d="M3.85 8.62a4 4 0 0 1 4.78-4.77 4 4 0 0 1 6.74 0 4 4 0 0 1 4.78 4.78 4 4 0 0 1 0 6.74 4 4 0 0 1-4.77 4.78 4 4 0 0 1-6.75 0 4 4 0 0 1-4.78-4.77 4 4 0 0 1 0-6.76Z"/>',
    speaker: '<path d="M2 10v3"/><path d="M6 6v11"/><path d="M10 3v18"/><path d="M14 8v7"/><path d="M18 5v13"/><path d="M22 10v3"/>',
    trunk: '<path d="M11 21.73a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73z"/><path d="M12 22V12"/><path d="m3.3 7 7.703 4.734a2 2 0 0 0 1.994 0L20.7 7"/><path d="m7.5 4.27 9 5.15"/>',
    'engine-block': '<ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M3 5v14a9 3 0 0 0 18 0V5"/>',
    filter: '<path d="M6 12H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><path d="M6 8h12"/><path d="M18.3 17.7a2.5 2.5 0 0 1-3.16 3.83 2.53 2.53 0 0 1-1.14-2V12"/><path d="M6.6 15.6A2 2 0 1 0 10 17v-5"/>',
    strut: '<rect width="13" height="7" x="8" y="3" rx="1"/><path d="m2 9 3 3-3 3"/><rect width="13" height="7" x="8" y="14" rx="1"/>',
    arch: '<rect width="18" height="18" x="3" y="3" rx="2"/><path d="M12 9v6"/><path d="M16 15v6"/><path d="M16 3v6"/><path d="M3 15h18"/><path d="M3 9h18"/><path d="M8 15v6"/><path d="M8 3v6"/>',
    aerial: '<path d="M2 12 7 2"/><path d="m7 12 5-10"/><path d="m12 12 5-10"/><path d="m17 12 5-10"/><path d="M4.5 7h15"/><path d="M12 16v6"/>',
    fuel: '<line x1="3" x2="15" y1="22" y2="22"/><line x1="4" x2="14" y1="9" y2="9"/><path d="M14 22V4a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v18"/><path d="M14 13h2a2 2 0 0 1 2 2v2a2 2 0 0 0 2 2a2 2 0 0 0 2-2V9.83a2 2 0 0 0-.59-1.42L18 5"/>',
    door: '<path d="M13 4h3a2 2 0 0 1 2 2v14"/><path d="M2 20h3"/><path d="M13 20h9"/><path d="M10 12v.01"/><path d="M13 4.562v16.157a1 1 0 0 1-1.242.97L5 20V5.562a2 2 0 0 1 1.515-1.94l4-1A2 2 0 0 1 13 4.561Z"/>',
    lightbar: '<path d="M7 18v-6a5 5 0 1 1 10 0v6"/><path d="M5 21a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-1a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2z"/><path d="M21 12h1"/><path d="M18.5 4.5 18 5"/><path d="M2 12h1"/><path d="M12 2v1"/><path d="m4.929 4.929.707.707"/><path d="M12 12v6"/>',
    xenon: '<circle cx="12" cy="12" r="4"/><path d="M12 2v2"/><path d="M12 20v2"/><path d="m4.93 4.93 1.41 1.41"/><path d="m17.66 17.66 1.41 1.41"/><path d="M2 12h2"/><path d="M20 12h2"/><path d="m6.34 17.66-1.41 1.41"/><path d="m19.07 4.93-1.41 1.41"/>',
    pearlescent: '<path d="M6 3h12l4 6-10 13L2 9Z"/><path d="M11 3 8 9l4 13 4-13-3-6"/><path d="M2 9h20"/>',
    tint: '<path d="M7 16.3c2.2 0 4-1.83 4-4.05 0-1.16-.57-2.26-1.71-3.19S7.29 6.75 7 5.3c-.29 1.45-1.14 2.84-2.29 3.76S3 11.1 3 12.25c0 2.22 1.8 4.05 4 4.05z"/><path d="M12.56 6.6A10.97 10.97 0 0 0 14 3.02c.5 2.5 2 4.9 4 6.5s3 3.5 3 5.5a6.98 6.98 0 0 1-11.91 4.97"/>',
    smoke: '<path d="M12.8 19.6A2 2 0 1 0 14 16H2"/><path d="M17.5 8a2.5 2.5 0 1 1 2 4H2"/><path d="M9.8 4.4A2 2 0 1 1 11 8H2"/>',
    interior: '<path d="M19 9V6a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2v3"/><path d="M3 16a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-5a2 2 0 0 0-4 0v1.5a.5.5 0 0 1-.5.5h-9a.5.5 0 0 1-.5-.5V11a2 2 0 0 0-4 0z"/><path d="M5 18v2"/><path d="M19 18v2"/>',
    livery: '<path d="M12.83 2.18a2 2 0 0 0-1.66 0L2.6 6.08a1 1 0 0 0 0 1.83l8.58 3.91a2 2 0 0 0 1.66 0l8.58-3.9a1 1 0 0 0 0-1.83z"/><path d="M2 12a1 1 0 0 0 .58.91l8.6 3.91a2 2 0 0 0 1.65 0l8.58-3.9A1 1 0 0 0 22 12"/><path d="M2 17a1 1 0 0 0 .58.91l8.6 3.91a2 2 0 0 0 1.65 0l8.58-3.9A1 1 0 0 0 22 17"/>',
    default: '<path d="m21 8-2 2-1.5-3.7A2 2 0 0 0 15.646 5H8.4a2 2 0 0 0-1.903 1.257L5 10 3 8"/><path d="M7 14h.01"/><path d="M17 14h.01"/><rect width="18" height="8" x="3" y="10" rx="2"/><path d="M5 18v2"/><path d="M19 18v2"/>',
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
    const isCheckout = item.type === 'checkout';
    const isPay = item.type === 'pay';
    const hasValues = !isCategory && !isRepair && !isCheckout && !isPay && item.values && item.values.length;
    const progress = hasValues ? valueProgress(item) : null;

    card.className = 'customs-item';
    if (isCategory) card.classList.add('customs-item--category');
    if (isRepair) card.classList.add('customs-item--repair');
    if (isCheckout) card.classList.add('customs-item--checkout');
    if (isPay) card.classList.add('customs-item--pay');
    if (isActive) card.classList.add('customs-item--active');

    let meta = '';
    if (isCategory) meta = 'Press ENTER to open';
    else if (isRepair) meta = 'Press ENTER to repair';
    else if (isCheckout) meta = item.meta || 'Press ENTER to pay';
    else if (isPay) meta = 'Press ENTER to confirm payment';
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
          ${isCategory || isCheckout ? chevronSvg() : ''}
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
            <span>Lock in choice</span>
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
      ${isCheckout && isActive ? `
        <div class="customs-item__controls">
          <div class="customs-item__buy-hint customs-item__buy-hint--checkout">
            <span class="customs-panel__kbd">ENTER</span>
            <span>Choose payment method</span>
          </div>
        </div>
      ` : ''}
      ${isPay && isActive ? `
        <div class="customs-item__controls">
          <div class="customs-item__buy-hint customs-item__buy-hint--checkout">
            <span class="customs-panel__kbd">ENTER</span>
            <span>Pay ${escapeHtml(item.price || '')}</span>
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
