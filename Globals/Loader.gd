extends Node

# Auto Start Load 
const cursor: Resource					= preload("res://Assets/UI/Hud/cursor.png");
const gameHud: PackedScene 				= preload("res://Scenes/Hud.tscn");
const camList: PackedScene				= preload("res://Scenes/UI/CamList.tscn");
const mainCamera: PackedScene 			= preload("res://Scenes/MainCamera.tscn");
const clickedCursor: Resource			= preload("res://Assets/UI/Hud/click.png");

enum Stat {
	INVALID = ResourceLoader.THREAD_LOAD_INVALID_RESOURCE,
	IN_PROG = ResourceLoader.THREAD_LOAD_IN_PROGRESS,
	FAILED 	= ResourceLoader.THREAD_LOAD_FAILED,
	LOADED 	= ResourceLoader.THREAD_LOAD_LOADED
}

func stat(res: String, arr: Array = []) -> ResourceLoader.ThreadLoadStatus:
	return ResourceLoader.load_threaded_get_status(res, arr)

func req(res: String) -> Error:
	return ResourceLoader.load_threaded_request(res)
	
func grep(res: String) -> Resource:
	return ResourceLoader.load_threaded_get(res)
