--local moonshine = require 'moonshine'
local maf = require 'maf'

local t = 0
local vt = 0
local demopart = 0
local _dt = 0
local loadcursor = 0
local firstdraw = 1
local pointindex = 1

local vectors_src = {}
local vectors_tgt = {}
local is_morph = {}
local morphtime = {}
local points_x = {}
local points_y = {}
local points_z = {}

local palette_r = {}
local palette_g = {}

function update_load()
    love.graphics.print(love.system.getMemUsage(), 0,loadcursor)
    love.graphics.present()
    loadcursor=loadcursor+20
end
 
function love.load()
--    canvas = love.graphics.newCanvas(320, 240)

--	effect = moonshine(moonshine.effects.crt)

	mainFont = love.graphics.newFont("main.ttf", 20)

    love.graphics.clear()
    love.graphics.setColor(255,255,255)
    love.graphics.setFont(mainFont);
    love.graphics.print('Loading...', 110,85)
    love.graphics.present()

	skrollilogo = love.graphics.newImage( "skrolli.png" )
	quadlogo = love.graphics.newImage( "quadlogo.png" )
	city = love.graphics.newImage( "city.png" )

	music = love.audio.newSource("mono.wav")
    update_load()

    init_vector()
    for i=1,100 do
    	palette_r[i] = i*1.5
    	palette_g[i] = i*1.3

    	love.graphics.setColor(palette_r[i],palette_g[i],192)
    end

	music:play()
end

function draw_center_x(pic,xo,y,yo)
	clip = love.graphics.newQuad(0,yo,pic:getWidth(),1)

	love.graphics.draw(pic,clip,160-pic:getWidth()/2+xo, y)
end

local logotick = 0
local yoo = 0
local scrollx = 0
local fader = 0

function do_intro() 
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()

	love.graphics.setBlendMode("normal")

    local x, y = 290-skrollilogo:getWidth()/2,130-skrollilogo:getHeight()/2
    x=-238+t*50+math.cos(x+t)*100
    if x > 160 then x = 160 logotick = logotick + _dt end

    if logotick <= 6 then
	    love.graphics.draw(skrollilogo,x-128,y-64-16)
	end

	if x == 160 and logotick > 4 and logotick < 8 then
		if logotick >= 6 then yoo=(logotick-6)*64 end
     	love.graphics.draw(skrollilogo,x-128,y-64-16-yoo+math.cos(yoo)) 
     end


    if logotick >= 12 then
		offs = quadlogo:getHeight()*(logotick-12)
		if offs > quadlogo:getHeight() then offs = quadlogo:getHeight() end
	    for i=0,offs do
	    	xo = math.cos(i+-2+t*0.2)*math.sin(-2+t*0.3)*10
	    	if -2+t*0.3 > 0.0 then xo = 0 end
	    	if logotick >= 12 then xo = math.cos(i*(logotick-12))*(logotick-12) end

    		if logotick < 14 then yoo = 0 end
    		if logotick >= 14 then yoo = (logotick-14)*16 end

		    draw_center_x(quadlogo,xo+yoo,100-quadlogo:getHeight()+i*2,i+yoo)
	    end

	end    	

--	if logotick < 12 then
--		love.graphics.setBlendMode("color")
--	    scrollx = 500-t*100
--	    love.graphics.setColor(64, 32, 92)
--	    love.graphics.print('the power of scripted languages upon your disk operating system. Welcome everybody! *** Skrolliparty 2018 ***', scrollx+math.cos(t*5)*15, 170)
--	    love.graphics.setColor(64*2.3, 32*2.5, 92*2.3)
--	    love.graphics.print('the power of scripted languages upon your disk operating system. Welcome everybody! *** Skrolliparty 2018 ***', -1+scrollx+math.cos(t*5)*15, -1+170)
--	end


	if logotick > 22 and demopart == 0 then
		demopart = 1
		t = 0
		vt = -3
		love.graphics.resetPalette()
	end
end

local pointcount = 35
local curpoints = 1

function calc_point(a,i)
	local x,y,z = a:unpack()

	local u = (x / z)*320;
	local v = (y / z)*200;

	points_x[i] = u
	points_y[i] = v
	points_z[i] = 4+(u + v)/64
	pointindex=pointindex+1
end

function get_vector(i)
	local a = maf.vector(0.51+math.sin(i*0.1+t)*0.3+0.2*math.sin(t*0.5),0.51+math.cos(i*0.1+t)*0.3+0.2*math.cos(t*0.5), 1.0)
	return a
end

function init_vector( )
	for i=1,pointcount do
		local a = get_vector(i)
		vectors_src[i] = maf.vector(0,0,1.0)
		vectors_tgt[i] = a
		is_morph[i] = 0
		morphtime[i] = 0
	end
end

function init_vector_one(i)
	local a = get_vector(i)
	vectors_tgt[i] = a
end


function clamp_uv(u,v) 
	if u > 319 then u = 319 end
	if v > 199 then v = 199 end
	if u < 0 then u = 0 end
	if v < 0 then v = 0 end
	return u,v
end


function do_vector()
	if vt < 0 then return end
	local rx = math.cos(vt*0.1)
	local ry = vt*0.1
	local rz = vt*0.1

	of = maf.vector(-0.5,-0.5,0.0)
	local r = maf.rotation.fromAngleAxis(0.1,0.1,0.0,rx)

	local px,py = 0
	curpoints = 1+vt*3.8
	if curpoints > pointcount then curpoints = pointcount end


	for i=1,pointcount do
		local a = vectors_src[i]
		if is_morph[i] == 1 and morphtime[i] <= 1 then
			a = a:lerp(vectors_tgt[i],morphtime[i])
			
			morphtime[i] = morphtime[i] + _dt*0.6
			if morphtime[i] >= 1.0 then
				is_morph[i] = 0
				morphtime[i] = 0
			end
		end

		a:add(of)
		a:rotate(r)
		a:sub(of)

		calc_point(a,i)
	end


	for i=1,curpoints do
		local u = points_x[i]
		local v = points_y[i]
		if i == 1 then 
			px = u
			py = v 
		end

		if (u >= 314 or v >= 194 or u <= 10 or v <= 10) and is_morph[i] == 0 then
			is_morph[i] = 1
			morphtime[i] = 0
			init_vector_one(i)
		end

			u,v = clamp_uv(u,v)

			love.graphics.setColor(palette_r[math.floor(v*0.5)],palette_g[math.floor(v*0.5)],192)
			love.graphics.line(u,v,px,py)
			love.graphics.setColor(32+32*morphtime[i],32,32)
			cs = points_z[i]
			love.graphics.circle('fill',u,v,cs)
			px = u
			py = v
	end


	if vt > 31.5 then 
		demopart = 2 
		t = 0
		love.graphics.resetPalette() 
	end

end

function test_clamp_uv(u,v,o) 
	local tt = 0
	if u > 319+o then tt = 1 end
	if v > 199+o then tt = 1 end
	if u < 0-o then tt = 1 end
	if v < 0-o then tt = 1 end
	return tt
end


function calc_point_spin(a)
	local x,y,z = a:unpack()

	local u = (x / z)*320;
	local v = (y / z)*200;

	local z = z
	return u,v,z
end

function do_spinner()
	local rx = t*0.1

	of = maf.vector(-0.5,-0.5,-1.0)
	local r = maf.rotation.fromAngleAxis(t*2.,0.0,0.0,1.0)

	local sto = -t*6
	local max = t*6
	if max > 24 then max = 24 end
	local eka = 1
	for i=sto,sto+max do
		local a = maf.vector(0.5+math.cos(i*0.2)*0.3,0.5+math.sin(i*0.2)*0.3,1.0+math.cos(i*0.1+t)*0.2)
		a:add(of)
		a:rotate(r)
		a:sub(of)

		local u,v,z = calc_point_spin(a)
		local cs = (2.-z)*32
		tt = test_clamp_uv(u,v,cs)
		cs = math.floor(cs)

		eka = 1
		if i == sto+max then eka = 0 end


		if eka == 1 then 
			love.graphics.setColor(math.cos(cs)*255,192,-128+cs*4)
			if tt == 0 then love.graphics.circle('fill',u,v,cs) end
		else
			love.graphics.setColor(math.cos(cs)*255,192,-128+cs*4)
			if tt == 0 then love.graphics.circle('fill',u,v,cs) end
			love.graphics.setColor(0,0,0)
			if tt == 0 then love.graphics.circle('fill',u,v,cs-2-7+8*math.abs(math.cos(t*4+math.sin(t*1)))) end
		end

	end

	if t > 6 then 
	love.graphics.setColor(152,24,132)
	love.graphics.print("Ouroboros",1,1)
	love.graphics.setColor(192,64,192)
	love.graphics.print("Ouroboros",0,0)
	end


	if t > 10 and t < 20 then 
	love.graphics.setColor(24,152*0.7,132*0.5)
	love.graphics.print("the mighty wyrm",131,181)
	love.graphics.setColor(64,192*0.7,192*0.5)
	love.graphics.print("the mighty wyrm",130,180)
	end

	if t > 14 and t < 19 then 
	love.graphics.setColor(152,24,132)
	love.graphics.print("always chasing",131,181-20)
	love.graphics.setColor(192,64,192)
	love.graphics.print("always chasing",130,180-20)
	end

	if t > 18 and t < 22 then 
	love.graphics.setColor(152*0.5,24,132*0.5)
	love.graphics.print("never reaching",131,181-40)
	love.graphics.setColor(192*0.5,64,192*0.5)
	love.graphics.print("never reaching",130,180-40)
	end


end

function draw_scroll(pic,xo,yo,w,h,x,y)
	clip = love.graphics.newQuad(xo,yo,w,h)
	love.graphics.draw(pic,clip,x, y)
end


function do_city()
 	love.graphics.setBackgroundColor(0,0,0)
    love.graphics.clear()

	love.graphics.setBlendMode("normal")

	local scro = 1

	if logotick >= 18 then 
		scro = 1.0-((logotick-18)*0.1)
	end

	if scro < 0.0 then scro = 0.0 end

	scrollx = math.floor(t*40)*scro
	scrollx = scrollx % 320
	
	buildings_y = 100
	lights_y = buildings_y+16

	draw_scroll(city,scrollx,64,320-scrollx,16,0,buildings_y)
	draw_scroll(city,0,64,scrollx,16,320-scrollx,buildings_y)

	for yy=1,24,1 do
		scrollx2 = (math.floor(t*(50+yy*4)))*scro
		scrollx2 = scrollx2 % 320
		draw_scroll(city,scrollx2,80+yy,320-scrollx2,2,0,lights_y+yy)
		draw_scroll(city,0,80+yy,scrollx2,2,320-scrollx2,lights_y+yy)

	end

	do_intro()
end



function love.draw()

--    love.graphics.setCanvas(canvas)
	if firstdraw == 1 then t = 0 end

	firstdraw = 0

	if demopart == 0 then do_city() end
	if demopart == 1 then do_city()  do_vector() end
	if demopart == 2 then do_spinner() end

--    love.graphics.setCanvas()

--    love.graphics.clear()

--    love.graphics.setColor(1, 1, 1, 1.0)

--	effect.crt.time = t

--	effect(function()
--		love.graphics.push()
--		love.graphics.scale(3.0, 3.0)
--	    love.graphics.draw(canvas)
--		love.graphics.pop()
--	end)

end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

function love.update(dt)
	t = t + dt
	vt = vt + dt
	_dt = dt
end