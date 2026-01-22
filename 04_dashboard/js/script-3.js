
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

// open dropdown on click
selected.addEventListener('click', (e) => {
  e.stopPropagation();
  menu.classList.toggle('open');
});

// close dropdown when clicking outside
document.addEventListener('click', () => {
  menu.classList.remove('open');
});

// prevent closing when clicking inside menu
menu.addEventListener('click', (e) => {
  e.stopPropagation();
});

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

    window.map.easeTo({
      center: view.center,
      zoom: view.zoom,
      duration: 400
    });

    // update the label of the selected button
    document.querySelector('#dropdown-selected-city .txt-menu').textContent = city;

    // close menu
    menu.classList.remove('open');
  });
});


// checkbox boundaries
const checkbox_municipality = document.getElementById('checkbox-municipality-input');

function setMunicipalityVisibility(visible) {
  if (!window.map) return;
  const municipality_id = 'municipality-limits';

  if (!window.map.getLayer(municipality_id)) {
    console.warn('Layer not found:', municipality_id);
    return;
  }

  window.map.setLayoutProperty(
    municipality_id,
    'visibility',
    visible ? 'visible' : 'none'
  );
  console.log('Municipality outline:', visible ? 'visible' : 'none');
}

// change on click
checkbox_municipality.addEventListener('change', (e) => {
  setMunicipalityVisibility(e.target.checked);
});

// make sure initial state matches the checkbox
if (checkbox_municipality.checked) {
  setMunicipalityVisibility(true);
} else {
  setMunicipalityVisibility(false);
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


// popup
const popup = new mapboxgl.Popup({
  className: "popup-override",
  closeButton: false,
  closeOnClick: false,
  closeOnMove: false,
  anchor: "left",
  offset: { left: [32, 32] }
});

// animation frame id
let raf_id;

// helpers
function money(v) {
  const n = Number(v);
  if (!Number.isFinite(n)) return "—";
  return "$ " + n.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function pct(v) {
  const n = Number(v);
  if (!Number.isFinite(n)) return "—";
  return n.toFixed(2) + "%";
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

  document.getElementById("detail-rent").textContent   = money(p.ConRent_mean_2020);
  document.getElementById("detail-house").textContent  = money(p.HouseValue_mean_2020);
  document.getElementById("detail-income").textContent = money(p.HHIncome_mean_2020);
  document.getElementById("detail-poverty").textContent= pct(p.Poverty_pct_2020);
  document.getElementById("detail-bach").textContent   = pct(p.Bach_pct_2020);
  document.getElementById("detail-white").textContent  = pct(p.WhiteCollar_pct_2020);

  console.log(Object.keys(f.properties || {}));

  return {geoid, idx_txt};
}




// run once when the map style is ready
window.map.on('load', () => {
  period_select(checkbox_period.checked);
});

// run on toggle
checkbox_period.addEventListener('change', (e) => {
  period_select(e.target.checked);
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

  const hover_id = "gi-hover";

  // add hover outline once
  if (!window.map.getLayer(hover_id)) {
    const hover_def = {
      id: hover_id,
      type: "line",
      source: source_base,
      filter: ["==", ["get", "GEOID"], "__none__"],
      paint: {
        "line-color": "#314A80",
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
      // keep normal arrow (not pointer)
      window.map.getCanvas().style.cursor = "default";
      if (!popup.isOpen()) popup.addTo(window.map);
    });

    window.map.on("mousemove", layer_id, (e) => {
      const f = e.features && e.features[0];
      if (!f) return;

      const geoid = String(f.properties?.GEOID ?? "");
      window.map.setFilter(hover_id, ["==", ["get", "GEOID"], geoid]);

      const { geoid: geoid_txt, idx_txt } = update_details(f);

      const small_html = `
        <div class="popup-wrapper">
          <div class="popup-title">tract ${geoid_txt}</div>
          <div class="popup-title">index ${idx_txt}</div>
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
      window.map.getCanvas().style.cursor = ""; // back to mapbox default (grab)
    });
  }

  // bind both layers so hover works no matter which is visible
  layer_ids.forEach(bind_hover);
});
