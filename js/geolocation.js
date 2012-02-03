$(function() {
    navigator.geolocation.getCurrentPosition(showMap);
    console.log(trail);
});


function showMap(position) {
    $("#map").gMap({
        markers = [{latitude: position.coords.latitude, longitude: position.coords.longitude, html: "U R HERE"}]
    })
}
