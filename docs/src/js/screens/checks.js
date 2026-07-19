// === Screen: История чеков (точь-в-точь Flutter checks_screen.dart) ===
import { store } from '../core/store.js';
import { tg } from '../core/telegram.js';
import { createFilterDropdown } from '../widgets/filter-dropdown.js';
import { showCalendarPicker } from '../widgets/calendar.js';
import { showClientCard } from '../widgets/client-card.js';
import { printer } from '../services/printer.js';

export function renderChecks() {
  const stats = store.getStats();
  const el = document.createElement('div');
  el.className = 'screen screen-checks';
  el.innerHTML = `
    <div class="screen-title">Чеки</div>
    <div class="search-bar" style="margin-bottom:10px;">
      <span class="search-icon">🔍</span>
      <input type="text" id="checks-search" placeholder="Имя, сумма, телефон, дата" autocomplete="off">
    </div>
    <div id="checks-client-suggestions" class="hidden"></div>
    <div class="filter-bar">
      <div id="checks-period-dropdown"></div>
      <div class="calendar-chip" id="checks-calendar" title="Календарь">📅</div>
      <div class="icon-filter-chip" id="checks-filter-btn" title="Фильтры">⚙️</div>
      <div class="sort-chip" id="checks-sort">
        <div class="sort-trigger" id="sort-trigger" title="Сортировка">↕️</div>
      </div>
    </div>
    <div class="card" style="margin-bottom:var(--sp-lg);">
      <div style="display:flex;justify-content:space-between;">
        <div><div style="font-size:13px;color:var(--kMuted);">Всего чеков</div><div style="font-size:20px;font-weight:700;">${stats.totalReceipts}</div></div>
        <div style="text-align:right;"><div style="font-size:13px;color:var(--kMuted);">Выручка</div><div style="font-size:20px;font-weight:700;color:var(--kGreen);">+${store.formatMoney(stats.totalRevenue)} ₽</div></div>
      </div>
    </div>
    <div id="checks-list"></div>
  `;
  setTimeout(() => { renderChecksList(); initChecksHandlers(); }, 0);
  return el;
}

function renderChecksList(filter = '') {
  const list = document.getElementById('checks-list');
  if (!list) return;
  let receipts = [...store.receipts];
  if (filter) {
    const q = filter.toLowerCase();
    receipts = receipts.filter(r => {
      const client = store.getClientById(r.clientId);
      if (client && (client.name.toLowerCase().includes(q) || client.phone.includes(q))) return true;
      if (r.total.toString().includes(q)) return true;
      if (r.date.includes(q)) return true;
      return false;
    });
  }
  list.innerHTML = receipts.map(r => {
    const client = store.getClientById(r.clientId);
    return `
      <div class="card check-card" data-receipt-id="${r.id}" style="display:flex;align-items:center;gap:12px;padding:12px;margin-bottom:8px;cursor:pointer;">
        ${client ? `<div class="client-avatar" data-client-id="${r.clientId}" style="width:44px;height:44px;border-radius:50%;background:var(--kFill);display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:700;color:var(--kEmber);overflow:hidden;flex-shrink:0;">${client.avatarAsset ? `<img src="${client.avatarAsset}" style="width:100%;height:100%;object-fit:cover;border-radius:50%;">` : store.getClientInitials(client)}</div>` : `<div style="width:44px;height:44px;border-radius:50%;background:var(--kFill);display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0;">👤</div>`}
        <div style="flex:1;min-width:0;">
          <div style="font-weight:700;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${r.isGuest ? 'Гость' : (client?.name || 'Неизвестен')}</div>
          <div style="font-size:12px;color:var(--kMuted2);">${r.date} · ${r.tariffLabel}</div>
        </div>
        <span style="display:inline-flex;padding:2px 6px;font-size:10px;font-weight:700;border-radius:6px;background:${r.fiscal ? 'rgba(232,145,43,0.12)' : 'rgba(140,133,118,0.12)'};color:${r.fiscal ? 'var(--kOrange)' : 'var(--kMuted)'};flex-shrink:0;">${r.fiscal ? 'С ФН' : 'Без ФН'}</span>
        <div style="font-size:15.5px;font-weight:700;color:#3FA66B;white-space:nowrap;">+${store.formatMoney(r.total)} ₽</div>
      </div>
    `;
  }).join('');

  list.querySelectorAll('.check-card').forEach(card => {
    card.addEventListener('click', () => {
      const receipt = store.receipts.find(r => r.id === card.dataset.receiptId);
      if (receipt) showCheckDetail(receipt);
    });
  });
  list.querySelectorAll('.client-avatar').forEach(avatar => {
    avatar.addEventListener('click', (e) => {
      e.stopPropagation();
      showClientCard(parseInt(avatar.dataset.clientId));
      tg.hapticImpact('light');
    });
  });
}

function initChecksHandlers() {
  const searchInput = document.getElementById('checks-search');
  searchInput?.addEventListener('input', e => renderChecksList(e.target.value.trim()));

  const periodContainer = document.getElementById('checks-period-dropdown');
  if (periodContainer) {
    periodContainer.innerHTML = '';
    createFilterDropdown(periodContainer, {
      value: null, label: 'Период',
      items: [
        { value: null, label: 'Нет', isReset: true, enabled: false },
        { value: 'today', label: 'Сегодня' }, { value: 'week', label: 'Неделя' },
        { value: 'month', label: 'Месяц' }, { value: 'quarter', label: 'Квартал' },
        { value: 'all', label: 'Все время' },
      ],
      onChanged: () => renderChecksList(searchInput?.value?.trim() || ''),
    });
  }

  document.getElementById('checks-calendar')?.addEventListener('click', async () => {
    await showCalendarPicker(null);
    renderChecksList(searchInput?.value?.trim() || '');
  });

  document.getElementById('checks-filter-btn')?.addEventListener('click', showFilterDialog);

  // Sort chip
  const sortTrigger = document.getElementById('sort-trigger');
  const sortContainer = document.getElementById('checks-sort');
  let sortOpen = false, sortMenu = null, sortField = 'date', sortDesc = true;
  const sortOptions = [
    { value: 'date', label: 'По дате' }, { value: 'total', label: 'По сумме' },
    { value: 'visits', label: 'По посещениям' }, { value: 'ltv', label: 'По LTV' },
    { value: 'fish', label: 'По улову' },
  ];
  sortTrigger?.addEventListener('click', e => {
    e.stopPropagation();
    if (sortOpen) { closeSort(); return; }
    sortOpen = true;
    sortTrigger.classList.add('active');
    sortMenu = document.createElement('div');
    sortMenu.style.cssText = 'position:absolute;top:calc(100% + 4px);right:0;background:#fff;border:1px solid #EFE8D8;border-radius:10px;box-shadow:0 6px 16px rgba(0,0,0,0.12);z-index:50;padding:4px 0;min-width:170px;';
    sortMenu.innerHTML = sortOptions.map(o => `<div style="padding:10px 12px;font-size:13px;cursor:pointer;display:flex;align-items:center;gap:8px;background:${o.value===sortField?'#EFD9AC':'transparent'};font-weight:${o.value===sortField?'700':'400'};" data-sort="${o.value}">${o.label}${o.value===sortField?`<span style="margin-left:auto;font-size:11px;color:#9C9484;">${sortDesc?'↓':'↑'}</span>`:''}</div>`).join('') + `<div style="border-top:0.5px solid #E7E0D1;margin:4px 0;"></div><div style="padding:10px 12px;font-size:13px;cursor:pointer;color:#9C9484;" data-sort-toggle>${sortDesc?'По убыванию':'По возрастанию'} ↕</div>`;
    sortContainer.appendChild(sortMenu);
    sortMenu.querySelectorAll('[data-sort]').forEach(item => {
      item.addEventListener('click', ev => { ev.stopPropagation(); sortField = item.dataset.sort; closeSort(); renderChecksList(searchInput?.value?.trim()||''); });
    });
    sortMenu.querySelector('[data-sort-toggle]')?.addEventListener('click', ev => { ev.stopPropagation(); sortDesc = !sortDesc; closeSort(); renderChecksList(searchInput?.value?.trim()||''); });
    setTimeout(() => document.addEventListener('click', closeSort), 0);
  });
  function closeSort() { sortOpen = false; sortTrigger?.classList.remove('active'); if (sortMenu) { sortMenu.remove(); sortMenu = null; } document.removeEventListener('click', closeSort); }
}

function showFilterDialog() {
  const overlay = document.createElement('div');
  overlay.className = 'modal-overlay';
  let tmpType = null, tmpTariffs = new Set(), tmpPayments = new Set(), tmpFirstTime = false;
  overlay.innerHTML = `
    <div class="sheet filter-dialog">
      <div style="text-align:center;font-size:18px;font-weight:700;color:var(--kInk);margin-bottom:20px;">Фильтры</div>
      <div class="filter-section"><div class="filter-section-title">Тип чека</div><div class="chip-group"><div class="chip" data-filter-type="fiscal">С ФН</div><div class="chip" data-filter-type="nonfiscal">Без ФН</div></div></div>
      <div class="filter-section"><div class="filter-section-title">Тариф</div><div class="chip-group"><div class="chip" data-filter-tariff="Стандарт">Стандарт</div><div class="chip" data-filter-tariff="Гостевой">Гостевой</div><div class="chip" data-filter-tariff="Пенсионер">Пенсионер</div></div></div>
      <div class="filter-section"><div class="filter-section-title">Способ оплаты</div><div class="chip-group"><div class="chip" data-filter-payment="Наличными">Наличными</div><div class="chip" data-filter-payment="Картой">Картой</div><div class="chip" data-filter-payment="Счет заведения">Счет заведения</div></div></div>
      <div class="filter-checkbox"><input type="checkbox" id="first-time"><label for="first-time" style="font-size:14px;font-weight:500;color:var(--kInk);cursor:pointer;">Первый раз на пруду</label></div>
      <div class="filter-actions"><button class="btn-reset" id="filter-reset">Сбросить</button><button class="btn-apply" id="filter-apply">Применить</button></div>
    </div>
  `;
  document.body.appendChild(overlay);
  overlay.querySelectorAll('.chip').forEach(chip => chip.addEventListener('click', () => { chip.classList.toggle('selected'); tg.hapticSelection(); }));
  overlay.querySelector('#filter-reset')?.addEventListener('click', () => overlay.querySelectorAll('.chip').forEach(c => c.classList.remove('selected')));
  overlay.querySelector('#filter-apply')?.addEventListener('click', () => { overlay.remove(); tg.hapticNotification('success'); });
  overlay.addEventListener('click', e => { if (e.target === overlay) overlay.remove(); });
}

function showCheckDetail(receipt) {
  const client = store.getClientById(receipt.clientId);
  const overlay = document.createElement('div');
  overlay.className = 'modal-overlay';
  const paymentLabels = { cash: 'Наличные', card: 'Карта', account: 'Счёт заведения' };
  overlay.innerHTML = `
    <div class="sheet" style="max-width:340px;">
      <div style="text-align:center;font-size:20px;font-weight:700;margin-bottom:4px;">КАССОВЫЙ ЧЕК</div>
      <div style="text-align:center;font-size:11px;color:var(--kMuted2);margin-bottom:16px;">CRAZY TROUT ARENA</div>
      <div style="font-size:11px;color:var(--kMuted2);text-align:center;margin-bottom:12px;">г. Москва, ул. Прудовая, д. 1<br>ИНН: 7701234567</div>
      <div style="border-top:1px dashed var(--kHairline2);margin:8px 0;"></div>
      <div style="font-size:13px;">
        <div style="display:flex;justify-content:space-between;margin-bottom:4px;"><span style="color:var(--kMuted);">Чек №</span><span>${receipt.id}</span></div>
        <div style="display:flex;justify-content:space-between;margin-bottom:4px;"><span style="color:var(--kMuted);">Дата</span><span>${receipt.date}</span></div>
        <div style="display:flex;justify-content:space-between;margin-bottom:4px;"><span style="color:var(--kMuted);">Тариф</span><span>${receipt.tariffLabel} — ${receipt.tariffPrice} ₽</span></div>
        <div style="display:flex;justify-content:space-between;margin-bottom:4px;"><span style="color:var(--kMuted);">Оплата</span><span>${paymentLabels[receipt.paymentMethod] || receipt.paymentMethod}</span></div>
      </div>
      ${receipt.catches.length ? `<div style="font-weight:700;margin:12px 0 8px;font-size:13px;">УЛОВ</div>${receipt.catches.map(c => { const w = c.kg > 0 ? `${c.kg}кг${c.grams > 0 ? c.grams + 'г' : ''}` : `${c.grams}г`; return `<div style="display:flex;justify-content:space-between;font-size:12px;margin-bottom:4px;"><span>${c.label || c.breedLabel} ${w} × ${c.pricePerKg}₽/кг</span><span style="font-weight:600;">${store.formatMoney(c.sum)} ₽</span></div>`; }).join('')}<div style="border-top:1px dashed var(--kHairline2);margin:8px 0;"></div>` : ''}
      <div style="display:flex;justify-content:space-between;font-size:20px;font-weight:700;"><span>ИТОГО</span><span style="color:var(--kOrange);">${store.formatMoney(receipt.total)} ₽</span></div>
      ${receipt.fiscal ? `<div style="border-top:1px dashed var(--kHairline2);margin:12px 0 8px;"></div><div style="font-size:10px;color:var(--kMuted2);text-align:center;">СНО: УСН доходы<br>ФН: 8710000100412345<br>ФД: ${receipt.fiscalDoc || receipt.id}<br>ФПД: 6789012345<br>Сайт ФНС: nalog.gov.ru</div>` : ''}
      ${client ? `<div style="margin-top:16px;padding:10px;background:var(--kFill);border-radius:12px;display:flex;align-items:center;gap:10px;cursor:pointer;" id="detail-client"><div class="client-avatar" style="width:36px;height:36px;border-radius:50%;background:var(--kFill);display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;color:var(--kEmber);overflow:hidden;flex-shrink:0;">${client.avatarAsset ? `<img src="${client.avatarAsset}" style="width:100%;height:100%;object-fit:cover;border-radius:50%;">` : store.getClientInitials(client)}</div><div style="flex:1;"><div style="font-size:13px;font-weight:600;">${client.name}</div><div style="font-size:11px;color:var(--kMuted2);">${client.phone}</div></div><span style="color:var(--kMuted2);">›</span></div>` : ''}
      <div style="display:flex;gap:12px;margin-top:16px;">
        <button class="btn btn-outline" id="detail-print" style="flex:1;">🖨️ Печать</button>
        <button class="btn btn-ghost btn-full" id="detail-close" style="color:var(--kMuted2);">Закрыть</button>
      </div>
    </div>
  `;
  document.body.appendChild(overlay);
  overlay.querySelector('#detail-close')?.addEventListener('click', () => overlay.remove());
  overlay.addEventListener('click', e => { if (e.target === overlay) overlay.remove(); });
  overlay.querySelector('#detail-client')?.addEventListener('click', () => { overlay.remove(); showClientCard(client.id); });
  overlay.querySelector('#detail-print')?.addEventListener('click', async () => {
    const result = await printer.print(receipt);
    if (result) tg.hapticNotification('success');
    else tg.showAlert('Не удалось напечатать чек.');
  });
}
