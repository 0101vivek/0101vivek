/* FlexForge Admin — a metadata-driven UI. It knows nothing about any specific app;
   it reads /__meta and renders the entity browser, forms and search from that. */
(() => {
  const state = {
    meta: null,
    entity: null,
    page: 0,
    size: 10,
    token: localStorage.getItem('ff_token') || null,
    editingId: null,
  };

  const $ = (id) => document.getElementById(id);

  // ---- HTTP -------------------------------------------------------------
  async function api(path, options = {}) {
    const headers = Object.assign({ 'Content-Type': 'application/json' }, options.headers || {});
    if (state.token) headers['Authorization'] = 'Bearer ' + state.token;
    const res = await fetch(path, Object.assign({}, options, { headers }));
    if (res.status === 401) {
      openLogin();
      throw new Error('Authentication required');
    }
    const text = await res.text();
    const data = text ? JSON.parse(text) : null;
    if (!res.ok) {
      const msg = data && data.errors ? data.errors.join(', ')
        : (data && data.message ? data.message : ('HTTP ' + res.status));
      const err = new Error(msg);
      err.payload = data;
      throw err;
    }
    return data;
  }

  // ---- bootstrap --------------------------------------------------------
  async function init() {
    wireGlobalUi();
    try {
      state.meta = await fetch('/__meta').then((r) => r.json());
    } catch (e) {
      return banner('Could not load /__meta: ' + e.message, 'error');
    }
    $('appId').textContent = state.meta.appId ? '· ' + state.meta.appId : '';
    renderSidebar();
    renderAuthBox();
    if (state.meta.security && state.meta.security.enabled && !state.token) openLogin();
  }

  function renderSidebar() {
    const nav = $('entityNav');
    nav.innerHTML = '';
    (state.meta.entities || []).forEach((e) => {
      const a = document.createElement('a');
      a.textContent = e.name;
      a.onclick = () => selectEntity(e.name);
      a.dataset.entity = e.name;
      nav.appendChild(a);
    });
    const flags = $('apiFlags');
    const rest = state.meta.api.rest.enabled, gql = state.meta.api.graphql.enabled;
    const sec = state.meta.security && state.meta.security.enabled;
    flags.innerHTML =
      flag('REST', rest) + flag('GraphQL', gql) + flag('Auth', sec);
  }
  const flag = (label, on) =>
    `<span><i class="dot ${on ? 'on' : 'off'}"></i>${label}: ${on ? 'on' : 'off'}</span>`;

  // ---- entity browsing --------------------------------------------------
  function currentEntityMeta() {
    return state.meta.entities.find((e) => e.name === state.entity);
  }

  function selectEntity(name) {
    state.entity = name;
    state.page = 0;
    document.querySelectorAll('#entityNav a').forEach((a) =>
      a.classList.toggle('active', a.dataset.entity === name));
    $('welcome').classList.add('hidden');
    $('entityView').classList.remove('hidden');
    $('entityTitle').textContent = name;
    const sel = $('searchField');
    sel.innerHTML = currentEntityMeta().fields
      .filter((f) => f.uiVisible !== false)
      .map((f) => `<option value="${f.name}">${f.name}</option>`).join('');
    $('searchValue').value = '';
    loadList();
  }

  async function loadList() {
    const em = currentEntityMeta();
    let q = `?page=${state.page}&size=${state.size}`;
    const sv = $('searchValue').value.trim();
    if (sv) q += `&${$('searchField').value}_like=${encodeURIComponent(sv)}`;
    let res;
    try {
      res = await api(`/api/${state.entity}${q}`);
    } catch (e) {
      return banner(e.message, 'error');
    }
    renderTable(em, res);
  }

  function renderTable(em, page) {
    const cols = em.fields.filter((f) => f.uiVisible !== false);
    const thead = $('dataTable').querySelector('thead');
    const tbody = $('dataTable').querySelector('tbody');
    thead.innerHTML = '<tr>' + cols.map((c) => `<th>${c.name}</th>`).join('') + '<th></th></tr>';
    tbody.innerHTML = '';
    const pk = em.fields.find((f) => f.pk);
    (page.content || []).forEach((row) => {
      const tr = document.createElement('tr');
      tr.innerHTML = cols.map((c) => `<td>${fmt(row[c.name])}</td>`).join('');
      const td = document.createElement('td');
      td.className = 'row-actions';
      const id = row[pk.name];
      const edit = btn('Edit', 'small', () => openForm(row));
      const del = btn('Delete', 'small danger', () => removeRow(id));
      td.append(edit, del);
      tr.appendChild(td);
      tbody.appendChild(tr);
    });
    $('pageInfo').textContent =
      `Page ${page.page + 1} · ${page.total} total`;
    $('prevBtn').disabled = page.page <= 0;
    $('nextBtn').disabled = (page.page + 1) * page.size >= page.total;
  }

  const fmt = (v) => {
    if (v === null || v === undefined) return '<span class="muted">—</span>';
    if (typeof v === 'boolean') return v ? '✓' : '✗';
    const s = String(v);
    return s.length > 60 ? s.slice(0, 60) + '…' : s;
  };

  // ---- record form ------------------------------------------------------
  function openForm(row) {
    const em = currentEntityMeta();
    const pk = em.fields.find((f) => f.pk);
    state.editingId = row ? row[pk.name] : null;
    $('modalTitle').textContent = (row ? 'Edit ' : 'New ') + em.name;
    const form = $('recordForm');
    form.innerHTML = '';
    em.fields.forEach((f) => {
      if (f.pk || f.uiVisible === false) return;
      form.appendChild(fieldInput(f, row ? row[f.name] : null));
    });
    hideFormError();
    show('modal');
  }

  function fieldInput(f, value) {
    const label = document.createElement('label');
    if (!f.nullable) label.classList.add('req');
    label.append(document.createTextNode(f.name));
    let input;
    switch (f.type) {
      case 'BOOLEAN':
        input = el('select'); input.innerHTML = '<option value="">—</option><option>true</option><option>false</option>';
        if (value !== null && value !== undefined) input.value = String(value);
        break;
      case 'TEXT': case 'JSON':
        input = el('textarea'); input.rows = 3; if (value != null) input.value = value;
        break;
      case 'INT': case 'LONG': case 'DOUBLE': case 'DECIMAL':
        input = el('input'); input.type = 'number'; if (value != null) input.value = value;
        if (f.min != null) input.min = f.min; if (f.max != null) input.max = f.max;
        break;
      case 'REFERENCE':
        input = el('select');
        input.innerHTML = '<option value="">—</option>';
        populateReference(input, f.references, value);
        break;
      case 'DATE':
        input = el('input'); input.type = 'date'; if (value != null) input.value = String(value).slice(0, 10);
        break;
      case 'TIMESTAMP':
        input = el('input'); input.type = 'datetime-local'; if (value != null) input.value = String(value).slice(0, 16);
        break;
      default:
        input = el('input'); input.type = f.email ? 'email' : 'text'; if (value != null) input.value = value;
        if (f.minLength != null) input.minLength = f.minLength;
        if (f.maxLength != null) input.maxLength = f.maxLength;
        if (f.pattern) input.pattern = f.pattern;
    }
    input.dataset.field = f.name;
    input.dataset.ftype = f.type;
    label.appendChild(input);
    return label;
  }

  async function populateReference(select, targetName, selected) {
    const target = state.meta.entities.find((e) => e.name === targetName);
    if (!target) return;
    const pk = target.fields.find((f) => f.pk);
    const labelField = target.fields.find((f) => !f.pk && (f.type === 'STRING' || f.type === 'TEXT'));
    try {
      const res = await api(`/api/${targetName}?size=100`);
      (res.content || []).forEach((row) => {
        const o = el('option');
        o.value = row[pk.name];
        o.textContent = labelField ? `${row[labelField.name]} (#${row[pk.name]})` : `#${row[pk.name]}`;
        if (selected != null && String(selected) === String(row[pk.name])) o.selected = true;
        select.appendChild(o);
      });
    } catch (e) { /* leave just the placeholder if target not readable */ }
  }

  function collectForm() {
    const body = {};
    $('recordForm').querySelectorAll('[data-field]').forEach((inp) => {
      let v = inp.value;
      if (v === '' || v === null) return;
      const t = inp.dataset.ftype;
      if (t === 'BOOLEAN') v = (v === 'true');
      else if (['INT', 'LONG', 'REFERENCE'].includes(t)) v = parseInt(v, 10);
      else if (['DOUBLE', 'DECIMAL'].includes(t)) v = parseFloat(v);
      body[inp.dataset.field] = v;
    });
    return body;
  }

  async function saveRecord() {
    const body = collectForm();
    const base = `/api/${state.entity}`;
    try {
      if (state.editingId == null) {
        await api(base, { method: 'POST', body: JSON.stringify(body) });
      } else {
        await api(`${base}/${state.editingId}`, { method: 'PUT', body: JSON.stringify(body) });
      }
      hide('modal');
      banner('Saved', 'ok');
      loadList();
    } catch (e) {
      showFormError(e.message);
    }
  }

  async function removeRow(id) {
    if (!confirm('Delete this record?')) return;
    try {
      await api(`/api/${state.entity}/${id}`, { method: 'DELETE' });
      banner('Deleted', 'ok');
      loadList();
    } catch (e) {
      banner(e.message, 'error');
    }
  }

  // ---- auth -------------------------------------------------------------
  function renderAuthBox() {
    const box = $('authBox');
    if (!(state.meta.security && state.meta.security.enabled)) { box.innerHTML = ''; return; }
    if (state.token) {
      box.innerHTML = '';
      box.appendChild(btn('Sign out', '', () => { state.token = null; localStorage.removeItem('ff_token'); renderAuthBox(); openLogin(); }));
    } else {
      box.innerHTML = '';
      box.appendChild(btn('Sign in', 'primary', openLogin));
    }
  }
  function openLogin() { hideEl($('loginError')); show('loginModal'); }
  async function doLogin() {
    try {
      const res = await api('/auth/login', {
        method: 'POST',
        body: JSON.stringify({ username: $('loginUser').value, password: $('loginPass').value }),
      });
      state.token = res.token;
      localStorage.setItem('ff_token', res.token);
      hide('loginModal');
      renderAuthBox();
      if (state.entity) loadList();
    } catch (e) {
      const box = $('loginError'); box.textContent = e.message; box.classList.remove('hidden');
    }
  }

  // ---- misc UI ----------------------------------------------------------
  function wireGlobalUi() {
    $('newBtn').onclick = () => openForm(null);
    $('saveBtn').onclick = saveRecord;
    $('cancelBtn').onclick = () => hide('modal');
    $('modalClose').onclick = () => hide('modal');
    $('searchBtn').onclick = () => { state.page = 0; loadList(); };
    $('searchValue').addEventListener('keydown', (e) => { if (e.key === 'Enter') { state.page = 0; loadList(); } });
    $('prevBtn').onclick = () => { if (state.page > 0) { state.page--; loadList(); } };
    $('nextBtn').onclick = () => { state.page++; loadList(); };
    $('loginBtn').onclick = doLogin;
    $('loginForm').addEventListener('submit', (e) => { e.preventDefault(); doLogin(); });
  }

  function banner(msg, kind) {
    const b = $('banner');
    b.textContent = msg;
    b.className = 'banner ' + kind;
    setTimeout(() => b.classList.add('hidden'), 3500);
  }
  function showFormError(msg) { const e = $('formError'); e.textContent = msg; e.classList.remove('hidden'); }
  function hideFormError() { $('formError').classList.add('hidden'); }

  const el = (tag) => document.createElement(tag);
  function btn(text, cls, onclick) { const b = el('button'); b.className = 'btn ' + cls; b.textContent = text; b.onclick = onclick; return b; }
  const show = (id) => $(id).classList.remove('hidden');
  const hide = (id) => $(id).classList.add('hidden');
  const hideEl = (node) => node.classList.add('hidden');

  init();
})();
