// === Screen: История чеков (точь-в-точь Flutter checks_screen.dart) ===
import { store } from '../core/store.js';
import { tg } from '../core/telegram.js';
import { createFilterDropdown } from '../widgets/filter-dropdown.js';
import { showCalendarPicker } from '../widgets/calendar.js';
import { showClientCard } from '../widgets/client-card.js';
import { printer } from '../services/printer.js';

// ── Состояние фильтров (модульные переменные) ──
let _filterType = null;          // 'fiscal' | 'nonfiscal' | null
let _filterTariffs = new Set();  // 'Стандарт', 'Гостевой', 'Пенсионер'
let _filterPayments = new Set(); // 'Наличными', 'Картой', 'Счет заведения'
let _filterFirstTime = false;
let _currentPeriod = null;       // 'today' | 'week' | 'month' | 'quarter' | 'all' | null
let _currentDateRange = null;    // { start: Date, end: Date } | null
let _lastFilterSource = null;    // 'dropdown' | 'calendar' | null
let _sortField = 'date';
let _sortDesc = true;

export function renderChecks() {
  const stats = store.getStats();
  const el = document.createElement('div');
  el.className = 'screen screen-checks';
  el.innerHTML = `
    <div class="screen-title">Чеки</div>
    <div class="search-bar" style="margin-bottom:10px;">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#9C9484" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
      <input type="text" id="checks-search" placeholder="Имя, сумма, телефон, дата" autocomplete="off">
      <svg id="checks-clear" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#9C9484" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="cursor:pointer;display:none;"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
    </div>
    <div id="checks-client-suggestions"></div>
    <div class="filter-bar">
      <div id="checks-period-dropdown"></div>
      <div class="calendar-chip" id="checks-calendar" title="Календарь"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="18" x="3" y="4" rx="2" ry="2"/><line x1="16" x2="16" y1="2" y2="6"/><line x1="8" x2="8" y1="2" y2="6"/><line x1="3" x2="21" y1="10" y2="10"/></svg></div>
      <div class="icon-filter-chip" id="checks-filter-btn" title="Фильтры"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg></div>
      <div class="sort-chip" id="checks-sort">
        <div class="sort-trigger" id="sort-trigger" title="Сортировка"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m7 15 5 5 5-5"/><path d="m7 9 5-5 5 5"/></svg></div>
      </div>
    </div>
    <div id="checks-list"></div>
  `;
  setTimeout(() => { renderChecksList(); initChecksHandlers(); }, 0);
  return el;
}

// ── Проверка попадания в период ──
function isInPeriod(dateStr, period) {
  if (!period) return true;
  const now = new Date();
  const d = new Date(dateStr);
  let start;
  switch (period) {
    case 'today': start = new Date(now.getFullYear(), now.getMonth(), now.getDate()); break;
    case 'week': start = new Date(now - 7 * 86400000); break;
    case 'month': start = new Date(now - 30 * 86400000); break;
    case 'quarter': start = new Date(now - 90 * 86400000); break;
    default: return true;
  }
  return d >= start;
}

// ── Проверка попадания в диапазон дат ──
function isInDateRange(dateStr, range) {
  if (!range || !range.start || !range.end) return true;
  const d = new Date(dateStr); d.setHours(0,0,0,0);
  const s = new Date(range.start); s.setHours(0,0,0,0);
  const e = new Date(range.end); e.setHours(23,59,59,999);
  return d >= s && d <= e;
}

// ── Эффективный период (календарь имеет приоритет если выбран последним) ──
function getEffectivePeriod() {
  if (_lastFilterSource === 'calendar') return null;
  return _currentPeriod;
}

function getEffectiveDateRange() {
  if (_lastFilterSource === 'dropdown') return null;
  return _currentDateRange;
}

function renderChecksList(filter = '') {
  const list = document.getElementById('checks-list');
  if (!list) return;
  let receipts = [...store.receipts];

  // Текстовый поиск
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

  // Фильтр по периоду
  const period = getEffectivePeriod();
  if (period) {
    receipts = receipts.filter(r => isInPeriod(r.date, period));
  }

  // Фильтр по диапазону дат (календарь)
  const dateRange = getEffectiveDateRange();
  if (dateRange) {
    receipts = receipts.filter(r => isInDateRange(r.date, dateRange));
  }

  // Фильтр по типу чека (fiscal / nonfiscal)
  if (_filterType === 'fiscal') {
    receipts = receipts.filter(r => r.fiscal);
  } else if (_filterType === 'nonfiscal') {
    receipts = receipts.filter(r => !r.fiscal);
  }

  // Фильтр по тарифам
  if (_filterTariffs.size > 0) {
    receipts = receipts.filter(r => _filterTariffs.has(r.tariffLabel));
  }

  // Фильтр по способу оплаты
  if (_filterPayments.size > 0) {
    receipts = receipts.filter(r => _filterPayments.has(r.paymentLabel));
  }

  // Фильтр "первый раз на пруду"
  if (_filterFirstTime) {
    receipts = receipts.filter(r => {
      if (r.isGuest) return false;
      const client = store.getClientById(r.clientId);
      return client && client.visits === 1;
    });
  }

  // Сортировка
  receipts.sort((a, b) => {
    let cmp = 0;
    switch (_sortField) {
      case 'total':
        cmp = a.total - b.total;
        break;
      case 'visits': {
        const av = store.getClientById(a.clientId)?.visits || 0;
        const bv = store.getClientById(b.clientId)?.visits || 0;
        cmp = av - bv;
        break;
      }
      case 'ltv': {
        const av = store.getClientLTV(a.clientId);
        const bv = store.getClientLTV(b.clientId);
        cmp = av - bv;
        break;
      }
      case 'fish':
        cmp = a.catches.length - b.catches.length;
        break;
      default: // date
        cmp = a.date.localeCompare(b.date);
    }
    return _sortDesc ? -cmp : cmp;
  });

  list.innerHTML = receipts.length ? receipts.map(r => {
    const client = store.getClientById(r.clientId);
    return `
      <div class="card check-card" data-receipt-id="${r.id}" style="display:flex;align-items:center;gap:12px;padding:12px;margin-bottom:8px;cursor:pointer;">
        ${client ? `<div class="client-avatar" data-client-id="${r.clientId}" style="width:44px;height:44px;border-radius:50%;background:var(--kFill);display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:700;color:var(--kEmber);overflow:hidden;flex-shrink:0;">${client.avatarAsset ? `<img src="${client.avatarAsset}" style="width:100%;height:100%;object-fit:cover;border-radius:50%;">` : store.getClientInitials(client)}</div>` : `<div style="width:44px;height:44px;border-radius:50%;background:var(--kFill);display:flex;align-items:center;justify-content:center;flex-shrink:0;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#9C9484" stroke-width="2"><path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>`}
        <div style="flex:1;min-width:0;">
          <div style="font-weight:700;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${r.isGuest ? 'Гость' : (client?.name || 'Неизвестен')}</div>
          <div style="font-size:12px;color:var(--kMuted2);">${r.date} · ${r.tariffLabel}</div>
        </div>
        <span style="display:inline-flex;padding:2px 6px;font-size:10px;font-weight:700;border-radius:6px;background:${r.fiscal ? 'rgba(232,145,43,0.12)' : 'rgba(140,133,118,0.12)'};color:${r.fiscal ? 'var(--kOrange)' : 'var(--kMuted)'};flex-shrink:0;">${r.fiscal ? 'С ФН' : 'Без ФН'}</span>
        <div style="font-size:15.5px;font-weight:700;color:#3FA66B;white-space:nowrap;">+${store.formatMoney(r.total)} ₽</div>
      </div>
    `;
  }).join('') : `
    <div style="text-align:center;padding:40px 20px;color:var(--kMuted2);font-size:14px;">Нет чеков по заданным условиям</div>
  `;

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
  const clearBtn = document.getElementById('checks-clear');
  const suggestionsDiv = document.getElementById('checks-client-suggestions');

  function updateSuggestions(q) {
    if (!suggestionsDiv) return;
    if (!q) { suggestionsDiv.innerHTML = ''; suggestionsDiv.className = 'hidden'; return; }
    const query = q.toLowerCase();
    const seen = new Set();
    const clients = store.receipts
      .map(r => store.getClientById(r.clientId))
      .filter(c => c && !seen.has(c.id) && (c.name.toLowerCase().includes(query) || c.phone.includes(query)) && seen.add(c.id))
      .sort((a, b) => {
        const aS = a.name.toLowerCase().startsWith(query) ? 0 : 1;
        const bS = b.name.toLowerCase().startsWith(query) ? 0 : 1;
        return aS !== bS ? aS - bS : a.name.localeCompare(b.name);
      })
      .slice(0, 4);
    if (!clients.length) { suggestionsDiv.innerHTML = ''; suggestionsDiv.className = 'hidden'; return; }
    suggestionsDiv.className = 'client-suggestions';
    suggestionsDiv.innerHTML = clients.map(c => `
      <div class="client-suggestion-item" data-name="${c.name}">
        ${store.renderAvatar(c, 36)}
        <div style="flex:1;min-width:0;"><div style="font-size:14px;font-weight:600;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${c.name}</div><div style="font-size:12px;color:var(--kMuted2);">${c.phone}</div></div>
      </div>
    `).join('');
    suggestionsDiv.querySelectorAll('.client-suggestion-item').forEach(item => {
      item.addEventListener('click', () => {
        searchInput.value = item.dataset.name;
        suggestionsDiv.innerHTML = '';
        suggestionsDiv.className = 'hidden';
        renderChecksList(item.dataset.name);
      });
    });
  }

  searchInput?.addEventListener('input', e => {
    const q = e.target.value.trim();
    clearBtn.style.display = q ? 'block' : 'none';
    updateSuggestions(q);
    renderChecksList(q);
  });
  clearBtn?.addEventListener('click', () => {
    searchInput.value = '';
    clearBtn.style.display = 'none';
    if (suggestionsDiv) { suggestionsDiv.innerHTML = ''; suggestionsDiv.className = 'hidden'; }
    renderChecksList();
  });

  // ── Период-дропдаун (с сохранением и применением фильтра) ──
  const periodContainer = document.getElementById('checks-period-dropdown');
  if (periodContainer) {
    periodContainer.innerHTML = '';
    createFilterDropdown(periodContainer, {
      value: _currentPeriod,
      label: 'Период',
      items: [
        { value: null, label: 'Нет', isReset: true, enabled: _currentPeriod != null },
        { value: 'today', label: 'Сегодня' }, { value: 'week', label: 'Неделя' },
        { value: 'month', label: 'Месяц' }, { value: 'quarter', label: 'Квартал' },
        { value: 'all', label: 'Все время' },
      ],
      onChanged: (v) => {
        _currentPeriod = v;
        if (v != null) {
          _currentDateRange = null;
          _lastFilterSource = 'dropdown';
        } else {
          _lastFilterSource = _currentDateRange ? 'calendar' : null;
        }
        renderChecksList(searchInput?.value?.trim() || '');
      },
    });
  }

  // ── Календарь (сохраняем диапазон и фильтруем) ──
  document.getElementById('checks-calendar')?.addEventListener('click', async () => {
    const result = await showCalendarPicker(_currentDateRange);
    if (result && result.start && result.end) {
      if (result.start.getFullYear() === 2000) {
        // Сброс
        _currentDateRange = null;
        _lastFilterSource = _currentPeriod ? 'dropdown' : null;
      } else {
        _currentDateRange = result;
        _currentPeriod = null;
        _lastFilterSource = 'calendar';
      }
      renderChecksList(searchInput?.value?.trim() || '');
    }
  });

  document.getElementById('checks-filter-btn')?.addEventListener('click', showFilterDialog);

  // ── Сортировка ──
  const sortTrigger = document.getElementById('sort-trigger');
  const sortContainer = document.getElementById('checks-sort');
  let sortOpen = false, sortMenu = null;
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
    sortMenu.innerHTML = sortOptions.map(o => `<div style="padding:10px 12px;font-size:13px;cursor:pointer;display:flex;align-items:center;gap:8px;background:${o.value===_sortField?'#EFD9AC':'transparent'};font-weight:${o.value===_sortField?'700':'400'};" data-sort="${o.value}">${o.label}${o.value===_sortField?`<span style="margin-left:auto;font-size:11px;color:#9C9484;">${_sortDesc?'↓':'↑'}</span>`:''}</div>`).join('') + `<div style="border-top:0.5px solid #E7E0D1;margin:4px 0;"></div><div style="padding:10px 12px;font-size:13px;cursor:pointer;color:#9C9484;" data-sort-toggle>${_sortDesc?'По убыванию':'По возрастанию'} ↕</div>`;
    sortContainer.appendChild(sortMenu);
    sortMenu.querySelectorAll('[data-sort]').forEach(item => {
      item.addEventListener('click', ev => { ev.stopPropagation(); _sortField = item.dataset.sort; closeSort(); renderChecksList(searchInput?.value?.trim()||''); });
    });
    sortMenu.querySelector('[data-sort-toggle]')?.addEventListener('click', ev => { ev.stopPropagation(); _sortDesc = !_sortDesc; closeSort(); renderChecksList(searchInput?.value?.trim()||''); });
    setTimeout(() => document.addEventListener('click', closeSort), 0);
  });
  function closeSort() { sortOpen = false; sortTrigger?.classList.remove('active'); if (sortMenu) { sortMenu.remove(); sortMenu = null; } document.removeEventListener('click', closeSort); }
}

// ── Диалог фильтров (с применением к списку) ──
function showFilterDialog() {
  const overlay = document.createElement('div');
  overlay.className = 'modal-overlay';
  // Локальные копии для редактирования
  let tmpType = _filterType;
  let tmpTariffs = new Set(_filterTariffs);
  let tmpPayments = new Set(_filterPayments);
  let tmpFirstTime = _filterFirstTime;

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

  // Восстановить состояние чипов из локальных копий
  if (tmpType === 'fiscal') overlay.querySelector('[data-filter-type="fiscal"]')?.classList.add('selected');
  if (tmpType === 'nonfiscal') overlay.querySelector('[data-filter-type="nonfiscal"]')?.classList.add('selected');
  tmpTariffs.forEach(t => overlay.querySelector(`[data-filter-tariff="${t}"]`)?.classList.add('selected'));
  tmpPayments.forEach(p => overlay.querySelector(`[data-filter-payment="${p}"]`)?.classList.add('selected'));
  if (tmpFirstTime) overlay.querySelector('#first-time').checked = true;

  // Тип чека — toggle
  overlay.querySelectorAll('[data-filter-type]').forEach(chip => {
    chip.addEventListener('click', () => {
      const val = chip.dataset.filterType;
      tmpType = tmpType === val ? null : val;
      overlay.querySelectorAll('[data-filter-type]').forEach(c => c.classList.remove('selected'));
      if (tmpType) chip.classList.add('selected');
      tg.hapticSelection();
    });
  });

  // Тарифы — multi-toggle
  overlay.querySelectorAll('[data-filter-tariff]').forEach(chip => {
    chip.addEventListener('click', () => {
      const val = chip.dataset.filterTariff;
      tmpTariffs.has(val) ? tmpTariffs.delete(val) : tmpTariffs.add(val);
      chip.classList.toggle('selected');
      tg.hapticSelection();
    });
  });

  // Способы оплаты — multi-toggle
  overlay.querySelectorAll('[data-filter-payment]').forEach(chip => {
    chip.addEventListener('click', () => {
      const val = chip.dataset.filterPayment;
      tmpPayments.has(val) ? tmpPayments.delete(val) : tmpPayments.add(val);
      chip.classList.toggle('selected');
      tg.hapticSelection();
    });
  });

  // Первый раз на пруду
  overlay.querySelector('#first-time')?.addEventListener('change', (e) => {
    tmpFirstTime = e.target.checked;
  });

  // Сбросить
  overlay.querySelector('#filter-reset')?.addEventListener('click', () => {
    tmpType = null;
    tmpTariffs.clear();
    tmpPayments.clear();
    tmpFirstTime = false;
    overlay.querySelectorAll('.chip').forEach(c => c.classList.remove('selected'));
    overlay.querySelector('#first-time').checked = false;
    tg.hapticSelection();
  });

  // Применить — сохранить состояние и обновить список
  overlay.querySelector('#filter-apply')?.addEventListener('click', () => {
    _filterType = tmpType;
    _filterTariffs = tmpTariffs;
    _filterPayments = tmpPayments;
    _filterFirstTime = tmpFirstTime;
    overlay.remove();
    tg.hapticNotification('success');
    renderChecksList(document.getElementById('checks-search')?.value?.trim() || '');
  });

  overlay.addEventListener('click', e => { if (e.target === overlay) overlay.remove(); });
}

// ── Детали чека (полные реквизиты 54-ФЗ) ──
function showCheckDetail(receipt) {
  const client = store.getClientById(receipt.clientId);
  const overlay = document.createElement('div');
  overlay.className = 'modal-overlay';
  const paymentLabels = { cash: 'Наличные', card: 'Карта', account: 'Счёт заведения' };
  overlay.innerHTML = `
    <div class="sheet" style="max-width:340px;">
      <div style="text-align:center;font-size:16px;font-weight:700;color:var(--kInk);letter-spacing:0.3px;">CRAZY TROUT ARENA</div>
      <div style="text-align:center;font-size:12px;font-weight:600;color:var(--kMuted2);margin-top:2px;">${receipt.fiscal ? 'КАССОВЫЙ ЧЕК (Приход)' : 'ЧЕК (без ФН)'}</div>
      <div style="border-top:0.5px solid var(--kHairline2);margin:12px 0;"></div>
      <div style="font-size:11px;color:var(--kMuted2);margin-bottom:2px;">Продавец: ИП Сидоров А.В.</div>
      <div style="font-size:11px;color:var(--kMuted2);margin-bottom:2px;">ИНН: 770123456789</div>
      <div style="font-size:11px;color:var(--kMuted2);margin-bottom:2px;">Адрес: г. Москва, ул. Рыбацкая, д. 12</div>
      <div style="font-size:11px;color:var(--kMuted2);margin-bottom:2px;">Дата: ${receipt.date}  Чек №${receipt.number || receipt.id}  Смена №1</div>
      <div style="font-size:11px;color:var(--kMuted2);margin-bottom:2px;">СНО: УСН доходы</div>
      <div style="border-top:0.5px solid var(--kHairline2);margin:12px 0;"></div>
      <div style="font-size:13px;">
        <div style="display:flex;justify-content:space-between;margin-bottom:4px;"><span style="color:var(--kMuted);">Клиент</span><span>${receipt.isGuest ? 'Гость' : (client?.name || '—')}</span></div>
        <div style="display:flex;justify-content:space-between;margin-bottom:4px;"><span style="color:var(--kMuted);">Телефон</span><span>${client?.phone || '—'}</span></div>
      </div>
      <div style="border-top:0.5px solid var(--kHairline2);margin:12px 0;"></div>
      <div style="font-size:13px;">
        <div style="display:flex;justify-content:space-between;margin-bottom:4px;"><span style="color:var(--kMuted);">Тариф · ${receipt.tariffLabel}</span><span>${store.formatMoney(receipt.tariffPrice)} ₽</span></div>
      </div>
      ${receipt.catches.length ? `<div style="border-top:0.5px solid var(--kHairline2);margin:8px 0;"></div><div style="font-weight:700;margin-bottom:8px;font-size:13px;">УЛОВ</div>${receipt.catches.map(c => { const w = c.kg > 0 ? `${c.kg}кг${c.grams > 0 ? c.grams + 'г' : ''}` : `${c.grams}г`; return `<div style="display:flex;justify-content:space-between;font-size:12px;margin-bottom:4px;"><span>${c.label || c.breedLabel} ${w} × ${c.pricePerKg}₽/кг</span><span style="font-weight:600;">${store.formatMoney(c.sum)} ₽</span></div>`; }).join('')}` : ''}
      <div style="border-top:0.5px solid var(--kHairline2);margin:12px 0;"></div>
      <div style="display:flex;justify-content:space-between;font-size:20px;font-weight:700;"><span>ИТОГО</span><span style="color:var(--kOrange);">${store.formatMoney(receipt.total)} ₽</span></div>
      <div style="font-size:11px;color:var(--kMuted2);margin-top:4px;">НДС не облагается</div>
      <div style="border-top:0.5px solid var(--kHairline2);margin:12px 0;"></div>
      <div style="display:flex;justify-content:space-between;font-size:13px;margin-bottom:4px;"><span style="color:var(--kMuted);">Оплата</span><span>${paymentLabels[receipt.paymentMethod] || receipt.paymentMethod}</span></div>
      ${receipt.fiscal ? `
        <div style="border-top:0.5px solid var(--kHairline2);margin:12px 0;"></div>
        <div style="font-size:10px;color:var(--kMuted2);line-height:1.6;">
          ККТ: 0001234567001234<br>
          ФН: 9999078900001234<br>
          ФД №: ${receipt.fiscalDoc ? receipt.fiscalDoc.replace('#', '') : receipt.id}<br>
          ФПД: 6789012345<br>
          Проверка: <a href="https://nalog.ru" target="_blank" rel="noopener" style="color:var(--kOrange);text-decoration:underline;">nalog.ru</a>
        </div>
      ` : `
        <div style="border-top:0.5px solid var(--kHairline2);margin:12px 0;"></div>
        <div style="font-size:10px;color:var(--kMuted2);text-align:center;">Чек без фискального накопителя</div>
      `}
      ${client ? `<div style="margin-top:16px;padding:10px;background:var(--kFill);border-radius:12px;display:flex;align-items:center;gap:10px;cursor:pointer;" id="detail-client"><div class="client-avatar" style="width:36px;height:36px;border-radius:50%;background:var(--kFill);display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;color:var(--kEmber);overflow:hidden;flex-shrink:0;">${client.avatarAsset ? `<img src="${client.avatarAsset}" style="width:100%;height:100%;object-fit:cover;border-radius:50%;">` : store.getClientInitials(client)}</div><div style="flex:1;"><div style="font-size:13px;font-weight:600;">${client.name}</div><div style="font-size:11px;color:var(--kMuted2);">${client.phone} · ${receipt.tariffLabel}</div></div><span style="color:var(--kMuted2);">›</span></div>` : ''}
      <div style="display:flex;gap:12px;margin-top:16px;">
        <button class="btn btn-outline" id="detail-print" style="flex:1;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle;margin-right:4px;"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect width="12" height="8" x="6" y="14"/></svg> Печать</button>
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
