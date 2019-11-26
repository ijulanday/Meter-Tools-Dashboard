<head>
  <style>
     /* Set the size of the div element that contains the map */
    #map {
      height: 600px; 
      width: 100%;  
     }

    input[type=text], select {
      width: 100%;
      padding: 12px 20px;
      margin: 8px 0;
      display: inline-block;
      border: 1px solid #ccc;
      border-radius: 4px;
      box-sizing: border-box;
    }

    input[type=submit] {
      width: 100%;
      background-color: #4CAF50;
      color: white;
      padding: 14px 20px;
      margin: 8px 0;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }

    input[type=submit]:hover {
      background-color: #45a049;
    }

    input[type=checkbox] {
      padding: 6px 12px;
      margin: 10px 0;
    }

    .report-upload {
      background-color: #f2f2f2;
      padding: 20px;
      border-radius: 5px;
      width: 45%;
      float: left;
      margin-top: 2em;
    }

    .map-filter {
      width: 45%;
      float: right;
      margin-top: 2em;
      background-color: #f2f2f2;
      border-radius: 5px;
      padding: 20px;
    }

  </style>

  <!--- bootstrap stylesheet n friends --->
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
  <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
  <script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
  <link rel="stylesheet" type="text/css" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">

</head>

<!--- header thing above nav bar similar across pages --->
<div class="px-2 text-center">
  <h1>Cool, Untitled L+G Metering Dashboard</h1>
  <p>For reading terrible customer meter reports, among other things
  </p>
  <hr/>
</div>

<!--- nav bar --->
<nav class="navbar navbar-expand-sm bg-light navbar-light">
  <ul class="navbar-nav">
    <li class="nav-item">
      <a class="nav-link" href="main.cfm">Home</a>
    </li>
    <li class="nav-item active">
      <a class="nav-link" href="#">Map</a>
    </li>
    <li class="nav-item">
      <a class="nav-link" href="helpmain.cfm">Help</a>
    </li>
  </ul>
</nav>

<!--- to only show the general search bar thing if a file's loaded --->
<cfset variables.show_meter_search = false>

<!--- cfscript to start file I/O and stuff --->
<cfscript>
  spreadsheet = New spreadsheetLibrary.Spreadsheet();
  oldFile = "";
  newFile = "";
  usedFile = "";
  fce = [];
  keys = [];
  mapCenterCoordinates = [];

  try {
    if (structKeyExists(form, "latitudeInput") and len(form.latitudeInput) and len(form.longitudeInput)) {
      // write user-specified coordinates to file
      fileWrite(expandPath("./mapCenterCoordinates.txt"), 
        #form.latitudeInput# & "," & #form.longitudeInput#
      );
      mapCenterCoordinates = [#form.latitudeInput#, #form.longitudeInput#];
      writeDump(mapCenterCoordinates);
    }
    else {
      // read in map center coordinate file
      fileContent = fileRead(expandPath("./mapCenterCoordinates.txt"), "utf-8");
      replace(fileContent, " ", "", "ALL")
      mapCenterCoordinates = fileContent.split(",");
    }
  } catch (any e) {
    writeDump(e);
  }

  try {

    // get all local files
    arrayOfLocalFiles = directoryList( expandPath( "./" ), false, "name", "", "DateLastModified DESC" );
    for (file in arrayOfLocalFiles) {
      if (file.contains(".xlsx")) {
        oldFile = file;
      }
    }

    // branch taken if form has been submitted with file data
    if (structKeyExists(form, "fileData") and len(form.fileData) ){ 
      //delete old .xlsx file, if there is one
      if (len(oldFile)) {
        fileDelete(expandPath("./") & "\" & oldFile);  
        // writeDump("old file: " & oldFile);
      }

      //find full path to new .xlsx file
      uploadfile = fileupload("C:\lucee\tomcat\webapps\ROOT\Meter-Report-CFML","form.fileData"," ","overwrite");
      arrayOfLocalFiles = directoryList( expandPath( "./" ), false, "name", "", "DateLastModified DESC" );
      for (file in arrayOfLocalFiles) {
        if (file.contains(".xlsx")) {
          newFile = file;
          usedFile = file;
          filepath = expandPath(newFile);
        // writeDump(newFile);
        }
      }
    } 
    
    // branch taken if there's an old file that's been uploaded
    else if (len(oldFile)) {
      filepath = expandPath(oldFile);
      usedFile = oldFile;
      variables.show_meter_search = true;
    }

    // branch for when there's no file loaded on the server; do not display the search bar
    else {
      variables.show_meter_search = false;
    }

    // find the header row value for the spreadsheet column titles
    tq = spreadsheet.read(src=filepath, format="csv", rows="1-10");
    tq = tq.split("\n");
    marray = [];
    headerRow = 1;
    leaveLoop = false;
    for (array in tq) {
      marray = array.split(",");
      for (badstring in marray) {
        string = replace(badstring, """", "", "ALL")
        if (lCase(string) == "meter badge" || lCase(string) ==  "meter no" || lCase(string) == "meter number") {
          leaveLoop = true;
          keys = marray;
        }
      }
      if (leaveLoop) {
        break;
      } else {
        headerRow += 1;
      } 
    }
    
    // read in the whole spreadsheet object for JS use later
    fullSheetObj = spreadsheet.read(
      src=filepath
      ,format="query"
      ,headerRow=#headerRow#
    );

  } catch (any e) {
    // general exception handler, generally not useful for debugging but makes sure that
    //  the report object gets generated as an empty array so to not break things later.
    fullSheetObj = [];
  }

</cfscript>

<!--- map title thing ---> 
<div style="margin: 1em">
  <h3>Flexible Meter Report Map</h3>
  <!--- if there's a file that's been loaded, display the filename --->
  <cfif len(usedFile)>
    <cfoutput>
      <p>Currently viewing: #usedFile#</p>
    </cfoutput>
  </cfif>
</div>

<!-- The div element for the map -->
<div id="map"></div>

<!--- google maps js stuff wrapped in cfoutput to use cf variables --->
<cfoutput>
<script type="text/javascript" language="JavaScript"> 
  /*
  * 
  * The two vars below are grabbing the CF stuff and putting them in JS objects
  *   that can be accessed by the name in quotes. The ## symbols de-reference the
  *   CF objects, and the ToScript function outputs the cf object as a JS object.
  *   Not sure what the false param does but oh well. 
  */
  var #ToScript(fullSheetObj, "fullSheetObj", false)#;
  var #ToScript(keys, "keys", false)#;
  var #ToScript(mapCenterCoordinates, "mapCenterCoordinates", false)#;

  // get rid of terrible characters from the object keys
  for (i = 0; i < keys.length; i++) {
    keys[i] = keys[i].replace(/['"|\r]+/g, '');
  }

  // declare marker and map vars so that they're accessible by other functions here
  var markers = Array();
  var map;

  // The location of mapCenter
  var mapCenter = {
    lat: parseFloat(mapCenterCoordinates[0])
    , lng: parseFloat(mapCenterCoordinates[1])
  };

  // useful later
  var filter;

  /**
   * Initialize google map here! 
   */
  function initMap() {
    // The map, centered at mapCenter
    map = new google.maps.Map(
        document.getElementById('map'), {zoom: 9, center: mapCenter});

    // loop through each entry in the spreadsheet
    for ( i = 0; i < fullSheetObj.length; i++) {
      
      // find the keys associated with lat/lon. NOTE: this assumes that the lat & lon
      //  columns are in order (as stated here), right next to each other, and that all
      //  lat/lon data is within 5 degrees of the center defined above.
      //  IF NOT, THERE WILL PROBABLY BE REALLY WEIRD & BAD BEHAVIOR.
      var latKey;
      var lonKey;
      for (j in keys) {
        if (parseFloat(fullSheetObj[i][keys[j]]) > mapCenter.lat - 5 && parseFloat(fullSheetObj[i][keys[j]]) < mapCenter.lat + 5 && latKey == null) {
          latKey = keys[j];
        } 
        
        else if (parseFloat(fullSheetObj[i][keys[j]]) > mapCenter.lng - 5 && parseFloat(fullSheetObj[i][keys[j]]) < mapCenter.lng + 5) {
          lonKey = keys[j]
        }
      }

      // branch taken if above script was successful
      if (fullSheetObj[i][latKey] && fullSheetObj[i][lonKey]) {
        var mlat = parseFloat(fullSheetObj[i][latKey]);
        var mlon = parseFloat(fullSheetObj[i][lonKey]);
        var meterLocation = {lat: mlat, lng: mlon};

        // create a new marker and info window, format the content for the info window
        var marker = new google.maps.Marker({position: meterLocation, map: map});
        
        var infoWindow = new google.maps.InfoWindow();
        var contentStr = '';
        for (j in keys) {
          if (fullSheetObj[i][keys[j]]) {
            contentStr += '<h5>' + keys[j] + ': ' + fullSheetObj[i][keys[j]] + '</h5>'
          }
        }

        marker.html = contentStr;

        google.maps.event.addListener(marker, 'click', function() {
                infoWindow.setContent(this.html);
                infoWindow.open(map, this);
        }); 

        // store the spreadsheet row, marker, & info window in the markers array for use later
        markers.push({
          meterInfo: fullSheetObj[i]
          , mapMarker: marker
          , infoWindo: infoWindow
        });
      }
    }

    setUpFilterButton(1);
    
    console.log('initMap() finished');
  }

  // invoked by the general search bar
  function panToMarker() {
    var searchVal = document.getElementById('meternoSearch').value;

    for (i in markers) {
      meterInfo = markers[i].meterInfo;
      // console.log("marker meterno: " + marker.meterno);
      for (j in keys) {
        if (searchVal == meterInfo[keys[j]] && !searchVal.includes(",")) {
          map.panTo(markers[i].mapMarker.getPosition());
          map.setZoom(16);
        } 

        else if (searchVal.includes(",")) {
          var latLon = searchVal.replace(" ", "");
          var latLon = latLon.split(",");
          if (latLon.length == 2 
            && Math.abs(parseFloat(latLon[0]) - mapCenter.lat) < 5
            && Math.abs(parseFloat(latLon[1]) - mapCenter.lng) < 5) {
              map.panTo(new google.maps.LatLng(parseFloat(latLon[0]), parseFloat(latLon[1])));
              map.setZoom(16);
          } 
          return;
        }
      }
      
    }
  }
  
  // set up filters based on report header columns
  function setUpFilterButton(filterno) {
    document.getElementById("filter-dropdown-menu" + filterno).innerHTML = "";
    for (i in keys) {
      if ([keys[i]]) {
        document.getElementById("filter-dropdown-menu" + filterno).innerHTML += 
          "<a class=\"dropdown-item\" onclick=\"updateFilter(\'" + keys[i] + "\'," + filterno +")\">" + keys[i] + "</a>";
      }
    }
  }

  /**
   * invoked when a filter is selected. 
   * changes the text on the filter button to be the filter the user selected.
   */ 
  function updateFilter(arg, filterno) {
    document.getElementById("dropdownMenuButton" + filterno).innerHTML = arg;
  }

  /**
   * invoked by changing the text in the filter section. 
   * updates every time the text input changes or the user hits 'enter'.
   * all filters are cleared if the text input field is cleared.
   */
  function applyFilters() {
    var categories = [];
    var vals = []
    var numFilters = parseInt(document.getElementById("add-link").name);
    console.log('numfilters: ' + numFilters);
    for (i = 1; i <= numFilters; i++) {
      categories.push(document.getElementById("dropdownMenuButton" + i).innerHTML);
      var val = document.getElementById("filterInput" + i).value;
      vals.push(val.split(","));
    }

    for (i in vals) {
      for (j in vals[i]) {
        if (vals[i][j] == "" && i == vals.length - 1) {
          for (i in markers) {
            markers[i].mapMarker.setVisible(true);
          }
          return;
        }
      }
    }

    for (i in markers) {
      var matches = 0;

      for (j in categories) {
        var cont = false;
        if (vals[j].length == 1 && vals[j][0] == "") {
          matches++;
          continue;
        }

        for (k in vals[j]) {
          if (markers[i].meterInfo[categories[j]].toString().toLowerCase() == vals[j][k].toString().toLowerCase()) {
            matches++;
            cont = true;
            break;
          }
        }

        if (cont) {
          continue;
        } 
      }

      markers[i].mapMarker.setVisible(matches == numFilters);
    }
  }

  function addFilter() {
    var filterno = parseInt(document.getElementById('add-link').name) + 1;
    document.getElementById('add-link').name = filterno.toString();
    document.getElementById('remove-link').style.visibility = "visible";
    var filter = document.getElementById('filter-container1');
    var newFilter = filter.cloneNode(true);
    newFilter.id = "filter-container" + filterno;
    newFilter.childNodes[3].childNodes[1].id = "filterInput" + filterno;
    newFilter.childNodes[1].childNodes[1].id = "dropdownMenuButton" + filterno;
    newFilter.childNodes[1].childNodes[3].id = "filter-dropdown-menu" + filterno;
    newFilter.childNodes[3].childNodes[1].onkeydown = function() {applyFilters()};
    newFilter.childNodes[3].childNodes[1].oncut = function() {applyFilters()};
    newFilter.childNodes[3].childNodes[1].onpaste = function() {applyFilters()};
    document.getElementById('multi-filter-container').appendChild(newFilter);
    setUpFilterButton(filterno);
    
  }

  function removeFilter() {
    var filterno = parseInt(document.getElementById('add-link').name) - 1;
    document.getElementById('add-link').name = filterno.toString();
    console.log(filterno);
    var filter = document.getElementById('filter-container' + (filterno + 1));
    document.getElementById('multi-filter-container').removeChild(filter);
    if (filterno == 1) {
      document.getElementById('remove-link').style.visibility = "hidden";
      return;
    }
  }
</script>
</cfoutput>

<cfif 
(IsDefined("Form.submit"))
or (variables.show_meter_search)
>
  <div class="px-2 text-center" style="margin-top: 2em">
    <h3>General Search</h3>
    <cfform name="meterSearch" method="post" onkeydown="return event.key != 'Enter';">
      <input type="Text" name="meternoSearch" id="meternoSearch"
      onkeydown="panToMarker()"
      oncut="panToMarker()"
      onpaste="panToMarker()"
      >
    </cfform> 
  </div>
</cfif>

<div style="margin: 2em; display: block;">
  <!--- html for report upload section --->
  <div class="report-upload" style="margin-top: 2em">
    <h3>Report Upload</h3>
    <cfform name="reportUpload" method="post" enctype="multipart/form-data"> 

      <cfinput type="file" name="fileData" id="fileData">
      <cfinput type="submit" name="submit" value="Process Report">

      <!--- TODO: make this link actually link to a help page --->   
      <a href="maphelp.cfm">Trouble with your files?</a>
    </cfform> 
    
  </div>
    
  <!--- html for filter section area thing --->
  <div class="map-filter" id="filter-div">
    <h3>Filter</h3>
    <div id="multi-filter-container">
      <div id="filter-container1">
        <div class="dropdown">
          <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton1" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
            Filter Options
          </button>
          <div class="dropdown-menu" id="filter-dropdown-menu1" aria-labelledby="dropdownMenuButton1">
          </div>
        </div>
        <form name="filterForm" method="post" onkeydown="return event.key != 'Enter';">
          <input type="Text" name="filterInput1" id="filterInput1"
          onkeydown="applyFilters()"
          oncut="applyFilters()"
          onpaste="applyFilters()"
          >
        </form> 
      </div>
    </div>
    <p style="display: inline-block">
      <a href="#" name="1" id="add-link" onclick="addFilter()">Add another filter</a><br/>
      <a href="#" id="remove-link" onclick="removeFilter()" style="visibility: hidden">Remove a filter</a>
    </p>
    
  </div>
</div>

<!--- for changing location --->
<div style="margin: 2em; display: inline-block;">
  <h3>Change Map Center</h3>
  <cfform name="mapCenterForm" method="post" enctype="multipart/form-data">
    <label for="latitudeInput">Latitude: </label>
    <cfinput type = "Text" name = "latitudeInput"
    message = "Please enter a float value (i.e 32.2226, -110.9747)"
    validate = "regex" pattern = "[0-9|.|-]$" required = "yes">
    
    <label for="longitudeInput">Longitude: </label>
    <cfinput type = "Text" name = "longitudeInput"
    message = "Please enter a float value (i.e 32.2226, -110.9747)"
    validate = "regex" pattern = "[0-9|.|-]$" required = "yes">

    <cfinput type="submit" name="submit" value="Change map center!">
  </cfform>
</div>

<!--Load the API from the specified URL
* The async attribute allows the browser to render the page while the API loads
* The key parameter will contain your own API key (which is not needed for this tutorial)
* The callback parameter executes the initMap() function
-->
<script async defer
src="https://maps.googleapis.com/maps/api/js?key=API_KEY_GOES_HERE&callback=initMap">
</script>

