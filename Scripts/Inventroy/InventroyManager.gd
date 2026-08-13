extends Button;

# Lazy Load 
@onready var openAnim: ProtonControlAnimation = $Open;
@onready var closeAnime: ProtonControlAnimation = $Close;
@onready var fadeIn: ProtonControlAnimation =  $FadeIn;
@onready var fadeOut: ProtonControlAnimation = $FadeOut;
@onready var main: Control = $BG/Main;

# Booleans 
var isAnimating: bool;

func openInventroy() -> void:
	if isAnimating: return;
	isAnimating = true;
	self.visible = true;
	openAnim.start();

func closeInventroy() -> void:
	if isAnimating: return;
	isAnimating = true;
	fadeOut.start();

func handlePostOpen() -> void:
	main.visible = true;
	fadeIn.start();

func handlePostClose() -> void:
	isAnimating = false;
	self.visible = false;
	self.process_mode = Node.PROCESS_MODE_DISABLED;	

func handlePostFadeIn() -> void:
	isAnimating = false;

func handlePostFadeOut() -> void:
	main.visible = false;
	closeAnime.start();
