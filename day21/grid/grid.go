package grid

type Vec struct {
	X, Y int
}

func NewVec(x, y int) Vec {
	return Vec{x, y}
}

type Connection struct {
	From, To Vec
}

func NewConnection(from, to Vec) Connection {
	return Connection{from, to}
}

var dirs = [...]Vec{{Y: -1}, {X: 1}, {Y: 1}, {X: -1}}
