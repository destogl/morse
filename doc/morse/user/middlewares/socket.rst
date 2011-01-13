Sockets
=======

A simple method to export data through the network. The MORSE sockets
middleware will create a single UDP port for each robot, and the communication
for all components of the robot using sockets will be made through the same
port.

Data is shared as simple text strings.

.. note:: The port numbers used in MORSE start at 70000.

Files
-----

- Blender: ``$ORS_ROOT/data/morse/components/middleware/socket_empty.blend``
- Python: ``$ORS_ROOT/src/morse/modifiers/socket_mw.py``

Available methods
-----------------

- ``read_message``: Gets information from a port, and stores it in the ``modified_data`` array of the associated component. This method expects a list of variables.
- ``post_message``: Formats the contents of ``modified_data`` into a string separated by ';', and sends it through the port associated with a component. This method is only able to handle data of types: integer, float and string.