
// dropdown
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
  "Los Angeles": {center: [-118.2437, 34.0522], zoom: 8.5},
  "Chicago": {center: [-87.6298, 41.8781], zoom: 9},
  "Dallas": {center: [-96.7970, 32.7767], zoom: 10},
  "Houston": {center: [-95.3698, 29.7604], zoom: 9},
  "Washington DC": {center: [-77.0369, 38.9072], zoom: 9},
  "Philadelphia": {center: [-75.1652, 39.9526], zoom: 10},
  "Atlanta": {center: [-84.3880, 33.7490], zoom: 8},
  "US": {center: [-98.5795, 39.8283], zoom: 4}
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



// checkbox municipality
// const checkbox_municipality = document.getElementById('checkbox-municipality-input');

// window.addEventListener('load', () => {
//   setTimeout(() => {
//     if (window.map) {
//       checkbox_municipality.addEventListener('change', (e) => {
//         const visibility = e.target.checked ? 'visible' : 'none';
//         window.map.setLayoutProperty(
//           'municipality-nyc-line',
//           'visibility',
//           visibility
//         );
//         console.log('Municipality outline:', visibility);
//       });
//     } else {
//       console.error('Map not found!');
//     }
//   }, 1000);
// });

// checkbox municipality new
const checkbox_municipality = document.getElementById('checkbox-municipality-input');

function setMunicipalityVisibility(visible) {
  if (!window.map) return;
  const layerId = 'municipality-nyc-line';

  if (!window.map.getLayer(layerId)) {
    console.warn('Layer not found:', layerId);
    return;
  }

  window.map.setLayoutProperty(
    layerId,
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



// checkbox index
const checkbox_index = document.getElementById('legend-index-input');

window.addEventListener('load', () => {
  setTimeout(() => {
    if (window.map) {
      checkbox_index.addEventListener('change', (e) => {
        const visibility = e.target.checked ? 'visible' : 'none';
        window.map.setLayoutProperty(
          'gi-fac-1990_2020',
          'visibility',
          visibility
        );
        console.log('Intensity layer gi-fac-1990_2020:', visibility);
      });
    } else {
      console.error('Map not found!');
    }
  }, 1000);
});


// hover popup
const popup = new mapboxgl.Popup({
  className: 'popup-override',
  closeButton: false,
  closeOnClick: false,
  closeOnMove: false,
  anchor: 'left',
  offset: {left: [32, 32]} // elements coming from mapbox needs to be customized in th js, not in the css
});

// to later limit redraws
let rafId; 

// loading popup
map.on('load', () => {
  const layer_index = 'gi-fac-1990_2020'; // to uniformize the names
  const layer_base = map.getLayer(layer_index);

  if (!layer_base) {
    console.error(`Layer ${layer_index} not found`);
    return;
  }
  
  const source_base = layer_base.source; // from mapbox: "composite"
  const source_sub_layer = layer_base['source-layer'];
  console.log(layer_base);

  // highlighting the hovered tract
  const hover_index = `${layer_index}-hover`;
  const hover_def = {
    id: hover_index,
    type: 'line',
    source: source_base,
    filter: ['==', ['get', 'GEOID'], '__none__'], // Mapbox GL JS language
    paint: {
      'line-color': '#314A80',
      'line-width': 2,
      'line-opacity': 1
    }
  };

  if (source_sub_layer) 
    hover_def['source-layer'] = source_sub_layer;
  map.addLayer(hover_def);

  // updating the filter during hover
  // using geoid as key
  map.on('mousemove', layer_index, (e) => {
    const f = e.features && e.features[0];
    if (!f) return;
    const geoid_highlight = String(f.properties.GEOID ?? '');
    map.setFilter(hover_index, ['==', ['get', 'GEOID'], geoid_highlight]);
  });

  // turning off highlight on leave
  map.on('mouseleave', layer_index, () => {
    map.setFilter(hover_index, ['==', ['get', 'GEOID'], '__none__']);
  });

  // pop-up for the hovered tract
  // creating separately from the highlight, so it keeps independently for using with future layers
  map.on('mouseenter', layer_index, () => {
    map.getCanvas().style.cursor = 'default';
    if (!popup.isOpen())
      popup.addTo(map);
  });

  map.on('mousemove', layer_index, (e) => {
    const f = e.features && e.features[0];
    if (!f) return;
    console.log(f.properties); 

    // popup content
    const cbsa  = (f.properties.CBSA_NAME || '')
      .split(',')[0]
      .replaceAll('-', '<br>');
    const geoid_popup = f.properties.GEOID || '';
    const index = Number(f.properties.FAC_1990to2020).toFixed(2);
    const bach = Number(f.properties.Bach_pct_2020).toFixed(2);
    const rent = Number(f.properties.ConRent_mean_2020)
      .toLocaleString("en-US", {minimumFractionDigits: 2, maximumFractionDigits: 2});
    const income = Number(f.properties.HHIncome_mean_2020)
      .toLocaleString("en-US", {minimumFractionDigits: 2, maximumFractionDigits: 2});
    const house_value = Number(f.properties.HouseValue_mean_2020)
      .toLocaleString("en-US", {minimumFractionDigits: 2, maximumFractionDigits: 2});
    const poverty = Number(f.properties.Poverty_pct_2020).toFixed(2);
    const white_collar = Number(f.properties.WhiteCollar_pct_2020).toFixed(2);
    const type  = (f.properties.classtype || '')
      .replace(/^./, c => c.toUpperCase());
    
    const html = `
      <div>
        <strong>${cbsa}</strong><br><br>
        <div class="line pop"></div>
        <div class="popup-content">
          <div><strong>Census tract</strong><br>${geoid_popup}</div>
          <div><strong>Gentrification intensity index</strong><br>${index}</div>
          <div class="line pop"></div>
          <div><strong>Rental contract, mean</strong><br>$${rent}</div>
          <div><strong>Household income, mean</strong><br>$${income}</div>
          <div><strong>House value, mean</strong><br>$${house_value}</div>
          <div><strong>Poverty</strong><br>${poverty}%</div>
          <div><strong>Bachelor</strong><br>${bach}%</div>
          <div><strong>White collar positions</strong><br>${white_collar}%</div>
          <div class="line pop"></div>
          <div><strong>Class</strong><br>${type}</div>
        </div>
      </div>
    `;

    // smoothing follow
    cancelAnimationFrame(rafId);
    rafId = requestAnimationFrame(() => {
      popup.setLngLat(e.lngLat).setHTML(html);
    });
  });

  map.on('mouseleave', layer_index, () => {
    // map.getCanvas().style.cursor = 'default';
    popup.remove();
  });

}

);