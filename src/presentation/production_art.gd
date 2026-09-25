extends RefCounted
## Authored atlas regions are based on the actual image, not the requested grid.
const PROPS = preload("res://assets/production/props.webp")
const REGIONS := [Rect2(38,45,335,312),Rect2(417,49,255,299),Rect2(731,92,328,258),Rect2(44,362,280,354),Rect2(371,428,350,221),Rect2(776,374,268,315),Rect2(106,704,167,409),Rect2(422,700,208,411),Rect2(723,721,355,380),Rect2(30,1136,346,246),Rect2(393,1113,305,304),Rect2(740,1123,328,289)]
static func texture(id: int) -> AtlasTexture:
	var result := AtlasTexture.new()
	result.atlas = PROPS
	result.region = REGIONS[id]
	return result
static func paint(canvas: CanvasItem, id: int, rect: Rect2, tint: Color = Color.WHITE) -> void:
	var source: Rect2 = REGIONS[id]
	var factor := minf(rect.size.x/source.size.x,rect.size.y/source.size.y)
	var extent := source.size*factor
	canvas.draw_texture_rect_region(PROPS,Rect2(rect.position+(rect.size-extent)*0.5,extent),source,tint)
