<head>

    <!--- bootstrap stylesheet n friends --->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
    <link rel="stylesheet" type="text/css" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">

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
        <a class="nav-link" href="#">Help</a>
      </li>
    </ul>
</nav>

<div class="px-2" style="padding: 1em; margin: 1em;">
    <h1><br/>This is the help section<br/></h1>
    <p>You can find info on how the pages here work in their relevant sections.</p>
    <h2 style="margin-top: 2em; margin-bottom: 1em;">Map</h2>
    <p>
        <strong>map.cfm</strong> uses the JavaScript Google Maps API and the 
        <a href="https://github.com/cfsimplicity/lucee-spreadsheet">cfsimplicity spreadsheet library for Lucee</a> to
        parse self-hosted customer meter reports and display them on a map. <br/><br/>
        To learn more about how the page works, click <a href="maphelp.cfm">here</a>.
    </p>
</div>