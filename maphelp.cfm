<head>

    <!--- bootstrap stylesheet n friends --->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
    <link rel="stylesheet" type="text/css" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">
    <style>
        .center-fit {
            display: block;
            width: 75%;
            margin-left: auto;
            margin-right: auto;
            margin-top: 25px;
            margin-bottom: 25px;
            border: 1px solid rgb(99, 99, 99)31, 15, 15);
            border-radius: 4px;
        }

        .center {
            background-color: #fff; 
            border: none;
            border-radius: 8px;
            padding: 10px 30px;
        }

        .parallax {
            /* The image used */
            background-image: url("image-resources/map-screen-example.png");
            background-color: rgba(255,255,255,0.6);
            background-blend-mode: lighten;
            /* Set a specific height */
            height: 500px;

            /* Create the parallax scrolling effect */
            background-attachment: fixed;
            background-position: center;
            background-repeat: no-repeat;
            background-size: cover;
        }

    </style>
</head>

<div class="px-2 text-center">
    <h1>Cool, Untitled L+G Metering Dashboard</h1>
    <p>For reading terrible customer meter reports, among other things
    </p>
    <hr/>
</div>

<nav class="navbar navbar-expand-sm bg-light navbar-light">
    <ul class="navbar-nav">
      <li class="nav-item">
        <a class="nav-link" href="main.cfm">Home</a>
      </li>
      <li class="nav-item">
        <a class="nav-link" href="map.cfm">Map</a>
      </li>
      <li class="nav-item active">
        <a class="nav-link" href="helpmain.cfm">Help</a>
      </li>
    </ul>
</nav>

<div class="parallax" style="padding: 1em; margin: 1em;">
    <div class="center">
        <h1>Using map.cfm</h1>
    </div>
    <img class="center-fit" src="image-resources/example-spreadsheets.png" alt="The map page">
    <div class="center">
        <p>
            <strong>map.cfm</strong> parses meter reports by finding the header column and generating a list of keys from it.
            Specifically, it will look for "meter no," "meter badge," or some other value for the L+G meter number column.
            There are also a few assumptions that the parser makes when generating the list of column headers: <br/>
            
            <div class="center">
            <strong>1. </strong> the Latitude and Longitude columns are next to eachother <strong>and in that order.</strong><br/>
            <strong>2. </strong> the coordinates for the <strong>map center</strong> are defined. To clarify, the parser will 
            check to see if the lat/lon coordinates for each meter are within <strong>5 degrees</strong> of the center.<br/>
            <strong>3. </strong> there are <strong>no hidden or blank rows</strong> between row 1 and the header row. This is 
            due to a limitation of the Lucee spreadsheet parser library.<br/>
            <strong>4. </strong> the sheet containing all of the meter information (with latitude and longitude) must be 
            <strong>the first sheet in the workbook.</strong>
            </div>

            <img class="center-fit" src="image-resources/spreadsheet-pitfalls2.png" alt="be careful!">

        </p>
    </div> 
    <div class="center">
        <p>
            Here's a breakdown of the basic workflow of using the map tool:<br/><br/>
            First, specify the <strong>map center</strong> at the bottom of the page (like in the image above) to the city or region where the meters
            are centered around. Once you do this, <strong>map.cfm</strong> writes these coordinates to a file on the Lucee server
            so that you don't have to keep entering in the coordinates.<br/><br>
            
            Once the <strong>map center</strong> has been defined you can upload a report which should populate the map with clickable 
            markers for each meter. The general search form is good for searching by meter number, but it works by looking for a matching
            string in <strong>any</strong> of the meters information field, so it can search by other unique meter values.<br/><br/>

            Finally, filters can be added or removed and will find any meter that matches the specified field. Currently, there is not support
            for filter ranges--only exact values. However you can seperate values by comma to allow for multiple values for specific fields.

        </p>
    </div> 
    <img class="center-fit" style="width: 40%" src="image-resources/filter-form-example.png" alt="filter form example">
</div>
