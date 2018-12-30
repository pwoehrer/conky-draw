conky-draw
==========

Easily create beautiful conky graphs and drawings.

The main idea is this: stop copying and pasting random code from the web to your monolithic conkyrc + something.lua. Start using a nicely defined set of visual elements, in a very clean config file, separated from the code that has the drawing logic. "You ask, conky_draw draws".

Also, `Daguhh <http://github.com/Daguhh>`_ made a GUI to generate the configs! `ConkyLuaMakerGUIv2 <https://github.com/Daguhh/ConkyLuaMakerGUIv2>`_

The GUI is not compatible with this version of conky-draw!

Changes:
--------

- The elements ``ring`` and ``ring_graph`` now include the functionality of ``ellipse`` and ``ellipse_graph``. This is accomplished by providing elements of the kinds ``ring`` and ``ring_graph`` with a major and minor radius.


.. code:: lua

    {
        kind = 'ring_graph',
        radius = {a = 50, b=25},
    },

    -- this sytnax is recognized as well:
    {
        kind = 'ring_graph',
        radius = {50, 25},
    },


- There is only an element of the kind ``text``, that replaces ``text_static`` and ``text_variable``. There has to be either a ``text`` or a ``conky_value`` entry. The properties of ``text`` differ significantly from both:


.. code:: lua

    {
        kind = 'text',
        text = 'Sample text.',  -- use conky_value = 'cpu' for variable text
        rotation_angle = 90,  -- rotation in degrees
        alignment = {
            horizontal = 'left',  -- possible values are 'left', 'center', 'right'
            vertical = 'top',  -- possible values are 'top', 'middle', 'bottom'
        }
        prefix = '',  -- this and suffix are mostly useful to display conky_values with units
        suffix = '',
    }


.. image:: /samples/text.png

- The (not implemented) element kind ``clock`` is not longer available.

- Background values are not set as defaults but instead are derived from the elements colors. So it isn't necessary to specify them explicitely.


Examples
--------

.. image:: ./samples/sample1.png


Simple disk usage.

.. code:: lua

    {
        kind = 'bar_graph',
        conky_value = 'fs_used_perc /home/',
        from = {x = 0, y = 45},
        to = {x = 180, y = 45},
        background_thickness = 20,
        bar_thickness = 16,
    },


.. image:: ./samples/sample2.png


Normal vs critical mode. You can even decide what changes when critical values are reached.

.. code:: lua

    {
        kind = 'bar_graph',
        conky_value = 'fs_used_perc /home/',
        from = {x = 50, y = 120},
        to = {x = 120, y = 45},

        bar_thickness = 5,
        bar_color = 0x00E5FF,

        critical_threshold = 60,

        change_color_on_critical = true,
        change_thickness_on_critical = true,

        background_color_critical = 0xFFA0A0,
        background_thickness_critical = 10,

        bar_color_critical = 0xFF0000,
        bar_thickness_critical = 13
    },

.. image:: ./samples/graduated_line_graph.jpg

Idem with graduation

.. code:: lua

    {
        kind = 'bar_graph',
        conky_value = 'fs_used_perc /home/',
        from = {x = 50, y = 120},
        to = {x = 120, y = 45},

        bar_thickness = 5,
        bar_color = 0x00E5FF,

        critical_threshold = 60,

        change_color_on_critical = true,
        change_thickness_on_critical = true,

        background_color_critical = 0xFFA0A0,
        background_thickness_critical = 10,

        bar_color_critical = 0xFF0000,
        bar_thickness_critical = 13,
        graduated= true,
        number_graduation= 30,
        space_between_graduation=2,
    },

    
.. image:: ./samples/sample3.png
	   

Everybody loves ring graphs in conky.

.. code:: lua

    {
        kind = 'ring_graph',
        conky_value = 'fs_used_perc /home/',
        center = {x = 75, y = 100},
        radius = 30,
    },

.. image:: ./samples/graduated_ring.png
    
Ring with graduation

.. code:: lua

  {
       kind = 'ring_graph',
       center = {x = 50, y = 50},
       conky_value = 'fs_used_perc /home/',
       radius = 30,
       graduated = true,
       number_graduationi = 40,
       angle_between_graduation = 3,
       start_angle = 0,
       end_angle = 360,
       color = 0xFF6600,
       background_color = 0xD75600,
   },
    
.. image:: ./samples/sample4.png

Lord of the customized rings.

.. code:: lua

    {
        kind = 'ring_graph',
        conky_value = 'fs_used_perc /home/',
        center = {x = 75, y = 100},
        radius = 30,

        background_color = 0xFFFFFF,
        background_alpha = 1,
        background_thickness = 35,

        bar_color = 0x00E5FF,
        bar_alpha = 1,
        bar_thickness = 15,
    },


.. image:: ./samples/sample5.png


Or even ring fragments.

.. code:: lua

    {
        kind = 'ring_graph',
        conky_value = 'fs_used_perc /home/',
        center = {x = 75, y = 100},
        radius = 30,

        background_alpha = 0.7,
        background_thickness = 2,

        bar_color = 0xFFFFFF,
        bar_alpha = 1,
        bar_thickness = 6,

        start_angle = 140,
        end_angle = 300,
    },

.. image:: ./samples/ellipse.png

Simple and graduated ellipse using ring_graph 

.. code:: lua

  {
       kind = 'ring_graph',
       center = {x = 10, y = 10},
       conky_value = 'fs_used_perc /home/',
       radius = {10, 20},
       graduated = true,
       number_graduation = 40,
       angle_between_graduation=3,
       start_angle = 0,
       end_angle = 360,
       color = 0xFF6600,
       background_color = 0xD75600,
   },

   {
       kind = 'ring_graph',
       center = {x = 30, y = 10},
       conky_value = 'fs_used_perc /home/',
       radius = {a = 20, b = 10}
       start_angle = 0,
       end_angle = 360,
       color= 0xFF6600,
       background_color= 0xD75600,
   },


Right now you can define bar and ring graphs, and static lines and rings. Plans for the future:

* More basic elements: filled circles, rectangles, ...
* Other more complex visual elements (example: clocks)

Installation
------------

1. Copy both ``conky_draw.lua`` and ``conky_draw_config.lua`` to your ``.conky`` folder (your own ``conkyrc`` should be there too).
2. Include this in your conkyrc:

.. code::

    lua_load ./conky_draw.lua
    lua_draw_hook_post main

or this if you are using conky 1.10 or newer:

.. code:: lua

    conky.config = {
        -- (...)

        lua_load = 'conky_draw.lua',
        lua_draw_hook_pre = 'main',
    };

3. Customize the ``conky_draw_config.lua`` file as you wish. You just need to add elements in the ``elements`` variable (examples above).
4. Be sure to run conky from **inside** your ``.conky`` folder. Example: ``cd .conky && conky -c conkyrc``


Full list of available elements and their properties
----------------------------------------------------

Properties marked as **required** must be defined by you. The rest have default values, you can leave them undefined, or define them with the values you like.

But first, some general notions on the values of properties.

+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| If the property is a...| this is what you should know:                                                                                                                      |
+========================+====================================================================================================================================================+
| point                  | Its value should be something with x and y values.                                                                                                 |
|                        | Example: ``from = {x = 100, y = 100}``                                                                                                             |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| color                  | Its value should be a hexadecimal number, defining a color (each byte standing for red, green, and blue respectively).                             |
|                        | Example (red): ``color = 0xFF0000``                                                                                                                |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| alpha level            | Its value should be a transpacency level from 0 (fully transparent) to 1 (solid, no transpacency).                                                 |
|                        | Example: ``alpha = 0.2``                                                                                                                           |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| angle                  | Its value should be expressed in **degrees**. Angle 0 is east, angle 90 is south, angle 180 is west, and angle 270 is north.                       |
|                        | Example: ``start_angle = 90``                                                                                                                      |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| thickness              | Its value should be the thickness in pixels.                                                                                                       |
|                        | Example: ``thickness = 5``                                                                                                                         |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| conky value            | Its value should be a string of a conky value to use, and when used for graphs, should be something that yields a number. All the possible conky   |
|                        | values are listed `here <http://conky.sourceforge.net/variables.html>`_.                                                                           |
|                        | Example: ``conky_value = 'upspeedf eth0'``                                                                                                         |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| maximum value          | It should be maximum possible value for the conky value used in a graph. It's needed to calculate the length of the bars in the graphs, so be sure |
|                        | it's correct (for cpu usage values it's 100, for network speeds it's your top speed, etc.).                                                        |
|                        | Example: ``max_value = 100``                                                                                                                       |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| critical threshold     | It should be the value at which the graph should change appearance. If you do not want that, just leave it equal to max_value to disable           |
|                        | appearance changes.                                                                                                                                |
|                        | Example: ``critical_threshold = 90``                                                                                                               |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| boolean                | It should be either true or false, with no quotes.                                                                                                 |
|                        | Example: ``change_color_on_critical = true``                                                                                                       |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| text                   | A string value of any kind. There is no check on how long the string can be, so be careful.                                                        |
|                        | Example: ``text = Temperature:``                                                                                                                   |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
| alignment              | A table containing two keys ``horizontal`` and ``vertical``. ``horizontal`` can take the values of **left** (default), **center**, and **right**.  |
|                        | ``vertical`` takes the values of **top** (default), **middle**, and **bottom**. The  text will be positioned at the specified corners.             |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
+ font property          + Boolean ``true`` or ``false``.                                                                                                                     +
|                        | Example: ``font_weight = true``                                                                                                                    |
|                        |          ``font_slant = true``                                                                                                                     |
+------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------+
+ radius                 + The value can be a single number or a table consisting of a major and minor diameter. The table can be spcified with or without indices.           +
|                        | Example: ``radius = 50               -- this will draw a circle with the radius of 50 pixels``                                                     |
+                        +                                                                                                                                                    +
|                        |          ``radius = {30, 50}         -- this will draw an ellipse with a radius of 30 pixels along the x axes and one of 50 pixels on the y axes`` |
+                        +                                                                                                                                                    +
|                        |          ``radius = {a = 30, b = 50} -- the same as the above with conventional naming of the radii``                                              |

Now, the elements and properties
--------------------------------

line:
-----

+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| A simple straight line from point A to point B.                                                                                                                         |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| from (required)                | A point where the line should start.                                                                                                   |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| to (required)                  | A point where the line should end.                                                                                                     |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| color                          | Color of the line.                                                                                                                     |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| alpha                          | Transpacency level of the line.                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| thickness                      | Thickness of the line.                                                                                                                 |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| graduated                      | specify if the element is  graduated.                                                                                                  |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| number_graduation              | specify the number of  graduation.                                                                                                     |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| space_between_graduation       | specify the space between  graduation.                                                                                                 |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+


bar_graph:
----------

+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| A bar graph, able to display a value from conky, and optionaly able to change appearance when the value hits a "critical" threshold.                                    |
| It's composed of two lines (rectangles), one for the background, and the other to represent the current value of the conky stat.                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| from (required)                | A point where the bar graph should start.                                                                                              |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| to (required)                  | A point where the bar graph should end.                                                                                                |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| conky_value (required)         | Conky value to use on the graph.                                                                                                       |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| max_value and                  | For the conky value being used on the graph.                                                                                           |
| critical_threshold             |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| background_color,              | For the appearance of the background of the graph in normal conditions.                                                                |
| background_alpha and           |                                                                                                                                        |
| background_thickness           |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| bar_color, bar_alpha and       | For the appearance of the bar of the graph in normal conditions.                                                                       |
| bar_thickness                  |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| change_color_on_critical,      | Booleans to control wether the color, alpha and thickness of both background and bar changes when the critical value is reached.       |
| change_alpha_on_critical and   |                                                                                                                                        |
| change_thickness_on_critical   |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| background_color_critical,     | For the appearance of the background of the graph when the value is above critical threshold.                                          |
| background_alpha_critical and  |                                                                                                                                        |
| background_thickness_critical  |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| bar_color_critical,            | For the appearance of the bar of the graph when the value is above critical threshold.                                                 |
| bar_alpha_critical and         |                                                                                                                                        |
| bar_thickness_critical         |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| graduated                      | specify if the element is  graduated.                                                                                                  |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| number_graduation              | specify the number of  graduation.                                                                                                     |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| space_between_graduation       | specify the space between  graduation.                                                                                                 |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+

ring:
-----

+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| A simple ring (can be a section of the ring too).                                                                                                                       |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| center (required)              | The center point of the ring.                                                                                                          |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| radius (required)              | The radius of the ring.                                                                                                                |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| color                          | Color of the ring.                                                                                                                     |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| alpha                          | Transpacency level of the ring.                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| thickness                      | Thickness of the ring.                                                                                                                 |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| start_angle                    | Angle at which the arc starts. Useful to limit the ring to just a section of the circle.                                               |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| end_angle                      | Angle at which the arc ends. Useful to limit the ring to just a section of the circle.                                                 |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| *Extra tip*: start_angle and end_angle can be swapped, to produce oposite arcs. If you don't understand this, just try what happens with this two examples:             |
|                                                                                                                                                                         |
| * ``start_angle=90, end_angle=180``                                                                                                                                     |
| * ``start_angle=180, end_angle=90``                                                                                                                                     |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| graduated                      | specify if the element is  graduated.                                                                                                  |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| number_graduation              | specify the number of  graduation.                                                                                                     |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| angle_between_graduation       | specify the angle between  graduation.                                                                                                 |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+

ring_graph:
-----------

+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| A ring graph (can be a section of the ring too) able to display a value from conky, and optionaly able to change appearance when the value hits a "critical" threshold. |
| It's composed of two rings, one for the background, and the other to represent the current value of the conky stat.                                                     |
+================================+========================================================================================================================================+
| center (required)              | The center point of the ring.                                                                                                          |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| radius (required)              | The radius of the ring. Can be specified as a single radius (for a circle) or a pair of radii or a                                     |
|                                | table ``{a = .., b = ..}`` (ellipse).                                                                                                  |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| conky_value (required)         | Conky value to use on the graph.                                                                                                       |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| max_value and                  | For the conky value being used on the graph.                                                                                           |
| critical_threshold             |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| background_color,              | For the appearance of the background of the graph in normal conditions.                                                                |
| background_alpha and           |                                                                                                                                        |
| background_thickness           |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| bar_color, bar_alpha and       | For the appearance of the bar of the graph in normal conditions.                                                                       |
| bar_thickness                  |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| change_color_on_critical,      | Booleans to control wether the color, alpha and thickness of both background and bar changes when the critical value is reached.       |
| change_alpha_on_critical and   |                                                                                                                                        |
| change_thickness_on_critical   |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| background_color_critical,     | For the appearance of the background of the graph when the value is above critical threshold.                                          |
| background_alpha_critical and  |                                                                                                                                        |
| background_thickness_critical  |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| bar_color_critical,            | For the appearance of the bar of the graph when the value is above critical threshold.                                                 |
| bar_alpha_critical and         |                                                                                                                                        |
| bar_thickness_critical         |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| start_angle                    | Angle at which the arc starts. Useful to limit the ring to just a section of the circle.                                               |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| end_angle                      | Angle at which the arc ends. Useful to limit the ring to just a section of the circle.                                                 |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| *Extra tip*: start_angle and end_angle can be swapped, to produce oposite arcs. If you don't understand this, just try what happens with this two examples:             |
|                                                                                                                                                                         |
| * ``start_angle=90, end_angle=180``                                                                                                                                     |
| * ``start_angle=180, end_angle=90``                                                                                                                                     |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| graduated                      | specify if the element is  graduated.                                                                                                  |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| number_graduation              | specify the number of  graduation.                                                                                                     |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| angle_between_graduation       | specify the angle between  graduation.                                                                                                 |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+


text:
-----

+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| Simple text                                                                                                                                                             |
+================================+========================================================================================================================================+
| from (required)                | A point where the text should start.                                                                                                   |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| alignment                      | To which point the text should be aligned: ``alignement = { horizontal = 'left', vertical = 'top'}``. Possible values for horizontal   |
|                                | are ``left``, ``center`` and ``right``, for vertical ``top``. ``middle`` and ``bottom``.                                               |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| text, conky-value              | Displayed text                                                                                                                         |
| (mutual optional)              |                                                                                                                                        |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| color                          | Color of the text.                                                                                                                     |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| rotation_angle                 | Inclination of the text.                                                                                                               |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| font                           | Font of the text, default: Noto Sans.                                                                                                  |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| font_size                      | Set the size of the text.                                                                                                              |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| bold                           | Set the text in bold.                                                                                                                  |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| italic                         | Set the text in italic.                                                                                                                |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+
| alpha                          | Transpacency level.                                                                                                                    |
+--------------------------------+----------------------------------------------------------------------------------------------------------------------------------------+

