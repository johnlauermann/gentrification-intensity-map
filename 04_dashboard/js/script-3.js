// responsiveness 
const is_touch = navigator.maxTouchPoints > 0

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

// cities zoom
const cities_centers = {
  "New York City": { center: [-74.0000, 40.7300], zoom: 10 },
  "Los Angeles": { center: [-118.2437, 34.0522], zoom: 10 },
  "Chicago": { center: [-87.6298, 41.8781], zoom: 10 },
  "Dallas": { center: [-96.7970, 32.7767], zoom: 10 },
  "Houston": { center: [-95.3698, 29.7604], zoom: 10 },
  "Washington DC": { center: [-77.0369, 38.9072], zoom: 10 },
  "Philadelphia": { center: [-75.1652, 39.9526], zoom: 10 },
  "Atlanta": { center: [-84.3880, 33.7490], zoom: 10 },
  "US": { center: [-98.5795, 39.8283], zoom: 5 }
};

// when clicking on a city name
menu.querySelectorAll('.dropdown-link').forEach(link => {
  link.addEventListener('click', (e) => {
    e.preventDefault();
    e.stopPropagation();

    const city = link.textContent.trim();
    const view = cities_centers[city];
    if (!view || !window.map) return;

    // centering municipalities
    window.map.easeTo({ center: view.center, zoom: view.zoom, duration: 400, padding: { left: 516 } }); // 516 > boxes width
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
const layer_1970 = 'gi-fac-1970_2020';
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
  offset: { left: [32, 32] }
});

// selected popup
const popup_selected = new mapboxgl.Popup({
  className: "popup-selected",
  closeButton: false,
  closeOnClick: false,
  closeOnMove: false,
  anchor: "left",
  offset: { left: [26, 26] }
});

let raf_id; // animation frame id
let selected_geoid = null; // initial state for selected tract

// hover and selected tracts
// const hover_id = "gi-hover";
// const selected_id = "gi-selected";

// helpers
function money(v) {
  const n = Number(v);
  if (!Number.isFinite(n)) return "\u00A0";
  return "$ " + n.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function pct(v) {
  const n = Number(v);
  if (!Number.isFinite(n)) return "\u00A0";
  return n.toFixed(2) + "%";
}

function reset_details_ui() {
  document.getElementById("box-3").classList.remove("has-data");
  document.getElementById("detail-tract").innerHTML = "<span><br></span>";
  document.getElementById("detail-metro").innerHTML = "<span><br><br></span>";
  document.getElementById("detail-class").innerHTML = "<span><br></span>";
  document.getElementById("detail-rent").innerHTML = "<span><br></span>";
  document.getElementById("detail-house").innerHTML = "<span><br></span>";
  document.getElementById("detail-income").innerHTML = "<span><br></span>";
  document.getElementById("detail-poverty").innerHTML = "<span><br></span>";
  document.getElementById("detail-bach").innerHTML = "<span><br></span>";
  document.getElementById("detail-white").innerHTML = "<span><br></span>";
}

function set_details_from_feature(f) {
  const {idx_num} = update_details(f);
  set_legend_marker(idx_num);
}

function set_selected_feature(f, lngLat) {
  const geoid = Number(f?.properties?.GEOID ?? f?.properties?.GEOID10);

  // clicking the already-selected tract toggles selection off
  if (selected_geoid && geoid === selected_geoid) {
    clear_selected();
    return;
  }

  selected_geoid = geoid;

  // selected outline
  ["gi-selected-1990", "gi-selected-1970"].forEach(id => {
    if (window.map.getLayer(id)) window.map.setFilter(id, ["==", ["get", "GEOID"], selected_geoid]);
  });


  // freeze box 3 + legend marker to selected
  const {idx_txt, idx_num} = update_details(f);
  set_legend_marker(idx_num);

  // fixed popup shows selected tract info
  const p = f.properties || {};
  const geoid_txt = String(p.GEOID ?? p.GEOID10 ?? " ");
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

  ["gi-selected-1990", "gi-selected-1970"].forEach(id => {
    if (window.map.getLayer(id)) window.map.setFilter(id, ["==", ["get", "GEOID"], "__none__"]);
  });
  popup_selected.remove();
  hide_legend_marker();

  // reset box 3 back to empty state
  reset_details_ui();
}

// switch periods
function get_active_period() {
  return document.getElementById('checkbox-period-input').checked ? '1970to2020' : '1990to2020';
}

// update box 3 indicators
function update_details(f) {
  const p = f.properties || {};
  const period = get_active_period();
  const geoid = String(p.GEOID ?? p.GEOID10 ?? " ");
  const cbsa = String(p.CBSA_NAME ?? "").split(",")[0] || " ";
  const type = String(p.classtype ?? " ").replace(/^./, c => c.toUpperCase());
  const idx = Number(p[`GentIntensity_${period}_sdfrommean`]);
  const idx_txt = Number.isFinite(idx) ? idx.toFixed(2) : " ";

  document.getElementById("box-3").classList.add("has-data");
  document.getElementById("detail-tract").textContent = geoid;
  document.getElementById("detail-metro").textContent = cbsa;
  document.getElementById("detail-class").textContent = type;
  document.getElementById("detail-rent").textContent = money(p[`ConRent_mean_chg_${period}`]);
  document.getElementById("detail-house").textContent = money(p[`HouseValue_mean_chg_${period}`]);
  document.getElementById("detail-income").textContent = money(p[`HHIncome_mean_chg_${period}`]);
  document.getElementById("detail-poverty").textContent = pct(p[`Poverty_pct_chg_${period}`]);
  document.getElementById("detail-bach").textContent = pct(p[`Bach_pct_chg_${period}`]);
  document.getElementById("detail-white").textContent = pct(p[`WhiteCollar_pct_chg_${period}`]);

  return { geoid, idx_txt, idx_num: idx };
}

// run once when the map style is ready
window.map.on('load', () => {
  period_select(checkbox_period.checked);
});

// run on toggle
checkbox_period.addEventListener('change', (e) => {
  clear_selected();
  period_select(e.target.checked);
});

// legend marker
const legend_wrap = document.getElementById("legend_wrap");
const legend_marker = document.getElementById("legend_marker");
const legend_marker_value = document.getElementById("legend_marker_value");
const legend_gradient = document.querySelector(".legend-gradient");

// legend scale range
const legend_min = -3; // actual is -4.348218
const legend_max = 5; // actual is 7.16

const scale_colors = [
  [-4, "#f197d0"],
  [-3, "#f197d0"],
  [-2, "#E2BFF3"],
  [-1, "#CCBFF3"],
  [0, "#BFCFF3"],
  [1, "#3381F0"],
  [2, "#3267A9"],
  [3, "#314A80"],
  [7, "#314A80"]
];

// mapbox expression to linear color scale
// controling the colors from mapbox here
const mapbox_expression = [
  "interpolate", ["linear"],
  ["get", "GentIntensity_1990to2020_sdfrommean"],
  ...scale_colors.flat()
];

// css gradient
// it's in js, so it can be controled along with the layer color
const legend_total = legend_max - legend_min;
const gradient_stops = scale_colors.map(([val, color]) => {
  const legend_pct = ((val - legend_min) / legend_total * 100).toFixed(2);
  return `${color} ${legend_pct}%`;
}).join(", ");

document.querySelector(".legend-gradient").style.background =
  `linear-gradient(to right, ${gradient_stops})`;


function set_legend_marker(idx_num) {
  const n = Number(idx_num);
  if (!Number.isFinite(n)) return;

  const ticks = document.querySelectorAll(".legend-ticks");
  const wrap_left = legend_wrap.getBoundingClientRect().left;
  const first = ticks[0].getBoundingClientRect();
  const last = ticks[ticks.length - 1].getBoundingClientRect();
  const first_center = first.left + first.width / 2 - wrap_left;
  const last_center = last.left + last.width / 2 - wrap_left;
  const run_width = last_center - first_center;

  const n_clamped = Math.max(-3, Math.min(5, n));
  const t = (n_clamped - (-3)) / (5 - (-3));

  legend_marker.style.left = `${first_center + t * run_width}px`;
  legend_marker_value.textContent = n.toFixed(2);
  legend_marker.style.display = "block";
}

function hide_legend_marker() {
  if (!legend_marker) return;
  legend_marker.style.display = "none";
}

// load
window.map.on("load", () => {
  const layer_ids = ["gi-fac-1990_2020", "gi-fac-1970_2020"];

  if (!window.map.getLayer("gi-fac-1990_2020")) {
    console.error("base layer not found");
    return;
  }

  // hover outline for each data source
  function add_outline_layer(id, source, source_layer, paint) {
    if (!window.map.getLayer(id)) {
      window.map.addLayer({
        id,
        type: "line",
        source,
        "source-layer": source_layer,
        filter: ["==", ["get", "GEOID"], "__none__"],
        paint
      });
    }
  }
  const source_1990 = window.map.getLayer("gi-fac-1990_2020").source;
  const source_1970 = window.map.getLayer("gi-fac-1970_2020").source;
add_outline_layer("gi-hover-1990", source_1990, "layer1", { "line-color": "#007BFF", "line-width": 2, "line-opacity": 1 });
add_outline_layer("gi-hover-1970", source_1970, "gentintensity_1970to2020", { "line-color": "#007BFF", "line-width": 2, "line-opacity": 1 });
add_outline_layer("gi-selected-1990", source_1990, "layer1", { "line-color": "white", "line-width": 2, "line-opacity": 1 });
add_outline_layer("gi-selected-1970", source_1970, "gentintensity_1970to2020", { "line-color": "white", "line-width": 2, "line-opacity": 1 });

  // // hovered tract
  // if (!window.map.getLayer(hover_id)) {
  //   const hover_def = {
  //     id: hover_id,
  //     type: "line",
  //     source: source_base,
  //     filter: ["==", ["get", "GEOID"], "__none__"],
  //     paint: {
  //       "line-color": "#007BFF",
  //       "line-width": 2,
  //       "line-opacity": 1
  //     }
  //   };
  //   if (!window.map.getLayer(hover_id)) {
  //     window.map.addLayer({
  //       id: hover_id,
  //       type: "line",
  //       source: source_base,
  //       "source-layer": "layer1",
  //       filter: ["==", ["get", "GEOID"], "__none__"],
  //       paint: {
  //         "line-color": "#007BFF",
  //         "line-width": 2,
  //         "line-opacity": 1
  //       }
  //     });
  //   }
  // }

  // // selected tract outline
  // if (!window.map.getLayer(selected_id)) {
  //   window.map.addLayer({
  //     id: selected_id,
  //     type: "line",
  //     source: source_base,
  //     "source-layer": "layer1", // temp
  //     filter: ["==", ["get", "GEOID"], "__none__"],
  //     paint: { "line-color": "white", "line-width": 2, "line-opacity": 1 }
  //   });
  // }

  function bind_hover(layer_id) {
    if (!window.map.getLayer(layer_id)) {
      console.warn("missing layer:", layer_id);
      return;
    }

    // desktop only
    if (!is_touch) {
      // mouse enter
      window.map.on("mouseenter", layer_id, () => {
        window.map.getCanvas().style.cursor = "crosshair";
        if (!popup.isOpen()) popup.addTo(window.map);
      });

      // mouse move
      window.map.on("mousemove", layer_id, (e) => {
        const f = e.features && e.features[0];
        if (!f) return;

        // hover outline always updates
        const geoid = Number(f?.properties?.GEOID ?? f?.properties?.GEOID10); //GEOID>1990, GEOID10>1970
        ["gi-hover-1990", "gi-hover-1970"].forEach(id => {
          if (window.map.getLayer(id)) window.map.setFilter(id, ["==", ["get", "GEOID"], geoid]);
        });

        // box 3 follows hover ONLY if nothing is selected
        if (!selected_geoid) {
          set_details_from_feature(f);
        }

        // hover popup always follow cursor
        const p = f.properties || {};
        const geoid_txt = String(p.GEOID ?? p.GEOID10 ?? " ");
        const period = get_active_period();
        const idx = Number(p[`GentIntensity_${period}_sdfrommean`]);
        const idx_txt = Number.isFinite(idx) ? idx.toFixed(2) : " ";
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

      // mouse leave
      window.map.on("mouseleave", layer_id, () => {
        ["gi-hover-1990", "gi-hover-1970"].forEach(id => {
          if (window.map.getLayer(id)) window.map.setFilter(id, ["==", ["get", "GEOID"], "__none__"]);
        });
        popup.remove();
        window.map.getCanvas().style.cursor = "";

        // if nothing is selected, leaving should hide marker + reset details
        if (!selected_geoid) {
          hide_legend_marker();
          reset_details_ui();
        }
      });
    }
  }

  layer_ids.forEach(bind_hover);

  // one click handler for selection (toggle same tract off; empty space clears)
  window.map.on("click", (e) => {
    const features = window.map.queryRenderedFeatures(e.point, {
      layers: ["gi-fac-1990_2020", "gi-fac-1970_2020"]
    });

    console.log("clicked features:", features.length, features.map(f => f.layer.id));

    const f = features && features[0];
    if (f) {
      set_selected_feature(f, e.lngLat);
    } else {
      clear_selected();
    }
  });
});

// temp logs to check for bugs

