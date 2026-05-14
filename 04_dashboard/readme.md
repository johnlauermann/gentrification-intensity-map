### README
### National Gentrification Intensity Web Interactive Map

**John Lauermann's Lab Group, School of Information, Pratt Institute**  
Dashboard designed and developed by Alice Viggiani  
Last updated May 2026

The National Gentrification Intensity Map is an interactive web dashboard that visualizes the gentrification intensity index, created by John Lauermann's lab group, at the tract level across US communities. It supports exploration through two time periods (1970–2020 and 1990–2020), with filtering by index range, community selection, and address search, and provides a tract-level panel displaying the underlying index indicators.

---
### Development

**Data pipeline:** R  
**Front-end:** HTML, CSS, JavaScript  
**Map platform:** Mapbox  

### Libraries and plugins

**R:** `sf`, `dplyr`, `here`, `mapboxapi`  
**JavaScript:** Mapbox GL JS, Mapbox GL CSS, Mapbox Geocoder  

---

### Pipeline

### 1. Create tilesets in R

Tract-level gentrification scores are joined to Census tract boundaries and uploaded to Mapbox as vector tilesets using the `mapboxapi` package, which interfaces with the Mapbox Tiling Service (MTS). The project uses two tilesets, one per time period, each with a unique internal layer name.

### 2. Style the basemap in Mapbox Studio

The basemap visuals, such as background, water, and land, are configured in Mapbox Studio. The gentrification index layer boundaries and colors are primarily defined in CSS, with a fallback style set in Mapbox Studio.

### 3. Initialize the map in HTML with Mapbox GL JS

The map is initialized in HTML using Mapbox GL JS and the Mapbox Geocoder plugin, both referenced externally in the HTML file, pointing to Mapbox's servers. The address search feature is styled in CSS and powered by the Mapbox Geocoding API.

### 4. Build the UI in HTML and CSS

The dashboard layout consists of a full-screen map and three panel components: 1/ a title and info box, 2/ an interactions and filtering panel, and 3/ a data panel displaying the result of the interactions. The layout adapts to mobile viewports via CSS grid.

### 5. Map interactions and logic in JavaScript

All map behavior is handled in vanilla JavaScript:

**Panel behavior**  
Manages expand and collapse behaviors, with mobile adjustments.

**Municipality dropdown menu**  
Controls the municipalities dropdown, with opening, closing, and navigating to city coordinates on the map.

**Address search**  
Custom search bar fetching suggestions from the Mapbox Geocoding API, displaying results in the dropdown, and supporting keyboard navigation.

**Layer controls**  
Checkbox for toggling municipality boundary visibility, and a period toggle switching between the 1970–2020 and 1990–2020 tilesets.

**Hover and selection**  
Hover highlights and popup on mouse movement, and tract selection with a fixed popup. Hover and tract detail panel are restricted to desktop. Clicking the same tract again or an empty area clears the selection.

**Tract data panel**  
Populates tract GEOID, metro name, class type, and the six index indicators, with negative values colored differently.

**Legend**  
CSS gradient built from the color scale, a draggable marker tracking the selected tract's index value, and a dual-handle range filter that masks and filters the map by index range.

**Mapbox GL JS methods**  
Layer visibility, styling, hovering, and selecting are controlled through `addSource()`, `addLayer()`, `setPaintProperty()`, and `setFilter()`.

### 6. Deploy on GitHub Pages

The dashboard is hosted as a static site on GitHub Pages from the `04_dashboard/` directory of the project repository.
