// ===== Crazy Trout Arena CRM — Exact Deck Copy =====
(function(){
'use strict';

// Screen definitions with exact HTML from pitch deck
const SCREENS = {};

// Will be populated from JSON
async function loadScreens() {
  const resp = await fetch('screen_defs.json');
  const data = await resp.json();
  Object.assign(SCREENS, data);
  init();
}

let currentScreen = 's06_0';
let currentView = 'mobile';

// Screen navigation order
const NAV_ORDER = [
  {id:'s06_0', label:'Регистрация', group:'Клиент · Мобильное'},
  {id:'s06_1', label:'Вход', group:'Клиент · Мобильное'},
  {id:'s07_0', label:'Восстановление', group:'Клиент · Мобильное'},
  {id:'s07_1', label:'Новый пароль', group:'Клиент · Мобильное'},
  {id:'s08_0', label:'Карта пруда', group:'Клиент · Мобильное'},
  {id:'s08_1', label:'Бронирование', group:'Клиент · Мобильное'},
  {id:'s09_0', label:'Профиль клиента', group:'Клиент · Мобильное'},
  {id:'s09_1', label:'История посещений', group:'Клиент · Мобильное'},
  {id:'s21_0', label:'Карта пруда · Админ', group:'Админ · Мобильное'},
  {id:'s22_0', label:'Лента чеков · Админ', group:'Админ · Мобильное'},
  {id:'s23_0', label:'Профиль админа', group:'Админ · Мобильное'},
];

// Nav bar templates per screen
const NAV_BARS = {
  // Client mobile nav
  'c': `<div class="nav-bar" style="display:flex;border-top:1px solid var(--hair);padding:8px 0 2px;">
    <div class="nav-item" data-goto="s08_0" style="flex:1;display:flex;flex-direction:column;align-items:center;gap:2px;font-size:8.5px;color:var(--muted);cursor:pointer;background:none;border:none;font-family:inherit;">
      <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M9 4L3 6v14l6-2 6 2 6-2V4l-6 2-6-2z"/><path d="M9 4v14M15 6v14"/></svg>
      Карта
    </div>
    <div class="nav-item" data-goto="s08_1" style="flex:1;display:flex;flex-direction:column;align-items:center;gap:2px;font-size:8.5px;color:var(--muted);cursor:pointer;background:none;border:none;font-family:inherit;">
      <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="5" width="16" height="16" rx="2"/><path d="M8 3v4M16 3v4M4 10h16"/></svg>
      Бронирование
    </div>
    <div class="nav-item" data-goto="s09_0" style="flex:1;display:flex;flex-direction:column;align-items:center;gap:2px;font-size:8.5px;color:var(--muted);cursor:pointer;background:none;border:none;font-family:inherit;">
      <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="3.5"/><path d="M5 20c1.5-4 4.5-5.5 7-5.5s5.5 1.5 7 5.5"/></svg>
      Профиль
    </div>
  </div>`,
  // Admin mobile nav
  'a': `<div class="nav-bar" style="display:flex;border-top:1px solid var(--hair);padding:8px 0 2px;">
    <div class="nav-item" data-goto="s21_0" style="flex:1;display:flex;flex-direction:column;align-items:center;gap:2px;font-size:8.5px;color:var(--muted);cursor:pointer;background:none;border:none;font-family:inherit;">
      <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M9 4L3 6v14l6-2 6 2 6-2V4l-6 2-6-2z"/><path d="M9 4v14M15 6v14"/></svg>
      Карта
    </div>
    <div class="nav-item" data-goto="s22_0" style="flex:1;display:flex;flex-direction:column;align-items:center;gap:2px;font-size:8.5px;color:var(--muted);cursor:pointer;background:none;border:none;font-family:inherit;">
      <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01"/></svg>
      Чеки
    </div>
    <div class="nav-item" data-goto="s23_0" style="flex:1;display:flex;flex-direction:column;align-items:center;gap:2px;font-size:8.5px;color:var(--muted);cursor:pointer;background:none;border:none;font-family:inherit;">
      <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="3.5"/><path d="M5 20c1.5-4 4.5-5.5 7-5.5s5.5 1.5 7 5.5"/></svg>
      Профиль
    </div>
  </div>`
};

function getNavBar(screenId) {
  if (screenId.startsWith('s06') || screenId.startsWith('s07')) return ''; // auth screens no nav
  if (screenId.startsWith('s09_1')) return NAV_BARS['c']; // history has client nav
  if (screenId.startsWith('s0')) return NAV_BARS['c'];
  if (screenId.startsWith('s2')) return NAV_BARS['a'];
  return '';
}

function render() {
  const phoneScreen = document.getElementById('phoneScreen');
  const phoneFrame = document.getElementById('phoneFrame');
  const desktopContent = document.getElementById('desktopContent');

  if (currentView === 'mobile') {
    phoneFrame.style.display = 'flex';
    desktopContent.style.display = 'none';
    const screenData = SCREENS[currentScreen];
    if (screenData) {
      phoneScreen.innerHTML = screenData + getNavBar(currentScreen);
      // Make nav items clickable
      phoneScreen.querySelectorAll('[data-goto]').forEach(el => {
        el.addEventListener('click', () => goTo(el.dataset.goto));
      });
      // Highlight active nav item
      phoneScreen.querySelectorAll('.nav-item').forEach(el => {
        if (el.dataset.goto === currentScreen) {
          el.style.color = 'var(--orange)';
        }
      });
    }
  } else {
    phoneFrame.style.display = 'none';
    desktopContent.style.display = 'block';
    const screenData = SCREENS[currentScreen];
    const meta = NAV_ORDER.find(s => s.id === currentScreen);
    if (screenData) {
      desktopContent.innerHTML = `
        <div style="display:flex;gap:24px;align-items:flex-start;">
          <div style="flex:1;">
            <div class="brand" style="display:flex;align-items:center;gap:10px;margin-bottom:20px;">
              <div style="width:13px;height:13px;border-radius:50%;background:var(--orange);"></div>
              <div style="font-weight:800;font-size:13px;letter-spacing:0.08em;text-transform:uppercase;">CRAZY TROUT</div>
              <div style="font-weight:600;font-size:13px;letter-spacing:0.08em;text-transform:uppercase;color:var(--muted);margin-left:2px;">ARENA CRM</div>
            </div>
            <div style="font-weight:700;font-size:11px;letter-spacing:0.14em;text-transform:uppercase;color:var(--orange);margin-bottom:7px;">${meta ? meta.group : ''}</div>
            <h1 style="font-family:'Inter Tight',sans-serif;font-weight:800;font-size:30px;line-height:1.16;margin-bottom:16px;">${meta ? meta.label : ''}</h1>
            <div style="background:var(--paper);border-radius:16px;padding:24px;box-shadow:0 2px 12px rgba(0,0,0,0.06);max-width:500px;">
              ${screenData}
            </div>
          </div>
          <div style="flex-shrink:0;">
            <div class="phone-frame" style="width:320px;height:693px;border-radius:30px;">
              <div class="phone-status" style="display:flex;justify-content:space-between;align-items:center;padding:10px 16px 2px;font-size:9.5px;font-weight:700;">
                <span>9:41</span>
                <div class="phone-dots" style="display:flex;gap:3px;">
                  <span style="width:3px;height:3px;border-radius:50%;background:#14130F;display:block;"></span>
                  <span style="width:3px;height:3px;border-radius:50%;background:#14130F;display:block;"></span>
                  <span style="width:3px;height:3px;border-radius:50%;background:#14130F;display:block;"></span>
                </div>
              </div>
              <div class="phone-body" style="flex:1;padding:14px 17px 18px;overflow-y:auto;">
                ${screenData}
                ${getNavBar(currentScreen)}
              </div>
            </div>
          </div>
        </div>
      `;
    }
  }

  // Update sidebar
  document.querySelectorAll('.sidebar-link').forEach(l => {
    l.classList.toggle('active', l.dataset.screen === currentScreen);
  });
  document.getElementById('screenSelect').value = currentScreen;
}

window.goTo = function(id) {
  currentScreen = id;
  render();
};

function init() {
  // Build sidebar
  const nav = document.getElementById('sidebarNav');
  let group = '';
  NAV_ORDER.forEach(s => {
    if (s.group !== group) {
      group = s.group;
      nav.innerHTML += `<div style="font-size:9px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;color:#5A5548;padding:8px 10px 4px;margin-top:8px;">${group}</div>`;
    }
    nav.innerHTML += `<button class="sidebar-link" data-screen="${s.id}" onclick="goTo('${s.id}')">${s.label}</button>`;
  });

  // Build select
  const sel = document.getElementById('screenSelect');
  NAV_ORDER.forEach(s => {
    const opt = document.createElement('option');
    opt.value = s.id;
    opt.textContent = s.label;
    sel.appendChild(opt);
  });
  sel.addEventListener('change', () => goTo(sel.value));

  // View toggle
  document.getElementById('viewToggle').addEventListener('click', e => {
    const btn = e.target.closest('[data-view]');
    if (!btn) return;
    document.querySelectorAll('#viewToggle .toggle-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    currentView = btn.dataset.view;
    render();
  });

  render();
}

document.addEventListener('DOMContentLoaded', loadScreens);
})();
