extends Node

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
