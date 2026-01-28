// box collapse

document.addEventListener("DOMContentLoaded", () => {
  // box 1 collapse
  const box1 = document.getElementById("box-1");
  const btn1 = document.getElementById("dropdown-learn_more");
  if (box1 && btn1) {
    const icon1 = btn1.querySelector("img.picto");
    const body_wrapper = box1.querySelector(".txt-body")?.closest(".wrapper");

    if (body_wrapper) {
      body_wrapper.classList.add("learnmore-collapse");

      let collapsed = false;
      btn1.setAttribute("aria-expanded", "true");

      function set_collapsed(next) {
        collapsed = next;
        box1.classList.toggle("is-collapsed", collapsed);

        if (icon1) {
          icon1.src = collapsed ? "images/picto-plus.png" : "images/picto-minus.png";
          icon1.alt = collapsed ? "Expand" : "Collapse";
        }
        btn1.setAttribute("aria-expanded", collapsed ? "false" : "true");
      }

      btn1.addEventListener("click", (e) => {
        e.preventDefault();
        e.stopPropagation();
        set_collapsed(!collapsed);
      });
    }
  }

  // box 3 collapse
  const box3 = document.getElementById("box-3");
  const toggle_btn = document.getElementById("toggle-details");
  const toggle_icon = toggle_btn?.querySelector("img.picto");

  let open = true;

  function set_open(next) {
    open = next;
    if (!box3 || !toggle_btn) return;

    box3.classList.toggle("is-collapsed", !open);
    toggle_btn.setAttribute("aria-expanded", open ? "true" : "false");

    if (toggle_icon) {
      toggle_icon.src = open ? "images/picto-minus.png" : "images/picto-plus.png";
      toggle_icon.alt = open ? "Collapse" : "Expand";
    }
  }

  toggle_btn?.addEventListener("click", (e) => {
    e.preventDefault();
    e.stopPropagation();
    set_open(!open);
  });

  set_open(true);
});



// dropdown municipalities

const selected = document.getElementById('dropdown-selected-city');
const menu = document.getElementById('dropdown-menu-city');
const box2 = document.getElementById('box-2');

function menu_set(is_open) {
  menu.classList.toggle('open', is_open);
  box2.classList.toggle('menu-open', is_open);
}

// toggle on button
selected.addEventListener('click', (e) => {
  e.preventDefault();
  e.stopPropagation();
  menu_set(!menu.classList.contains('open'));
});

// click outside closes
document.addEventListener('click', () => menu_set(false));

// clicking inside menu shouldn’t close before your link handler runs
menu.addEventListener('click', (e) => e.stopPropagation());

// cities zooms
const cities_centers = {
  "New York City": {center: [-74.0000, 40.7300], zoom: 10},
  "Los Angeles": {center: [-118.2437, 34.0522], zoom: 10},
  "Chicago": {center: [-87.6298, 41.8781], zoom: 10},
  "Dallas": {center: [-96.7970, 32.7767], zoom: 10},
  "Houston": {center: [-95.3698, 29.7604], zoom: 10},
  "Washington DC": {center: [-77.0369, 38.9072], zoom: 10},
  "Philadelphia": {center: [-75.1652, 39.9526], zoom: 10},
  "Atlanta": {center: [-84.3880, 33.7490], zoom: 10},
  "US": {center: [-98.5795, 39.8283], zoom: 5}
};

// when clicking on a city name
menu.querySelectorAll('.dropdown-link').forEach(link => {
  link.addEventListener('click', (e) => {
    e.preventDefault();
    e.stopPropagation();

    const city = link.textContent.trim();
    const view = cities_centers[city];
    if (!view || !window.map) return;

    window.map.easeTo({ center: view.center, zoom: view.zoom, duration: 400 });
    document.querySelector('#dropdown-selected-city .txt-menu').textContent = city;
    menu_set(false);
  });
});



// checkbox boundaries

const checkbox_municipality = document.getElementById('checkbox-municipality-input');

function set_municipality_visibility(visible) {
  if (!window.map) return;
  const municipality_id = 'municipality-limits';

  if (!window.map.getLayer(municipality_id)) {
    console.warn('Layer not found:', municipality_id);
    return;
  }

  window.map.setLayoutProperty(municipality_id, 'visibility', visible ? 'visible' : 'none');
  console.log('Municipality outline:', visible ? 'visible' : 'none');
}

// change on click
checkbox_municipality.addEventListener('change', (e) => {
  set_municipality_visibility(e.target.checked);
});

// make sure initial state matches the checkbox
if (checkbox_municipality.checked) {
  set_municipality_visibility(true);
} else {
  set_municipality_visibility(false);
}



// data period toggle

const checkbox_period = document.getElementById('checkbox-period-input');
const layer_1970 = 'gi-fac-1970_2020_temp';
const layer_1990 = 'gi-fac-1990_2020';

function period_select(is_1970) {
  if (!window.map) return;

  // layers must exist (only true after map style loads)
  if (!window.map.getLayer(layer_1970) || !window.map.getLayer(layer_1990)) {
    console.warn('One or both period layers not found:', layer_1970, layer_1990);
    return;
  }

  window.map.setLayoutProperty(layer_1970, 'visibility', is_1970 ? 'visible' : 'none');
  window.map.setLayoutProperty(layer_1990, 'visibility', is_1970 ? 'none' : 'visible');
}



// hovered and selected tract

// hover popup
const popup = new mapboxgl.Popup({
  className: "popup-override",
  closeButton: false,
  closeOnClick: false,
  closeOnMove: false,
  anchor: "left",
  offset: {left: [32, 32]}
});

// selected popup (fixed, with shadow)
const popup_selected = new mapboxgl.Popup({
  className: "popup-selected",
  closeButton: false,
  closeOnClick: false,
  closeOnMove: false,
  anchor: "left",
  offset: {left: [26, 26]}
});

let raf_id; // animation frame id
let selected_geoid = null; // initial state for selected tract

// hover and selected tracts
const hover_id = "gi-hover";
const selected_id = "gi-selected";

// helpers
function money(v) {
  const n = Number(v);
  if (!Number.isFinite(n)) return "—";
  return "$ " + n.toLocaleString("en-US", {minimumFractionDigits: 2, maximumFractionDigits: 2});
}

function pct(v) {
  const n = Number(v);
  if (!Number.isFinite(n)) return "—";
  return n.toFixed(2) + "%";
}

function set_selected_feature(f, lngLat) {
  const geoid = String(f?.properties?.GEOID ?? "");
  if (!geoid) return;

  selected_geoid = geoid;

  // selected outline only (no dropshadow on tract)
  if (window.map.getLayer(selected_id)) {
    window.map.setFilter(selected_id, ["==", ["get", "GEOID"], selected_geoid]);
  }

  // update box 3 + legend marker from selected tract
  const { idx_txt, idx_num } = update_details(f);
  set_legend_marker(idx_num);

  // fixed popup shows selected tract info
  const p = f.properties || {};
  const geoid_txt = String(p.GEOID ?? "—");
  const fixed_html = `
    <div class="popup-wrapper">
      <span class="txt-label">Tract</span>
      <span class="txt-value">${geoid_txt}</span>
      <span class="txt-label">Index</span>
      <span class="txt-value">${idx_txt}</span>
    </div>
  `;

  if (lngLat) {
    popup_selected.setLngLat(lngLat).setHTML(fixed_html).addTo(window.map);
  }
}

function clear_selected() {
  selected_geoid = null;

  if (window.map.getLayer(selected_id)) {
    window.map.setFilter(selected_id, ["==", ["get", "GEOID"], "__none__"]);
  }

  popup_selected.remove();
  hide_legend_marker();
}


// update box 3 details
function update_details(f) {
  const p = f.properties || {};
  const geoid = String(p.GEOID ?? "—");
  const cbsa = String(p.CBSA_NAME ?? "").split(",")[0] || "—";
  const type = String(p.classtype ?? "—").replace(/^./, c => c.toUpperCase());
  const idx = Number(p.FAC_1990to2020);
  const idx_txt = Number.isFinite(idx) ? idx.toFixed(2) : "—";

  document.getElementById("detail-tract").textContent = geoid;
  document.getElementById("detail-metro").textContent = cbsa;
  document.getElementById("detail-class").textContent = type;
  document.getElementById("detail-rent").textContent = money(p.ConRent_mean_2020);
  document.getElementById("detail-house").textContent = money(p.HouseValue_mean_2020);
  document.getElementById("detail-income").textContent = money(p.HHIncome_mean_2020);
  document.getElementById("detail-poverty").textContent = pct(p.Poverty_pct_2020);
  document.getElementById("detail-bach").textContent = pct(p.Bach_pct_2020);
  document.getElementById("detail-white").textContent = pct(p.WhiteCollar_pct_2020);

  console.log(Object.keys(f.properties || {}));
  return { geoid, idx_txt, idx_num: idx };
}

// run once when the map style is ready
window.map.on('load', () => {
  period_select(checkbox_period.checked);
});

// run on toggle
checkbox_period.addEventListener('change', (e) => {
  period_select(e.target.checked);
});

// legend marker
const legend_wrap = document.getElementById("legend_wrap");
const legend_marker = document.getElementById("legend_marker");
const legend_marker_value = document.getElementById("legend_marker_value");

// legend scale range
const legend_min = -4;
const legend_max =  4;

function clamp_1(t) {return Math.max(0, Math.min(1, t));}

function set_legend_marker(idx_num) {
  if (!legend_wrap || !legend_marker || !legend_marker_value) return;

  const n = Number(idx_num);
  if (!Number.isFinite(n)) {
    hide_legend_marker();
    return;
  }
  const t = clamp_1((n - legend_min) / (legend_max - legend_min)); // normalized value from 0 to 1
  const w = legend_wrap.getBoundingClientRect().width; // width of the legend area
  const mw = legend_marker.getBoundingClientRect().width || 0; // marker width
  const x_px = (t * w) - (mw / 2); // pixel position along the bar

  // marker position
  legend_marker.style.left = `${x_px}px`;

  // show + update text
  legend_marker_value.textContent = n.toFixed(2); //decimals
  legend_marker.style.display = "block";
  legend_marker.setAttribute("aria-hidden", "false");
}

function hide_legend_marker() {
  if (!legend_marker) return;
  legend_marker.style.display = "none";
  legend_marker.setAttribute("aria-hidden", "true");
}

window.addEventListener("resize", () => {
  if (!legend_marker || legend_marker.style.display !== "block") return;
  const n = Number(legend_marker_value?.textContent);
  if (Number.isFinite(n)) set_legend_marker(n);
});


// popup + highlight
window.map.on("load", () => {
  const layer_ids = ["gi-fac-1990_2020", "gi-fac-1970_2020_temp"];

  // pick a base layer to copy source from
  const base_layer_id = layer_ids.find((id) => window.map.getLayer(id));
  if (!base_layer_id) {
    console.error("no period layers found:", layer_ids);
    return;
  }

  const base_layer = window.map.getLayer(base_layer_id);
  const source_base = base_layer.source;
  const source_sub_layer = base_layer["source-layer"];

  // selected tract outline (NO shadow layer)
  if (!window.map.getLayer(selected_id)) {
    const selected_def = {
      id: selected_id,
      type: "line",
      source: source_base,
      filter: ["==", ["get", "GEOID"], "__none__"],
      paint: {
        "line-color": "white",
        "line-width": 2,
        "line-opacity": 1
      }
    };
    if (source_sub_layer) selected_def["source-layer"] = source_sub_layer;
    window.map.addLayer(selected_def);
  }

  // hovered tract
  if (!window.map.getLayer(hover_id)) {
    const hover_def = {
      id: hover_id,
      type: "line",
      source: source_base,
      filter: ["==", ["get", "GEOID"], "__none__"],
      paint: {
        "line-color": "#007BFF",
        "line-width": 2,
        "line-opacity": 1
      }
    };

    if (source_sub_layer) hover_def["source-layer"] = source_sub_layer;
    window.map.addLayer(hover_def);
  }

  function bind_hover(layer_id) {
    if (!window.map.getLayer(layer_id)) {
      console.warn("missing layer:", layer_id);
      return;
    }

    window.map.on("mouseenter", layer_id, () => {
      window.map.getCanvas().style.cursor = "default";
      if (!popup.isOpen()) popup.addTo(window.map);
    });

    window.map.on("mousemove", layer_id, (e) => {
      const f = e.features && e.features[0];
      if (!f) return;

      const geoid = String(f.properties?.GEOID ?? "");
      window.map.setFilter(hover_id, ["==", ["get", "GEOID"], geoid]);

      // hover popup (NOT selected)
      const p = f.properties || {};
      const geoid_txt = String(p.GEOID ?? "—");
      const idx = Number(p.FAC_1990to2020);
      const idx_txt = Number.isFinite(idx) ? idx.toFixed(2) : "—";
      const small_html = `
        <div class="popup-wrapper">
          <span class="txt-label">Tract</span>
          <span class="txt-value">${geoid_txt}</span>
          <span class="txt-label">Index</span>
          <span class="txt-value">${idx_txt}</span>
        </div>
      `;

      cancelAnimationFrame(raf_id);
      raf_id = requestAnimationFrame(() => {
        popup.setLngLat(e.lngLat).setHTML(small_html);
      });
    });

    window.map.on("mouseleave", layer_id, () => {
      window.map.setFilter(hover_id, ["==", ["get", "GEOID"], "__none__"]);
      popup.remove();
      window.map.getCanvas().style.cursor = "";
      // keep legend marker if there is a selection
      if (!selected_geoid) hide_legend_marker();
    });
  }

  // bind both layers so hover works no matter which is visible
  layer_ids.forEach(bind_hover);

  // one click handler for selection (sets fixed popup + details)
  window.map.on("click", (e) => {
    const features = window.map.queryRenderedFeatures(e.point, {
      layers: ["gi-fac-1990_2020", "gi-fac-1970_2020_temp"]
    });

    const f = features && features[0];
    if (f) {
      set_selected_feature(f, e.lngLat);
    } else {
      clear_selected();
    }
  });

});
