extends Node
## Stored across scene reloads; resets only when the application closes.
var tombstones: Array[Vector2] = []

func add_tombstone(at: Vector2) -> void:
    tombstones.append(at)
