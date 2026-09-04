pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- linesgotchi
-- fantasy console virtual pet & color lines

-- screens
s_pet=0
s_lines=1
s_result=2
s_stats=3
s_records=4
s_settings=5

scr=s_pet
menu_i=1
msg=""
msg_timer=0
result_reason=""
new_best=false
quit_confirm=false
clear_cells={}
clear_timer=0
care_clock=0
settings_i=1
stats_i=1

-- lines config
bs=8
cs=9
ox=8
oy=23
colors={11,12,14,10,13}
ball_sprs={48,49,50,51,52}
dxs={1,0,1,1}
dys={0,1,1,-1}

-- gotchi state
pet={
 hunger=15,
 happy=55,
 health=100,
 energy=80,
 discipline=45,
 weight=10,
 age=0,
 level=1,
 exp=0,
 max_exp=100,
 tomatoes=3,
 toilet_ok=true,
 sleep_ready=true,
 eating_t=0,
 sleeping_t=0,
 age_progress=0
}

-- records
hi_score=0
games_played=0
total_lines=0
best_line=0

-- lines state
b={}
cx=1
cy=1
sel=0
score=0
session_lines=0
session_best=0
moves=0
game_over=false
next_balls={}

-- settings
sound_on=true
hints_on=true

function _init()
 cartdata("linesgotchi_v2")
 load_save()
 for i=1,bs*bs do b[i]=0 end
 roll_next()
 show_pet()
end

function roll_next()
 next_balls={}
 for i=1,3 do
  add(next_balls,flr(rnd(#colors))+1)
 end
end

function _update()
 care_clock+=1
 if care_clock>=900 then
  care_clock=0
  pet.hunger=clamp(pet.hunger+1,0,100)
  if pet.hunger>70 then pet.happy=clamp(pet.happy-1,0,100) end
  if pet.sleeping_t==0 then pet.energy=max(0,pet.energy-1) end
  update_weight_health()
  save_state()
 end
 if pet.eating_t>0 then pet.eating_t-=1 end
 update_sleep()
 if msg_timer>0 then
  msg_timer-=1
  if msg_timer==0 then msg="" end
 end

 if scr==s_pet then update_pet()
 elseif scr==s_lines then update_lines()
 elseif scr==s_result then update_result()
 elseif scr==s_stats then update_stats()
 elseif scr==s_records then update_nav_screen()
 elseif scr==s_settings then update_settings()
 end
end

function _draw()
 cls(1)
 if scr==s_pet then draw_pet_screen()
 elseif scr==s_lines then draw_lines_screen()
 elseif scr==s_result then draw_result_screen()
 elseif scr==s_stats then draw_stats_screen()
 elseif scr==s_records then draw_records_screen()
 elseif scr==s_settings then draw_settings_screen()
 end
end

function show_pet()
 scr=s_pet
 menu_i=1
 quit_confirm=false
end

function load_save()
 if dget(10)==1 then
  hi_score=max(0,dget(0))
  games_played=max(0,dget(1))
  total_lines=max(0,dget(2))
  best_line=max(0,dget(3))
  pet.hunger=clamp(dget(4),0,100)
  pet.happy=clamp(dget(5),0,100)
  pet.weight=clamp(dget(6),1,99)
  pet.tomatoes=max(0,dget(7))
  pet.level=max(1,dget(8))
  pet.exp=max(0,dget(9))
  if dget(12)==1 then
   local flags=dget(11)
   sound_on=band(flags,1)==1
   hints_on=band(flags,2)==2
   pet.age=max(0,dget(13))
   pet.health=clamp(dget(14),0,100)
   pet.discipline=clamp(dget(15),0,100)
   pet.age_progress=clamp(dget(16),0,2)
   pet.max_exp=max(100,dget(17))
   pet.toilet_ok=dget(18)==1
   if dget(20)==1 then
    pet.sleep_ready=dget(19)==1
   else
    pet.sleep_ready=true
   end
  end
  pet.exp=clamp(pet.exp,0,pet.max_exp-1)
  if dget(23)==1 then
   pet.energy=clamp(flr(dget(21)),0,100)
   local duration=flr((101-pet.energy)/2)*30
   pet.sleeping_t=0
   if dget(22)>0 and duration>0 then
    pet.sleeping_t=clamp(flr(dget(22)),max(1,duration-29),duration)
   end
  else
   pet.energy=80
   pet.sleeping_t=0
  end
 end
end

function save_state()
 dset(0,hi_score)
 dset(1,games_played)
 dset(2,total_lines)
 dset(3,best_line)
 dset(4,pet.hunger)
 dset(5,pet.happy)
 dset(6,pet.weight)
 dset(7,pet.tomatoes)
 dset(8,pet.level)
 dset(9,pet.exp)
 dset(10,1)
 dset(11,(sound_on and 1 or 0)+(hints_on and 2 or 0))
 dset(12,1)
 dset(13,pet.age)
 dset(14,pet.health)
 dset(15,pet.discipline)
 dset(16,pet.age_progress)
 dset(17,pet.max_exp)
 dset(18,pet.toilet_ok and 1 or 0)
 dset(19,pet.sleep_ready and 1 or 0)
 dset(20,1)
 dset(21,pet.energy)
 dset(22,pet.sleeping_t)
 dset(23,1)
end

function clamp(v,lo,hi)
 return max(lo,min(hi,v))
end

function full()
 return 100-pet.hunger
end

function set_msg(txt,frames)
 msg=txt
 msg_timer=frames or 60
end

function play_sound(id)
 if sound_on then sfx(id) end
end

function update_pet()
 if btnp(5) then return end
 if btnp(0) then menu_i=max(1,menu_i-1) play_sound(0) end
 if btnp(1) then menu_i=min(5,menu_i+1) play_sound(0) end
 if btnp(4) then
  open_menu()
 end
end

function open_menu()
 if menu_i==1 then show_pet()
 elseif menu_i==2 then start_lines()
 elseif menu_i==3 then scr=s_stats stats_i=0
 elseif menu_i==4 then scr=s_records
 elseif menu_i==5 then scr=s_settings
 end
end

function feed_pet()
 if pet.sleeping_t>0 then
  set_msg("let me sleep",30)
 elseif pet.eating_t>0 then
  set_msg("still eating",20)
 elseif pet.hunger<=0 then
  set_msg("not hungry",30)
 elseif pet.tomatoes>0 then
  pet.tomatoes-=1
  pet.hunger=clamp(pet.hunger-20,0,100)
  pet.weight=clamp(pet.weight+1,1,99)
  pet.eating_t=40
  pet.toilet_ok=false
  update_weight_health()
  set_msg("yummy! +full",50)
  play_sound(4)
  save_state()
 else
  set_msg("no tomatoes!",40)
  play_sound(2)
 end
end

function start_lines()
 if pet.sleeping_t>0 then set_msg("let me sleep",40) return end
 if pet.energy<=0 then set_msg("need sleep",40) return end
 scr=s_lines
 menu_i=2
 cx=1
 cy=1
 sel=0
 score=0
 session_lines=0
 session_best=0
 moves=0
 game_over=false
 quit_confirm=false
 clear_cells={}
 clear_timer=0
 msg=""
 msg_timer=0
 new_best=false
 for i=1,bs*bs do b[i]=0 end
 add_balls_random(5)
 roll_next()
 local cleared=clear_lines()
 while cleared>0 do
  add_balls_random(cleared)
  cleared=clear_lines()
 end
 score=0
 session_lines=0
 session_best=0
 msg=""
 msg_timer=0
end

function update_lines()
 if game_over then
  finish_lines("game over")
  return
 end

 if clear_timer>0 then
  clear_timer-=1
  if clear_timer==0 then finish_clear_fx() end
  return
 end

 if quit_confirm then
  if btnp(4) then -- O: confirm quit
   finish_lines("quit")
   return
  elseif btnp(5) then -- X: cancel quit
   quit_confirm=false
   return
  end
  return
 end

 if btnp(0) then cx=max(1,cx-1) play_sound(0) end
 if btnp(1) then cx=min(bs,cx+1) play_sound(0) end
 if btnp(2) then cy=max(1,cy-1) play_sound(0) end
 if btnp(3) then cy=min(bs,cy+1) play_sound(0) end

 if btnp(5) then -- X button
  if sel>0 then
   sel=0
   set_msg("cancel",30)
   play_sound(1)
  else
   quit_confirm=true
  end
 end

 if btnp(4) then lines_action() end
end

function lines_action()
 local i=idx(cx,cy)
 if sel==0 then
  if b[i]>0 then
   sel=i
   play_sound(1)
  end
 else
  if i==sel then
   sel=0
   play_sound(1)
  elseif b[i]>0 then
   sel=i
   play_sound(1)
  elseif can_reach(sel,i) then
   b[i]=b[sel]
   b[sel]=0
   sel=0
   moves+=1
   tick_pet_play()
   local before=capture_board()
   local cleared,best=clear_lines()
   if cleared==0 then
    spawn_next_balls()
    before=capture_board()
    cleared,best=clear_lines()
   end
   if cleared>0 then
    begin_clear_fx(before)
   else
    game_over=is_full()
   end
  else
   set_msg("no path",30)
   play_sound(2)
  end
 end
end

function tick_pet_play()
 pet.energy=max(0,pet.energy-1)
 if moves%3==0 then
  pet.happy=clamp(pet.happy+1,0,100)
  pet.hunger=clamp(pet.hunger+1,0,100)
 end
 if moves%8==0 and pet.weight>5 then
  pet.weight-=1
 end
 update_weight_health()
 save_state()
end

function capture_board()
 local copy={}
 for i=1,bs*bs do copy[i]=b[i] end
 return copy
end

function begin_clear_fx(before)
 clear_cells={}
 for i=1,bs*bs do
  if before[i]>0 and b[i]==0 then
   add(clear_cells,{i=i,c=before[i]})
   b[i]=before[i]
  end
 end
 clear_timer=10
 play_sound(3)
end

function finish_clear_fx()
 for item in all(clear_cells) do b[item.i]=0 end
 clear_cells={}
 game_over=is_full()
end

function clearing_cell(i)
 for item in all(clear_cells) do
  if item.i==i then return true end
 end
 return false
end

function spawn_next_balls()
 for k=1,#next_balls do
  local empties={}
  for i=1,bs*bs do
   if b[i]==0 then add(empties,i) end
  end
  if #empties==0 then
   game_over=true
   return
  end
  local spot=empties[flr(rnd(#empties))+1]
  b[spot]=next_balls[k]
 end
 roll_next()
end

function add_balls_random(n)
 for k=1,n do
  local empties={}
  for i=1,bs*bs do
   if b[i]==0 then add(empties,i) end
  end
  if #empties>0 then
   local spot=empties[flr(rnd(#empties))+1]
   b[spot]=flr(rnd(#colors))+1
  end
 end
end

function finish_lines(reason)
 result_reason=reason
 new_best=false
 if reason~="quit" then
  games_played+=1
  new_best=score>hi_score
  if new_best then hi_score=score end
  total_lines+=session_lines
  if session_best>best_line then best_line=session_best end

  local gain=flr(session_lines/2)+2
  pet.happy=clamp(pet.happy+gain,0,100)
  pet.hunger=clamp(pet.hunger+4,0,100)
  pet.exp+=score
  while pet.exp>=pet.max_exp do
   pet.level+=1
   pet.exp-=pet.max_exp
   pet.max_exp+=50
   pet.tomatoes+=3
  end
  if session_lines>3 then
   pet.tomatoes+=flr(session_lines/4)
  end
  pet.age_progress+=1
  if pet.age_progress>=3 then
   pet.age+=1
   pet.age_progress=0
  end
  update_weight_health()
 end

 save_state()
 scr=s_result
end

function update_result()
 if btnp(4) or btnp(5) then show_pet() end
end

function update_nav_screen()
 if btnp(0) then menu_i=max(1,menu_i-1) play_sound(0) end
 if btnp(1) then menu_i=min(5,menu_i+1) play_sound(0) end
 if btnp(4) then open_menu() end
 if btnp(5) then show_pet() end
end

function update_settings()
 if btnp(2) then settings_i=max(1,settings_i-1) play_sound(0) end
 if btnp(3) then settings_i=min(2,settings_i+1) play_sound(0) end
 if btnp(0) then menu_i=max(1,menu_i-1) play_sound(0) end
 if btnp(1) then menu_i=min(5,menu_i+1) play_sound(0) end
 if btnp(4) then
  if menu_i~=5 then
   open_menu()
  elseif settings_i==1 then
   sound_on=not sound_on
   if sound_on then sfx(0) end
  else
   hints_on=not hints_on
   play_sound(1)
  end
  save_state()
 end
 if btnp(5) then show_pet() end
end

function update_stats()
 if btnp(5) then show_pet() return end
 if btnp(2) then stats_i=max(0,stats_i-1) play_sound(0) end
 if btnp(3) then stats_i=min(2,stats_i+1) play_sound(0) end
 if btnp(0) then menu_i=max(1,menu_i-1) play_sound(0) end
 if btnp(1) then menu_i=min(5,menu_i+1) play_sound(0) end
 if btnp(4) then
  if menu_i~=3 then open_menu()
  elseif stats_i==0 then feed_pet()
  elseif stats_i==1 then use_toilet()
  else put_pet_to_sleep() end
 end
end

function use_toilet()
 if pet.toilet_ok then
  set_msg("already clean",35)
 else
  pet.toilet_ok=true
  pet.happy=clamp(pet.happy+2,0,100)
  pet.discipline=clamp(pet.discipline+1,0,100)
  set_msg("all clean!",40)
  save_state()
 end
 play_sound(1)
end

function put_pet_to_sleep()
 if pet.eating_t>0 then
  set_msg("still eating",20)
 elseif pet.sleeping_t>0 then
  set_msg("already asleep",30)
 elseif pet.energy>=100 then
  set_msg("already rested",30)
 else
  pet.sleeping_t=flr((101-pet.energy)/2)*30
  pet.sleep_ready=false
  set_msg("sweet dreams",45)
  save_state()
  play_sound(1)
 end
end

function update_sleep()
 if pet.sleeping_t<=0 then return end
 pet.sleeping_t-=1
 -- One recovery tick each second. Save the remaining phase, not wall time.
 if pet.sleeping_t%30==0 then
  pet.energy=min(100,pet.energy+2)
  if pet.energy>=100 then pet.sleeping_t=0 end
  if pet.sleeping_t==0 then
   pet.sleep_ready=false
   set_msg("fully rested",45)
  end
 end
 save_state()
end

function update_weight_health()
 local risk=max(0,pet.weight-16)*3+max(0,6-pet.weight)*4
 local cap=max(25,100-risk)
 if pet.health>cap then pet.health-=1
 elseif pet.health<cap and pet.weight>=6 and pet.weight<=16 then pet.health+=1 end
 pet.health=clamp(pet.health,0,100)
end

function pet_stage()
 if pet.age>=14 or pet.level>=10 then return "adult" end
 if pet.age>=7 or pet.level>=7 then return "teen" end
 if pet.age>=3 or pet.level>=4 then return "child" end
 return "baby"
end

function idx(x,y)
 return (y-1)*bs+x
end

function xy(i)
 local y=flr((i-1)/bs)+1
 local x=i-(y-1)*bs
 return x,y
end

function inb(x,y)
 return x>=1 and x<=bs and y>=1 and y<=bs
end

function can_reach(a,d)
 local q={a}
 local head=1
 local seen={}
 seen[a]=true
 while head<=#q do
  local i=q[head]
  head+=1
  if i==d then return true end
  local x,y=xy(i)
  for n=1,4 do
   local nx=x
   local ny=y
   if n==1 then nx=x-1
   elseif n==2 then nx=x+1
   elseif n==3 then ny=y-1
   else ny=y+1
   end
   if inb(nx,ny) then
    local ni=idx(nx,ny)
    if b[ni]==0 and not seen[ni] then
     seen[ni]=true
     add(q,ni)
    end
   end
  end
 end
 return false
end

function clear_lines()
 local mark={}
 local best=0
 for y=1,bs do
  for x=1,bs do
   local i=idx(x,y)
   local c=b[i]
   if c>0 then
    for d=1,4 do
     local px=x-dxs[d]
     local py=y-dys[d]
     if not inb(px,py) or b[idx(px,py)]~=c then
      local count=1
      local nx=x+dxs[d]
      local ny=y+dys[d]
      while inb(nx,ny) and b[idx(nx,ny)]==c do
       count+=1
       nx+=dxs[d]
       ny+=dys[d]
      end
      if count>=5 then
       best=max(best,count)
       for n=0,count-1 do
        mark[idx(x+dxs[d]*n,y+dys[d]*n)]=true
       end
      end
     end
    end
   end
  end
 end
 local cleared=0
 for i=1,bs*bs do
  if mark[i] then
   b[i]=0
   cleared+=1
  end
 end
 if cleared>0 then
  score+=cleared*10
  session_lines+=cleared
  session_best=max(session_best,best)
  set_msg("+"..(cleared*10),40)
 end
 return cleared,best
end

function is_full()
 for i=1,bs*bs do
  if b[i]==0 then return false end
 end
 return true
end

-- =====================================================================
-- DRAWING FUNCTIONS (Pixel-perfect matching reference)
-- =====================================================================

function device_bezel(frame_col)
 pal()
 pal(1,129,1)
 pal(3,131,1)
 pal(8,142,1)
 pal(11,139,1)
 cls(7)
 pal(6,frame_col)
 pal(7,6)
 rectfill(8,2,119,125,6)
 spr(128,0,0)
 spr(130,120,0)
 spr(134,0,120)
 spr(136,120,120)
 for x=8,112,8 do spr(129,x,0) spr(135,x,120) end
 for y=8,112,8 do spr(131,0,y) spr(133,120,y) end
 pal(0)
 for x=9,29,5 do
  rectfill(x,5,x+1,6,1)
  rectfill(x,9,x+1,10,1)
 end
 for x=98,118,5 do
  rectfill(x,5,x+1,6,1)
  rectfill(x,9,x+1,10,1)
 end
 spr(87,60,4)
end

function inner_screen(x0,y0,x1,y1,bg_col)
 rectfill(x0,y0,x1,y1,1)
 rect(x0+1,y0+1,x1-1,y1-1,6)
 rectfill(x0+2,y0+2,x1-2,y1-2,bg_col or 7)
end

function draw_pet_sprite(x,y,state)
 sspr(state*24,0,24,24,x,y)
end

function current_pet_state()
 if pet.eating_t>0 then return 4 end
 if pet.sleeping_t>0 then return 3 end
 if pet.hunger>75 or pet.happy<35 then return 2 end
 if pet.happy>80 then return 0 end
 return 1
end

function number_text(v)
 v=flr(v)
 if v>9999 then return flr(v/1000).."k" end
 return tostr(v)
end

function right_number(v,x,y,c)
 local txt=number_text(v)
 print(txt,x-#txt*4+1,y,c)
end

function notice()
 if msg=="" then return end
 rectfill(9,90,118,101,1)
 rect(9,90,118,101,6)
 print(msg,64-#msg*2,94,10)
end

function draw_pet_screen()
 device_bezel(3)
 inner_screen(5,15,122,103,15)
 -- Warm wall, baseboard and floor form one continuous room.
 rectfill(7,17,120,65,7)
 rectfill(7,66,120,68,6)
 line(7,66,120,66,15)
 rectfill(7,69,120,78,15)
 line(7,74,120,74,6)
 line(25,70,25,73,6)
 line(88,75,88,78,6)
 spr(160,12,21,4,4)
 spr(164,100,22,2,2)
 spr(98,13,52)
 spr(114,13,60)
 spr(100,99,61)
 spr(101,107,61)
 ovalfill(52,70,76,72,6)
 draw_pet_sprite(52,47+flr(time()*2)%2,current_pet_state())
 spr(80,11,81)
 draw_bar(25,82,70,5,full(),11)
 right_number(full(),115,83,1)
 spr(81,11,93)
 draw_bar(25,94,70,5,pet.happy,10)
 right_number(pet.happy,115,95,1)
 notice()
 draw_nav(menu_i)
end

function draw_lines_screen()
 device_bezel(13)
 -- Restore vivid green for the puzzle without changing the room palette.
 pal(11,11,1)
 inner_screen(5,15,82,103,15)
 inner_screen(85,15,122,103,1)
 -- Equal 9px cells: 8px interior and one thin shared separator.
 rectfill(ox,oy,ox+71,oy+71,15)
 for y=1,bs do
  for x=1,bs do
   local px=ox+(x-1)*cs
   local py=oy+(y-1)*cs
   rectfill(px,py,px+7,py+7,7)
   local i=idx(x,y)
   if b[i]>0 then
    local by=py
    if i==sel then by-=abs(flr(sin(time()*4)*2)) end
    if clearing_cell(i) and clear_timer%4<2 then
     for c=1,15 do pal(c,7) end
    end
    spr(ball_sprs[b[i]],px,by)
    pal(0)
   end
  end
 end
 if clear_timer>0 then draw_clear_particles() end
 local x=ox+(cx-1)*cs
 local y=oy+(cy-1)*cs
 -- Corner focus does not obscure the ball face.
 for d=0,2 do
  pset(x+d,y,1) pset(x,y+d,1)
  pset(x+7-d,y+7,1) pset(x+7,y+7-d,1)
 end
 if sel>0 then
  local sx,sy=xy(sel)
  rect(ox+(sx-1)*cs-1,oy+(sy-1)*cs-1,
       ox+(sx-1)*cs+8,oy+(sy-1)*cs+8,10)
 end
 spr(67,90,20)
 right_number(score,118,22,7)
 line(89,31,118,31,5)
 spr(80,89,35)
 draw_bar(100,36,17,4,full(),11)
 spr(81,89,46)
 draw_bar(100,47,17,4,pet.happy,10)
 inner_screen(89,54,118,82,7)
 draw_pet_sprite(92,56,sel>0 and 4 or current_pet_state())
 print("next",96,85,6)
 -- One shared tray, equal 2px gaps and margins; no contact with the bezel.
 rectfill(88,92,119,101,15)
 rectfill(89,93,118,100,7)
 for k=1,3 do
  spr(ball_sprs[next_balls[k]],90+(k-1)*10,93)
 end
 if hints_on then
  panel(6,106,81,121,1,6)
  spr(69,10,110)
  print("move",21,112,6)
  spr(70,42,110)
  print("o pick",53,112,7)
  panel(85,106,121,121,1,6)
  print("x exit",91,112,7)
 end
 if quit_confirm then
  inner_screen(10,43,117,73,1)
  print("quit game?",44,50,7)
  print("o yes    x no",38,62,10)
 else
  notice()
 end
end

function draw_clear_particles()
 local phase=10-clear_timer
 for item in all(clear_cells) do
  local x,y=xy(item.i)
  local px=ox+(x-1)*cs+3
  local py=oy+(y-1)*cs+3
  local d=1+flr(phase/3)
  pset(px-d,py,7) pset(px+d,py,10)
  pset(px,py-d,7) pset(px,py+d,10)
 end
end

function draw_stats_screen()
 device_bezel(8)
 inner_screen(5,15,86,103,1)
 inner_screen(8,18,37,46,7)
 draw_pet_sprite(11,20,current_pet_state())
 print("lv "..pet.level,42,21,7)
 draw_bar(42,30,38,4,pet.exp/pet.max_exp*100,14)
 print(number_text(pet.exp).."/"..number_text(pet.max_exp),42,38,6)
 print(pet_stage(),42,46,14)
 local vals={full(),pet.happy,total_lines,games_played}
 local labels={"full","mood","lines","games"}
 local cols={11,10,14,12}
 for i=1,4 do
  local y=53+(i-1)*12
  spr(79+i,10,y)
  print(labels[i],22,y+2,cols[i])
  right_number(vals[i],80,y+2,7)
 end
 inner_screen(89,15,122,42,1)
 if stats_i==0 then rect(89,15,122,42,10) end
 spr(84,94,20)
 right_number(pet.tomatoes,117,31,7)
 panel(89,46,122,73,1,stats_i==1 and 10 or 6)
 spr(85,102,50)
 print(pet.toilet_ok and "clean" or "use",96,63,12)
 panel(89,77,122,103,1,stats_i==2 and 10 or 6)
 spr(86,101,82)
 print((pet.sleeping_t>0 and "+" or "")..pet.energy.."%",96,95,10)
 notice()
 draw_nav(menu_i)
end

function draw_records_screen()
 device_bezel(11)
 inner_screen(5,15,122,103,1)
 -- Decorative category strip; only local saved records are displayed.
 panel(8,18,43,29,8,6)
 spr(67,22,20)
 print("local records",51,22,7)
 local labels={"best","games","lines","longest"}
 local values={hi_score,games_played,total_lines,best_line}
 local icons={67,65,82,83}
 for i=1,4 do
  local y=35+(i-1)*14
  spr(icons[i],11,y)
  print(labels[i],25,y+2,7)
  right_number(values[i],115,y+2,i==1 and 10 or 7)
  line(10,y+11,117,y+11,5)
 end
 draw_nav(menu_i)
end

function draw_settings_screen()
 device_bezel(13)
 inner_screen(5,15,122,103,1)
 print("settings",12,22,7)
 line(9,31,118,31,5)
 for i=1,2 do
  local y=39+(i-1)*23
  local on=i==1 and sound_on or i==2 and hints_on
  if settings_i==i then rect(9,y-4,118,y+13,10) end
  spr(i==1 and 68 or 69,13,y)
  print(i==1 and "sound" or "hints",27,y+2,7)
  rectfill(95,y,112,y+7,on and 3 or 5)
  rectfill(on and 105 or 96,y+1,on and 111 or 102,y+6,7)
 end
 spr(84,13,88)
 print("saved locally",27,90,6)
 draw_nav(menu_i)
end

function draw_result_screen()
 device_bezel(8)
 inner_screen(8,18,119,104,1)
 print(new_best and "new record!" or result_reason,40,26,10)
 local labels={"score","lines","best","food"}
 local values={score,session_lines,session_best,
               result_reason=="quit" and 0 or flr(session_lines/4)}
 for i=1,4 do
  local y=40+(i-1)*13
  spr(66+i%2,17,y)
  print(labels[i],33,y+2,6)
  right_number(values[i],109,y+2,7)
 end
 line(12,95,115,95,5)
 print("o continue",44,110,7)
end

function draw_nav(active)
 -- Five 22px buttons, 1px gutters, all within x=7..120.
 for i=1,5 do
  local x=7+(i-1)*23
  local on=i==active
  rectfill(x,107,x+21,121,on and 10 or 1)
  rect(x,107,x+21,121,on and 7 or 6)
  line(x+1,120,x+20,120,on and 9 or 5)
  if on then pal(7,1) pal(10,1) end
  spr(63+i,x+7,110)
  pal(0)
 end
end

function panel(x0,y0,x1,y1,fill_col,edge_col)
 rectfill(x0,y0,x1,y1,fill_col)
 rect(x0,y0,x1,y1,edge_col or 5)
end

function draw_bar(x,y,w,h,val,col)
 rectfill(x,y,x+w-1,y+h-1,1)
 local fw=flr((w-2)*clamp(val,0,100)/100)
 if fw>0 then
  rectfill(x+1,y+1,x+fw,y+h-2,col)
  if h>4 then line(x+1,y+1,x+fw,y+1,7) end
 end
end
__gfx__
00000000011000000000000000000000011000000000000000000000011000000000000000000000011000000000000000000000011000000000000000000000
0000000001c10000000000000000000001c10000000000000000000001c10000000000000000000001c10000000000000000000001c100000000000000000000
00000000001c11100000000000000000001c11100000000000000000001c11100000000000000000001c11100000000000000000001c11100000000000000000
0000000111cccc11100000000000000111cccc11100000000000000111cccc11100000000000000111cccc11100000000000000111cccc111000000000000000
0000011cccccccccc11000000000011cccccccccc11000000000011cccccccccc11000000000011cccccccccc11000000000011cccccccccc110000000000000
00001cccccccccccccc1000000001cccccccccccccc1000000001cccccccccccccc1000000001cccccccccccccc1000000001cccccccccccccc1000000000000
0001cccccccccccccccc10000001cccccccccccccccc10000001cccccccccccccccc10000001cccccccccccccccc10000001cccccccccccccccc100000000000
001cccccccccccccccccc100001cccccccccccccccccc100001cccccccccccccccccc100001cccccccccccccccccc100001cccccccccccccccccc10000000000
001ccc777cccccc777ccc100001ccc777cccccc777ccc100001ccc777cccccc777ccc100001cccccccccccccccccc100001ccc777cccccc777ccc10000000000
01ccc77777cccc77777ccc1001ccc77777cccc77777ccc1001ccc77777cccc77777ccc1001cccccccccccccccccccc1001ccc77777cccc77777ccc1000000000
01cc7711177cc7711177cc1001cc7711177cc7711177cc1001cc7711177cc7711177cc1001cccccccccccccccccccc1001cc7711177cc7711177cc1000000000
01cc7711117cc7711117cc1001cc7711117cc7711117cc1001cc7711117cc7711117cc1001ccc1cccc1ccc1cccc1cc1001cc7711117cc7711117cc1000000000
01cc7111117cc7111117cc1001cc7111117cc7111117cc1001cc7111117cc7111117cc1001cccc1111ccccc1111ccc1001cc7111117cc7111117cc1000000000
01cc7111117cc7111117cc1001cc7111117cc7111117cc1001cc7111117cc7111117cc1001cccccccccccccccccccc1001cc7111117cc7111117cc1000000000
01ccc71117cccc71117ccc1001ccc71117cccc71117ccc1001ccc71117cccc71117ccc1001cccccccccccccccccccc1001ccc71117cccc71117ccc1000000000
01cccc777cccccc777cccc1001cccc777cccccc777cccc1001cccc777cccccc777cccc1001cccccccccccccccccccc1001cccc777cccccc777cccc1000000000
001cccccccccccccccccc100001cccccccccccccccccc100001cccccccccccccccccc100001cccccccccccccccccc100001cccccccccccccccccc10000000000
001cdccccc1111ccccccc100001cdccccc1111ccccccc100001cdcccccc11cccccccc100001cdcccccc11cccccccc100001cdcccc111111cccccc10000000000
0001cdccccc81ccccccc10000001cdccccc81ccccccc10000001cdcccc1771cccccc10000001cdcccc1cc1cccccc10000001cdcccc1881cccccc100000000000
00001cdccccccccccdc1000000001cdccccccccccdc1000000001cdccc1111cccdc1000000001cdccccccccccdc1000000001cdcccc11ccccdc1000000000000
000001cddccccccddc100000000001cddccccccddc100000000001cddccccccddc100000000001cddccccccddc100000000001cddccccccddc10000000000000
00000011cddddddc1100000000000011cddddddc1100000000000011cddddddc1100000000000011cddddddc1100000000000011cddddddc1100000000000000
00000000111111110000000000000000111111110000000000000000111111110000000000000000111111110000000000000000111111110000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00bbbb0000cccc0000eeee0000aaaa0000dddd000077770000888800777777760aaaaaa000000000000000000000000000000000000000000000000000000000
0b77bbb00c77ccc00e77eee00a77aaa00d77ddd007777770087788807ffffff6a000000a00000000000000000000000000000000000000000000000000000000
b7bbbbb3c7ccccc1e7eeeee2a7aaaaa9d7ddddd277777776878888827ffffff6a000000a00000000000000000000000000000000000000000000000000000000
bbbbbbb3ccccccc1eeeeeee2aaaaaaa9ddddddd277777776888888827ffffff6a000000a00000000000000000000000000000000000000000000000000000000
bbbbbbb3ccccccc1eeeeeee2aaaaaaa9ddddddd277777776888888827ffffff6a000000a00000000000000000000000000000000000000000000000000000000
bbbbbb33cccccc11eeeeee22aaaaaa99dddddd2277777766888888227ffffff6a000000a00000000000000000000000000000000000000000000000000000000
03bbb33001ccc11002eee22009aaa99002ddd22006777660028882207ffffff6a000000a00000000000000000000000000000000000000000000000000000000
00333300001111000022220000999900002222000066660000222200666666660aaaaaa000000000000000000000000000000000000000000000000000000000
00077000770770770000007707777770000770000007700000088000700000070000000000000000000000000000000000000000000000000000000000000000
00777700770770770000007777aaaa77070770700007700000888800070000700000000000000000000000000000000000000000000000000000000000000000
07777770000000000007707770aaaa0700777700000770000b0880c0007007000000000000000000000000000000000000000000000000000000000000000000
777777777707707700077077077aa7707770077777777777bbb00ccc000770000000000000000000000000000000000000000000000000000000000000000000
077777707707707777077077000aa00077700777777777770b0aa0c0000770000000000000000000000000000000000000000000000000000000000000000000
07700770000000007707707700077000007777000007700000aaaa00007007000000000000000000000000000000000000000000000000000000000000000000
077007707707707777077077007777000707707000077000000aa000070000700000000000000000000000000000000000000000000000000000000000000000
07700770770770777707707707777770000770000007700000000000700000070000000000000000000000000000000000000000000000000000000000000000
0110011000111100000110000001100000033000011111000001100a011001100000000000000000000000000000000000000000000000000000000000000000
1bb11bb101aaaa100001a100001cc100003bb30001777100001aa1001ee11ee10000000000000000000000000000000000000000000000000000000000000000
1b7bbbb11a1aa1a11111a11101cccc10018888100177710001aa10001eeeeee10000000000000000000000000000000000000000000000000000000000000000
1bbbbbb11aaaaaa101aaaa101cccccc1188788811177711001aa100a01eeee100000000000000000000000000000000000000000000000000000000000000000
01bbbb101a1aa1a1001aa10001cccc10188888811cc77cc101aa1000001ee1000000000000000000000000000000000000000000000000000000000000000000
001bb1001aa11aa101a11a10001cc1001888888101cccc10001aa100000110000000000000000000000000000000000000000000000000000000000000000000
0001100001aaaa100110011000011000018888100017710000011000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001111000000000000000000001111000111111000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444000b000044444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4cccccc44cccccc400bbb00047777774011001100110011000000000000000000000000000000000000000000000000000000000000000000000000000000000
4ccaacc44c77ccc40bb3bb004711717401c1018101b101a100000000000000000000000000000000000000000000000000000000000000000000000000000000
4caaaac447777cc403b33b0041ee1ee401c1018101b101a100000000000000000000000000000000000000000000000000000000000000000000000000000000
4ccaacc44cccccc400b33b0041eeee1401c1018101b101a100000000000000000000000000000000000000000000000000000000000000000000000000000000
4cccccc44cccccc40bb3bb00471ee17401c1018101b101a100000000000000000000000000000000000000000000000000000000000000000000000000000000
4cccccc44cccccc400bbb00047711774444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444000b000044444444040000400400004000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444440499994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4cccccc44cccccc40499994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4cccccc44cccccc40049940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4cc33cc44cccccc40049940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4c3333c44cc33cc40444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
433333344c3333c40040040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
43333334433333340040040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444440040040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055555555555555555500057666666666666666666667557666666666666666666667500000000000000000000000000000000000000000000000000000000
00577777777777777777750057666666666666666666667557666666666666666666667500000000000000000000000000000000000000000000000000000000
05766666666666666666675057666666666666666666667557666666666666666666667500000000000000000000000000000000000000000000000000000000
57666666666666666666667557666666666666666666667557666666666666666666667500000000000000000000000000000000000000000000000000000000
57666666666666666666667557666666666666666666667557666666666666666666667500000000000000000000000000000000000000000000000000000000
57666666666666666666667557666666666666666666667505766666666666666666675000000000000000000000000000000000000000000000000000000000
57666666666666666666667557666666666666666666667500555555555555555555550000000000000000000000000000000000000000000000000000000000
57666666666666666666667557666666666666666666667500055555555555555555500000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444000000044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4ffffffffffffffffffffffffffffff40000004ff400000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fccccccccccccc44cccccccccccccf4000004ffff40000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fccccccccccccc44cccccccccccccf4044444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fccccccccccccc44cccccccccccccf404ffffffffffff4000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fccccccccccccc44cccccccccccccf404f7777777777f4000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fcccc777cccccc44ccccaaaccccccf404f7777777777f4000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fccc77777ccccc44cccaaaaacccccf404f77ee77ee77f4000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fcc7777777cccc44ccaaaaaaaccccf404f7eeeeeeee7f4000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fccccccccccccc44ccaaaaaaaccccf404f7eeeeeeee7f4000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fccccccccccccc44cccaaaaacccccf404f77eeeeee77f4000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fccccccccccccc44ccccaaaccccccf404f777eeee777f4000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fccccccccccccc44cccccccccccccf404f7777ee7777f4000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fccccccccccccc44cccccccccccccf404f7777777777f4000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fccccccccccccc44cccccccccccccf404ffffffffffff4000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fccccccccccccc44cccccccccccccf4044444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000
4ffffffffffffffffffffffffffffff4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4ffffffffffffffffffffffffffffff4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fccccccccccccc44cccccccccccccf4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fccccccccccccc44cccccccccccccf4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fccccccccccccc44ccccc33ccccccf4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fcccc33ccccccc44cccc3bb3cccccf4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fccc3bb3cccccc44ccc3bbbb3ccccf4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fcc3bbbb3ccccc44cc3bbbbbb3cccf4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fc3bbbbbb3cccc44c3bbbbbbbb3ccf4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fcbbbbbbbb3333443bbbbbbbbbb3cf4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fcbbbbbbbbbbbb44bbbbbbbbbbbbcf4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fc33333333333344333333333333cf4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fc33333333333344333333333333cf4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4fccccccccccccc44cccccccccccccf4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4ffffffffffffffffffffffffffffff4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00040000182301c220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001a2401f240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000143400f340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000182501c2501f2502425028250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000e6400b640106400c63000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fff55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff611dfffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1cc1fffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1cccfffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff61ccfffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff61cfffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff11111cfffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff11dcccccfffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1ccccccccfffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffff51cccccccccfffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665fffffffffffffffffffffffffffffffffffffffffffffffffffffffd1ccccccccccfffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665fffffffffffffffffffffffffffffffffffffffffffffffffffffff1cccccccccccfffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffd1cccccccccccfffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffff1ccc777777cccfffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665fffffffffffffffffffffffffffffffffffffffffffffffffffffd1cc77d11177ccfffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffd1cc677d61117ccfffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffd1cc7717751117cfffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffff1ccc7717711117cfffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffff3ccc7711111117cfffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff566665ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff566665fff
fff56666555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555566665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666655555556555555565555555655555556555555565555555655555556555555566666666666666666666666666666666666666666665fff
fff56666666666666656666656566666565666665656666656566666565666665656666656566666566666666666666666666666666666666666666666665fff
fff56666666666666656bbbb56566666565666665656666656566666565666665656666656566666566666666666666666666666666666666666666666665fff
fff56666666666666656bbbb56566666565666665656666656566666565666665656666656566666566666666666666666666666666666666666666666665fff
fff56666666666666655bbbb56555555565555555655555556555555565555555655555556555555566666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666655555556555555565555555655555556555555565555555655555556555555566666666666666666666666666666666666666666665fff
fff56666666666666656666656566666565666665656666656566666565666665656666656566666566666666666666666666666666666666666666666665fff
fff56666666666666656666656566666565666665656cccc56566666565666665656666656566666566666666666666666666666666666666666666666665fff
fff56666666666666656666656566666565666665656cccc56566666565666665656666656566666566666666666666666666666666666666666666666665fff
fff56666666666666655555556555555565555555655cccc56555555565555555655555556555555566666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666655555556555555565555555655555556555555565555555655555556555555566666666666666666666666666666666666666666665fff
fff56666666666666656666656566666565666665656666656566666565666665656666656566666566666666666666666666666666666666666666666665fff
fff56666666666666656666656566666565666665656666656566666565688885656666656566666566666666666666666666666666666666666666666665fff
fff56666666666666656666656566666565666665656666656566666565688885656666656566666566666666666666666666666666666666666666666665fff
fff56666666666666655555556555555565555555655555556555555565588885655555556555555566666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666655555556555555565555555655555556555555565555555655555556555555566666666666666666666666666666666666666666665fff
fff56666666666666656666656566666565666665656666656566666565666665656666656566666566666666666666666666666666666666666666666665fff
fff566666666666666566666565666665656aaaa5656666656566666565666665656666656566666566666666666666666666666666666666666666666665fff
fff566666666666666566666565666665656aaaa5656666656566666565666665656666656566666566666666666666666666666666666666666666666665fff
fff566666666666666555555565555555655aaaa5655555556555555565555555655555556555555566666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666655555556555555565555555655555556555555565555555655555556555555566666666666666666666666666666666666666666665fff
fff56666666666666656666656566666565666665656666656566666565666665656666656566666566666666666666666666666666666666666666666665fff
fff56666666666666656666656566666565666665656666656566666565666665656666656566666566666666666666666666666666666666666666666665fff
fff56666666666666656666656566666565666665656666656566666565666665656666656566666566666666666666666666666666666666666666666665fff
fff56666666666666655555556555555565555555655555556555555565555555655555556555555566666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff56666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666665fff
fff55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555fff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
