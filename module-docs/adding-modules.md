# Adding Modules

New modules are new .cfm files. Below is template HTML code that goes at the top of each new module file. Basically, this template just contains a header section containing the stylesheet, the nav bar and page header, and a div for where module content is supposed to go. Refer to the comments for where things like custom CSS styles should be placed.

```html
<head>

    <!--- bootstrap stylesheet n friends --->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
    <link rel="stylesheet" type="text/css" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">

    <syle>
        <!--- custom styles go here! --->
    </syle>
</head>

<!-- page header -->
<div class="px-2 text-center">
    <h1>Cool, Untitled L+G Metering Dashboard</h1>
    <p>For reading terrible customer meter reports, among other things
    </p>
    <hr/>
</div>

<!-- nav bar -->
<nav class="navbar navbar-expand-sm bg-light navbar-light">
    <ul class="navbar-nav">
        <!-- IMPORTANT: Keep this up-to-date across ALL files -->
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

<div>
    <!-- module content goes here -->
</div>
```