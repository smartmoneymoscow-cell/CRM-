// === Screen: Выставление чека ===

import { store, TARIFFS, FISH_BREEDS } from '../core/store.js';
import { tg } from '../core/telegram.js';

export function renderReceipt() {
  const el = document.createElement('div');
  el.className = 'screen screen-receipt';
  el.innerHTML = `
    <!-- Поиск клиента -->
    <div class="search-bar">
      <span class="search-icon">🔍</span>
      <input class="input" id="client-search" type="text" placeholder="Имя или телефон клиента...">
    </div>

    <!-- QR-сканер -->
    <button class="btn btn-secondary btn-full" id="btn-scan-qr" style="margin-bottom: var(--spacing-lg);">
      📷 Сканировать QR-код
    </button>

    <!-- Информация о клиенте -->
    <div id="client-section" class="card hidden" style="margin-bottom: var(--spacing-lg);">
      <div class="receipt-header">
        <div class="client-avatar" id="client-avatar">?</div>
        <div class="client-info">
          <div class="client-name" id="client-name">—</div>
          <div class="client-phone" id="client-phone">—</div>
        </div>
        <span class="badge badge-accent" id="client-level">—</span>
      </div>
    </div>

    <!-- Тарифы -->
    <h3 style="margin-bottom: var(--spacing-md); font-size: var(--font-size-lg);">Тариф</h3>
    <div class="tariff-grid" id="tariff-grid">
      ${TARIFFS.map(t => `
        <div class="tariff-card ${t.id === 'standard' ? 'selected' : ''}" data-tariff="${t.id}">
          <div class="tariff-name">${t.label}</div>
          <div class="tariff-price">${t.price}₽</div>
        </div>
      `).join('')}
    </div>

    <!-- Улов -->
    <h3 style="margin-bottom: var(--spacing-md); font-size: var(--font-size-lg);">Улов</h3>
    <div id="catch-list"></div>
    <button class="btn btn-secondary btn-full" id="btn-add-catch" style="margin-top: var(--spacing-sm);">
      + Добавить рыбу
    </button>

    <!-- Оплата -->
    <div class="divider"></div>
    <h3 style="margin-bottom: var(--spacing-md); font-size: var(--font-size-lg);">Оплата</h3>
    <div class="segmented" id="payment-method" style="margin-bottom: var(--spacing-md);">
      <button class="segmented-item active" data-method="cash">Наличные</button>
      <button class="segmented-item" data-method="card">Карта</button>
      <button class="segmented-item" data-method="account">Счёт</button>
    </div>

    <!-- Тип чека -->
    <div class="segmented" id="receipt-type" style="margin-bottom: var(--spacing-xl);">
      <button class="segmented-item active" data-fiscal="true">Фискальный</button>
      <button class="segmented-item" data-fiscal="false">Без ФН</button>
    </div>

    <!-- Итого -->
    <div class="card" style="margin-bottom: var(--spacing-lg);">
      <div style="display: flex; justify-content: space-between; align-items: center;">
        <span style="font-size: var(--font-size-lg);">ИТОГО</span>
        <span style="font-size: var(--font-size-xxl); font-weight: bold; color: var(--color-accent);" id="total-amount">750₽</span>
      </div>
    </div>

    <!-- Кнопка печати -->
    <button class="btn btn-primary btn-full" id="btn-print">
      🖨️ Напечатать чек
    </button>
  `;

  // Инициализация обработчиков
  setTimeout(() => initReceiptHandlers(), 0);

  return el;
}

function initReceiptHandlers() {
  // Поиск клиента
  const searchInput = document.getElementById('client-search');
  searchInput?.addEventListener('input', (e) => {
    const client = store.findClient(e.target.value);
    if (client) showClient(client);
  });

  // QR-сканер
  document.getElementById('btn-scan-qr')?.addEventListener('click', async () => {
    const result = await tg.showScanQR('Наведите на QR-код клиента');
    if (result) {
      const client = store.getClientById(result) || store.findClient(result);
      if (client) {
        showClient(client);
        searchInput.value = client.name;
      }
    }
  });

  // Тарифы
  document.getElementById('tariff-grid')?.addEventListener('click', (e) => {
    const card = e.target.closest('.tariff-card');
    if (!card) return;
    document.querySelectorAll('.tariff-card').forEach(c => c.classList.remove('selected'));
    card.classList.add('selected');
    tg.hapticSelection();
    updateTotal();
  });

  // Сегментед контролы
  document.querySelectorAll('.segmented').forEach(seg => {
    seg.addEventListener('click', (e) => {
      const btn = e.target.closest('.segmented-item');
      if (!btn) return;
      seg.querySelectorAll('.segmented-item').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      tg.hapticSelection();
    });
  });

  // Кнопка печати
  document.getElementById('btn-print')?.addEventListener('click', () => {
    tg.hapticImpact('heavy');
    // TODO: вызов printer.js
    tg.showAlert('Чек напечатан! (демо)');
  });
}

function showClient(client) {
  const section = document.getElementById('client-section');
  if (section) {
    section.classList.remove('hidden');
    document.getElementById('client-avatar').textContent = store.getClientInitials(client);
    document.getElementById('client-name').textContent = client.name;
    document.getElementById('client-phone').textContent = client.phone;
    document.getElementById('client-level').textContent = store.getLevelBadge(client.level);
  }
}

function updateTotal() {
  const selected = document.querySelector('.tariff-card.selected');
  const tariffId = selected?.dataset.tariff || 'standard';
  const tariff = TARIFFS.find(t => t.id === tariffId);
  const total = tariff?.price || 0;
  const el = document.getElementById('total-amount');
  if (el) el.textContent = `${total}₽`;
}
