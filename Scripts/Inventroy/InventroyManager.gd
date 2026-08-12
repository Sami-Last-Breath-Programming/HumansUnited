extends Button;

# Signlas
signal AnimSlots();
signal RestSlotsColor();

# Lazy Load 
@onready var openAnim: ProtonControlAnimation = $Open;
@onready var closeAnime: ProtonControlAnimation = $Close;
@onready var fadeIn: ProtonControlAnimation =  $FadeIn;
@onready var fadeOut: ProtonControlAnimation = $FadeOut;
@onready var main: Control = $BG/Main;

func openInventroy() -> void:
	self.visible = true;
	openAnim.start();

func closeInventroy() -> void:
	fadeOut.start();

func handlePostStart() -> void:
	main.visible = true;
	fadeIn.start();

func handlePostFadeIn() -> void:
	AnimSlots.emit();

func handlePostFadeOut() -> void:
	main.visible = false;
	RestSlotsColor.emit();
	closeAnime.start();

func handlePostClose() -> void:
	self.visible = false;
	self.process_mode = Node.PROCESS_MODE_DISABLED;	
