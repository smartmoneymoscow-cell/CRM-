// ===== Crazy Trout Arena CRM — Full Prototype =====
(function(){
'use strict';

// ===== IMAGE MAPPING =====
const IMG = {
  logo: 'assets/img_000.png',
  phoneLogo1: 'assets/img_001.png',
  phoneLogo2: 'assets/img_002.png',
  phoneLogo3: 'assets/img_003.png',
  phoneLogo4: 'assets/img_004.png',
  pondMap: 'assets/img_005.jpeg',
  profilePhoto: 'assets/img_006.jpeg',
  catchBadge: 'assets/img_007.png',
  webScreenshot1: 'assets/img_008.png',
  webScreenshot2: 'assets/img_009.png',
  webScreenshot3: 'assets/img_010.png',
  webScreenshot4: 'assets/img_011.png',
  navIcon1: 'assets/img_012.jpeg',
  mapThumb: 'assets/img_013.jpeg',
  secPhoto1: 'assets/img_014.jpeg',
  secPhoto2: 'assets/img_015.jpeg',
  secPhoto3: 'assets/img_016.jpeg',
  secPhoto4: 'assets/img_017.jpeg',
  navIcon2: 'assets/img_018.jpeg',
  navIcon3: 'assets/img_019.jpeg',
  profileTop: 'assets/img_020.jpeg',
  qrCode: 'assets/img_021.png',
  userAvatar: 'assets/img_022.jpeg',
  rankGold: 'assets/img_023.jpeg',
  rankSilver: 'assets/img_024.jpeg',
  rankBronze: 'assets/img_025.jpeg',
  rank4: 'assets/img_026.jpeg',
  rank5: 'assets/img_027.jpeg',
  rank6: 'assets/img_028.jpeg',
  rtCard: 'assets/img_029.png',
  rtCatch1: 'assets/img_030.png',
  rtCatch2: 'assets/img_031.png',
  rtCatch3: 'assets/img_032.png',
  rtCatch4: 'assets/img_033.png',
  rtCatch5: 'assets/img_034.png',
  bonusUser: 'assets/img_035.jpeg',
  bonusPrize1: 'assets/img_036.jpeg',
  bonusPrize2: 'assets/img_037.jpeg',
  bonusPrize3: 'assets/img_038.jpeg',
  bonusPrize4: 'assets/img_039.jpeg',
  bonusPrize5: 'assets/img_040.jpeg',
  bonusPrize6: 'assets/img_041.jpeg',
  bonusPrize7: 'assets/img_042.jpeg',
  bonusPrize8: 'assets/img_043.jpeg',
  adminMap: 'assets/img_044.jpeg',
  adminSearch: 'assets/img_045.jpeg',
  adminFinance: 'assets/img_046.jpeg',
  adminNav1: 'assets/img_047.jpeg',
  adminMapThumb: 'assets/img_048.jpeg',
  adminNav2: 'assets/img_049.jpeg',
  rcptClient: 'assets/img_050.jpeg',
  rcptAvatar: 'assets/img_051.jpeg',
  adminNav3: 'assets/img_052.jpeg',
  adminNav4: 'assets/img_053.jpeg',
  adminNav5: 'assets/img_054.jpeg',
  adminNav6: 'assets/img_055.jpeg',
  adminNav7: 'assets/img_056.jpeg',
  catchFish1: 'assets/img_057.png',
  catchFish2: 'assets/img_058.png',
  catchFish3: 'assets/img_059.png',
  catchFish4: 'assets/img_060.png',
  adminProfileNav: 'assets/img_061.jpeg',
  adminProfileBg: 'assets/img_062.jpeg',
};

// ===== SCREEN DEFINITIONS =====
const CLIENT_SCREENS = [
  {id:'c-auth-register', label:'Регистрация', group:'auth'},
  {id:'c-auth-login', label:'Вход', group:'auth'},
  {id:'c-auth-recovery', label:'Восстановление', group:'auth'},
  {id:'c-auth-newpass', label:'Новый пароль', group:'auth'},
  {id:'c-map', label:'Карта пруда', group:'main', nav:true, navLabel:'Карта', navIcon:'map'},
  {id:'c-booking', label:'Бронирование', group:'main', nav:true, navLabel:'Бронирование', navIcon:'calendar'},
  {id:'c-profile', label:'Профиль', group:'main', nav:true, navLabel:'Профиль', navIcon:'user'},
  {id:'c-ratings', label:'Рейтинги', group:'extra'},
  {id:'c-bonuses', label:'Бонусы', group:'extra'},
];

const ADMIN_SCREENS = [
  {id:'a-map', label:'Карта и чек', group:'main', nav:true, navLabel:'Карта', navIcon:'map'},
  {id:'a-receipts', label:'Лента чеков', group:'main', nav:true, navLabel:'Чеки', navIcon:'list'},
  {id:'a-profile', label:'Профиль админа', group:'main', nav:true, navLabel:'Профиль', navIcon:'user'},
  {id:'a-new-receipt', label:'Новый чек', group:'extra'},
  {id:'a-finance', label:'Финансы', group:'extra'},
  {id:'a-expenses', label:'Расходы', group:'extra'},
  {id:'a-users', label:'Пользователи', group:'extra'},
  {id:'a-stats', label:'Статистика улова', group:'extra'},
];

let currentMode = 'client';
let currentView = 'desktop';
let currentScreen = 'c-auth-register';

// ===== NAV SVG ICONS =====
const NAV_ICONS = {
  map: '<svg viewBox="0 0 24 24"><path d="M9 4L3 6v14l6-2 6 2 6-2V4l-6 2-6-2z"/><path d="M9 4v14M15 6v14"/></svg>',
  calendar: '<svg viewBox="0 0 24 24"><rect x="4" y="5" width="16" height="16" rx="2"/><path d="M8 3v4M16 3v4M4 10h16"/></svg>',
  user: '<svg viewBox="0 0 24 24"><circle cx="12" cy="8" r="3.5"/><path d="M5 20c1.5-4 4.5-5.5 7-5.5s5.5 1.5 7 5.5"/></svg>',
  list: '<svg viewBox="0 0 24 24"><path d="M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01"/></svg>',
  settings: '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 01-2.83 2.83l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/></svg>',
};

// ===== SCREEN HTML TEMPLATES =====
function getScreenHTML(screenId) {
  const screens = {

// ──── CLIENT: Регистрация ────
'c-auth-register': `
<div class="ph-header">
  <div style="width:16px"></div>
  <div class="ph-title">Регистрация</div>
  <div style="width:16px"></div>
</div>
<div style="text-align:center;margin-bottom:16px;">
  <img src="${IMG.phoneLogo1}" style="width:86px;margin-bottom:10px;" alt="logo">
</div>
<div class="field-label">Имя</div>
<div class="field-input" contenteditable="true" data-placeholder="Алексей">Алексей</div>
<div class="field-label">Телефон</div>
<div class="field-input" contenteditable="true" data-placeholder="+7 900 123-45-67">+7 900 123-45-67</div>
<div class="field-label">Пароль</div>
<div class="field-input" contenteditable="true" data-placeholder="••••••••">••••••••</div>
<div class="strength-row">
  <div class="strength-seg"></div><div class="strength-seg"></div>
  <div class="strength-seg"></div><div class="strength-seg off"></div>
</div>
<div class="strength-label">Надёжный пароль</div>
<div class="field-label">Подтвердите пароль</div>
<div class="field-input" contenteditable="true" data-placeholder="••••••••">••••••••</div>
<div class="btn-block primary" onclick="go('c-auth-login')">Создать аккаунт</div>
<div class="link-center" onclick="go('c-auth-login')">Уже есть аккаунт? Войти</div>
`,

// ──── CLIENT: Вход ────
'c-auth-login': `
<div class="ph-header">
  <div style="width:16px"></div>
  <div class="ph-title">Вход</div>
  <div style="width:16px"></div>
</div>
<div style="text-align:center;margin-bottom:16px;">
  <img src="${IMG.phoneLogo2}" style="width:86px;margin-bottom:10px;" alt="logo">
</div>
<div class="field-label">Телефон</div>
<div class="field-input" contenteditable="true">+7 900 123-45-67</div>
<div class="field-label">Пароль</div>
<div class="field-input" contenteditable="true">••••••••</div>
<div class="btn-block primary" onclick="go('c-map')">Войти</div>
<div class="link-center" onclick="go('c-auth-recovery')">Забыли пароль?</div>
<div class="link-center muted" onclick="go('c-auth-register')">Нет аккаунта? Регистрация</div>
`,

// ──── CLIENT: Восстановление ────
'c-auth-recovery': `
<div class="ph-header">
  <div class="link-center" onclick="go('c-auth-login')" style="font-size:11px">← Назад</div>
  <div class="ph-title">Восстановление</div>
  <div style="width:16px"></div>
</div>
<div style="text-align:center;margin-bottom:16px;">
  <img src="${IMG.phoneLogo3}" style="width:86px;margin-bottom:10px;" alt="logo">
</div>
<div class="field-label">Телефон</div>
<div class="field-input" contenteditable="true">+7 900 123-45-67</div>
<div class="btn-block primary" onclick="go('c-auth-newpass')">Получить код</div>
`,

// ──── CLIENT: Новый пароль ────
'c-auth-newpass': `
<div class="ph-header">
  <div class="link-center" onclick="go('c-auth-recovery')" style="font-size:11px">← Назад</div>
  <div class="ph-title">Новый пароль</div>
  <div style="width:16px"></div>
</div>
<div style="text-align:center;margin-bottom:12px;">
  <img src="${IMG.phoneLogo4}" style="width:86px;margin-bottom:10px;" alt="logo">
</div>
<div class="field-label">Код из SMS</div>
<div class="code-row">
  <div class="code-box filled">4</div><div class="code-box filled">7</div>
  <div class="code-box filled">2</div><div class="code-box">_</div>
  <div class="code-box">_</div><div class="code-box">_</div>
</div>
<div class="timer-note">Повторный код через 0:24</div>
<div class="field-label">Новый пароль</div>
<div class="field-input" contenteditable="true">••••••••</div>
<div class="strength-row">
  <div class="strength-seg"></div><div class="strength-seg"></div>
  <div class="strength-seg off"></div><div class="strength-seg off"></div>
</div>
<div class="strength-label" style="color:var(--gold)">Средний</div>
<div class="field-label">Подтвердите пароль</div>
<div class="field-input" contenteditable="true">••••••••</div>
<div class="btn-block primary" onclick="go('c-auth-login')">Сохранить</div>
`,

// ──── CLIENT: Карта пруда ────
'c-map': `
<div class="ph-header">
  <div class="ph-title">Карта пруда</div>
</div>
<div class="ph-chips">
  <div class="chip">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="10" height="10"><rect x="3" y="4" width="18" height="18" rx="2"/><path d="M16 2v4M8 2v4M3 10h18"/></svg>
    12 июля
  </div>
  <div class="chip">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="10" height="10"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 3"/></svg>
    06:00
  </div>
</div>
<div class="pond-svg-wrap">
  <img src="${IMG.pondMap}" alt="Карта пруда">
</div>
<div class="legend">
  <div class="legend-item"><div class="legend-dot" style="background:#3FA66B"></div> Свободно 11</div>
  <div class="legend-item"><div class="legend-dot" style="background:#E89829"></div> Занято 5</div>
</div>
<div class="btn-book" onclick="go('c-booking')">Выбрать сектор</div>
`,

// ──── CLIENT: Бронирование ────
'c-booking': `
<div class="ph-header">
  <div class="link-center" onclick="go('c-map')" style="font-size:11px">← Назад</div>
  <div class="ph-title">Бронирование</div>
  <div style="width:16px"></div>
</div>
<div class="field-label">Дата</div>
<div class="field-val">12 июля 2026, суббота</div>
<div class="field-label">Время</div>
<div class="field-val" style="display:flex;justify-content:space-between;">
  <span>06:00</span><span style="color:var(--muted)">▾</span>
</div>
<div class="field-label">Сектор</div>
<div class="field-val">№ 07 · Северный берег</div>
<div class="field-label">Тип клиента</div>
<div class="field-val" style="display:flex;justify-content:space-between;">
  <span>Стандарт</span><span style="color:var(--muted)">▾</span>
</div>
<div class="rows">
  <div class="price-row"><span>Тариф «Стандарт»</span><span>750 ₽</span></div>
  <div class="price-total"><span>Итого</span><span>750 ₽</span></div>
</div>
<div class="btn-pay" onclick="go('c-profile')">Оплатить · ЮKassa</div>
`,

// ──── CLIENT: Профиль ────
'c-profile': `
<div class="ph-header">
  <div style="width:16px"></div>
  <div class="ph-title">Профиль</div>
  <div style="width:16px"></div>
</div>
<div class="profile-card-dark">
  <div style="display:flex;align-items:center;gap:12px;text-align:left;">
    <img src="${IMG.profilePhoto}" style="width:44px;height:44px;border-radius:50%;object-fit:cover;" alt="avatar">
    <div>
      <div class="profile-name">Алексей Козлов</div>
      <div class="profile-phone">+7 900 123-45-67</div>
    </div>
  </div>
</div>
<div class="stats-row">
  <div class="stat-card"><div class="stat-num">12</div><div class="stat-label">Поездок</div></div>
  <div class="stat-card"><div class="stat-num">47</div><div class="stat-label">Кг улова</div></div>
  <div class="stat-card"><div class="stat-num">850</div><div class="stat-label">Бонусов</div></div>
</div>
<div class="loyalty-card">
  <div class="loyalty-header"><span>🏆 Программа лояльности</span><span class="loyalty-level">Золото</span></div>
  <div class="loyalty-bar"><div class="loyalty-fill" style="width:70%"></div></div>
  <div class="loyalty-hint">До платины: 3 поездки</div>
</div>
<div class="menu-list">
  <div class="menu-item" onclick="go('c-ratings')"><span>📊</span><span>Рейтинги</span></div>
  <div class="menu-item" onclick="go('c-bonuses')"><span>🎁</span><span>Мои бонусы</span></div>
  <div class="menu-item"><span>⚙️</span><span>Настройки</span></div>
  <div class="menu-item"><span>💬</span><span>Поддержка</span></div>
</div>
<div class="btn-block outline" onclick="go('c-auth-login')" style="margin-top:10px">Выйти</div>
`,

// ──── CLIENT: Рейтинги ────
'c-ratings': `
<div class="ph-header">
  <div class="link-center" onclick="go('c-profile')" style="font-size:11px">← Назад</div>
  <div class="ph-title">Рейтинги</div>
  <div style="width:16px"></div>
</div>
<div style="display:flex;gap:6px;margin-bottom:14px;">
  <div class="pill pill-green">🏆 Топ рыбаков</div>
  <div class="pill pill-blue">🐟 Топ улов</div>
</div>
<div style="display:flex;align-items:center;gap:10px;padding:10px;background:#fff;border:1.5px solid var(--hair);border-radius:12px;margin-bottom:8px;">
  <img src="${IMG.rankGold}" style="width:32px;height:32px;border-radius:50%;object-fit:cover;" alt="">
  <div style="flex:1"><div style="font-weight:800;font-size:12px">Иван Петров</div><div style="font-size:9px;color:var(--muted)">32 поездки · 128 кг</div></div>
  <div style="font-family:'Inter Tight';font-weight:800;font-size:18px;color:var(--gold)">1</div>
</div>
<div style="display:flex;align-items:center;gap:10px;padding:10px;background:#fff;border:1.5px solid var(--hair);border-radius:12px;margin-bottom:8px;">
  <img src="${IMG.rankSilver}" style="width:32px;height:32px;border-radius:50%;object-fit:cover;" alt="">
  <div style="flex:1"><div style="font-weight:800;font-size:12px">Дмитрий Сидоров</div><div style="font-size:9px;color:var(--muted)">28 поездок · 95 кг</div></div>
  <div style="font-family:'Inter Tight';font-weight:800;font-size:18px;color:#B7B2A2">2</div>
</div>
<div style="display:flex;align-items:center;gap:10px;padding:10px;background:#fff;border:1.5px solid var(--hair);border-radius:12px;margin-bottom:8px;">
  <img src="${IMG.rankBronze}" style="width:32px;height:32px;border-radius:50%;object-fit:cover;" alt="">
  <div style="flex:1"><div style="font-weight:800;font-size:12px">Сергей Иванов</div><div style="font-size:9px;color:var(--muted)">24 поездки · 82 кг</div></div>
  <div style="font-family:'Inter Tight';font-weight:800;font-size:18px;color:#A0785A">3</div>
</div>
<div style="display:flex;align-items:center;gap:10px;padding:10px;background:#fff;border:1.5px solid var(--hair);border-radius:12px;margin-bottom:8px;border-color:var(--orange);">
  <img src="${IMG.userAvatar}" style="width:32px;height:32px;border-radius:50%;object-fit:cover;" alt="">
  <div style="flex:1"><div style="font-weight:800;font-size:12px">Алексей Козлов (Вы)</div><div style="font-size:9px;color:var(--muted)">12 поездок · 47 кг</div></div>
  <div style="font-family:'Inter Tight';font-weight:800;font-size:18px;color:var(--orange)">7</div>
</div>
`,

// ──── CLIENT: Бонусы ────
'c-bonuses': `
<div class="ph-header">
  <div class="link-center" onclick="go('c-profile')" style="font-size:11px">← Назад</div>
  <div class="ph-title">Мои бонусы</div>
  <div style="width:16px"></div>
</div>
<div class="balance-card">
  <div class="balance-label">✦ Личный баланс</div>
  <div class="balance-num">850</div>
  <div class="balance-sub">бонусных баллов</div>
</div>
<div style="font-size:10px;font-weight:700;letter-spacing:0.08em;text-transform:uppercase;color:var(--muted);margin-bottom:10px;">Призы</div>
<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-bottom:14px;">
  <div style="background:#fff;border:1.5px solid var(--hair);border-radius:12px;padding:10px;text-align:center;">
    <img src="${IMG.bonusPrize1}" style="width:40px;height:40px;border-radius:8px;object-fit:cover;margin-bottom:6px;" alt="">
    <div style="font-size:9px;font-weight:700;">Удочка</div>
    <div style="font-size:8px;color:var(--orange);font-weight:700;">200 ✦</div>
  </div>
  <div style="background:#fff;border:1.5px solid var(--hair);border-radius:12px;padding:10px;text-align:center;">
    <img src="${IMG.bonusPrize2}" style="width:40px;height:40px;border-radius:8px;object-fit:cover;margin-bottom:6px;" alt="">
    <div style="font-size:9px;font-weight:700;">Набор</div>
    <div style="font-size:8px;color:var(--orange);font-weight:700;">350 ✦</div>
  </div>
  <div style="background:#fff;border:1.5px solid var(--hair);border-radius:12px;padding:10px;text-align:center;">
    <img src="${IMG.bonusPrize3}" style="width:40px;height:40px;border-radius:8px;object-fit:cover;margin-bottom:6px;" alt="">
    <div style="font-size:9px;font-weight:700;">Шапка</div>
    <div style="font-size:8px;color:var(--orange);font-weight:700;">150 ✦</div>
  </div>
  <div style="background:#fff;border:1.5px solid var(--hair);border-radius:12px;padding:10px;text-align:center;">
    <img src="${IMG.bonusPrize4}" style="width:40px;height:40px;border-radius:8px;object-fit:cover;margin-bottom:6px;" alt="">
    <div style="font-size:9px;font-weight:700;">Футболка</div>
    <div style="font-size:8px;color:var(--orange);font-weight:700;">500 ✦</div>
  </div>
  <div style="background:#fff;border:1.5px solid var(--hair);border-radius:12px;padding:10px;text-align:center;">
    <img src="${IMG.bonusPrize5}" style="width:40px;height:40px;border-radius:8px;object-fit:cover;margin-bottom:6px;" alt="">
    <div style="font-size:9px;font-weight:700;">Кепка</div>
    <div style="font-size:8px;color:var(--orange);font-weight:700;">180 ✦</div>
  </div>
  <div style="background:#fff;border:1.5px solid var(--hair);border-radius:12px;padding:10px;text-align:center;">
    <img src="${IMG.bonusPrize6}" style="width:40px;height:40px;border-radius:8px;object-fit:cover;margin-bottom:6px;" alt="">
    <div style="font-size:9px;font-weight:700;">Термос</div>
    <div style="font-size:8px;color:var(--orange);font-weight:700;">300 ✦</div>
  </div>
</div>
<div style="font-size:10px;font-weight:700;letter-spacing:0.08em;text-transform:uppercase;color:var(--muted);margin-bottom:10px;">История начислений</div>
<div style="display:flex;justify-content:space-between;font-size:10px;padding:6px 0;border-bottom:1px solid var(--hair);"><span>Бронирование #07891</span><span style="color:var(--green);font-weight:700">+50 ✦</span></div>
<div style="display:flex;justify-content:space-between;font-size:10px;padding:6px 0;border-bottom:1px solid var(--hair);"><span>Бронирование #06734</span><span style="color:var(--green);font-weight:700">+45 ✦</span></div>
<div style="display:flex;justify-content:space-between;font-size:10px;padding:6px 0;"><span>Обмен на удочку</span><span style="color:var(--ember);font-weight:700">-200 ✦</span></div>
`,

// ──── ADMIN: Карта и чек ────
'a-map': `
<div class="ph-header">
  <div class="ph-title">Карта пруда</div>
  <div style="font-size:9px;color:var(--muted)">Админ</div>
</div>
<div class="ph-chips">
  <div class="chip">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="10" height="10"><rect x="3" y="4" width="18" height="18" rx="2"/><path d="M16 2v4M8 2v4M3 10h18"/></svg>
    12 июля
  </div>
  <div class="chip">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="10" height="10"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 3"/></svg>
    06:00
  </div>
</div>
<div class="pond-svg-wrap">
  <img src="${IMG.pondMap}" alt="Карта пруда">
</div>
<div class="legend">
  <div class="legend-item"><div class="legend-dot" style="background:#3FA66B"></div> Свободно 11</div>
  <div class="legend-item"><div class="legend-dot" style="background:#E89829"></div> Занято 5</div>
</div>
<div class="btn-book" onclick="go('a-new-receipt')">Новый чек</div>
`,

// ──── ADMIN: Новый чек ────
'a-new-receipt': `
<div class="ph-header">
  <div class="link-center" onclick="go('a-map')" style="font-size:11px">← Назад</div>
  <div class="ph-title">Новый чек</div>
  <div style="width:16px"></div>
</div>
<div class="field-label">Сектор</div>
<div class="field-val">№ 07 · Северный берег</div>
<div class="field-label">Клиент</div>
<div style="display:flex;align-items:center;gap:8px;margin-bottom:12px;">
  <img src="${IMG.rcptClient}" style="width:28px;height:28px;border-radius:50%;object-fit:cover;" alt="">
  <div class="field-val" style="margin-bottom:0;flex:1">Алексей Козлов</div>
</div>
<div class="field-label">Тариф</div>
<div class="field-val" style="display:flex;justify-content:space-between;"><span>Стандарт</span><span style="color:var(--muted)">▾</span></div>
<div class="field-label">Время</div>
<div class="field-val">06:00 — 14:00</div>
<div class="rows">
  <div class="price-row"><span>Тариф «Стандарт»</span><span>750 ₽</span></div>
  <div class="price-row"><span>Аренда удочки</span><span>200 ₽</span></div>
  <div class="price-total"><span>Итого</span><span>950 ₽</span></div>
</div>
<div class="btn-pay" onclick="go('a-receipts')">Создать чек</div>
`,

// ──── ADMIN: Лента чеков ────
'a-receipts': `
<div class="ph-header">
  <div class="ph-title">Лента чеков</div>
  <div style="font-size:9px;color:var(--muted)">12 июля</div>
</div>
<div class="history-card">
  <div class="history-top"><span class="history-code">#07891</span><span class="history-status done">Оплачен</span></div>
  <div class="history-row"><span>Клиент</span><span>Алексей Козлов</span></div>
  <div class="history-row"><span>Сектор</span><span>№ 07</span></div>
  <div class="history-row"><span>Сумма</span><span style="font-weight:700">950 ₽</span></div>
</div>
<div class="history-card">
  <div class="history-top"><span class="history-code">#07890</span><span class="history-status done">Оплачен</span></div>
  <div class="history-row"><span>Клиент</span><span>Дмитрий С.</span></div>
  <div class="history-row"><span>Сектор</span><span>№ 03</span></div>
  <div class="history-row"><span>Сумма</span><span style="font-weight:700">750 ₽</span></div>
</div>
<div class="history-card">
  <div class="history-top"><span class="history-code">#07889</span><span class="history-status pending">Ожидание</span></div>
  <div class="history-row"><span>Клиент</span><span>Сергей И.</span></div>
  <div class="history-row"><span>Сектор</span><span>№ 12</span></div>
  <div class="history-row"><span>Сумма</span><span style="font-weight:700">1 200 ₽</span></div>
</div>
<div class="history-card">
  <div class="history-top"><span class="history-code">#07888</span><span class="history-status done">Оплачен</span></div>
  <div class="history-row"><span>Клиент</span><span>Мария В.</span></div>
  <div class="history-row"><span>Сектор</span><span>№ 05</span></div>
  <div class="history-row"><span>Сумма</span><span style="font-weight:700">750 ₽</span></div>
</div>
`,

// ──── ADMIN: Профиль ────
'a-profile': `
<div class="ph-header">
  <div style="width:16px"></div>
  <div class="ph-title">Профиль</div>
  <div style="width:16px"></div>
</div>
<div class="profile-card-dark">
  <div style="display:flex;align-items:center;gap:12px;text-align:left;">
    <img src="${IMG.rcptAvatar}" style="width:44px;height:44px;border-radius:50%;object-fit:cover;" alt="">
    <div>
      <div class="profile-name">Менеджер</div>
      <div class="profile-phone">Пруд «Лесной»</div>
    </div>
  </div>
</div>
<div class="stats-row">
  <div class="stat-card"><div class="stat-num">24</div><div class="stat-label">Чеков</div></div>
  <div class="stat-card"><div class="stat-num">18K</div><div class="stat-label">Выручка</div></div>
  <div class="stat-card"><div class="stat-num">16</div><div class="stat-label">Клиентов</div></div>
</div>
<div class="menu-list">
  <div class="menu-item" onclick="go('a-finance')"><span>💰</span><span>Финансы</span></div>
  <div class="menu-item" onclick="go('a-expenses')"><span>📋</span><span>Расходы</span></div>
  <div class="menu-item" onclick="go('a-users')"><span>👥</span><span>Пользователи</span></div>
  <div class="menu-item" onclick="go('a-stats')"><span>📊</span><span>Статистика улова</span></div>
  <div class="menu-item"><span>⚙️</span><span>Настройки</span></div>
</div>
<div class="btn-block outline" onclick="go('c-auth-login')" style="margin-top:10px">Выйти</div>
`,

// ──── ADMIN: Финансы ────
'a-finance': `
<div class="ph-header">
  <div class="link-center" onclick="go('a-profile')" style="font-size:11px">← Назад</div>
  <div class="ph-title">Финансы</div>
  <div style="width:16px"></div>
</div>
<div style="display:flex;gap:4px;margin-bottom:14px;background:#F4F0E8;border-radius:8px;padding:3px;">
  <div style="flex:1;text-align:center;padding:6px;font-size:10px;font-weight:700;background:#fff;border-radius:6px;box-shadow:0 1px 3px rgba(0,0,0,0.06);">День</div>
  <div style="flex:1;text-align:center;padding:6px;font-size:10px;font-weight:500;color:var(--muted);">Неделя</div>
  <div style="flex:1;text-align:center;padding:6px;font-size:10px;font-weight:500;color:var(--muted);">Месяц</div>
</div>
<div class="stats-row">
  <div class="stat-card"><div class="stat-num">18K</div><div class="stat-label">Выручка</div></div>
  <div class="stat-card"><div class="stat-num">2.4K</div><div class="stat-label">Расходы</div></div>
  <div class="stat-card"><div class="stat-num">15.6K</div><div class="stat-label">Прибыль</div></div>
</div>
<div style="font-size:10px;font-weight:700;letter-spacing:0.08em;text-transform:uppercase;color:var(--muted);margin-bottom:10px;">По дням</div>
<div class="chart-bars">
  <div class="bar-col"><div class="bar" style="height:40%"><span>12K</span></div><small>Пн</small></div>
  <div class="bar-col"><div class="bar" style="height:55%"><span>15K</span></div><small>Вт</small></div>
  <div class="bar-col"><div class="bar" style="height:35%"><span>10K</span></div><small>Ср</small></div>
  <div class="bar-col"><div class="bar" style="height:70%"><span>18K</span></div><small>Чт</small></div>
  <div class="bar-col"><div class="bar" style="height:90%"><span>24K</span></div><small>Пт</small></div>
  <div class="bar-col"><div class="bar" style="height:100%"><span>28K</span></div><small>Сб</small></div>
  <div class="bar-col"><div class="bar" style="height:80%"><span>22K</span></div><small>Вс</small></div>
</div>
`,

// ──── ADMIN: Расходы ────
'a-expenses': `
<div class="ph-header">
  <div class="link-center" onclick="go('a-profile')" style="font-size:11px">← Назад</div>
  <div class="ph-title">Расходы</div>
  <div style="width:16px"></div>
</div>
<div class="history-card">
  <div class="history-top"><span class="history-code">Корм для рыбы</span><span style="font-size:10px;font-weight:700">3 500 ₽</span></div>
  <div class="history-row"><span>Поставщик</span><span>АкваФерм</span></div>
  <div class="history-row"><span>Дата</span><span>12 июля 2026</span></div>
</div>
<div class="history-card">
  <div class="history-top"><span class="history-code">Уборка территории</span><span style="font-size:10px;font-weight:700">2 000 ₽</span></div>
  <div class="history-row"><span>Подрядчик</span><span>ЧистоМир</span></div>
  <div class="history-row"><span>Дата</span><span>11 июля 2026</span></div>
</div>
<div class="history-card">
  <div class="history-top"><span class="history-code">Электричество</span><span style="font-size:10px;font-weight:700">4 200 ₽</span></div>
  <div class="history-row"><span>Период</span><span>Июнь 2026</span></div>
  <div class="history-row"><span>Дата оплаты</span><span>10 июля 2026</span></div>
</div>
<div class="btn-block primary" style="margin-top:10px">+ Добавить расход</div>
`,

// ──── ADMIN: Пользователи ────
'a-users': `
<div class="ph-header">
  <div class="link-center" onclick="go('a-profile')" style="font-size:11px">← Назад</div>
  <div class="ph-title">Пользователи</div>
  <div style="width:16px"></div>
</div>
<div class="field-input" style="margin-bottom:14px;color:var(--muted);font-size:10px;" contenteditable="true">🔍 Поиск по имени или телефону...</div>
<div style="display:flex;align-items:center;gap:10px;padding:10px;background:#fff;border:1.5px solid var(--hair);border-radius:12px;margin-bottom:8px;">
  <img src="${IMG.userAvatar}" style="width:32px;height:32px;border-radius:50%;object-fit:cover;" alt="">
  <div style="flex:1"><div style="font-weight:800;font-size:12px">Алексей Козлов</div><div style="font-size:9px;color:var(--muted)">+7 900 123-45-67 · Золото</div></div>
  <div style="font-size:9px;color:var(--green);font-weight:700">12 поездок</div>
</div>
<div style="display:flex;align-items:center;gap:10px;padding:10px;background:#fff;border:1.5px solid var(--hair);border-radius:12px;margin-bottom:8px;">
  <img src="${IMG.rankGold}" style="width:32px;height:32px;border-radius:50%;object-fit:cover;" alt="">
  <div style="flex:1"><div style="font-weight:800;font-size:12px">Иван Петров</div><div style="font-size:9px;color:var(--muted)">+7 912 555-12-34 · Платина</div></div>
  <div style="font-size:9px;color:var(--green);font-weight:700">32 поездки</div>
</div>
<div style="display:flex;align-items:center;gap:10px;padding:10px;background:#fff;border:1.5px solid var(--hair);border-radius:12px;margin-bottom:8px;">
  <img src="${IMG.rankSilver}" style="width:32px;height:32px;border-radius:50%;object-fit:cover;" alt="">
  <div style="flex:1"><div style="font-weight:800;font-size:12px">Дмитрий Сидоров</div><div style="font-size:9px;color:var(--muted)">+7 903 777-88-99 · Золото</div></div>
  <div style="font-size:9px;color:var(--green);font-weight:700">28 поездок</div>
</div>
<div style="display:flex;align-items:center;gap:10px;padding:10px;background:#fff;border:1.5px solid var(--hair);border-radius:12px;margin-bottom:8px;">
  <img src="${IMG.rankBronze}" style="width:32px;height:32px;border-radius:50%;object-fit:cover;" alt="">
  <div style="flex:1"><div style="font-weight:800;font-size:12px">Сергей Иванов</div><div style="font-size:9px;color:var(--muted)">+7 926 111-22-33 · Серебро</div></div>
  <div style="font-size:9px;color:var(--green);font-weight:700">24 поездки</div>
</div>
`,

// ──── ADMIN: Статистика улова ────
'a-stats': `
<div class="ph-header">
  <div class="link-center" onclick="go('a-profile')" style="font-size:11px">← Назад</div>
  <div class="ph-title">Статистика улова</div>
  <div style="width:16px"></div>
</div>
<div style="display:flex;gap:4px;margin-bottom:14px;background:#F4F0E8;border-radius:8px;padding:3px;">
  <div style="flex:1;text-align:center;padding:6px;font-size:10px;font-weight:700;background:#fff;border-radius:6px;box-shadow:0 1px 3px rgba(0,0,0,0.06);">Неделя</div>
  <div style="flex:1;text-align:center;padding:6px;font-size:10px;font-weight:500;color:var(--muted);">Месяц</div>
  <div style="flex:1;text-align:center;padding:6px;font-size:10px;font-weight:500;color:var(--muted);">Сезон</div>
</div>
<div style="font-size:10px;font-weight:700;letter-spacing:0.08em;text-transform:uppercase;color:var(--muted);margin-bottom:10px;">По видам рыбы</div>
<div style="display:flex;align-items:center;gap:8px;margin-bottom:8px;">
  <img src="${IMG.catchFish1}" style="width:28px;height:28px;border-radius:6px;object-fit:cover;" alt="">
  <div style="flex:1"><div style="font-size:11px;font-weight:700">Форель</div><div style="height:4px;background:var(--hair);border-radius:2px;margin-top:3px;"><div style="height:100%;width:65%;background:var(--green);border-radius:2px;"></div></div></div>
  <div style="font-size:11px;font-weight:800">42 кг</div>
</div>
<div style="display:flex;align-items:center;gap:8px;margin-bottom:8px;">
  <img src="${IMG.catchFish2}" style="width:28px;height:28px;border-radius:6px;object-fit:cover;" alt="">
  <div style="flex:1"><div style="font-size:11px;font-weight:700">Карп</div><div style="height:4px;background:var(--hair);border-radius:2px;margin-top:3px;"><div style="height:100%;width:45%;background:var(--teal);border-radius:2px;"></div></div></div>
  <div style="font-size:11px;font-weight:800">28 кг</div>
</div>
<div style="display:flex;align-items:center;gap:8px;margin-bottom:8px;">
  <img src="${IMG.catchFish3}" style="width:28px;height:28px;border-radius:6px;object-fit:cover;" alt="">
  <div style="flex:1"><div style="font-size:11px;font-weight:700">Осётр</div><div style="height:4px;background:var(--hair);border-radius:2px;margin-top:3px;"><div style="height:100%;width:30%;background:var(--orange);border-radius:2px;"></div></div></div>
  <div style="font-size:11px;font-weight:800">18 кг</div>
</div>
<div style="display:flex;align-items:center;gap:8px;margin-bottom:14px;">
  <img src="${IMG.catchFish4}" style="width:28px;height:28px;border-radius:6px;object-fit:cover;" alt="">
  <div style="flex:1"><div style="font-size:11px;font-weight:700">Щука</div><div style="height:4px;background:var(--hair);border-radius:2px;margin-top:3px;"><div style="height:100%;width:20%;background:var(--gold);border-radius:2px;"></div></div></div>
  <div style="font-size:11px;font-weight:800">12 кг</div>
</div>
<div style="font-size:10px;font-weight:700;letter-spacing:0.08em;text-transform:uppercase;color:var(--muted);margin-bottom:10px;">Общий улов за неделю</div>
<div class="chart-bars">
  <div class="bar-col"><div class="bar" style="height:50%"><span>14 кг</span></div><small>Пн</small></div>
  <div class="bar-col"><div class="bar" style="height:35%"><span>10 кг</span></div><small>Вт</small></div>
  <div class="bar-col"><div class="bar" style="height:65%"><span>18 кг</span></div><small>Ср</small></div>
  <div class="bar-col"><div class="bar" style="height:45%"><span>12 кг</span></div><small>Чт</small></div>
  <div class="bar-col"><div class="bar" style="height:80%"><span>22 кг</span></div><small>Пт</small></div>
  <div class="bar-col"><div class="bar" style="height:100%"><span>28 кг</span></div><small>Сб</small></div>
  <div class="bar-col"><div class="bar" style="height:70%"><span>19 кг</span></div><small>Вс</small></div>
</div>
`,

  };
  return screens[screenId] || '<div style="padding:20px;text-align:center;color:var(--muted);">Экран в разработке</div>';
}

// ===== NAV BAR HTML =====
function getNavBar(screenId) {
  const screens = currentMode === 'client' ? CLIENT_SCREENS : ADMIN_SCREENS;
  const navItems = screens.filter(s => s.nav);
  let html = '<div class="nav-bar">';
  navItems.forEach(item => {
    const isActive = screenId === item.id;
    html += `<div class="nav-item${isActive?' active':''}" onclick="go('${item.id}')">
      ${NAV_ICONS[item.navIcon]||''}
      <span>${item.navLabel}</span>
    </div>`;
  });
  html += '</div>';
  return html;
}

// ===== DESKTOP WEB LAYOUTS =====
function getDesktopHTML(screenId) {
  // For desktop view, show web-app layout with sidebar navigation
  const screens = currentMode === 'client' ? CLIENT_SCREENS : ADMIN_SCREENS;
  const screen = screens.find(s => s.id === screenId);
  if (!screen) return '';

  // Auth screens: centered card
  if (screen.group === 'auth') {
    return `<div style="display:flex;align-items:center;justify-content:center;width:100%;min-height:100%;">
      <div style="background:var(--paper);border-radius:16px;padding:40px 36px;width:400px;box-shadow:0 4px 24px rgba(0,0,0,0.12);">
        <div style="text-align:center;margin-bottom:24px;">
          <img src="${IMG.logo}" style="width:120px;margin-bottom:16px;" alt="logo">
          <h2 style="font-family:'Inter Tight';font-weight:800;font-size:22px;margin-bottom:4px;">${screen.label}</h2>
        </div>
        ${getScreenHTML(screenId).replace(/onclick="go\('[^']+'\)"|class="ph-[^"]*"|class="link-center[^"]*"|class="code-row"[\s\S]*?<\/div>/g, (m) => {
          // Adapt mobile HTML for desktop
          return m.replace(/font-size:11px/g,'font-size:13px').replace(/font-size:10px/g,'font-size:12px');
        })}
      </div>
    </div>`;
  }

  // Main screens: full-width app layout
  return `<div style="width:100%;max-width:900px;padding:24px;">
    <div style="margin-bottom:20px;">
      <div class="brand"><div class="brand-dot"></div><div class="brand-name">CRAZY TROUT</div><div class="brand-sub">ARENA CRM</div></div>
      <div class="eyebrow">${currentMode==='client'?'Client':'Admin'} · ${screen.label}</div>
      <h1>${screen.label}</h1>
    </div>
    <div style="display:flex;gap:24px;">
      <div style="flex:1;min-width:0;">
        ${getScreenHTML(screenId)}
      </div>
      <div style="width:280px;flex-shrink:0;">
        <div class="phone-frame" style="width:280px;height:600px;border-radius:28px;">
          <div class="phone-status"><span>9:41</span><div class="phone-dots"><span></span><span></span><span></span></div></div>
          <div class="phone-body" style="font-size:85%;">
            ${getScreenHTML(screenId)}
            ${getNavBar(screenId)}
          </div>
        </div>
      </div>
    </div>
  </div>`;
}

// ===== RENDER =====
function render() {
  const phoneScreen = document.getElementById('phoneScreen');
  const desktopScreen = document.getElementById('desktopScreen');
  const phoneFrame = document.getElementById('phoneFrame');
  const viewportInner = document.getElementById('viewportInner');
  const clientSidebar = document.getElementById('clientSidebar');
  const adminSidebar = document.getElementById('adminSidebar');

  // Toggle mode
  if (currentMode === 'client') {
    clientSidebar.style.display = 'flex';
    adminSidebar.style.display = 'none';
  } else {
    clientSidebar.style.display = 'none';
    adminSidebar.style.display = 'flex';
  }

  // Toggle view
  if (currentView === 'mobile') {
    viewportInner.className = 'viewport-inner mobile-mode';
    phoneFrame.style.display = 'flex';
    desktopScreen.style.display = 'none';
    // Render phone screen
    phoneScreen.innerHTML = getScreenHTML(currentScreen) + getNavBar(currentScreen);
  } else {
    viewportInner.className = 'viewport-inner desktop-mode';
    phoneFrame.style.display = 'none';
    desktopScreen.style.display = 'flex';
    desktopScreen.innerHTML = getDesktopHTML(currentScreen);
  }

  // Update sidebar active state
  document.querySelectorAll('.sidebar-link').forEach(l => {
    l.classList.toggle('active', l.dataset.screen === currentScreen);
  });

  // Update select
  const sel = document.getElementById('screenSelect');
  sel.value = currentScreen;
}

// ===== GLOBAL NAV =====
window.go = function(screenId) {
  currentScreen = screenId;
  render();
};

// ===== INIT =====
function init() {
  // Build sidebar navs
  const clientNav = document.getElementById('clientNav');
  const adminNav = document.getElementById('adminNav');

  function buildNav(screens, container) {
    let group = '';
    screens.forEach(s => {
      if (s.group !== group) {
        group = s.group;
        const label = group === 'auth' ? 'Авторизация' : group === 'main' ? 'Основное' : 'Дополнительно';
        container.innerHTML += `<div style="font-size:9px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;color:#5A5548;padding:8px 10px 4px;margin-top:8px;">${label}</div>`;
      }
      container.innerHTML += `<button class="sidebar-link" data-screen="${s.id}" onclick="go('${s.id}')">${s.label}</button>`;
    });
  }
  buildNav(CLIENT_SCREENS, clientNav);
  buildNav(ADMIN_SCREENS, adminNav);

  // Build select dropdown
  const sel = document.getElementById('screenSelect');
  function addGroup(label, screens) {
    const optgroup = document.createElement('optgroup');
    optgroup.label = label;
    screens.forEach(s => {
      const opt = document.createElement('option');
      opt.value = s.id;
      opt.textContent = s.label;
      optgroup.appendChild(opt);
    });
    sel.appendChild(optgroup);
  }
  addGroup('👤 Клиент', CLIENT_SCREENS);
  addGroup('⚙️ Админ', ADMIN_SCREENS);
  sel.addEventListener('change', () => { currentScreen = sel.value; render(); });

  // Mode toggle
  document.getElementById('modeToggle').addEventListener('click', e => {
    const btn = e.target.closest('[data-mode]');
    if (!btn) return;
    document.querySelectorAll('#modeToggle .toggle-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    currentMode = btn.dataset.mode;
    currentScreen = currentMode === 'client' ? 'c-auth-register' : 'a-map';
    render();
  });

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

document.addEventListener('DOMContentLoaded', init);
})();
