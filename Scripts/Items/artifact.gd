extends Item
class_name Artifact

func _init():
    label = "Artifact"
    description = ""
    ascii = Constants.ARTIFACT
    type = Type.USEABLE

func on_use(player: Node):
    player.log_message.emit("You have won the game.")
