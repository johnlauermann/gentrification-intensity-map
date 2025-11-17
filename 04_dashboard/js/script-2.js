
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


// checkbox municipality
const checkbox_municipality = document.getElementById('checkbox-municipality-input');

window.addEventListener('load', () => {
  setTimeout(() => {
    if (window.map) {
      checkbox_municipality.addEventListener('change', (e) => {
        const visibility = e.target.checked ? 'visible' : 'none';
        window.map.setLayoutProperty(
          'municipality-nyc-line',
          'visibility',
          visibility
        );
        console.log('Municipality outline:', visibility);
      });
    } else {
      console.error('Map not found!');
    }
  }, 1000);
});


// checkbox index
const checkbox_index = document.getElementById('legend-index-input');

window.addEventListener('load', () => {
  setTimeout(() => {
    if (window.map) {
      checkbox_index.addEventListener('change', (e) => {
        const visibility = e.target.checked ? 'visible' : 'none';
        window.map.setLayoutProperty(
          // 'large_metros_intensity', // old alice
          'gi-fac-2020',
          'visibility',
          visibility
        );
        console.log('Intensity layer gi-fac-2020:', visibility);
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
  // const layer_index = 'large_metros_intensity'; // to uniformize the names // alice old
  const layer_index = 'gi-fac-2020'; 
  const layer_base = map.getLayer(layer_index);

  if (!layer_base) {
    console.error(`Layer ${layer_index} not found`);
    return;
  }
  
  const source_base = layer_base.source; // from mapbox: "composite"
  const source_sub_layer = layer_base['source-layer'];  // from mapbox: "largemetros_layer_6-5dhbcd"
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
    const index = f.properties.FAC_2020;
    const type  = (f.properties.classtype || '')
      .replace(/^./, c => c.toUpperCase());
    const geoid_popup = f.properties.GEOID || '';
    const html = `
      <div>
        <strong>${cbsa}</strong><br><br>
        <div class="line pop"></div>
        <div class="popup-content">
          <div><strong>Census tract</strong><br>${geoid_popup}</div>
          <div><strong>Gentrification intensity index</strong><br>${index}</div>
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