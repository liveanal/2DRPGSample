class_name VideoManager extends VideoStreamPlayer

@export var videos:Array[VideoStream] = []

var random = RandomNumberGenerator.new()

func _ready():
	connect("finished",func():
		await get_tree().create_timer(2.5).timeout
		refresh()
	)

func refresh():
	stream = videos[random.randi() % videos.size()]
	super.play()
