package main

import fmt "core:fmt"
import "core:math/rand"
import "core:time"

import SDL "vendor:sdl2"

@(private)
WindowProperties :: struct {
	width, height: i32,
	title:         cstring,
}


@(private)
window := WindowProperties {
	width  = 1920,
	height = 1200,
	title  = "Astroneat",
}

@(private)
Game :: struct {
	perf_frequency: f64,
	renderer:       ^SDL.Renderer,
}

game := Game{}

@(private)
Player :: struct {
	x_position:     f64,
	y_position:     f64,
	movement_speed: f64,
	jump_magnitude: f64,
}

ChangeWindowBackgroundColor :: proc(r, g, b, a: u8) {
	SDL.SetRenderDrawColor(game.renderer, r, g, b, a)
	SDL.RenderClear(game.renderer)
	SDL.RenderPresent(game.renderer)
}

main :: proc() {

	DM := SDL.DisplayMode{}
	SDL.GetCurrentDisplayMode(0, &DM)

	assert(SDL.Init(SDL.INIT_VIDEO) == 0, SDL.GetErrorString())
	defer SDL.Quit()

	if DM.w != 0 && DM.h != 0 {
		window.width = DM.w
		window.height = DM.h
	} else {
		SDL.Log("SDL_GetDesktopDisplayMode failed: %s", SDL.GetErrorString())
		SDL.Quit()
	}

	window := SDL.CreateWindow(
		window.title,
		SDL.WINDOWPOS_CENTERED,
		SDL.WINDOWPOS_CENTERED,
		window.width,
		window.height,
		SDL.WINDOW_SHOWN,
	)

	assert(window != nil, SDL.GetErrorString())
	defer SDL.DestroyWindow(window)


	game.renderer = SDL.CreateRenderer(window, -1, SDL.RENDERER_ACCELERATED)
	assert(game.renderer != nil, SDL.GetErrorString())
	defer SDL.DestroyRenderer(game.renderer)

	SDL.SetWindowFullscreen(window, SDL.WINDOW_FULLSCREEN)

	ChangeWindowBackgroundColor(0, 0, 0, 0)

	game.perf_frequency = f64(SDL.GetPerformanceFrequency())
	start: f64
	end: f64

	event: SDL.Event
	state: [^]u8

	game_loop: for {
		game.perf_frequency = f64(SDL.GetPerformanceFrequency())
		start: f64
		end: f64

		start = get_time()

		if SDL.PollEvent(&event) {

			if event.type == SDL.EventType.QUIT {break game_loop}

			if event.type == SDL.EventType.APP_LOWMEMORY {break game_loop}

			if event.type == SDL.EventType.KEYDOWN {

				if event.key.keysym.scancode == SDL.Scancode.DOWN {
					rng := rand.Rand{}
					rand.init(&rng, transmute(u64)time.time_to_unix_nano(time.now()))

					r := cast(u8)rand.uint32(&rng)
					g := cast(u8)rand.uint128(&rng)
					b := cast(u8)rand.uint128(&rng)
					a := cast(u8)rand.uint128(&rng)

					ChangeWindowBackgroundColor(r, g, b, a)
				}
			}

		}

		event: SDL.Event
		state: [^]u8
	}
}

get_time :: proc() -> f64 {
	return f64(SDL.GetPerformanceCounter()) * 1000 / game.perf_frequency
}
