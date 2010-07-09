import math
import GameLogic
import morse.helpers.sensor

class ThermometerClass(morse.helpers.sensor.MorseSensorClass):
	""" Class definition for the gyroscope sensor.
		Sub class of Morse_Object. """

	def __init__(self, obj, parent=None):
		""" Constructor method.
			Receives the reference to the Blender object.
			The second parameter should be the name of the object's parent. """
		print ("######## THERMOMETER '%s' INITIALIZING ########" % obj.name)
		# Call the constructor of the parent class
		super(self.__class__,self).__init__(obj, parent)

		self.local_data['temperature'] = 0.0
		self._global_temp = 15.0
		self._fire_temp = 200.0

		self.data_keys = ['temperature']

		# Initialise the copy of the data
		for variable in self.data_keys:
			self.modified_data.append(self.local_data[variable])

		# Get the global coordinates of defined in the scene
		scene = GameLogic.getCurrentScene()
		script_empty_name = 'Scene_Script_Holder'
		# Prefix the name of the component with 'OB'
		# Will only be necessary until the change to Blender 2.5
		if GameLogic.pythonVersion < 3:
			script_empty_name = 'OB' + script_empty_name
		script_empty = scene.objects[script_empty_name]
		self._global_temp = float(script_empty['Temperature'])

		print ('######## THERMOMETER INITIALIZED ########')


	def default_action(self):
		""" Compute the local temperature

		Temperature is measured dependent on the closest fire source.
		"""
		min_distance = 100000.0
		fires = False

		scene = GameLogic.getCurrentScene()
		# Look for the fire sources marked so
		for obj in scene.objects:
			try:
				obj['Fire']
				fire_radius = obj['Fire_Radius']
				# If the direction of the fire is also important,
				#  we can use getVectTo instead of getDistanceTo
				distance = self.blender_obj.getDistanceTo(obj)
				if distance < min_distance:
					min_distance = distance
					fires = True
			except KeyError as detail:
				# print "Exception: ", detail
				pass

		temperature = self._global_temp
		# Trial and error formula to get a temperature dependant on
		#  distance to the nearest fire source. 
		if fires:
			temperature += self._fire_temp * math.e ** (-0.2 * min_distance)

		# Store the data acquired by this sensor that could be sent
		#  via a middleware.
		self.local_data['temperature'] = float(temperature)