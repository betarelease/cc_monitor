/*
 * Cylinder Graph 0.1 - A RaphaelJS Plugin
 *
 * Copyright (c) 2010 Damian Dawber (http://www.ibuildstuff.net)
 * Licensed under the MIT (http://www.opensource.org/licenses/mit-license.php) license.
 */


Raphael.fn.cylinderGraph = function(data, options) {

    /*
     *store a reference to the 'paper' object supplied by Raphael.fn.
     *'this' object contains the Raphael drawing methods (e.g. path())
     */
    var that = this;

    /*define settings and set default options*/
    var defaults = {
        numCylinders: 5,
        easingType: '<>',
        labelsColor: '#000',
        baseColorTop: '#333',
        baseColorBottom: '#222',
        colors: [
            ['0-#a00-#f00:50-#a00', 'r(0.5,0)#a00-#d00'],
            ['0-#0a0-#0f0:50-#0a0', 'r(0.5,0)#0a0-#0d0'],
            ['0-#0aa-#0ff:50-#0aa', 'r(0.5,0)#0aa-#0dd'],
            ['0-#b87b00-#fa0:50-#b87b00', 'r(0.5,0)#b87b00-#fa0'],
            ['0-#aa0-#ff0:50-#aa0', 'r(0.5,0)#aa0-#dd0']
        ],
        cylinderSpacing: 0.6,
        baseHeight: 0.75,
        animationLength: 1000,
        showPrevNextLinks: true,
        prevNextLinksIds: {
            prev: 'cylinder-graph-prev-' + that.canvas.parentNode.id,
            next: 'cylinder-graph-next-' + that.canvas.parentNode.id
        }
    };

    var settings = {};

    for(var prop in defaults) {
        settings[prop] = defaults[prop];
    }

    if(typeof options !== 'undefined' && typeof options === 'object') {
        for(var prop in options) {
            settings[prop] = options[prop];
        }
    }

    var canvasWidth = that.width,
        canvasHeight = that.height;

    /*this function returns x and y dimensions of various graph elements*/
    var dimensions = function() {

        /* the default relative proportions of certain elements
         * given as fractions of the total canvas width (x) and height (y)
         */
        var arbitraryDimensions = {
            x: {
                //expect a value between 0 and 1 in settings for cylinder spacing
                cylinderSpacing: 0.05 * (settings.cylinderSpacing >= 0 && settings.cylinderSpacing <= 1 ?
                    settings.cylinderSpacing : defaults.cylinderSpacing)
            },
            y: {
                dataDisplayHeight: 0.18,
                cylinderYRadius: 0.05,
                baseHeight: 0.08 * (settings.baseHeight >= 0 && settings.baseHeight <= 1 ?
                    settings.baseHeight : defaults.baseHeight),
                xLabelsHeight: 0.06
            }
        };

        var x = {}, y = {}, sumY = 0;

        for(var prop in arbitraryDimensions.x) {
            x[prop] = Math.floor(arbitraryDimensions.x[prop] * canvasWidth);
        }

        for(var prop in arbitraryDimensions.y) {
            y[prop] = Math.floor(arbitraryDimensions.y[prop] * canvasHeight);
            sumY += y[prop];
        }

        /*
         * determineAll()
         * function calculates all dimensions based on arbitrary dimensions
         */
        function determineAll() {

            x.cylinderWidth = Math.floor(
                ( canvasWidth - (x.cylinderSpacing * (settings.numCylinders + 1)) ) / settings.numCylinders
            );

            if(x.cylinderWidth % 2 !== 0) {
                x.cylinderWidth -= 1;
            }
            x.cylinderXRadius = x.cylinderWidth / 2;

            y.cylinderHeight = Math.floor(canvasHeight - sumY);

            return {
                x: x,
                y: y
            };

        }

        return {
            get: determineAll()
        };

    }();


    var baseOrigin = {
        x: 0,
        y: canvasHeight - dimensions.get.y.baseHeight - dimensions.get.y.xLabelsHeight
    };

    var origin = {
        x: baseOrigin.x + dimensions.get.x.cylinderSpacing,
        y: baseOrigin.y - dimensions.get.y.cylinderYRadius
    };

    /*parse the data supplied and calculate relative bar heights*/
    var munchedData = function() {
        var flag = 0;
        for(var i = 0, len = data.length - 1; i < len; i+=1) {
            if( data[flag][1] < data[i+1][1]) {
                flag = i + 1;
            }
        }
        var maxValue = data[flag][1];

        var relYData = [],
            xLabels = [];

        for(var i = 0, len = data.length; i < len; i+=1) {
            relYData.push( dimensions.get.y.cylinderHeight * ( data[i][1] / maxValue ) );
            xLabels.push(data[i][0]);
        }

        return {
            relYData: relYData,
            xLabels: xLabels
        };

    }();

    /*begin draw base of graph*/

    var xMargin = dimensions.get.x.cylinderSpacing,
        cylinderYRadius = dimensions.get.y.cylinderYRadius,
        baseHeight = dimensions.get.y.baseHeight;

    var bottomOfBasePath = [
        'M', baseOrigin.x, baseOrigin.y,
        'l', canvasWidth - xMargin, 0,
        'l', xMargin, -2*cylinderYRadius,
        'l', 0, baseHeight,
        'l', -xMargin, 2*cylinderYRadius,
        'l', -canvasWidth + xMargin, 0,
        'l', 0, -baseHeight
    ];

    that.path(bottomOfBasePath).attr({fill: settings.baseColorBottom, stroke: settings.baseColorBottom});

    var topOfBasePath = [
        'M', baseOrigin.x, baseOrigin.y,
        'l', canvasWidth - xMargin, 0,
        'l', xMargin, -2*cylinderYRadius,
        'l', -canvasWidth + xMargin, 0,
        'l', -xMargin, 2*cylinderYRadius
    ];

    that.path(topOfBasePath).attr({fill: settings.baseColorTop, stroke: settings.baseColorTop});

    /*end draw base of path*/

    var cylinders = [], ellipses = [], xDataLabels = [], yDataLabels = [];

    function drawCylinder(cylinderHeight, color, startX) {
        var startY = origin.y,
            cylinderDiameter = dimensions.get.x.cylinderWidth,
            cylinderXRad = dimensions.get.x.cylinderXRadius,
            cylinderYRad = dimensions.get.y.cylinderYRadius;


        var cylinderPathInit = [
            'M', startX, startY,
            'a', cylinderXRad, cylinderYRad, 0, 0, 0, cylinderDiameter, 0,
            'l', 0, 0,
            'l', -cylinderDiameter, 0,
            'z'
        ];

        var cylinderPathAnim = [
            'M', startX, startY,
            'a', cylinderXRad, cylinderYRad, 0, 0, 0, cylinderDiameter, 0,
            'l', 0, -cylinderHeight,
            'l', -cylinderDiameter, 0,
            'z'
        ];

        cylinders.push(
            that.path(cylinderPathInit)
            .attr({fill: color[0], stroke: 'none'})
            .animate({
                path: cylinderPathAnim
            }, settings.animationLength, settings.easingType)
        );

        ellipses.push(
            that.ellipse(startX + cylinderXRad, startY,
                cylinderXRad, cylinderYRad)
            .attr({fill: color[1], stroke: 'none'})
            .animate({cy: startY-cylinderHeight}, settings.animationLength, settings.easingType)
        );

    }

    function drawLabels(cylinderHeight, xLabel, dataValue, startX) {
        var centerX = startX + dimensions.get.x.cylinderXRadius;
        var centerY = origin.y - cylinderHeight - 2*dimensions.get.y.cylinderYRadius;

        yDataLabels.push(that.text(centerX, -10, dataValue.toString()).animate({y: centerY}, settings.animationLength, settings.easingType)
            .attr({fill: settings.labelsColor})
        );

        startX += dimensions.get.x.cylinderXRadius;
        xDataLabels.push(that.text(startX, baseOrigin.y + dimensions.get.y.baseHeight + dimensions.get.y.xLabelsHeight/2, xLabel.toString())
            .attr({fill: settings.labelsColor})
        );
    }

    /*function removes existing canvas drawings and starts the drawing*/
    var initDraw = function(index) {

        for(var i = 0; i < cylinders.length; i+=1) {
            cylinders[i].remove();
            ellipses[i].remove();
        }

        for(var i = 0, len = xDataLabels.length; i < len; i+=1) {
            xDataLabels[i].remove();
            yDataLabels[i].remove();
        }

        cylinders = [], ellipses = [], xDataLabels = [], yDataLabels = [];

        var relYData = munchedData.relYData;

        var increment = dimensions.get.x.cylinderWidth + dimensions.get.x.cylinderSpacing; //pos'n relative to previous cylinder

        var startX = origin.x;

        for(var i = index, j = 0; i < settings.numCylinders + index; i+=1) {

            j = j > settings.colors.length - 1 ? 0 : j; //determines cylinders color

            if(typeof relYData[i] !== 'undefined') {
                drawCylinder(relYData[i], settings.colors[j], startX);
                drawLabels(relYData[i], data[i][0], data[i][1], startX);
                startX += increment;
            }

            j += 1;
        }

    };


    var currentCylinder = 0; //always start drawing at 1st cylinder

    initDraw(currentCylinder);

    /*
     * handle custom previous-next links
     */

    if(settings.numCylinders !== data.length && settings.showPrevNextLinks !== false) {

        /*we should show previous and next links, custom or added*/

        if(settings.prevNextLinksIds.next === defaults.prevNextLinksIds.next
            && settings.prevNextLinksIds.prev === defaults.prevNextLinksIds.prev) {

            /*
             * no custom event handlers have been specified so create a div and append
             * it with 'default' previous and next links
             */

            var canvasContainer = document.getElementById(that.canvas.parentNode.id),
                linksContainer = document.createElement('div'),
                containerStyles = {
                    padding: '10px',
                    textAlign: 'center',
                    color:'#555',
                    marginTop: '15px',
                    fontSize: '11px',
                    width: (canvasWidth - 2*dimensions.get.x.cylinderSpacing) + 'px',
                    paddingRight: (2*dimensions.get.x.cylinderSpacing) + 'px'
                };

            for(var prop in containerStyles) {
                linksContainer.style[prop] = containerStyles[prop];
            }

            //insert prev-next links AFTER the div containing the graph
            canvasContainer.parentNode.insertBefore(linksContainer, canvasContainer.nextSibling);

            linksContainer.innerHTML =
                '<a id="' + settings.prevNextLinksIds.prev 
                    + '" href="#" style="display: inline-block">&laquo; Previous</a>  <a id="'
                    + settings.prevNextLinksIds.next
                    + '" style="display: inline-block" href="#">Next &raquo; </a>';

        }

        /* helper function used to set opacity of prev next links*/
        function setOpacity(elm, level) {
            if(elm.filters) {
                elm.style.filter = 'alpha(opacity = ' + level + ')';
                if(elm.getElementsByTagName('img')[0]) {
                    elm.getElementsByTagName('img')[0].style.filter = 'alpha(opacity = ' + level + ')';
                }
            } else {
                elm.style.opacity = level/100;
            }
        }

        var prevLink = document.getElementById(settings.prevNextLinksIds.prev),
            nextLink = document.getElementById(settings.prevNextLinksIds.next);

        /*hide prev link initially*/
        setOpacity(prevLink, 50);

        /*get the previous and next links specified in the settings and make them cycle through graphs*/

        prevLink.onclick = function() {
            
            if(currentCylinder > 0) {
                currentCylinder -= settings.numCylinders;

                if(currentCylinder <= 0) {
                    setOpacity(prevLink, 50);
                } else {
                    setOpacity(prevLink, 100);
                }
                if(currentCylinder + settings.numCylinders < data.length - 1) {
                    setOpacity(nextLink, 100);
                }

                initDraw(currentCylinder);
            }
            return false;
        }
        
        nextLink.onclick = function() {
            if(currentCylinder + settings.numCylinders < data.length - 1) {
                currentCylinder += settings.numCylinders;

                if(currentCylinder + settings.numCylinders >= data.length - 1) {
                    setOpacity(nextLink, 50);
                    //nextLink.style.opacity = 1;
                } else {
                    setOpacity(nextLink, 100);
                }
                if(currentCylinder > 0) {
                    setOpacity(prevLink, 100);
                }

                initDraw(currentCylinder);
                
            }
            return false;
        };

    }   
};