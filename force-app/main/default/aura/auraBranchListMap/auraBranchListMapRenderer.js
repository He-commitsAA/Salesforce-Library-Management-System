({
    rerender: function (component) {
        var nodes = this.superRerender();

        // If the Leaflet library is not yet loaded, we can't draw the map: return
        if (!window.L) {
            return nodes;
        }

        // Draw the map if it hasn't been drawn yet
        if (!component.map) {
            var mapElement = component.find('map').getElement();

            component.map = window.L.map(mapElement, {
                zoomControl: true,
                tap: false
            }).setView([38.907, -77.036], 13);
            component.map.scrollWheelZoom.disable();
            var url =
                'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}';

            window.L.tileLayer(url).addTo(component.map);
        }

        var branches = component.get('v.branches');

        if (!branches) {
            return nodes;
        }
        var markers = [];

        branches.forEach(function (branch) {
            var latLng = [
                branch.Location__Latitude__s,
                branch.Location__Longitude__s
            ];
            var myIcon = window.L.divIcon({
                className: 'my-div-icon',
                html:
                    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 52 52"><path fill="#DB4437" d="m26 2c-10.5 0-19 8.5-19 19.1 0 13.2 13.6 25.3 17.8 28.5 0.7 0.6 1.7 0.6 2.5 0 4.2-3.3 17.7-15.3 17.7-28.5 0-10.6-8.5-19.1-19-19.1z m0 27c-4.4 0-8-3.6-8-8s3.6-8 8-8 8 3.6 8 8-3.6 8-8 8z"></path></svg>'
            });
            var marker = window.L.marker(latLng, { icon: myIcon });

            marker.branchId = branch.Id;
            var callback = $A.getCallback(function (event) {
                var mc = component.find('branchSelectedMessageChannel');
                mc.publish({ branchId: event.target.branchId });
            });

            marker.on('click', callback);
            markers.push(marker);
        });

        component.layerGroup = window.L.layerGroup(markers);
        component.layerGroup.addTo(component.map);

        return nodes;
    }
});
