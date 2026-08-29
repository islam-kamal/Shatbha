/**
 * Shatbha Atelier Builder
 * Run on file: https://www.figma.com/design/fwLuDQqrjBYCWmzSDAgmdM
 * Plugins → Development → Import plugin from manifest → this folder.
 */
const W = 1440;
const H = 900;
const SIDE = 248;

const HEX = {
  stone: { r: 0x1c / 255, g: 0x18 / 255, b: 0x14 / 255 },
  raised: { r: 0x2a / 255, g: 0x24 / 255, b: 0x1e / 255 },
  muted: { r: 0x3a / 255, g: 0x33 / 255, b: 0x2c / 255 },
  ivory: { r: 0xf6 / 255, g: 0xf1 / 255, b: 0xe8 / 255 },
  ivory2: { r: 0xe8 / 255, g: 0xdf / 255, b: 0xd0 / 255 },
  brass: { r: 0xc4 / 255, g: 0xa5 / 255, b: 0x74 / 255 },
  brass2: { r: 0xd4 / 255, g: 0xbc / 255, b: 0x8c / 255 },
  terra: { r: 0xb8 / 255, g: 0x5c / 255, b: 0x38 / 255 },
  teal: { r: 0x4a / 255, g: 0x7c / 255, b: 0x74 / 255 },
  date: { r: 0xf0 / 255, g: 0xd9 / 255, b: 0xb5 / 255 },
  cash: { r: 0xd5 / 255, g: 0xe6 / 255, b: 0xe2 / 255 },
  expense: { r: 0xe8 / 255, g: 0xc9 / 255, b: 0xbc / 255 },
  calc: { r: 0xe9 / 255, g: 0xd9 / 255, b: 0xa8 / 255 },
  ident: { r: 0xd7 / 255, g: 0xe3 / 255, b: 0xea / 255 },
};

let VARS = {};
let STYLES = {};
let COMPS = {};

function solid(color, opacity) {
  return [{ type: "SOLID", color, opacity: opacity == null ? 1 : opacity }];
}

function paintVar(name, fallback) {
  const v = VARS[name];
  if (!v) return solid(fallback);
  return [
    figma.variables.setBoundVariableForPaint(
      { type: "SOLID", color: fallback },
      "color",
      v
    ),
  ];
}

function auto(direction, name) {
  const f = figma.createFrame();
  f.name = name || "Frame";
  f.layoutMode = direction;
  f.primaryAxisSizingMode = "AUTO";
  f.counterAxisSizingMode = "AUTO";
  f.fills = [];
  f.itemSpacing = 0;
  f.clipsContent = false;
  return f;
}

function pad(frame, t, r, b, l) {
  frame.paddingTop = t;
  frame.paddingRight = r == null ? t : r;
  frame.paddingBottom = b == null ? t : b;
  frame.paddingLeft = l == null ? (r == null ? t : r) : l;
}

async function txt(content, styleName, colorName, fallback, size) {
  const t = figma.createText();
  const style = STYLES[styleName];
  if (style) t.textStyleId = style.id;
  else {
    t.fontName = { family: "Cairo", style: "Regular" };
    t.fontSize = size || 14;
  }
  t.characters = content;
  t.fills = paintVar(colorName, fallback);
  t.textAlignHorizontal = "RIGHT";
  return t;
}

function findPage(name) {
  return figma.root.children.find((p) => p.name === name);
}

async function loadFonts() {
  for (const style of ["Regular", "Medium", "SemiBold", "Bold"]) {
    await figma.loadFontAsync({ family: "Cairo", style });
  }
}

async function loadTokens() {
  const vars = await figma.variables.getLocalVariablesAsync();
  VARS = {};
  for (const v of vars) VARS[v.name] = v;
  STYLES = {};
  for (const s of figma.getLocalTextStyles()) STYLES[s.name] = s;
}

function findComponents(page) {
  const found = {};
  for (const n of page.findAllWithCriteria({ types: ["COMPONENT", "COMPONENT_SET"] })) {
    found[n.name] = n;
  }
  return found;
}

function instanceOf(setOrComp, variantIncludes) {
  if (!setOrComp) return null;
  if (setOrComp.type === "COMPONENT") return setOrComp.createInstance();
  const child = setOrComp.children.find((c) =>
    variantIncludes ? c.name.indexOf(variantIncludes) >= 0 : true
  );
  return (child || setOrComp.defaultVariant).createInstance();
}

function setLabel(inst, value) {
  const nodes = inst.findAll((n) => n.type === "TEXT" && n.name === "Label");
  if (nodes[0]) nodes[0].characters = value;
  const vals = inst.findAll((n) => n.type === "TEXT" && n.name === "Value");
  if (vals[0] && arguments.length > 2) vals[0].characters = arguments[2];
}

async function ensureModuleTile(page) {
  if (COMPS.ModuleTile) return COMPS.ModuleTile;
  const tile = figma.createComponent();
  tile.name = "ModuleTile";
  tile.layoutMode = "HORIZONTAL";
  tile.counterAxisAlignItems = "CENTER";
  tile.itemSpacing = 10;
  pad(tile, 14);
  tile.resize(280, 64);
  tile.primaryAxisSizingMode = "FIXED";
  tile.counterAxisSizingMode = "AUTO";
  tile.cornerRadius = 10;
  tile.fills = paintVar("color/bg/chrome", HEX.stone);
  tile.strokes = paintVar("color/accent/brass", HEX.brass);
  tile.strokeWeight = 1;
  const label = await txt("اتفاق مقاولين", "Type/Strong", "color/text/on-chrome", HEX.ivory, 14);
  label.name = "Label";
  tile.appendChild(label);
  label.layoutSizingHorizontal = "FILL";
  tile.x = 40;
  tile.y = 640;
  page.appendChild(tile);
  COMPS.ModuleTile = tile;
  return tile;
}

async function ensureLedgerHeader(page) {
  if (COMPS.LedgerHeader) return COMPS.LedgerHeader;
  const specs = [
    ["Tint=Date", "color/tint/date", HEX.date, "تاريخ"],
    ["Tint=Cash", "color/tint/cash", HEX.cash, "توريد نقدي"],
    ["Tint=Expense", "color/tint/expense", HEX.expense, "مصروف"],
    ["Tint=Calculated", "color/tint/calculated", HEX.calc, "الباقي"],
    ["Tint=Identity", "color/tint/identity", HEX.ident, "اسم العميل"],
  ];
  const cells = [];
  for (const [name, token, fb, label] of specs) {
    const c = figma.createComponent();
    c.name = name;
    c.layoutMode = "HORIZONTAL";
    pad(c, 12, 14, 12, 14);
    c.fills = paintVar(token, fb);
    const t = await txt(label, "Type/Strong", "color/text/ink", HEX.stone, 12);
    t.name = "Label";
    c.appendChild(t);
    page.appendChild(c);
    cells.push(c);
  }
  const set = figma.combineAsVariants(cells, page);
  set.name = "LedgerHeader";
  set.x = 40;
  set.y = 760;
  set.layoutMode = "HORIZONTAL";
  set.itemSpacing = 8;
  pad(set, 12);
  COMPS.LedgerHeader = set;
  return set;
}

async function buildSidebar(navLabels, selected) {
  const side = auto("VERTICAL", "Sidebar");
  side.resize(SIDE, H);
  side.layoutSizingHorizontal = "FIXED";
  side.layoutSizingVertical = "FIXED";
  side.fills = paintVar("color/bg/raised", HEX.raised);
  pad(side, 24, 12, 24, 12);
  side.itemSpacing = 8;
  side.counterAxisSizingMode = "FIXED";

  const brand = await txt("شطبها", "Type/Title", "color/text/brass", HEX.brass2, 22);
  brand.textAlignHorizontal = "RIGHT";
  side.appendChild(brand);
  brand.layoutSizingHorizontal = "FILL";

  const sub = await txt("شطبينا · Atelier", "Type/Caption", "color/text/brass", HEX.brass2, 11);
  side.appendChild(sub);
  sub.layoutSizingHorizontal = "FILL";

  const navSet = COMPS.NavItem;
  for (const label of navLabels) {
    let row;
    if (navSet) {
      row = instanceOf(navSet, label === selected ? "Selected" : "Default");
      const texts = row.findAll((n) => n.type === "TEXT");
      if (texts[0]) texts[0].characters = label;
    } else {
      row = auto("HORIZONTAL", label);
      pad(row, 9, 10);
      const t = await txt(
        label,
        label === selected ? "Type/Strong" : "Type/Body",
        label === selected ? "color/text/brass" : "color/text/on-chrome",
        label === selected ? HEX.brass2 : HEX.ivory,
        13
      );
      row.appendChild(t);
      if (label === selected) row.fills = paintVar("color/bg/muted", HEX.muted);
      row.cornerRadius = 8;
    }
    side.appendChild(row);
    row.layoutSizingHorizontal = "FILL";
  }
  return side;
}

async function buildTopBar() {
  const bar = auto("HORIZONTAL", "TopBar");
  bar.counterAxisAlignItems = "CENTER";
  bar.primaryAxisAlignItems = "SPACE_BETWEEN";
  pad(bar, 12, 20);
  bar.itemSpacing = 12;
  bar.fills = paintVar("color/bg/raised", HEX.raised);
  bar.counterAxisSizingMode = "FIXED";
  bar.resize(W - SIDE, 56);
  bar.layoutSizingVertical = "FIXED";

  const btnSet = COMPS.Button;
  if (btnSet) {
    const home = instanceOf(btnSet, "Filled");
    const texts = home.findAll((n) => n.type === "TEXT");
    if (texts[0]) texts[0].characters = "HOME";
    bar.appendChild(home);
  } else {
    const home = await txt("HOME", "Type/Strong", "color/text/ink", HEX.stone, 13);
    bar.appendChild(home);
  }

  const range = await txt("من 01/11/2024   إلى 08/10/2025", "Type/Label", "color/text/brass", HEX.brass2, 12);
  bar.appendChild(range);

  const clock = await txt("27/06/2026  18:24", "Type/Strong", "color/text/on-chrome", HEX.ivory, 14);
  bar.appendChild(clock);
  return bar;
}

async function buildKpiRow(items) {
  const row = auto("HORIZONTAL", "KPI strip");
  row.itemSpacing = 10;
  const set = COMPS.KPI;
  for (const item of items) {
    let card;
    if (set) {
      const tone = item.negative ? "Negative" : item.emphasis ? "Emphasis" : "Default";
      card = instanceOf(set, tone);
      const labels = card.findAll((n) => n.type === "TEXT" && n.name === "Label");
      const values = card.findAll((n) => n.type === "TEXT" && n.name === "Value");
      if (labels[0]) labels[0].characters = item.label;
      if (values[0]) values[0].characters = item.value;
    } else {
      card = auto("VERTICAL", item.label);
      pad(card, 12, 14);
      card.itemSpacing = 6;
      card.fills = paintVar("color/bg/raised", HEX.raised);
      card.cornerRadius = 10;
      card.appendChild(await txt(item.label, "Type/Label", "color/text/brass", HEX.brass2, 11));
      card.appendChild(
        await txt(
          item.value,
          "Type/KPI",
          item.negative ? "color/text/outflow" : "color/text/on-chrome",
          item.negative ? HEX.terra : HEX.ivory,
          20
        )
      );
    }
    row.appendChild(card);
  }
  return row;
}

function tintToken(kind) {
  if (kind === "date") return ["color/tint/date", HEX.date];
  if (kind === "cash") return ["color/tint/cash", HEX.cash];
  if (kind === "expense") return ["color/tint/expense", HEX.expense];
  if (kind === "calc") return ["color/tint/calculated", HEX.calc];
  if (kind === "ident") return ["color/tint/identity", HEX.ident];
  return ["color/bg/ledger-alt", HEX.ivory2];
}

async function buildTable(columns, rows) {
  const table = auto("VERTICAL", "Ledger");
  table.fills = paintVar("color/bg/ledger", HEX.ivory);
  table.cornerRadius = 12;
  table.layoutSizingHorizontal = "FILL";
  table.clipsContent = true;

  const head = auto("HORIZONTAL", "Header");
  head.layoutSizingHorizontal = "FILL";
  const headerSet = COMPS.LedgerHeader;
  for (const col of columns) {
    let cell;
    if (headerSet) {
      const map = { date: "Date", cash: "Cash", expense: "Expense", calc: "Calculated", ident: "Identity" };
      cell = instanceOf(headerSet, map[col.tint] || "Identity");
      const texts = cell.findAll((n) => n.type === "TEXT");
      if (texts[0]) texts[0].characters = col.title;
    } else {
      const [token, fb] = tintToken(col.tint);
      cell = auto("HORIZONTAL", col.title);
      pad(cell, 12, 14);
      cell.fills = paintVar(token, fb);
      cell.appendChild(await txt(col.title, "Type/Strong", "color/text/ink", HEX.stone, 12));
    }
    head.appendChild(cell);
    cell.layoutSizingHorizontal = "FILL";
  }
  table.appendChild(head);
  head.layoutSizingHorizontal = "FILL";

  let i = 0;
  for (const row of rows) {
    const r = auto("HORIZONTAL", "Row " + (i + 1));
    r.fills = i % 2 === 0 ? paintVar("color/bg/ledger", HEX.ivory) : paintVar("color/bg/ledger-alt", HEX.ivory2);
    let c = 0;
    for (const col of columns) {
      const cell = auto("HORIZONTAL", col.title);
      pad(cell, 10, 14);
      const val = row[c] || "";
      const colorName = col.tint === "expense" && /[1-9]/.test(val) ? "color/text/outflow" : "color/text/ink";
      const fb = colorName === "color/text/outflow" ? HEX.terra : HEX.stone;
      cell.appendChild(await txt(val, "Type/Body Ink", colorName, fb, 13));
      r.appendChild(cell);
      cell.layoutSizingHorizontal = "FILL";
      c += 1;
    }
    table.appendChild(r);
    r.layoutSizingHorizontal = "FILL";
    i += 1;
  }
  return table;
}

async function buildScreen(page, spec, col, row) {
  const root = auto("HORIZONTAL", "Screen / " + spec.name);
  root.resize(W, H);
  root.layoutSizingHorizontal = "FIXED";
  root.layoutSizingVertical = "FIXED";
  root.fills = paintVar("color/bg/chrome", HEX.stone);
  root.itemSpacing = 0;
  root.clipsContent = true;

  const main = auto("VERTICAL", "Main");
  main.layoutSizingVertical = "FIXED";
  main.resize(W - SIDE, H);
  main.fills = paintVar("color/bg/chrome", HEX.stone);
  main.itemSpacing = 16;
  pad(main, 0, 0, 20, 0);

  const top = await buildTopBar();
  main.appendChild(top);
  top.layoutSizingHorizontal = "FILL";

  const body = auto("VERTICAL", "Body");
  pad(body, 0, 24, 0, 24);
  body.itemSpacing = 14;
  const title = await txt(spec.title, "Type/Title", "color/text/on-chrome", HEX.ivory, 22);
  title.textAlignHorizontal = "RIGHT";
  body.appendChild(title);
  title.layoutSizingHorizontal = "FILL";

  if (spec.kpis) {
    const kpis = await buildKpiRow(spec.kpis);
    body.appendChild(kpis);
    kpis.layoutSizingHorizontal = "FILL";
  }
  if (spec.columns) {
    const table = await buildTable(spec.columns, spec.rows);
    body.appendChild(table);
    table.layoutSizingHorizontal = "FILL";
    table.layoutSizingVertical = "FILL";
  }
  if (spec.extra) {
    body.appendChild(spec.extra);
  }
  main.appendChild(body);
  body.layoutSizingHorizontal = "FILL";
  body.layoutSizingVertical = "FILL";

  const side = await buildSidebar(spec.nav, spec.selected);
  root.appendChild(main);
  root.appendChild(side);
  main.layoutSizingHorizontal = "FILL";
  main.layoutSizingVertical = "FILL";
  side.layoutSizingVertical = "FILL";

  root.x = col * (W + 80);
  root.y = row * (H + 80);
  page.appendChild(root);
  return root.id;
}

async function buildHome(page) {
  const root = auto("HORIZONTAL", "Screen / Home");
  root.resize(W, H);
  root.layoutSizingHorizontal = "FIXED";
  root.layoutSizingVertical = "FIXED";
  root.fills = paintVar("color/bg/chrome", HEX.stone);
  root.clipsContent = true;

  const stage = auto("VERTICAL", "Stage");
  stage.resize(W - SIDE, H);
  stage.fills = paintVar("color/bg/chrome", HEX.stone);
  pad(stage, 24);
  stage.itemSpacing = 20;
  stage.primaryAxisAlignItems = "CENTER";
  stage.counterAxisAlignItems = "CENTER";

  const hero = await txt("شطبها", "Type/Display", "color/text/on-chrome", HEX.ivory, 48);
  hero.textAlignHorizontal = "CENTER";
  stage.appendChild(hero);
  const tag = await txt("أتيلية التشطيبات والمقاولات", "Type/Section", "color/text/brass", HEX.brass2, 16);
  tag.textAlignHorizontal = "CENTER";
  stage.appendChild(tag);

  const gallery = auto("HORIZONTAL", "Gallery");
  gallery.itemSpacing = 12;
  const captions = ["فيلا ليلية", "مطبخ", "صالة", "واجهة"];
  const tones = [HEX.muted, HEX.raised, HEX.teal, HEX.terra];
  for (let i = 0; i < 4; i++) {
    const shot = auto("VERTICAL", captions[i]);
    shot.resize(200, 220);
    shot.layoutSizingHorizontal = "FIXED";
    shot.layoutSizingVertical = "FIXED";
    shot.fills = solid(tones[i]);
    shot.cornerRadius = 12;
    shot.primaryAxisAlignItems = "MAX";
    pad(shot, 12);
    const cap = await txt(captions[i], "Type/Caption", "color/text/on-chrome", HEX.ivory, 11);
    shot.appendChild(cap);
    gallery.appendChild(shot);
  }
  stage.appendChild(gallery);

  const grid = auto("VERTICAL", "Modules");
  grid.itemSpacing = 10;
  const rows = [
    ["التعريفات", "يومية العملاء", "كشف حساب عميل", "مصاريف إدارية"],
    ["تقرير العملاء", "اتفاق مقاولين", "تقرير المقاولين", "قائمة الدخل"],
    ["تقرير العهد", "اتفاقات وتكعيب", "إيرادات أخرى", "طباعة / تصدير"],
  ];
  const tileComp = COMPS.ModuleTile;
  for (const labels of rows) {
    const r = auto("HORIZONTAL", "row");
    r.itemSpacing = 10;
    for (const label of labels) {
      let tile;
      if (tileComp) {
        tile = tileComp.createInstance();
        const texts = tile.findAll((n) => n.type === "TEXT");
        if (texts[0]) texts[0].characters = label;
      } else {
        tile = auto("HORIZONTAL", label);
        pad(tile, 14);
        tile.fills = paintVar("color/bg/chrome", HEX.stone);
        tile.strokes = paintVar("color/accent/brass", HEX.brass);
        tile.strokeWeight = 1;
        tile.cornerRadius = 10;
        tile.appendChild(await txt(label, "Type/Strong", "color/text/on-chrome", HEX.ivory, 13));
      }
      r.appendChild(tile);
    }
    grid.appendChild(r);
  }
  stage.appendChild(grid);

  const nav = ["الرئيسية", "التعريفات", "يومية العملاء", "مصاريف إدارية", "قائمة الدخل"];
  const side = await buildSidebar(nav, "الرئيسية");
  root.appendChild(stage);
  root.appendChild(side);
  stage.layoutSizingHorizontal = "FILL";
  stage.layoutSizingVertical = "FILL";
  side.layoutSizingVertical = "FILL";
  root.x = 0;
  root.y = 0;
  page.appendChild(root);
  return root.id;
}

const CORE_NAV = [
  "الرئيسية",
  "التعريفات",
  "يومية العملاء",
  "كشف حساب عميل",
  "تقرير العملاء",
  "مصاريف إدارية",
  "إيرادات أخرى",
  "قائمة الدخل",
];

const FINISH_NAV = CORE_NAV.concat(["اتفاق مقاولين", "تقرير المقاولين", "تقرير العهد", "اتفاقات وتكعيب"]);
const MFG_NAV = CORE_NAV.concat(["يومية الموردين", "تقرير الموردين", "تقرير المخزون"]);
const RE_NAV = CORE_NAV.concat(["مبيعات وحدات", "الأقساط والتحصيل", "يومية الشركاء", "تقرير الشركاء"]);
const TEX_NAV = CORE_NAV.concat(["الميزانية العمومية"]);

function specs() {
  return [
    {
      name: "Definitions",
      title: "التعريفات",
      nav: CORE_NAV,
      selected: "التعريفات",
      kpis: [
        { label: "عملاء", value: "5" },
        { label: "مقاولون", value: "4" },
        { label: "أنواع مصروف", value: "11" },
      ],
      columns: [
        { title: "الاسم", tint: "ident" },
        { title: "النوع", tint: "date" },
        { title: "هاتف", tint: "cash" },
      ],
      rows: [
        ["عميل اتفاق 7", "عميل اتفاق", "01000000007"],
        ["خالد", "عميل إشراف", "01000000001"],
        ["مقاول 2", "مقاول", "01200000002"],
        ["م. محمد", "مهندس", "—"],
      ],
    },
    {
      name: "Expense journal",
      title: "يومية المصروفات الإدارية المكتبية",
      nav: CORE_NAV,
      selected: "مصاريف إدارية",
      kpis: [
        { label: "إجمالي المصروف", value: "15,000", emphasis: true },
        { label: "إجمالي المرتجع", value: "2,000", negative: true },
        { label: "الصافي", value: "13,000" },
      ],
      columns: [
        { title: "تاريخ", tint: "date" },
        { title: "البيان", tint: "ident" },
        { title: "نوع المصروف", tint: "expense" },
        { title: "مبلغ المصروف", tint: "expense" },
      ],
      rows: [
        ["27/06/2026", "اشتراك برامج", "اشتراكات وفواتير", "100"],
        ["27/06/2026", "إكرامية موقع", "إكراميات وبدلات", "1,000"],
        ["30/05/2026", "تأسيس سباكة — أحمد", "تأسيس السباكة", "10,000"],
        ["31/05/2026", "تأسيس نقاشة — سالم", "تأسيس النقاشة", "5,000"],
      ],
    },
    {
      name: "Customer journal",
      title: "يومية العملاء",
      nav: CORE_NAV,
      selected: "يومية العملاء",
      kpis: [
        { label: "توريدات نقدية", value: "10,000" },
        { label: "مصنعيات", value: "15,000", negative: true },
        { label: "مرتجعات", value: "2,000" },
      ],
      columns: [
        { title: "تاريخ", tint: "date" },
        { title: "توريد نقدي", tint: "cash" },
        { title: "البيان", tint: "ident" },
        { title: "بضاعة", tint: "expense" },
        { title: "مصنعية", tint: "expense" },
        { title: "مرتجعات", tint: "calc" },
      ],
      rows: [
        ["30/05/2026", "10,000", "دفعة تعاقد", "—", "—", "—"],
        ["30/05/2026", "—", "تأسيس سباكة", "—", "10,000", "2,000"],
        ["31/05/2026", "—", "تأسيس نقاشة", "—", "5,000", "—"],
      ],
    },
    {
      name: "Customer statement",
      title: "كشف حساب عميل — عميل اتفاق 7",
      nav: CORE_NAV,
      selected: "كشف حساب عميل",
      kpis: [
        { label: "اتفاق المقايسة", value: "50,000", emphasis: true },
        { label: "باقي اتفاق", value: "40,000" },
        { label: "إجمالي المصاريف", value: "13,000", negative: true },
        { label: "الرصيد الحالي", value: "3,000" },
        { label: "نسبة إشراف", value: "0%" },
      ],
      columns: [
        { title: "تاريخ", tint: "date" },
        { title: "توريد نقدي", tint: "cash" },
        { title: "البيان", tint: "ident" },
        { title: "نوع المصروف", tint: "expense" },
        { title: "بضاعة", tint: "expense" },
        { title: "مصنعية", tint: "expense" },
        { title: "مرتجعات", tint: "calc" },
      ],
      rows: [
        ["30/05/2026", "10,000", "دفعة تعاقد", "—", "—", "—", "—"],
        ["30/05/2026", "—", "تأسيس سباكة — أحمد", "تأسيس السباكة", "—", "10,000", "2,000"],
        ["31/05/2026", "—", "تأسيس نقاشة — سالم", "تأسيس النقاشة", "—", "5,000", "—"],
      ],
    },
    {
      name: "Customer report",
      title: "تقرير العملاء",
      nav: CORE_NAV,
      selected: "تقرير العملاء",
      kpis: [
        { label: "قيمة المبيعات", value: "110,000", emphasis: true },
        { label: "قيمة التحصيل", value: "10,000" },
        { label: "أرصدة آخر المدة", value: "100,000" },
      ],
      columns: [
        { title: "اسم العميل", tint: "ident" },
        { title: "حساب سابق", tint: "date" },
        { title: "قيمة المبيعات", tint: "cash" },
        { title: "قيمة تحصيل", tint: "cash" },
        { title: "رصيد آخر المدة", tint: "calc" },
      ],
      rows: [
        ["عميل 1", "—", "50,000", "5,000", "45,000"],
        ["عميل 2", "—", "30,000", "3,000", "27,000"],
        ["عميل 3", "—", "20,000", "1,000", "19,000"],
        ["عميل 4", "—", "10,000", "1,000", "9,000"],
      ],
    },
    {
      name: "Contractor jobs",
      title: "حسابات المقاولين",
      nav: FINISH_NAV,
      selected: "اتفاق مقاولين",
      kpis: [
        { label: "إجمالي الأعمال", value: "10,000", emphasis: true },
        { label: "صادر", value: "3,000" },
        { label: "الباقي", value: "7,000" },
      ],
      columns: [
        { title: "التاريخ", tint: "date" },
        { title: "اسم المقاول", tint: "ident" },
        { title: "اسم العميل", tint: "ident" },
        { title: "نوع العمل", tint: "expense" },
        { title: "الكمية", tint: "date" },
        { title: "سعر الوحدة", tint: "cash" },
        { title: "إجمالي", tint: "calc" },
        { title: "صادر 1", tint: "cash" },
        { title: "صادر 2", tint: "cash" },
        { title: "الباقي", tint: "calc" },
      ],
      rows: [["22/04/2026", "مقاول 2", "خالد", "نقاشة", "100", "100", "10,000", "1,000", "2,000", "7,000"]],
    },
    {
      name: "Contractor report",
      title: "تقرير المتعهدين",
      nav: FINISH_NAV,
      selected: "تقرير المقاولين",
      kpis: [
        { label: "مصاريف بضاعة", value: "10,000" },
        { label: "مصاريف مصنعيات", value: "10,000", negative: true },
        { label: "مصاريف إدارية", value: "4,000" },
        { label: "الرصيد الحالي", value: "24,000", emphasis: true, negative: true },
      ],
      columns: [
        { title: "اسم المتعهد", tint: "ident" },
        { title: "استلام دفعات", tint: "cash" },
        { title: "مصاريف بضاعة", tint: "expense" },
        { title: "مصاريف مصنعيات", tint: "expense" },
        { title: "مصاريف إدارية", tint: "expense" },
        { title: "الرصيد الحالي", tint: "calc" },
      ],
      rows: [
        ["متعهد 1", "—", "10,000", "10,000", "4,000", "24,000-"],
        ["متعهد 2", "—", "—", "—", "—", "—"],
        ["متعهد 3", "—", "—", "—", "—", "—"],
      ],
    },
    {
      name: "Income statement",
      title: "قائمة الدخل",
      nav: CORE_NAV,
      selected: "قائمة الدخل",
      kpis: [
        { label: "تحصيل / إيراد", value: "1,000", emphasis: true },
        { label: "إجمالي مصاريف مكتبية", value: "100", negative: true },
        { label: "صافي الربح", value: "900", emphasis: true },
      ],
      columns: [
        { title: "البند", tint: "ident" },
        { title: "القيمة", tint: "calc" },
      ],
      rows: [
        ["تحصيل نسب إشراف تشطيبات", "1,000"],
        ["إجمالي مصاريف مكتبية وإدارية", "100"],
        ["اشتراكات وفواتير", "100"],
        ["إكراميات وبدلات", "—"],
        ["رواتب موظفين", "—"],
        ["صافي الربح", "900"],
      ],
    },
    {
      name: "Income food",
      title: "قائمة الدخل — رواد فود",
      nav: MFG_NAV,
      selected: "قائمة الدخل",
      kpis: [
        { label: "إجمالي إيرادات", value: "110,000", emphasis: true },
        { label: "تكلفة خامات مباعة", value: "10,000", negative: true },
        { label: "مجمل الربح", value: "100,000" },
        { label: "مصاريف إدارية", value: "1,000", negative: true },
        { label: "صافي الربح", value: "99,000", emphasis: true },
      ],
      columns: [
        { title: "البند", tint: "ident" },
        { title: "القيمة", tint: "calc" },
      ],
      rows: [
        ["إيرادات مبيعات خامات مخزون", "100,000"],
        ["مصنعية تركيب", "10,000"],
        ["إجمالي إيرادات", "110,000"],
        ["تكاليف خامات مخزون مباعة (-)", "10,000"],
        ["مجمل ربح عام", "100,000"],
        ["إكراميات وبدلات", "1,000"],
        ["صافي الربح", "99,000"],
      ],
    },
    {
      name: "Other revenues",
      title: "إيرادات أخرى",
      nav: CORE_NAV,
      selected: "إيرادات أخرى",
      kpis: [{ label: "إيرادات أخرى", value: "2,500", emphasis: true }],
      columns: [
        { title: "تاريخ", tint: "date" },
        { title: "البيان", tint: "ident" },
        { title: "القيمة", tint: "cash" },
      ],
      rows: [["12/03/2026", "بيع خردة ألوميتال", "2,500"]],
    },
    {
      name: "Petty cash",
      title: "تقرير العهد",
      nav: FINISH_NAV,
      selected: "تقرير العهد",
      kpis: [
        { label: "عهد مسلمة", value: "5,000", emphasis: true },
        { label: "مصروف منها", value: "3,200", negative: true },
        { label: "المتبقي", value: "1,800" },
      ],
      columns: [
        { title: "تاريخ", tint: "date" },
        { title: "المستلم", tint: "ident" },
        { title: "البيان", tint: "ident" },
        { title: "عهدة", tint: "cash" },
        { title: "صرف", tint: "expense" },
        { title: "المتبقي", tint: "calc" },
      ],
      rows: [["10/05/2026", "م. محمد", "عهدة موقع فيلا", "5,000", "3,200", "1,800"]],
    },
    {
      name: "Cubing",
      title: "اتفاقات وتكعيب",
      nav: FINISH_NAV,
      selected: "اتفاقات وتكعيب",
      kpis: [
        { label: "متر تشطيب", value: "420" },
        { label: "قيمة الاتفاق", value: "50,000", emphasis: true },
      ],
      columns: [
        { title: "البند", tint: "ident" },
        { title: "الوحدة", tint: "date" },
        { title: "الكمية", tint: "cash" },
        { title: "سعر الوحدة", tint: "cash" },
        { title: "الإجمالي", tint: "calc" },
      ],
      rows: [
        ["نقاشة حوائط", "م²", "220", "80", "17,600"],
        ["جبس بلدي", "م²", "80", "120", "9,600"],
        ["ألوميتال", "م.ط", "40", "350", "14,000"],
        ["كهرباء تشطيب", "نقطة", "80", "110", "8,800"],
      ],
    },
    {
      name: "Supplier journal",
      title: "يومية الموردين",
      nav: MFG_NAV,
      selected: "يومية الموردين",
      kpis: [
        { label: "مشتريات الفترة", value: "70,000", emphasis: true },
        { label: "مدفوعات", value: "—" },
        { label: "الرصيد", value: "70,000", negative: true },
      ],
      columns: [
        { title: "تاريخ", tint: "date" },
        { title: "المورد", tint: "ident" },
        { title: "البيان", tint: "ident" },
        { title: "مشتريات", tint: "expense" },
        { title: "سداد", tint: "cash" },
        { title: "الرصيد", tint: "calc" },
      ],
      rows: [
        ["01/12/2024", "موردين غزل", "توريد غزل", "70,000", "—", "70,000"],
        ["15/01/2025", "مورد خامات 1", "خامات متنوعة", "—", "—", "—"],
      ],
    },
    {
      name: "Inventory",
      title: "تقرير أصناف إنتاج تام",
      nav: MFG_NAV,
      selected: "تقرير المخزون",
      kpis: [
        { label: "أول المدة", value: "3,000" },
        { label: "إنتاج الفترة", value: "1,000" },
        { label: "مبيعات", value: "15" },
        { label: "مرتجع", value: "2" },
        { label: "رصيد حالي", value: "3,987", emphasis: true },
        { label: "عدد دست", value: "332.25" },
      ],
      columns: [
        { title: "مسلسل", tint: "ident" },
        { title: "اسم الصنف", tint: "ident" },
        { title: "أول المدة", tint: "date" },
        { title: "إنتاج", tint: "cash" },
        { title: "مبيعات", tint: "expense" },
        { title: "مرتجع", tint: "expense" },
        { title: "رصيد حالي", tint: "calc" },
        { title: "عدد دست", tint: "calc" },
      ],
      rows: [
        ["1", "منتج تام ١", "1,000", "1,000", "14", "2", "1,988", "165.7"],
        ["2", "منتج تام ٢", "1,000", "—", "1", "—", "999", "83.25"],
        ["3", "منتج تام ٣", "1,000", "—", "—", "—", "1,000", "83.33"],
      ],
    },
    {
      name: "Unit sales",
      title: "مبيعات وحدات",
      nav: RE_NAV,
      selected: "مبيعات وحدات",
      kpis: [
        { label: "وحدات مباعة", value: "3", emphasis: true },
        { label: "قيمة البيوع", value: "4,800,000" },
        { label: "محصّل", value: "1,200,000" },
      ],
      columns: [
        { title: "الوحدة", tint: "ident" },
        { title: "العميل", tint: "ident" },
        { title: "المساحة", tint: "date" },
        { title: "السعر", tint: "cash" },
        { title: "محصّل", tint: "cash" },
        { title: "المتبقي", tint: "calc" },
      ],
      rows: [
        ["ب-101", "خالد", "140", "1,800,000", "600,000", "1,200,000"],
        ["ب-102", "عميل 1", "120", "1,500,000", "400,000", "1,100,000"],
        ["ج-201", "بدير", "160", "1,500,000", "200,000", "1,300,000"],
      ],
    },
    {
      name: "Installments",
      title: "تقرير الأقساط والتحصيل",
      nav: RE_NAV,
      selected: "الأقساط والتحصيل",
      kpis: [
        { label: "مستحق الفترة", value: "450,000" },
        { label: "محصّل", value: "300,000" },
        { label: "متأخر", value: "150,000", negative: true },
      ],
      columns: [
        { title: "العميل", tint: "ident" },
        { title: "الوحدة", tint: "ident" },
        { title: "الاستحقاق", tint: "date" },
        { title: "القسط", tint: "cash" },
        { title: "تحصيل", tint: "cash" },
        { title: "الحالة", tint: "calc" },
      ],
      rows: [
        ["خالد", "ب-101", "01/06/2026", "150,000", "150,000", "مسدد"],
        ["عميل 1", "ب-102", "01/06/2026", "150,000", "150,000", "مسدد"],
        ["بدير", "ج-201", "01/06/2026", "150,000", "—", "متأخر"],
      ],
    },
    {
      name: "Partners",
      title: "تقرير الشركاء",
      nav: RE_NAV,
      selected: "تقرير الشركاء",
      kpis: [
        { label: "رأس المال", value: "2,000,000", emphasis: true },
        { label: "مسحوبات", value: "80,000", negative: true },
      ],
      columns: [
        { title: "الشريك", tint: "ident" },
        { title: "النسبة", tint: "date" },
        { title: "رأس المال", tint: "cash" },
        { title: "مسحوبات", tint: "expense" },
        { title: "الرصيد", tint: "calc" },
      ],
      rows: [
        ["الشريك أ", "60%", "1,200,000", "80,000", "1,120,000"],
        ["الشريك ب", "40%", "800,000", "—", "800,000"],
      ],
    },
    {
      name: "Balance sheet",
      title: "الميزانية العمومية",
      nav: TEX_NAV,
      selected: "الميزانية العمومية",
      kpis: [
        { label: "إجمالي الأصول", value: "95,447", emphasis: true },
        { label: "إجمالي الخصوم", value: "95,447", emphasis: true },
        { label: "صافي الربح", value: "2,360-", negative: true },
      ],
      columns: [
        { title: "أصول", tint: "ident" },
        { title: "قيمة", tint: "cash" },
        { title: "خصوم", tint: "ident" },
        { title: "قيمة", tint: "expense" },
      ],
      rows: [
        ["رصيد العملاء", "1,380", "موردين غزل", "70,000"],
        ["شيكات عملاء", "10,000", "صافي الربح", "2,360-"],
        ["قيمة مخزون غزل", "84,067", "رأس المال", "27,807"],
        ["إجمالي الأصول", "95,447", "إجمالي الخصوم", "95,447"],
      ],
    },
    {
      name: "Print preview",
      title: "طباعة / تصدير — قائمة الدخل",
      nav: CORE_NAV,
      selected: "قائمة الدخل",
      kpis: [{ label: "صافي الربح", value: "900", emphasis: true }],
      columns: [
        { title: "البند", tint: "ident" },
        { title: "القيمة", tint: "calc" },
      ],
      rows: [
        ["تحصيل نسب إشراف", "1,000"],
        ["مصاريف مكتبية", "100"],
        ["صافي الربح", "900"],
      ],
    },
  ];
}

async function run() {
  await loadFonts();
  await loadTokens();

  const compPage = findPage("Components");
  const screensPage = findPage("Screens");
  if (!compPage || !screensPage) {
    figma.closePlugin("Missing Components or Screens page. Open the Shatbha Atelier file first.");
    return;
  }

  await figma.setCurrentPageAsync(compPage);
  COMPS = findComponents(compPage);
  await ensureModuleTile(compPage);
  await ensureLedgerHeader(compPage);
  COMPS = findComponents(compPage);

  await figma.setCurrentPageAsync(screensPage);
  for (const child of [...screensPage.children]) {
    if (child.name.indexOf("Screen /") === 0) child.remove();
  }

  const ids = [];
  ids.push(await buildHome(screensPage));
  const list = specs();
  let i = 0;
  for (const spec of list) {
    i += 1;
    const col = i % 4;
    const row = Math.floor(i / 4);
    ids.push(await buildScreen(screensPage, spec, col, row));
  }

  figma.viewport.scrollAndZoomIntoView(screensPage.children.filter((n) => n.name === "Screen / Home"));
  figma.closePlugin("Built " + ids.length + " Atelier screens on the Screens page.");
}

const MOBILE_GROUPS = [
  { name: "00 Session", stems: ["22-splash", "25-login"] },
  { name: "01 Shell", stems: ["01-home", "55-ledger-hub", "56-reports-hub", "60-more-consistent"] },
  { name: "02 Definitions", stems: ["07-definitions", "28-add-customer", "54-add-supplier", "35-work-types", "36-items"] },
  { name: "03 Customers", stems: ["08-customer-journal", "30-add-entry", "31-pick-customer", "03-statement", "32-supervision", "09-customer-report"] },
  { name: "04 Expenses", stems: ["02-expenses", "50-empty", "29-add-expense", "37-expenses-report"] },
  { name: "05 Other revenues", stems: ["10-other-revenues"] },
  { name: "06 Contractors", stems: ["04-contractors", "33-add-job", "34-issue-pay", "13-cubing", "12-petty-cash", "11-contractor-report"] },
  { name: "07 Income statement", stems: ["05-pnl", "21-income-food", "40-income-aluminum"] },
  { name: "08 Sales report", stems: ["38-sales-report"] },
  { name: "09 Combined journal", stems: ["39-general-journal"] },
  { name: "10 Print", stems: ["20-print"] },
  { name: "11 Suppliers", stems: ["14-supplier-journal", "15-supplier-report"] },
  { name: "12 Inventory", stems: ["06-inventory", "42-material-out", "43-production", "41-mfg-customers"] },
  { name: "13 Checks", stems: ["44-checks"] },
  { name: "14 Real estate", stems: ["16-unit-sales", "46-unit-detail", "17-installments", "47-collect", "45-contracting"] },
  { name: "15 Partners", stems: ["48-partner-agree", "24-partners-journal", "18-partners"] },
  { name: "16 Balance sheet", stems: ["19-balance-sheet", "52-fixed-assets"] },
  { name: "17 Company packs", stems: ["26-company", "23-packs"] },
  { name: "18 System", stems: ["53-search", "49-date-filter", "51-backup"] },
  { name: "19 Flow states", stems: ["57-success", "58-error", "59-forbidden"] },
];

function stemFromFilename(name) {
  return String(name)
    .replace(/^.*\//, "")
    .replace(/^shatbha-mobile-/, "")
    .replace(/\.png$/i, "");
}

function groupForStem(stem) {
  for (const g of MOBILE_GROUPS) {
    if (g.stems.indexOf(stem) >= 0) return g.name;
  }
  return "20 Other";
}

function decodePng(b64) {
  if (typeof figma.base64Decode === "function") return figma.base64Decode(b64);
  const binary = atob(b64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes;
}

async function importMobile() {
  const screensPage = findPage("Screens") || figma.currentPage;
  await figma.setCurrentPageAsync(screensPage);

  const fonts = await figma.listAvailableFontsAsync();
  const cairo = fonts.find((f) => f.fontName.family === "Cairo" && f.fontName.style === "Regular");
  const font = cairo ? cairo.fontName : { family: "Inter", style: "Regular" };
  await figma.loadFontAsync(font);

  figma.showUI(__html__, { width: 420, height: 280 });

  const stone = { r: 28 / 255, g: 24 / 255, b: 20 / 255 };
  const brass = { r: 196 / 255, g: 165 / 255, b: 116 / 255 };
  const ivory = { r: 246 / 255, g: 241 / 255, b: 232 / 255 };

  let root = null;
  const rows = {};
  let placed = 0;

  function ensureRoot() {
    if (root && !root.removed) return;
    for (const child of [...screensPage.children]) {
      if (child.name === "Mobile screens") child.remove();
    }
    root = figma.createFrame();
    root.name = "Mobile screens";
    root.layoutMode = "VERTICAL";
    root.primaryAxisSizingMode = "AUTO";
    root.counterAxisSizingMode = "AUTO";
    root.itemSpacing = 120;
    root.paddingTop = 80;
    root.paddingRight = 80;
    root.paddingBottom = 80;
    root.paddingLeft = 80;
    root.fills = [{ type: "SOLID", color: stone }];
    root.clipsContent = false;
    let maxX = 0;
    for (const child of screensPage.children) {
      if (child.id === root.id) continue;
      maxX = Math.max(maxX, child.x + child.width);
    }
    root.x = maxX + 240;
    root.y = 0;
  }

  function rowFor(groupName) {
    if (rows[groupName] && !rows[groupName].block.removed) return rows[groupName];
    const block = figma.createFrame();
    block.name = groupName;
    block.layoutMode = "VERTICAL";
    block.primaryAxisSizingMode = "AUTO";
    block.counterAxisSizingMode = "AUTO";
    block.itemSpacing = 24;
    block.fills = [];
    block.clipsContent = false;
    const title = figma.createText();
    title.fontName = font;
    title.characters = groupName;
    title.fontSize = 28;
    title.fills = [{ type: "SOLID", color: brass }];
    block.appendChild(title);
    const row = figma.createFrame();
    row.name = "Screens";
    row.layoutMode = "HORIZONTAL";
    row.primaryAxisSizingMode = "AUTO";
    row.counterAxisSizingMode = "AUTO";
    row.itemSpacing = 48;
    row.fills = [];
    row.clipsContent = false;
    block.appendChild(row);
    root.appendChild(block);
    rows[groupName] = { block, row };
    return rows[groupName];
  }

  figma.ui.onmessage = async (msg) => {
    try {
      if (msg.type === "start") {
        ensureRoot();
        figma.ui.postMessage({ type: "next" });
        return;
      }
      if (msg.type === "file") {
        ensureRoot();
        const stem = stemFromFilename(msg.name);
        if (stem.indexOf("27-more") === 0) {
          figma.ui.postMessage({ type: "next" });
          return;
        }
        const groupName = groupForStem(stem);
        const { row } = rowFor(groupName);
        const col = figma.createFrame();
        col.name = stem;
        col.layoutMode = "VERTICAL";
        col.primaryAxisSizingMode = "AUTO";
        col.counterAxisSizingMode = "AUTO";
        col.itemSpacing = 12;
        col.fills = [];
        const cap = figma.createText();
        cap.fontName = font;
        cap.characters = stem;
        cap.fontSize = 14;
        cap.fills = [{ type: "SOLID", color: ivory }];
        col.appendChild(cap);
        const screen = figma.createFrame();
        screen.name = "Screen / " + stem;
        screen.resize(1024, 1536);
        screen.clipsContent = true;
        const image = figma.createImage(decodePng(msg.b64));
        screen.fills = [{ type: "IMAGE", imageHash: image.hash, scaleMode: "FILL" }];
        col.appendChild(screen);
        screen.layoutSizingHorizontal = "FIXED";
        screen.layoutSizingVertical = "FIXED";
        row.appendChild(col);
        placed += 1;
        figma.ui.postMessage({ type: "next" });
        return;
      }
      if (msg.type === "done") {
        if (root) figma.viewport.scrollAndZoomIntoView([root]);
        figma.closePlugin("Imported " + placed + " mobile screens onto the Screens page.");
      }
    } catch (e) {
      figma.ui.postMessage({
        type: "error",
        message: String(e && e.message ? e.message : e),
      });
    }
  };
}

if (figma.command === "desktop") {
  run().catch((e) => {
    figma.closePlugin(String(e && e.message ? e.message : e));
  });
} else {
  importMobile().catch((e) => {
    figma.closePlugin(String(e && e.message ? e.message : e));
  });
}
