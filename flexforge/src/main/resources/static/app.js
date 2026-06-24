/* FlexForge Console — a metadata-driven admin UI. It reads /__meta and renders the whole
   console (dashboard, data browser, flows, API) from that — nothing app-specific is hardcoded. */
(() => {
  const state = {
    meta: null, entity: null, view: 'dashboard',
    page: 0, size: 10, editingId: null, flow: null,
    token: localStorage.getItem('ff_token') || null,
  };
  const $ = (id) => document.getElementById(id);
  const el = (t) => document.createElement(t);

  // ---- HTTP ----
  async function api(path, options = {}) {
    const headers = Object.assign({ 'Content-Type': 'application/json' }, options.headers || {});
    if (state.token) headers['Authorization'] = 'Bearer ' + state.token;
    const res = await fetch(path, Object.assign({}, options, { headers }));
    if (res.status === 401) { openLogin(); throw new Error('Authentication required'); }
    const text = await res.text();
    const data = text ? JSON.parse(text) : null;
    if (!res.ok) {
      const msg = data && data.errors ? data.errors.join(', ') : (data && data.message ? data.message : 'HTTP ' + res.status);
      throw new Error(msg);
    }
    return data;
  }

  // ---- bootstrap ----
  async function init() {
    wireUi();
    try { state.meta = await fetch('/__meta').then((r) => r.json()); }
    catch (e) { return banner('Could not load /__meta: ' + e.message, 'error'); }
    $('appChip').textContent = state.meta.appId + ' · v' + (state.meta.configVersion || '0');
    renderSidebar();
    renderAuthBox();
    renderDashboard();
    if (state.meta.security && state.meta.security.enabled && !state.token) openLogin();
  }

  function renderSidebar() {
    const nav = $('entityNav');
    nav.innerHTML = '';
    (state.meta.entities || []).forEach((e) => {
      const a = el('a');
      a.className = 'nav-item';
      a.innerHTML = '<span class="ico">▤</span> ' + e.name;
      a.onclick = () => selectEntity(e.name);
      a.dataset.entity = e.name;
      nav.appendChild(a);
    });
  }

  function setActiveNav(key, entity) {
    document.querySelectorAll('.nav-item').forEach((a) => {
      a.classList.toggle('active', (entity && a.dataset.entity === entity) || (!entity && a.dataset.view === key));
    });
  }

  function showView(id) {
    ['dashboardView', 'entityView', 'flowsView', 'apiView'].forEach((v) => $(v).classList.add('hidden'));
    $(id).classList.remove('hidden');
  }

  // ---- DASHBOARD ----
  function renderDashboard() {
    showView('dashboardView'); setActiveNav('dashboard');
    const m = state.meta;
    $('dashSub').textContent = 'App "' + m.appId + '" — defined entirely by config, served over '
      + activeProtocols().join(' · ');
    $('statCards').innerHTML =
      stat(m.entities.length, 'Data models') +
      stat((m.flows || []).length, 'Flows') +
      stat((m.endpoints || []).length, 'Endpoints') +
      stat(activeProtocols().length, 'Active protocols', true);

    const ec = $('entityCards'); ec.innerHTML = '';
    m.entities.forEach((e) => {
      const card = el('div'); card.className = 'card';
      card.innerHTML = `<h3><span class="card-ico">▤</span> ${e.name}</h3>
        <div class="meta">${e.fields.length} fields · <span id="cnt-${e.name}">…</span> records</div>
        <div class="pill-row">${e.fields.slice(0, 5).map((f) => `<span class="pill ${f.pk ? 'key' : ''}">${f.name}</span>`).join('')}</div>`;
      card.onclick = () => selectEntity(e.name);
      ec.appendChild(card);
      api(`/api/${e.name}?size=1`).then((p) => { const n = $('cnt-' + e.name); if (n) n.textContent = p.total; }).catch(() => {});
    });

    const fc = $('flowCards'); fc.innerHTML = '';
    (m.flows || []).forEach((f) => {
      const card = el('div'); card.className = 'card';
      card.innerHTML = `<h3><span class="card-ico">⚙</span> ${f.name}</h3><div class="meta">${f.steps} steps</div>`;
      card.onclick = () => openFlow(f.name);
      fc.appendChild(card);
    });
    if (!(m.flows || []).length) fc.innerHTML = '<div class="muted">No flows configured.</div>';
  }

  const stat = (n, l, accent) => `<div class="stat"><div class="num ${accent ? 'accent' : ''}">${n}</div><div class="lbl">${l}</div></div>`;
  function activeProtocols() {
    const m = state.meta, out = [];
    if (m.api.rest.enabled) out.push('REST');
    if (m.api.graphql.enabled) out.push('GraphQL');
    out.push('SSE', 'WebSocket');
    return out;
  }

  // ---- ENTITY BROWSER ----
  function currentEntityMeta() { return state.meta.entities.find((e) => e.name === state.entity); }

  function selectEntity(name) {
    state.entity = name; state.page = 0;
    setActiveNav(null, name);
    showView('entityView');
    $('entityTitle').textContent = name;
    const sel = $('searchField');
    sel.innerHTML = currentEntityMeta().fields.filter((f) => f.uiVisible !== false)
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
    try { res = await api(`/api/${state.entity}${q}`); } catch (e) { return banner(e.message, 'error'); }
    renderTable(em, res);
  }

  function renderTable(em, page) {
    const cols = em.fields.filter((f) => f.uiVisible !== false);
    const pk = em.fields.find((f) => f.pk);
    $('dataTable').querySelector('thead').innerHTML =
      '<tr>' + cols.map((c) => `<th>${c.name}</th>`).join('') + '<th></th></tr>';
    const tbody = $('dataTable').querySelector('tbody'); tbody.innerHTML = '';
    (page.content || []).forEach((row) => {
      const id = row[pk.name];
      const tr = el('tr');
      tr.innerHTML = cols.map((c) => `<td>${cell(c, row, id)}</td>`).join('');
      const td = el('td'); td.className = 'row-actions';
      td.append(btn('Edit', 'small', () => openForm(row)), btn('Delete', 'small danger', () => removeRow(id)));
      tr.appendChild(td); tbody.appendChild(tr);
    });
    $('pageInfo').textContent = `Page ${page.page + 1} · ${page.total} total`;
    $('prevBtn').disabled = page.page <= 0;
    $('nextBtn').disabled = (page.page + 1) * page.size >= page.total;
  }

  function cell(c, row, id) {
    if (c.type === 'FILE') return row[c.name]
      ? `<a class="ghost" target="_blank" href="/api/${state.entity}/${id}/file/${c.name}">📎 open</a>`
      : '<span class="muted">—</span>';
    return fmt(row[c.name]);
  }
  const fmt = (v) => {
    if (v === null || v === undefined) return '<span class="muted">—</span>';
    if (typeof v === 'boolean') return v ? '✓' : '✗';
    const s = String(v); return s.length > 60 ? s.slice(0, 60) + '…' : s;
  };

  // ---- record form ----
  function openForm(row) {
    const em = currentEntityMeta(); const pk = em.fields.find((f) => f.pk);
    state.editingId = row ? row[pk.name] : null;
    $('modalTitle').textContent = (row ? 'Edit ' : 'New ') + em.name;
    const form = $('recordForm'); form.innerHTML = '';
    em.fields.forEach((f) => { if (!f.pk && f.uiVisible !== false) form.appendChild(fieldInput(f, row ? row[f.name] : null)); });
    hideFormError(); show('modal');
  }

  function fieldInput(f, value) {
    const label = el('label'); if (!f.nullable) label.classList.add('req');
    label.append(document.createTextNode(f.name));
    let input;
    switch (f.type) {
      case 'BOOLEAN': input = el('select'); input.innerHTML = '<option value="">—</option><option>true</option><option>false</option>';
        if (value != null) input.value = String(value); break;
      case 'FILE': input = el('input'); input.type = 'file'; break;
      case 'SELECT': input = el('select');
        input.innerHTML = '<option value="">—</option>' + (f.options || []).map((o) =>
          `<option ${String(value) === o ? 'selected' : ''}>${o}</option>`).join(''); break;
      case 'MULTISELECT': input = el('input'); input.type = 'text'; input.placeholder = 'comma,separated';
        if (value != null) input.value = Array.isArray(value) ? value.join(',') : value;
        if ((f.options || []).length) input.title = 'Options: ' + f.options.join(', '); break;
      case 'REFERENCE': input = el('select'); input.innerHTML = '<option value="">—</option>'; populateReference(input, f.references, value); break;
      case 'TEXT': case 'JSON': input = el('textarea'); input.rows = 3; if (value != null) input.value = value; break;
      case 'INT': case 'LONG': case 'DOUBLE': case 'DECIMAL': input = el('input'); input.type = 'number';
        if (value != null) input.value = value; if (f.min != null) input.min = f.min; if (f.max != null) input.max = f.max; break;
      case 'DATE': input = el('input'); input.type = 'date'; if (value != null) input.value = String(value).slice(0, 10); break;
      case 'TIMESTAMP': input = el('input'); input.type = 'datetime-local'; if (value != null) input.value = String(value).slice(0, 16); break;
      default: input = el('input'); input.type = f.email ? 'email' : 'text'; if (value != null) input.value = value;
        if (f.minLength != null) input.minLength = f.minLength; if (f.pattern) input.pattern = f.pattern;
    }
    input.dataset.field = f.name; input.dataset.ftype = f.type; label.appendChild(input); return label;
  }

  async function populateReference(select, targetName, selected) {
    const target = state.meta.entities.find((e) => e.name === targetName); if (!target) return;
    const pk = target.fields.find((f) => f.pk);
    const labelField = target.fields.find((f) => !f.pk && (f.type === 'STRING' || f.type === 'TEXT'));
    try {
      const res = await api(`/api/${targetName}?size=100`);
      (res.content || []).forEach((row) => {
        const o = el('option'); o.value = row[pk.name];
        o.textContent = labelField ? `${row[labelField.name]} (#${row[pk.name]})` : `#${row[pk.name]}`;
        if (selected != null && String(selected) === String(row[pk.name])) o.selected = true;
        select.appendChild(o);
      });
    } catch (e) { /* ignore */ }
  }

  function collectForm() {
    const body = {};
    $('recordForm').querySelectorAll('[data-field]').forEach((inp) => {
      const t = inp.dataset.ftype; if (t === 'FILE') return;
      let v = inp.value; if (v === '' || v === null) return;
      if (t === 'BOOLEAN') v = (v === 'true');
      else if (['INT', 'LONG', 'REFERENCE'].includes(t)) v = parseInt(v, 10);
      else if (['DOUBLE', 'DECIMAL'].includes(t)) v = parseFloat(v);
      body[inp.dataset.field] = v;
    });
    return body;
  }

  async function saveRecord() {
    const body = collectForm(); const base = `/api/${state.entity}`;
    const pk = currentEntityMeta().fields.find((f) => f.pk);
    try {
      let saved = state.editingId == null
        ? await api(base, { method: 'POST', body: JSON.stringify(body) })
        : await api(`${base}/${state.editingId}`, { method: 'PUT', body: JSON.stringify(body) });
      await uploadFiles(state.editingId != null ? state.editingId : saved[pk.name]);
      hide('modal'); banner('Saved', 'ok'); loadList();
    } catch (e) { showFormError(e.message); }
  }
  async function uploadFiles(id) {
    for (const inp of $('recordForm').querySelectorAll('input[type=file]')) {
      if (!inp.files || !inp.files[0]) continue;
      const fd = new FormData(); fd.append('file', inp.files[0]);
      const headers = state.token ? { Authorization: 'Bearer ' + state.token } : {};
      const res = await fetch(`/api/${state.entity}/${id}/file/${inp.dataset.field}`, { method: 'POST', headers, body: fd });
      if (!res.ok) throw new Error('File upload failed for ' + inp.dataset.field);
    }
  }
  async function removeRow(id) {
    if (!confirm('Delete this record?')) return;
    try { await api(`/api/${state.entity}/${id}`, { method: 'DELETE' }); banner('Deleted', 'ok'); loadList(); }
    catch (e) { banner(e.message, 'error'); }
  }

  // ---- FLOWS ----
  function renderFlows() {
    showView('flowsView'); setActiveNav('flows');
    const fc = $('flowRunCards'); fc.innerHTML = '';
    (state.meta.flows || []).forEach((f) => {
      const card = el('div'); card.className = 'card';
      card.innerHTML = `<h3><span class="card-ico">⚙</span> ${f.name}</h3><div class="meta">${f.steps} steps · POST /flows/${f.name}/run</div>`;
      card.onclick = () => openFlow(f.name);
      fc.appendChild(card);
    });
    if (!(state.meta.flows || []).length) fc.innerHTML = '<div class="muted">No flows configured.</div>';
  }
  function openFlow(name) {
    state.flow = name; $('flowModalTitle').textContent = 'Run flow: ' + name;
    $('flowInput').value = '{\n  \n}'; $('flowOutput').textContent = '—'; show('flowModal');
  }
  async function runFlow() {
    try {
      const input = JSON.parse($('flowInput').value || '{}');
      const out = await api(`/flows/${state.flow}/run`, { method: 'POST', body: JSON.stringify(input) });
      $('flowOutput').textContent = JSON.stringify(out, null, 2);
    } catch (e) { $('flowOutput').textContent = 'Error: ' + e.message; }
  }

  // ---- API VIEW ----
  function renderApi() {
    showView('apiView'); setActiveNav('api');
    const m = state.meta;
    const protos = [
      ['REST', m.api.rest.enabled, '/api/{entity}'],
      ['GraphQL', m.api.graphql.enabled, '/graphql'],
      ['Server-Sent Events', true, '/realtime/stream'],
      ['WebSocket', true, '/ws/events'],
      ['OpenAPI', true, '/__meta/openapi.json'],
      ['Audit log', true, '/__audit'],
    ];
    $('protocolCards').innerHTML = protos.map(([n, on, path]) =>
      `<div class="card flat"><h3>${n}</h3><div class="meta">${path}</div>
       <div class="pill-row"><span class="pill ${on ? 'on' : 'off'}">${on ? 'enabled' : 'disabled'}</span></div></div>`).join('');
    $('endpointCards').innerHTML = ((m.endpoints || []).map((e) =>
      `<div class="card flat"><h3>${e.name}</h3><div class="meta">/run/${e.name}</div>
       <div class="pill-row"><span class="pill method">${e.method}</span></div></div>`).join('') || '<div class="muted">No custom endpoints.</div>');
  }

  // ---- auth ----
  function renderAuthBox() {
    const box = $('authBox');
    if (!(state.meta.security && state.meta.security.enabled)) { box.innerHTML = ''; return; }
    box.innerHTML = '';
    box.appendChild(state.token
      ? btn('Sign out', '', () => { state.token = null; localStorage.removeItem('ff_token'); renderAuthBox(); openLogin(); })
      : btn('Sign in', 'primary', openLogin));
  }
  function openLogin() { $('loginError').classList.add('hidden'); show('loginModal'); }
  async function doLogin() {
    try {
      const res = await api('/auth/login', { method: 'POST', body: JSON.stringify({ username: $('loginUser').value, password: $('loginPass').value }) });
      state.token = res.token; localStorage.setItem('ff_token', res.token); hide('loginModal'); renderAuthBox();
      renderDashboard();
    } catch (e) { const b = $('loginError'); b.textContent = e.message; b.classList.remove('hidden'); }
  }

  // ---- wiring / helpers ----
  function wireUi() {
    $('navDashboard').onclick = renderDashboard;
    $('navFlows').onclick = renderFlows;
    $('navApi').onclick = renderApi;
    $('newBtn').onclick = () => openForm(null);
    $('saveBtn').onclick = saveRecord;
    $('cancelBtn').onclick = () => hide('modal');
    $('modalClose').onclick = () => hide('modal');
    $('searchBtn').onclick = () => { state.page = 0; loadList(); };
    $('searchValue').addEventListener('keydown', (e) => { if (e.key === 'Enter') { state.page = 0; loadList(); } });
    $('prevBtn').onclick = () => { if (state.page > 0) { state.page--; loadList(); } };
    $('nextBtn').onclick = () => { state.page++; loadList(); };
    $('flowRunBtn').onclick = runFlow;
    $('flowCancelBtn').onclick = () => hide('flowModal');
    $('flowModalClose').onclick = () => hide('flowModal');
    $('loginBtn').onclick = doLogin;
    $('loginForm').addEventListener('submit', (e) => { e.preventDefault(); doLogin(); });
  }
  function banner(msg, kind) { const b = $('banner'); b.textContent = msg; b.className = 'banner ' + kind; setTimeout(() => b.classList.add('hidden'), 3500); }
  function showFormError(msg) { const e = $('formError'); e.textContent = msg; e.classList.remove('hidden'); }
  function hideFormError() { $('formError').classList.add('hidden'); }
  function btn(text, cls, onclick) { const b = el('button'); b.className = 'btn ' + cls; b.textContent = text; b.onclick = onclick; return b; }
  const show = (id) => $(id).classList.remove('hidden');
  const hide = (id) => $(id).classList.add('hidden');

  init();
})();
