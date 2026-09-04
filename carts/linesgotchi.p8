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
ox=7
oy=18
colors={11,12,14,10,13}
ball_sprs={48,49,50,51,52}
dxs={1,0,1,1}
dys={0,1,1,-1}

-- gotchi state
pet={
 hunger=15,
 happy=55,
 health=100,
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
  if pet.sleeping_t==0 then pet.sleep_ready=true end
  update_weight_health()
  save_state()
 end
 if pet.eating_t>0 then pet.eating_t-=1 end
 if pet.sleeping_t>0 then pet.sleeping_t-=1 end
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
 if btnp(0) then menu_i=max(1,menu_i-1) play_sound(0) end
 if btnp(1) then menu_i=min(5,menu_i+1) play_sound(0) end
 if btnp(4) then
  open_menu()
 end
 if btnp(5) then feed_pet() end
end

function open_menu()
 if menu_i==1 then show_pet()
 elseif menu_i==2 then start_lines()
 elseif menu_i==3 then scr=s_stats
 elseif menu_i==4 then scr=s_records
 elseif menu_i==5 then scr=s_settings
 end
end

function feed_pet()
 if pet.eating_t>0 then
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
 if moves%3==0 then
  pet.happy=clamp(pet.happy+1,0,100)
  pet.hunger=clamp(pet.hunger+1,0,100)
 end
 if moves%8==0 and pet.weight>5 then
  pet.weight-=1
 end
 update_weight_health()
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
 if btnp(2) then stats_i=max(1,stats_i-1) play_sound(0) end
 if btnp(3) then stats_i=min(2,stats_i+1) play_sound(0) end
 if btnp(0) then menu_i=max(1,menu_i-1) play_sound(0) end
 if btnp(1) then menu_i=min(5,menu_i+1) play_sound(0) end
 if btnp(4) then
  if menu_i~=3 then open_menu()
  elseif stats_i==1 then use_toilet()
  else put_pet_to_sleep() end
 end
 if btnp(5) then show_pet() end
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
 if pet.sleeping_t>0 then
  set_msg("already asleep",30)
 elseif not pet.sleep_ready then
  set_msg("already rested",30)
 else
  pet.sleeping_t=180
  pet.sleep_ready=false
  pet.health=clamp(pet.health+8,0,100)
  pet.happy=clamp(pet.happy+2,0,100)
  pet.hunger=clamp(pet.hunger+2,0,100)
  set_msg("sweet dreams",45)
  save_state()
  play_sound(1)
 end
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
 cls(15)
 pal(6,frame_col)
 rectfill(8,8,119,119,6)
 spr(128,0,0)
 spr(130,120,0)
 spr(134,0,120)
 spr(136,120,120)
 for x=8,112,8 do
  spr(129,x,0)
  spr(135,x,120)
 end
 for y=8,112,8 do
  spr(131,0,y)
  spr(133,120,y)
 end
 pal()

 -- Top speaker grill dots
 for x=8,24,4 do
  pset(x,5,1); pset(x,7,1)
 end
 for x=103,119,4 do
  pset(x,5,1); pset(x,7,1)
 end

 -- Top center decorative heart
 spr(87,60,3)
end

function inner_screen(x0,y0,x1,y1,bg_col)
 rectfill(x0,y0,x1,y1,bg_col or 7)
 rect(x0,y0,x1,y1,5)
 rect(x0+1,y0+1,x1-1,y1-1,1)
end

function draw_pet_sprite(x,y,state)
 -- State: 0:happy, 1:neutral, 2:hungry, 3:sleepy, 4:excited
 local sx=state*24
 sspr(sx,0,24,24,x,y)
end

function current_pet_state()
 if pet.eating_t>0 then return 4 end -- excited/chewing
 if pet.sleeping_t>0 then return 3 end
 if pet.hunger>75 then return 2 end -- hungry
 if pet.happy<35 then return 2 end -- sad
 if pet.happy>80 then return 0 end -- happy
 return 1 -- neutral
end

-- ---------------------------------------------------------------------
-- 1. SCREEN: PET ROOM (Teal Bezel)
-- ---------------------------------------------------------------------
function draw_pet_screen()
 device_bezel(3) -- Teal / Dark Green
 inner_screen(5,13,122,103,7) -- Cream room background

 -- Window (sprites 96,97,112,113)
 spr(96,12,18); spr(97,20,18)
 spr(112,12,26); spr(113,20,26)

 -- Potted plant on stool (sprites 98,114)
 spr(98,12,42)
 spr(114,12,50)

 -- Heart picture frame (sprite 99)
 spr(99,102,18)

 -- Bookshelf with books (sprites 100,101)
 spr(100,98,48); spr(101,106,48)

 -- Floor divider line & warm baseboard floor
 rectfill(6,68,121,102,15)
 line(6,66,121,66,15)
 line(6,67,121,67,5)

 -- Pet in center with gentle idle breath/bob animation
 local bob=flr(time()*2)%2
 local state=current_pet_state()
 draw_pet_sprite(52,38+bob,state)

 -- Status Bars
 -- Fullness (Hunger): Green heart + bar + value
 spr(80,10,75)
 draw_bar(24,77,72,5,full(),11)
 print(full(),102,76,1)

 -- Happiness (Mood): Yellow smiley + bar + value
 spr(81,10,88)
 draw_bar(24,90,72,5,pet.happy,10)
 print(pet.happy,102,89,1)

 if msg~="" then
  rectfill(40,24,88,34,1)
  rect(40,24,88,34,7)
  print(msg,44,26,10)
 end

 draw_nav(menu_i)
end

-- ---------------------------------------------------------------------
-- 2. SCREEN: PLAY LINES (Purple Bezel)
-- ---------------------------------------------------------------------
function draw_lines_screen()
 device_bezel(13) -- Purple
 inner_screen(5,13,81,103,7)  -- Board panel
 inner_screen(84,13,122,103,1) -- Right info panel

 -- 8x8 Board
 for y=1,bs do
  for x=1,bs do
   local px=ox+(x-1)*cs
   local py=oy+(y-1)*cs
   spr(55,px,py) -- Clean 8x8 cell
   local i=idx(x,y)
   if b[i]>0 then
    local sid=ball_sprs[b[i]]
    local by=py
    if i==sel then
     by+=flr(sin(time()*4)*2)
    end
    if clearing_cell(i) and clear_timer%4<2 then
     pal(b[i],7)
     spr(sid,px,by)
     pal()
    else
     spr(sid,px,by) -- Pixel-perfect 8x8 ball 1:1
    end
   end
  end
 end

 if clear_timer>0 then draw_clear_particles() end

 -- Active Cursor
 local cp_x=ox+(cx-1)*cs
 local cp_y=oy+(cy-1)*cs
 rect(cp_x-1,cp_y-1,cp_x+8,cp_y+8,10)
 rect(cp_x,cp_y,cp_x+7,cp_y+7,7)

 -- Right Info Panel
 -- Trophy + Score
 spr(67,87,18)
 print(score,99,20,7)

 -- Heart + mini bar + 85
 spr(80,87,29)
 draw_bar(97,31,11,4,full(),11)
 print(full(),110,30,11)

 -- Smiley + mini bar + 55
 spr(81,87,40)
 draw_bar(97,42,11,4,pet.happy,10)
 print(pet.happy,110,41,10)

 -- Mini pet box
 rectfill(89,52,117,78,7)
 rect(89,52,117,78,5)
 local pet_face=game_over and 2 or (sel>0 and 4 or current_pet_state())
 draw_pet_sprite(91,53,pet_face)

 -- Next Balls Preview
 rectfill(87,83,119,100,5)
 rect(87,83,119,100,1)
 print("next",88,84,6)
 for k=1,#next_balls do
  spr(ball_sprs[next_balls[k]],88+(k-1)*11,91)
 end

 if hints_on then
  panel(5,106,81,122,1,5)
  print("+move",8,112,6)
  print("o:act",46,112,7)
  panel(84,106,122,122,1,5)
  print("x:exit",91,112,7)
 end

 if quit_confirm then
  rectfill(20,40,108,70,1)
  rect(20,40,108,70,10)
  print("quit game?",36,46,7)
  print("o: yes    x: no",28,58,10)
 elseif msg~="" then
  rectfill(18,22,70,32,1)
  rect(18,22,70,32,7)
  print(msg,22,24,10)
 end
end

function draw_clear_particles()
 local phase=10-clear_timer
 for item in all(clear_cells) do
  local x,y=xy(item.i)
  local px=ox+(x-1)*cs+3
  local py=oy+(y-1)*cs+3
  local d=1+flr(phase/3)
  pset(px-d,py,7)
  pset(px+d,py,10)
  pset(px,py-d,7)
  pset(px,py+d,10)
 end
end

-- ---------------------------------------------------------------------
-- 3. SCREEN: STATS (Coral / Pink Bezel)
-- ---------------------------------------------------------------------
function draw_stats_screen()
 device_bezel(14) -- Coral / Pink
 inner_screen(5,13,122,103,1)

 -- Top Left: Pet Box + Level
 rectfill(8,16,36,44,7)
 rect(8,16,36,44,5)
 draw_pet_sprite(10,18,0)

 print("lv 0"..pet.level,42,17,7)
 print(pet_stage(),42,41,14)
 draw_bar(42,26,45,5,flr((pet.exp/pet.max_exp)*100),14)
 print(pet.exp.."/"..pet.max_exp,44,34,6)

 -- Top Right: Tomato counter
 spr(84,94,18)
 print("x"..pet.tomatoes,104,20,7)

 line(8,47,119,47,5)

 -- Stats Rows with Icons
 spr(80,9,51)  print("full",21,52,11) print(full(),58,52,7)   print("/100",70,52,6)
 spr(81,9,63)  print("good",21,64,10) print(pet.happy,58,64,7) print("/100",70,64,6)
 spr(82,9,75)  print("play",21,76,14) print(total_lines,58,76,7)
 spr(83,9,87)  print("wins",21,88,12) print(games_played,58,88,7)

 -- Right Box: Toilet & Sleep status
 panel(91,51,119,73,5,stats_i==1 and 10 or 1)
 spr(85,93,55)
 print(pet.toilet_ok and "ok!" or "use",104,57,pet.toilet_ok and 12 or 10)

 panel(91,76,119,98,5,stats_i==2 and 10 or 1)
 spr(86,93,82)
 print(pet.sleeping_t>0 and "zzz" or "nap",104,83,10)

 print("hp "..pet.health,92,69,11)

 if msg~="" then
  rectfill(35,93,87,101,1)
  print(msg,38,95,10)
 end

 draw_nav(menu_i)
end

-- ---------------------------------------------------------------------
-- 4. SCREEN: RECORDS (Green Bezel)
-- ---------------------------------------------------------------------
function draw_records_screen()
 device_bezel(11) -- Green Bezel
 inner_screen(5,13,122,103,1)

 -- Tabs at top
 rectfill(8,15,44,26,10)
 rect(8,15,44,26,5)
 spr(67,22,17) -- Trophy

 rectfill(46,15,82,26,5)
 rect(46,15,82,26,1)
 spr(66,60,17) -- Bars

 rectfill(84,15,119,26,5)
 rect(84,15,119,26,1)
 spr(65,98,17) -- Grid

 line(8,27,119,27,5)

 -- Leaderboard rows
 record_row(1,"las",2340,32,10,12)
 record_row(2,"pico",1820,44,7,14)
 record_row(3,"gotchi",1450,56,9,11)
 record_row(4,"byte",980,68,5,13)
 record_row(5,"you",hi_score,80,14,10)

 draw_nav(menu_i)
end

function record_row(rank,name,score_val,y,badge_col,avatar_col)
 -- Medal/Rank badge
 rectfill(9,y,17,y+8,badge_col)
 rect(9,y,17,y+8,5)
 print(rank,12,y+1,0)

 -- Face avatar
 rectfill(21,y,29,y+8,avatar_col)
 rect(21,y,29,y+8,5)
 print("..",23,y+1,0)

 -- Name & Score
 local is_you=rank==5
 local txt_col=is_you and 14 or 7
 print(name,34,y+2,txt_col)
 print(score_val,88,y+2,txt_col)
end

-- ---------------------------------------------------------------------
-- 5. SCREEN: SETTINGS
-- ---------------------------------------------------------------------
function draw_settings_screen()
 device_bezel(5) -- Dark Gray Bezel
 inner_screen(5,13,122,103,1)

 print("settings",10,18,7)
 line(8,26,119,26,5)

 spr(68,12,36)
 print("sound",26,38,7)
 print(sound_on and "on" or "off",96,38,sound_on and 11 or 8)
 if settings_i==1 then rect(8,32,116,48,10) end

 spr(69,12,54)
 print("hints",26,56,7)
 print(hints_on and "on" or "off",96,56,hints_on and 11 or 8)
 if settings_i==2 then rect(8,50,116,66,10) end

 spr(84,12,72)
 print("data",26,74,7)
 print("saved",88,74,10)

 print("up/down  o toggle",24,91,6)

 draw_nav(menu_i)
end

-- ---------------------------------------------------------------------
-- 6. SCREEN: RESULT
-- ---------------------------------------------------------------------
function draw_result_screen()
 device_bezel(8) -- Red Bezel
 inner_screen(12,16,115,102,1)

 if new_best then
  print("new record!",38,22,10)
 else
  print(result_reason,46,22,7)
 end

 spr(67,26,38)
 print("score",44,40,6); print(score,86,40,10)

 spr(65,26,52)
 print("lines",44,54,6); print(session_lines,86,54,10)

 spr(82,26,66)
 print("best",44,68,6); print(session_best,86,68,10)

 spr(84,26,80)
 print("food",44,82,6); print("+"..flr(session_lines/4),86,82,11)

 line(14,92,113,92,5)
 print("press o to continue",24,95,7)
end

-- ---------------------------------------------------------------------
-- UI HELPERS
-- ---------------------------------------------------------------------
function draw_nav(active)
 -- 5 buttons along bottom (x = 6, 29, 52, 75, 98, w = 22, h = 16)
 for i=1,5 do
  local x=6+(i-1)*24
  local is_act=(i==active)
  local bg=is_act and 10 or 1
  local border=is_act and 7 or 5

  rectfill(x,106,x+21,122,bg)
  rect(x,106,x+21,122,border)
  rect(x+1,107,x+20,121,is_act and 9 or 0)

  -- Draw icon (sprites 64..68)
  local sid=63+i
  if is_act then
   -- Draw dark icon on bright yellow
   pal(7,1)
   spr(sid,x+7,110)
   pal()
  else
   spr(sid,x+7,110)
  end
 end
end

function panel(x0,y0,x1,y1,fill_col,edge_col)
 rectfill(x0,y0,x1,y1,fill_col)
 rect(x0,y0,x1,y1,edge_col or 5)
end

function draw_bar(x,y,w,h,val,col)
 val=clamp(val,0,100)
 rectfill(x,y,x+w,y+h,0)
 rect(x,y,x+w,y+h,5)
 local fw=flr((w-2)*val/100)
 if fw>0 then
  rectfill(x+1,y+1,x+fw,y+h-1,col)
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000110000000000000000000000110000000000000000000000110000000000000000000000110000000000000000000000110000000000000000000
00000000011cc1100000000000000000011cc1100000000000000000011cc1100000000000000000011cc1100000000000000000011cc1100000000000000000
00000001cccccccc1000000000000001cccccccc1000000000000001cccccccc1000000000000001cccccccc1000000000000001cccccccc1000000000000000
000001cccccccccccc100000000001cccccccccccc100000000001cccccccccccc100000000001cccccccccccc100000000001cccccccccccc10000000000000
00001cccccccccccccc1000000001cccccccccccccc1000000001cccccccccccccc1000000001cccccccccccccc1000000001cccccccccccccc1000000000000
0001cccccccccccccccc10000001cccccccccccccccc10000001cccccccccccccccc10000001ccccccccccccccc770000001cccccccccccccccc100000000000
001cccccccccccccccccc100001cccccccccccccccccc100001cccccccccccccccccc100001cccccccccccccccc7c100001cc17711cccc17711cc10000000000
001cc17711cccc17711cc100001cc17711cccc17711cc100001cccccccccccccccccc100001ccccccccccccccccc7100001cc17711cccc17711cc10000000000
001cc17711cccc17711cc100001cc17711cccc17711cc100001cc17711cccc17711cc100001cccccccccccccccccc100001cc11111cccc11111cc10000000000
001cc11111cccc11111cc100001cc11111cccc11111cc100001cc17711cccc17711cc100001cc1ccc1cccc1ccc1cc100001cc11171cccc11171cc10000000000
001cc11171cccc11171cc100001cc11171cccc11171cc100001cc11111cccc11111cc100001ccc111cccccc111ccc100001cc11111cccc11111cc10000000000
1cccc11111cccc11111cccc11cccc11111cccc11111cccc11cccc11111cccc11111cccc11cccccccccccccccccccccc11ccceecccc1111cccceeccc100000000
1ccccccccc1881ccccccccc11cccccccccc11cccccccccc11cccc11111cccc11111cccc11cccccccccccccccccccccc11ccccccccc1881ccccccccc100000000
01ccccccccc88ccccccccc1001cccccccccccccccccccc1001cccccccc1111cccccccc1001ccccccccc11ccccccccc1001cccccccc1e81cccccccc1000000000
001dddddddd11dddddddd100001dddddddddddddddddd100001ddddddd1881ddddddd100001dddddddddddddddddd100001ddddddd1111ddddddd10000000000
001dddddddddddddddddd100001dddddddddddddddddd100001ddddddd1111ddddddd100001dddddddddddddddddd100001dddddddddddddddddd10000000000
00011111111111111111100000011111111111111111100000011111111111111111100000011111111111111111100000011111111111111111100000000000
00001111111111111111000000001111111111111111000000001111111111111111000000001111111111111111000000001111111111111111000000000000
00000011111111111100000000000011111111111100000000000011111111111100000000000011111111111100000000000011111111111100000000000000
0000001d10000001d10000000000001d10000001d10000000000001d10000001d10000000000001d10000001d10000000000001d10000001d100000000000000
00000001000000001000000000000001000000001000000000000001000000001000000000000001000000001000000000000001000000001000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111100001111000011110000111100001111000055550000111100777777760aaaaaa000000000000000000000000000000000000000000000000000000000
01bbbb1001cccc1001eeee1001aaaa1001dddd1005777750018888107ffffff6a000000a00000000000000000000000000000000000000000000000000000000
17bbb31017ccc11017eee21017aaa91017ddd21057777650178882107ffffff6a000000a00000000000000000000000000000000000000000000000000000000
1bbbbb101ccccc101eeeee101aaaaa101ddddd1057777750188888107ffffff6a000000a00000000000000000000000000000000000000000000000000000000
1bbbbb101ccccc101eeeee101aaaaa101ddddd1057777750188888107ffffff6a000000a00000000000000000000000000000000000000000000000000000000
1b3333101c1111101e2222101a9999101d22221057666650182222107ffffff6a000000a00000000000000000000000000000000000000000000000000000000
013333100111111001222210019999100122221005666650012222107ffffff6a000000a00000000000000000000000000000000000000000000000000000000
00111100001111000011110000111100001111000055550000111100666666660aaaaaa000000000000000000000000000000000000000000000000000000000
00011000111111110000000001111110001111000001100000088000110000110000000000000000000000000000000000000000000000000000000000000000
0017710017171711000011001aaaaaa1017117100001710000888800011001100000000000000000000000000000000000000000000000000000000000000000
01777710111111110000171011aaaa1117177171111171110b0000a0001111000000000000000000000000000000000000000000000000000000000000000000
177777711717171100111710011aa1101170071117777771bbb00aaa000110000000000000000000000000000000000000000000000000000000000000000000
1771177111111111017117100001100011700711111171110b0000a0001111000000000000000000000000000000000000000000000000000000000000000000
17711771171717110171171100011000171771710001710000cc1100011001100000000000000000000000000000000000000000000000000000000000000000
177117711111111101711717001aa100017117100001100000011000110000110000000000000000000000000000000000000000000000000000000000000000
11111111000000001111111101111110001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
