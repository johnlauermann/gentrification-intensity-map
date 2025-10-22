
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
          'large_metros_intensity',
          'visibility',
          visibility
        );
        console.log('Intensity layer:', visibility);
      });
    } else {
      console.error('Map not found!');
    }
  }, 1000);
});
