pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- linesgotchi
-- fantasy console virtual pet & color lines

-- screens
s_pet=0
s_lines=1
s_result=2

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
care_mode=0
care_choice=1
status_page=1
attention_lit=false

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
 age_progress=0,
 poop=0,
 sick=false,
 medicine_left=0,
 lights_on=true,
 false_call=false,
 care_mistakes=0,
 care_ticks=0,
 need_ticks=0,
 dead=false,
 species=1,
 egg_t=0
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
  advance_care()
  save_state()
 end
 if pet.eating_t>0 then pet.eating_t-=1 end
 if pet.egg_t>0 then
  pet.egg_t-=1
  if pet.egg_t==0 then set_msg("hello!",45) save_state() end
 end
 update_sleep()
 if msg_timer>0 then
  msg_timer-=1
  if msg_timer==0 then msg="" end
 end

 if scr==s_pet then update_pet()
 elseif scr==s_lines then update_lines()
 elseif scr==s_result then update_result()
 end
end

function _draw()
 cls(1)
 if scr==s_pet then draw_pet_screen()
 elseif scr==s_lines then draw_lines_screen()
 elseif scr==s_result then draw_result_screen()
 end
end

function show_pet()
 scr=s_pet
 menu_i=1
 care_mode=0
 care_choice=1
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
  if dget(31)==1 then
   pet.poop=clamp(flr(dget(24)),0,3)
   pet.sick=dget(25)==1
   pet.medicine_left=clamp(flr(dget(26)),0,3)
   pet.lights_on=dget(27)==1
   pet.false_call=dget(28)==1
   pet.care_mistakes=max(0,flr(dget(29)))
   pet.care_ticks=max(0,flr(dget(30)))
  end
  if dget(36)==1 then
   pet.dead=dget(32)==1
   pet.need_ticks=clamp(flr(dget(33)),0,2)
   pet.species=clamp(flr(dget(34)),1,3)
   pet.egg_t=clamp(flr(dget(35)),0,150)
  end
 end
 attention_lit=attention_needed()
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
 dset(24,pet.poop)
 dset(25,pet.sick and 1 or 0)
 dset(26,pet.medicine_left)
 dset(27,pet.lights_on and 1 or 0)
 dset(28,pet.false_call and 1 or 0)
 dset(29,pet.care_mistakes)
 dset(30,pet.care_ticks)
 dset(31,1)
 dset(32,pet.dead and 1 or 0)
 dset(33,pet.need_ticks)
 dset(34,pet.species)
 dset(35,pet.egg_t)
 dset(36,1)
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

function attention_needed()
 return not pet.dead and pet.egg_t==0 and
  (pet.sick or pet.poop>0 or pet.false_call or
   pet.hunger>=80 or pet.happy<=20 or
   (pet.sleeping_t>0 and pet.lights_on))
end

function refresh_attention()
 local lit=attention_needed()
 if lit and not attention_lit then play_sound(5) end
 attention_lit=lit
end

function advance_care()
 if pet.dead or pet.egg_t>0 then return end
 pet.care_ticks+=1
 pet.hunger=clamp(pet.hunger+2,0,100)
 if pet.care_ticks%2==0 then
  pet.happy=clamp(pet.happy-1,0,100)
 end
 if pet.sleeping_t==0 then
  pet.energy=max(0,pet.energy-2)
 end
 if pet.care_ticks%6==0 then
  pet.poop=min(3,pet.poop+1)
  pet.toilet_ok=false
 end
 if pet.poop>=2 and not pet.sick then
  pet.sick=true
  pet.medicine_left=1+flr(rnd(3))
 end
 if pet.sleeping_t>0 and pet.lights_on then
  pet.happy=max(0,pet.happy-2)
 end
 if attention_needed() then
  pet.need_ticks+=1
  if pet.need_ticks>=3 then
   pet.need_ticks=0
   pet.care_mistakes+=1
   pet.health=max(0,pet.health-2)
  end
 else
  pet.need_ticks=0
  if pet.sleeping_t==0 and pet.care_ticks%9==0 and rnd(1)<0.35 then
   pet.false_call=true
  end
 end
 if pet.sleeping_t==0 and pet.energy<=10 then
  pet.sleeping_t=flr((101-pet.energy)/2)*30
  pet.sleep_ready=false
 end
 if pet.care_ticks%10==0 then
  pet.age+=1
  pet.age_progress=0
  if pet.age==6 then
   pet.species=pet.care_mistakes<=2 and 1 or
               pet.care_mistakes<=6 and 2 or 3
  end
 end
 update_weight_health()
 if pet.sick then pet.health=max(0,pet.health-3) end
 if pet.hunger>=95 then pet.health=max(0,pet.health-2) end
 if pet.health<=0 then
  pet.dead=true
  pet.sleeping_t=0
  pet.eating_t=0
  set_msg("goodbye...",120)
 end
 refresh_attention()
end

function update_pet()
 if pet.egg_t>0 then return end
 if pet.dead then
  if btnp(4) then hatch_pet() end
  return
 end
 if care_mode==0 then
  if btn(5) and btnp(0) then
   sound_on=not sound_on
   set_msg(sound_on and "sound on" or "sound off",40)
   save_state()
   return
  end
  if btnp(0) then menu_i=(menu_i+7)%9+1 play_sound(0) end
  if btnp(1) then menu_i=menu_i%9+1 play_sound(0) end
  if btnp(4) then open_menu() end
 else
  if btnp(5) then care_mode=0 play_sound(1) return end
  if care_mode==3 then
   if btnp(0) then status_page=(status_page+2)%4+1 play_sound(0) end
   if btnp(1) then status_page=status_page%4+1 play_sound(0) end
   if btnp(4) then care_mode=0 end
  else
   if btnp(0) or btnp(1) then care_choice=3-care_choice play_sound(0) end
   if btnp(4) then
    if care_mode==1 then feed_pet(care_choice)
    elseif care_mode==2 then set_light(care_choice==1) end
   end
  end
 end
end

function open_menu()
 care_choice=1
 if menu_i==1 then care_mode=1
 elseif menu_i==2 then care_mode=2
 elseif menu_i==3 then start_lines()
 elseif menu_i==4 then give_medicine()
 elseif menu_i==5 then use_toilet()
 elseif menu_i==6 then care_mode=3 status_page=1
 elseif menu_i==7 then discipline_pet()
 elseif menu_i==8 then care_mode=3 status_page=4
 elseif menu_i==9 then
  sound_on=not sound_on
  set_msg(sound_on and "sound on" or "sound off",40)
  save_state()
 end
end

function feed_pet(kind)
 if pet.sleeping_t>0 then
  set_msg("let me sleep",30)
 elseif pet.eating_t>0 then
  set_msg("still eating",20)
 elseif kind==1 and pet.hunger<=5 then
  set_msg("too full",30)
 elseif kind==2 and pet.happy>=100 then
  set_msg("no snack",30)
 else
  if kind==1 then
   pet.hunger=clamp(pet.hunger-25,0,100)
   pet.weight=clamp(pet.weight+1,1,99)
   set_msg("meal time!",40)
  else
   pet.happy=clamp(pet.happy+15,0,100)
   pet.weight=clamp(pet.weight+2,1,99)
   set_msg("tasty snack!",40)
  end
  pet.eating_t=40
  update_weight_health()
  play_sound(4)
  save_state()
 end
 refresh_attention()
end

function set_light(on)
 pet.lights_on=on
 set_msg(on and "light on" or "light off",35)
 play_sound(1)
 save_state()
 refresh_attention()
end

function give_medicine()
 if not pet.sick then
  set_msg("not sick",35)
  play_sound(2)
 else
  pet.medicine_left=max(0,pet.medicine_left-1)
  if pet.medicine_left==0 then
   pet.sick=false
   pet.health=min(100,pet.health+10)
   set_msg("all better!",45)
  else
   set_msg("one more dose",40)
  end
  play_sound(4)
  save_state()
 end
 refresh_attention()
end

function discipline_pet()
 if pet.false_call then
  pet.false_call=false
  pet.discipline=min(100,pet.discipline+10)
  pet.happy=max(0,pet.happy-2)
  set_msg("good manners",40)
 else
  pet.happy=max(0,pet.happy-5)
  set_msg("no reason!",35)
 end
 play_sound(2)
 save_state()
 refresh_attention()
end

function hatch_pet()
 pet.hunger=15 pet.happy=55 pet.health=100 pet.energy=80
 pet.discipline=0 pet.weight=5 pet.age=0 pet.level=1 pet.exp=0
 pet.poop=0 pet.sick=false pet.medicine_left=0 pet.lights_on=true
 pet.false_call=false pet.care_mistakes=0 pet.care_ticks=0
 pet.need_ticks=0 pet.dead=false pet.sleeping_t=0 pet.eating_t=0
 pet.species=1 pet.egg_t=150 pet.lights_on=true
 set_msg("a new egg!",60)
 save_state()
end

function start_lines()
 if pet.dead or pet.egg_t>0 then set_msg("not ready",40) return end
 if pet.sleeping_t>0 then set_msg("let me sleep",40) return end
 if pet.energy<=0 then set_msg("need sleep",40) return end
 scr=s_lines
 menu_i=3
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
  update_weight_health()
 end

 save_state()
 scr=s_result
end

function update_result()
 if btnp(4) or btnp(5) then show_pet() end
end

function use_toilet()
 if pet.poop<=0 then
  set_msg("no mess",35)
 else
  pet.poop=0
  pet.toilet_ok=true
  pet.happy=clamp(pet.happy+5,0,100)
  set_msg("flush! clean",40)
  save_state()
 end
 play_sound(1)
 refresh_attention()
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
   pet.lights_on=true
   set_msg("fully rested",45)
  end
 end
 refresh_attention()
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
 if pet.age>=6 then return "adult" end
 if pet.age>=3 then return "teen" end
 if pet.age>=1 then return "child" end
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
 ui_print(txt,x-#txt*4+1,y,c)
end

function ui_print(txt,x,y,c)
 print(txt,x+1,y+1,0)
 print(txt,x,y,c)
end

function notice()
 if msg=="" then return end
 rectfill(9,90,118,101,1)
 rect(9,90,118,101,6)
 ui_print(msg,64-#msg*2,94,10)
end

function mono_icon(sid,x,y,selected,ink)
 pal()
 ink=ink or 1
 for c=1,15 do pal(c,ink) end
 spr(sid,x,y)
 pal()
 if selected then
  local sy=y<64 and y+9 or y-2
  line(x,sy,x+7,sy,1)
 end
end

function draw_lcd_pet(x,y)
 pal()
 pal(7,7) pal(12,7) pal(8,1) pal(13,1) pal(14,1)
 draw_pet_sprite(x,y,current_pet_state())
 pal()
 local stage=pet_stage()
 if stage~="baby" then
  line(x+4,y+23,x+7,y+23,1)
  line(x+17,y+23,x+20,y+23,1)
 end
 if stage=="teen" or stage=="adult" then
  line(x-2,y+13,x+1,y+14,1)
  line(x+22,y+14,x+25,y+13,1)
 end
 if stage=="adult" then
  if pet.species==1 then
   line(x+7,y,x+9,y-3,1) line(x+16,y,x+14,y-3,1)
  elseif pet.species==2 then
   rectfill(x-2,y+7,x,y+10,1) rectfill(x+23,y+7,x+25,y+10,1)
  else
   pset(x+5,y-1,1) pset(x+11,y-3,1) pset(x+18,y-1,1)
  end
 end
end

function draw_egg()
 ovalfill(52,43,76,76,6)
 oval(52,43,76,76,1)
 line(54,57,61,53,1) line(61,53,67,59,1)
 line(67,59,74,54,1)
 print("egg",58,80,1)
end

function hearts(value,y)
 local n=clamp(ceil(value/25),0,4)
 for i=1,4 do
  local x=38+(i-1)*14
  if i<=n then
   rectfill(x,y,x+2,y+1,1) rectfill(x+4,y,x+6,y+1,1)
   rectfill(x-1,y+2,x+7,y+3,1)
   rectfill(x,y+4,x+6,y+5,1)
   rectfill(x+1,y+6,x+5,y+6,1)
   rectfill(x+2,y+7,x+4,y+7,1)
  else
   rect(x,y,x+6,y+5,1)
  end
 end
end

function draw_care_view()
 rectfill(2,18,125,110,6)
 if care_mode==1 then
  print("food",56,35,1)
  print((care_choice==1 and ">" or " ").."meal",38,50,1)
  print((care_choice==2 and ">" or " ").."snack",38,64,1)
  print("o:feed  x:back",34,79,1)
 elseif care_mode==2 then
  print("light",54,35,1)
  print((care_choice==1 and ">" or " ").."on",42,50,1)
  print((care_choice==2 and ">" or " ").."off",42,64,1)
  print("o:set   x:back",34,79,1)
 else
  draw_status_page()
 end
end

function draw_status_page()
 if status_page==1 then
  print("hungry",28,37,1) hearts(full(),47)
  print("happy",32,61,1) hearts(pet.happy,71)
 elseif status_page==2 then
  print("discipline",44,37,1)
  hearts(pet.discipline,50)
  print("care misses",39,65,1)
  print(pet.care_mistakes,62,76,1)
 elseif status_page==3 then
  print("age "..pet.age,35,42,1)
  print("weight "..pet.weight,35,55,1)
  print(pet_stage(),48,69,1)
 elseif status_page==4 then
  print("health "..pet.health,32,40,1)
  print("energy "..pet.energy,32,53,1)
  print("best "..number_text(hi_score),32,66,1)
  print("x:back",50,79,1)
 end
end

function draw_pet_screen()
 pal()
 -- Full-screen LCD: the PICO-8 viewport is the pet device screen.
 cls(1)
 rectfill(2,0,125,127,6)
 rectfill(0,2,127,125,6)
 line(2,0,125,0,1) line(2,127,125,127,1)
 line(0,2,0,125,1) line(127,2,127,125,1)
 local xs={8,34,60,86,112}
 local top={84,86,65,83,85}
 local bottom={66,82,67,68,87}
 for i=1,5 do mono_icon(top[i],xs[i],6,care_mode==0 and menu_i==i) end
 for i=1,5 do
  local selected=care_mode==0 and menu_i==i+5 and i<5
  local ink=1
  if i==5 then
   ink=attention_needed() and flr(time()*4)%2==0 and 1 or 5
  end
  mono_icon(bottom[i],xs[i],114,selected,ink)
 end
 if care_mode>0 then
  draw_care_view()
 elseif pet.egg_t>0 then
  rectfill(2,18,125,110,6)
  draw_egg()
 elseif pet.dead then
  rectfill(2,18,125,110,6)
  print("goodbye",50,47,1)
  print("o:new egg",46,66,1)
 elseif not pet.lights_on then
  rectfill(2,18,125,110,1)
  if pet.sleeping_t>0 then print("z z z",54,57,11) end
 else
  local names={"food","light","game","med","toilet","status","discipline","records","sound"}
  print(names[menu_i],64-#names[menu_i]*2,22,1)
  draw_lcd_pet(52,48+flr(time()*2)%2)
  for i=1,pet.poop do
   local px=27+(i-1)*9
   pset(px,78,1) rectfill(px-2,80,px+2,82,1)
  end
  if pet.sick then print("+",93,51,1) end
  if pet.false_call then print("!",94,68,1) end
  if msg~="" then
   rectfill(12,94,115,103,6)
   print(msg,64-#msg*2,96,1)
  end
 end
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
 right_number(score,118,22,1)
 line(89,31,118,31,5)
 spr(80,89,35)
 draw_bar(100,36,17,4,full(),11)
 spr(81,89,46)
 draw_bar(100,47,17,4,pet.happy,10)
 inner_screen(89,54,118,82,7)
 draw_pet_sprite(92,56,sel>0 and 4 or current_pet_state())
 ui_print("next",96,85,7)
 -- One shared tray, equal 2px gaps and margins; no contact with the bezel.
 rectfill(88,92,119,101,15)
 rectfill(89,93,118,100,7)
 for k=1,3 do
  spr(ball_sprs[next_balls[k]],90+(k-1)*10,93)
 end
 if hints_on then
  panel(6,106,81,121,1,6)
  spr(69,10,110)
  ui_print("move",21,112,7)
  spr(70,42,110)
  ui_print("o pick",53,112,7)
  panel(85,106,121,121,1,6)
  ui_print("x exit",91,112,7)
 end
 if quit_confirm then
  inner_screen(10,43,117,73,1)
  ui_print("quit game?",44,50,7)
  ui_print("o yes    x no",38,62,10)
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

function draw_result_screen()
 device_bezel(8)
 inner_screen(8,18,119,104,1)
 ui_print(new_best and "new record!" or result_reason,40,26,10)
 local labels={"score","lines","best","mood"}
 local values={score,session_lines,session_best,
               result_reason=="quit" and 0 or flr(session_lines/2)+2}
 for i=1,4 do
  local y=40+(i-1)*13
  spr(66+i%2,17,y)
  ui_print(labels[i],33,y+2,7)
  right_number(values[i],109,y+2,7)
 end
 line(12,95,115,95,5)
 ui_print("o continue",44,110,7)
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111111110000000000000000111111110000000000000000111111110000000000000000111111110000000000000000111111110000000000000000
00000011cccccccc1100000000000011cccccccc1100000000000011cccccccc1100000000000011cccccccc1100000000000011cccccccc1100000000000000
000001cccccccccccc100000000001cccccccccccc100000000001cccccccccccc100000000001cccccccccccc100000000001cccccccccccc10000000000000
00001cccccccccccccc1000000001cccccccccccccc1000000001cccccccccccccc1000000001cccccccccccccc1000000001cccccccccccccc1000000000000
0001cccccccccccccccc10000001cccccccccccccccc10000001cccccccccccccccc10000001cccccccccccccccc10000001cccccccccccccccc100000000000
001cccccccccccccccccc100001cccccccccccccccccc100001cccccccccccccccccc100001cccccccccccccccccc100001cccccccccccccccccc10000000000
01cccccccccccccccccccc1001cccccccccccccccccccc1001cccccccccccccccccccc1001cccccccccccccccccccc1001cccccccccccccccccccc1000000000
01cccccccccccccccccccc1001cccccccccccccccccccc1001cccccccccccccccccccc1001cccccccccccccccccccc1001cccccccccccccccccccc1000000000
01cccc111cccccc111cccc1001cccc111cccccc111cccc1001cccc111cccccc111cccc1001cccccccccccccccccccc1001cccc111cccccc111cccc1000000000
01ccc17771cccc17771ccc1001ccc17771cccc17771ccc1001ccc17771cccc17771ccc1001cccccccccccccccccccc1001ccc17771cccc17771ccc1000000000
01cc1777771cc1777771cc1001cc1777771cc1777771cc1001cc1777771cc1777771cc1001ccc1cccc1ccc1cccc1cc1001cc1777771cc1777771cc1000000000
01cc1771171cc1771171cc1001cc1771171cc1771171cc1001cc1771171cc1771171cc1001cccc1111ccccc1111ccc1001cc1771171cc1771171cc1000000000
01cc1771171cc1771171cc1001cc1771171cc1771171cc1001cc1771171cc1771171cc1001cccccccccccccccccccc1001cc1771171cc1771171cc1000000000
001cc17771cccc17771cc100001cc17771cccc17771cc100001cc17771cccc17771cc100001cccccccccccccccccc100001cc17771cccc17771cc10000000000
0001cc111cccccc111cc10000001cc111cccccc111cc10000001cc111cccccc111cc10000001cccccccccccccccc10000001cc111cccccc111cc100000000000
00001cccc1cccc1cccc1000000001cccccccccccccc1000000001cccccccccccccc1000000001cccccccccccccc1000000001ccccc1111ccccc1000000000000
000001cccc1cc1cccc100000000001cccccccccccc100000000001ccccc11ccccc100000000001ccccc11ccccc100000000001ccc1cccc1ccc10000000000000
00000011ccc11ccc1100000000000011cc1111cc1100000000000011cc1771cc1100000000000011cc1cc1cc1100000000000011c1c88c1c1100000000000000
00000000111111110000000000000000111111110000000000000000111111110000000000000000111111110000000000000000111111110000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111114aaaaa111111111111aaaaaa111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111114aaaaa111111111111aaaaaa111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111114aaaaa111111111111aaaaaa111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111114aaaaa111111111111aaaaaa111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111114aaaaa111111111111aaaaaa111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111114aaaaa11111111111111111111aaaaaaaaaaaaa1111111aaaaaaaaaa1111111aaaaaaaaaaa1111111111111111111111111111
111111111111111111111111114aaaaa11111111111111111111aaaaaaaaaaaaa1111111aaaaaaaaaa1111111aaaaaaaaaaa1111111111111111111111111111
111111111111111111111111114aaaaa111111111111aaaaaa11aaaaaaaaaaaaa1111111aaaaaaaaaa11111aaaaaaaaaaaaa1111111111111111111111111111
111111111111111111111111114aaaaa111111111111aaaaaa11aaaaaaaaaaaaaaa111aaaaaaaaaaaaaaa11aaaaaaaaaaaaa1111111111111111111111111111
111111111111111111111111114aaaaa111111111111aaaaaa11aaaaaaaaaaaaaaa111aaaaaaaaaaaaaaa11aaaaaaaaaaaaa1111111111111111111111111111
111111111111111111111111114aaaaa111111111111aaaaaa11aaaaaa1111aaaaa111aaaaa11111aaaaa11aaaa1111111111111111111111111111111111111
111111111111111111111111114aaaaa111111111111aaaaaa11aaaaaa1111aaaaa111aaaaaaaaaaaaaaa11aaaaaaaaaaa111111111111111111111111111111
111111111111111111111111114aaaaa111111111111aaaaaa11aaaaaa1111aaaaa111aaaaaaaaaaaaaaa11aaaaaaaaaaa111111111111111111111111111111
111111111111111111111111114aaaaa111111111111aaaaaa11aaaaaa1111aaaaa111aaaaaaaaaaaaaaa1111aaaaaaaaaaa1111111111111111111111111111
111111111111111111111111114aaaaa111111111111aaaaaa11aaaaaa1111aaaaa111aaaaaaaaaaaaaaa1111aaaaaaaaaaa1111111111111111111111111111
111111111111111111111111114aaaaaaaaaaaaaaa11aaaaaa11aaaaaa1111aaaaa111aaaaa11111111111111111111aaaaa1111111111111111111111111111
111111111111111111111111114aaaaaaaaaaaaaaa11aaaaaa11aaaaaa1111aaaaa111aaaaa11111111111111111111aaaaa1111111111111111111111111111
111111111111111111111111114aaaaaaaaaaaaaaa11aaaaaa11aaaaaa1111aaaaa111aaaaaaaaaaaaaa111aaaaaaaaaaaaa1111111111111111111111111111
111111111111111111111111114aaaaaaaaaaaaaaa11aaaaaa11aaaaaa1111aaaaa111aaaaaaaaaaaaaa111aaaaaaaaaaaaa1111111111111111111111111111
111111111111111111111111114aaaaaaaaaaaaaaa11aaaaaa11aaaaaa1111aaaaa11111aaaaaaaaaaaa111aaaaaaaaaaaaa1111111111111111111111111111
11111111111111111111111111544444444444444411aaaaaa11aaaaaa1111aaaaa11111aaaaaaaaaaaa111aaaaaaaaaaa111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111eeeeeeeeeeee11111111111111111111111111111111111111111111111111eeeee1111111111111eeeee11111111111111111111
11111111111111111111111eeeeeeeeeeee111111111111111111111111eeeee111111111111111111111eeeee1111111111111eeeee11111111111111111111
11111111111111111111111eeeeeeeeeeee111111111111111111111115eeeee111111111111111111111eeeee1111111111111eeeee11111111111111111111
111111111111111111111eeeeeeeeeeeeeeee1111111111111111111111eeeee111111111111111111111eeeee1111111111111eeeee11111111111111111111
111111111111111111111eeeeeeeeeeeeeeee1111111111111111111111eeeee111111111111111111111eeeee1111111111111eeeee11111111111111111111
111111111111111111111eeeeeedddddddeee1111111111111111111115eeeee111111111111111111111eeeee11111111111111111111111111111111111111
111111111111111111111eeeee1111111111111111eeeeeeeeee1111eeeeeeeeeee11111eeeeeeeeeee11eeeeeeeeeeeee111111111111111111111111111111
111111111111111111111eeeee1111111111111111eeeeeeeeee1111eeeeeeeeeee11111eeeeeeeeeee11eeeeeeeeeeeee11111eeeee11111111111111111111
111111111111111111111eeeee11eeeeeeeee11111eeeeeeeeee1111eeeeeeeeeee11111eeeeeeeeeee11eeeeeeeeeeeee55111eeeee11111111111111111111
111111111111111111111eeeee11eeeeeeeee11eeeeeeeeeeeeeeee1eeeeeeeeeee11eeeeeeeeeeeeee11eeeeeeeeeeeeeee111eeeee11111111111111111111
111111111111111111111eeeee11eeeeeeeee11eeeeeeeeeeeeeeee1eeeeeeeeeee11eeeeeeeeeeeeee11eeeeeeeeeeeeeee111eeeee11111111111111111111
111111111111111111111eeeee11eeeeeeeee11eeeeee11112eeeee1111eeeee11111eeeee11111111111eeeee11111eeeee111eeeee11111111111111111111
111111111111111111111eeeee11eeeeeeeee11eeeeee11112eeeee1111eeeee11111eeeee11111111111eeeee11111eeeee111eeeee11111111111111111111
111111111111111111111eeeee111111eeeee11eeeeee11112eeeee1111eeeee11111eeeee11111111111eeeee11111eeeee111eeeee11111111111111111111
111111111111111111111eeeee111111eeeee11eeeeee11112eeeee1111eeeee11111eeeee11111111111eeeee11111eeeee111eeeee11111111111111111111
111111111111111111111eeeee111111eeeee11eeeeee11112eeeee1111eeeee11111eeeee11111111111eeeee11111eeeee111eeeee11111111111111111111
111111111111111111111eeeeeeeeeeeeeeee11eeeeee11112eeeee1111eeeee11111eeeee11111111111eeeee11111eeeee111eeeee11111111111111111111
111111111111111111111eeeeeeeeeeeeeeee11eeeeeeeeeeeeeeee1115eeeeeeee11eeeeeeeeeeeeee11eeeee11111eeeee111eeeee11111111111111111111
111111111111111111111eeeeeeeeeeeeeeee11eeeeeeeeeeeeeeee1111eeeeeeee11eeeeeeeeeeeeee11eeeee11111eeeee111eeeee11111111111111111111
11111111111111111111111eeeeeeeeeeee1111111eeeeeeeeee111111111eeeeee11111eeeeeeeeeee11eeeee11111eeeee111eeeee11111111111111111111
11111111111111111111111eeeeeeeeeeee1111111eeeeeeeeee111111111eeeeee11111eeeeeeeeeee11eeeee11111eeeee111eeeee11111111111111111111
111111111111111111111111111111111111111111111dddd255111111111555ddd1111155eeeeeeeed11deeee11111deeed111eeeee11111111111111111111
11111111111111111111111111111111111111111111111111111111111100001111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111100001111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111111100cccc0011111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111111100cccc0011111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111111100cccc0011111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111100000000cccc00000000111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111100000000cccc00000000111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111110000cccccccccccccccccccc000001111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111110000cccccccccccccccccccc000001111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111110000cccccccccccccccccccccccccccc10001111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111110000cccccccccccccccccccccccccccc10001111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111100cccccccc66cccccccccccccccccccccccccc0011111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111100cccccccc66cccccccccccccccccccccccccc0011111111111111111111111111111111111111111111
11111111111111111111111111111111111111111100cccc666666cccccccccccccccccccccccccccccc00111111111111111111111111111111111111111111
11111111111111111111111111111111111111111100cccc666666cccccccccccccccccccccccccccccc00111111111111111111111111111111111111111111
111111111111111111111111111111111111111100cccc6666cccccccccccccccccccccccccccccccccccc101111111111111111111111111111111111111111
111111111111111111111111111111111111111100cccc6666cccccccccccccccccccccccccccccccccccc101111111111111111111111111111111111111111
111111111111111111111111111111111111110011cccc666ccccccccccccccccccccccccccccccccccccc310011111111111111111111111111111111111111
1111111111111111111111111111111111111100cccc6666cccccccccccccccccccccccccccccccccccccccc1011111111111111111111111111111111111111
1111111111111111111111111111111111111100cccc6676cccccccccccccccccccccccccccccccccccccccc1011111111111111111111111111111111111111
1111111111111111111111111111111111111100cccccccc77777777cccccccccccccccc77777777cccccccc1011111111111111111111111111111111111111
11111111111111111111111111111111111100cccccccccc77777777cccccccccccccccc77777777cccccccccc00011111111111111111111111111111111111
11111111111111111111111111111111111100cccccccc777777777777cccccccccccc777777777777cccccccc00011111111111111111111111111111111111
11111111111111111111111111111111111100cccccccc777777777777cccccccccccc777777777777cccccccc00011111111111111111111111111111111111
11111111111111111111111111111111111100cccccc7777777777777777cccccccc7777777777777777cccccc00011111111111111111111111111111111111
11111111111111111111111111111111111100cccccc7777777777777777cccccccc7777777777777777cccccc00111111111111111111111111111111111111
111111111111111111111111111111111100cccccc77777777000077777777cccc777777000000d7777777cccccc100111111111111111111111111111111111
111111111111111111111111111111111100cccccc77777777000077777777cccc777777000000d7777777cccccc100111111111111111111111111111111111
111111111111111111111111111111111100cccccc77777700000000777777cccc77777700000000777777cccccc100111111111111111111111111111111111
111111111111111111111111111111111100cccccc77777700000000777777cccc77777700000000777777cccccc100111111111111111111111111111111111
111111111111111111111111111111111100cccccc77770000000000007777cccc77770000000000007777cccccc100111111111111111111111111111111111
111111111111111111111111111111111100cccccc77770000000000007777cccc77770000000000007777cccccc100111111111111111111111111111111111
111111111111111111111111111111111100cccccc77770000000000007777cccc77770000000000007777cccccc100111111111111111111111111111111111
111111111111111111111111111111111100cccccc77770000000000007777cccc77770000000000007777cccccc100111111111111111111111111111111111
111111111111111111111111111111111100cccccc77770000000000007777cccc77770000000000007777cccccc100111111111111111111111111111111111
111111111111111111111111111111111100cccccc77775d000000005d7777cccc7777dd00000000d57777cccccc100111111111111111111111111111111111
111111111111111111111111111111111100cccccc77777700000000777777cccc77777700000000777777cccccc100111111111111111111111111111111111
111111111111111111111111111111111100cccccc77777700000000777777cccc77777700000000777777cccccc100111111111111111111111111111111111
111111111111111111111111111111111100cccccccc6777777777777766cccccccc7777777777777776cccccccc100111111111111111111111111111111111
111111111111111111111111111111111100cccccccc6677777777777766cccccccc7777777777777766cccccccc100111111111111111111111111111111111
11111111111111111111111111111111111100cccccccc777777777777cccccccccccc777777777777cccccccc00011111111111111111111111111111111111
11111111111111111111111111111111111100cccccccc777777777777cccccccccccc777777777777cccccccc00011111111111111111111111111111111111
11111111111111111111111111111111111100cccccccccccccccccccccccccccccccccccccccccccccccccccc00011111111111111111111111111111111111
11111111111111111111111111111111111100cccccccccccccccccccccccccccccccccccccccccccccccccccc00011111111111111111111111111111111111
1111111111111111111111111111111111111100cccccccccccccccccc000000000000cccccccccccccccccc0011111111111111111111111111111111111111
1111111111111111111111111111111111111100cccccccccccccccccc000000000000cccccccccccccccccc0011111111111111111111111111111111111111
1111111111111111111111111111111111111100cccccccccccccccccccc00000000cccccccccccccccccccc0011111111111111111111111111111111111111
111111111111111111111111111111111111110011cccccccccccccccccc00000000cccccccccccccccccc310011111111111111111111111111111111111111
111111111111111111111111111111111111111100cccccccccccccccccccc0000cccccccccccccccccccc101111111111111111111111111111111111111111
111111111111111111111111111111111111111100cccccccccccccccccccc0000cccccccccccccccccccc101111111111111111111111111111111111111111
11111111111111111111111111111111111111111100cccccccccccccccccccccccccccccccccccccccc10111111111111111111111111111111111111111111
11111111111111111111111111111111111111111100cccccccccccccccccccccccccccccccccccccccc00111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111100cccccccccccccccccccccccccccccccccccc0001111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111100333cccccccccccccccccccccccccccccc3330011111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111000cccccccccccccccccccccccccccccc0001111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111100000ccccccccccccccccccccc00001111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111100000ccccccccccccccccccccc00001111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111100000000000000000000011111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111100000000000000000000011111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111110000001111111111111110000001111111111111110000001111111111111111000001111111111111111000000111111111111111111
11111111111111111110000001111111111111110000001111111111111110000001111111111111111000001111111111111111000000111111111111111111
1111111111111111100888888001111111111100aaaaaa001111111111100bbbbbb0011111111111100ccccc0011111111111100eeeee2011111111111111111
1111111111111111100888888001111111111100aaaaaa001111111111100bbbbbb0011111111111100ccccc0011111111111100eeeee2011111111111111111
11111111111111100887778888801111111100aa777aaaaa011111111103b777bbbbb011111111100cc77ccccc001111111100ee777eeee00111111111111111
11111111111111100887778888801111111100aa777aaaaa011111111103b777bbbbb011111111100cc77ccccc001111111100ee777eeee00111111111111111
1111111111111008877788888888001111104a777aaaaaaaa001111100b677bbbbbbbb001111100cc777cccccccc00111100ee777eeeeeeee001111111111111
1111111111111008877788888888001111104a777aaaaaaaa001111100b777bbbbbbbb001111100cc777cccccccc00111100ee777eeeeeeee001111111111111
1111111111111008888888888888001111104aaaaaaaaaaaa001111100bbbbbbbbbbbb001111100ccccccccccccc00111100eeeeeeeeeeeee001111111111111
1111111111111008888888888888001111104aaaaaaaaaaaa001111100bbbbbbbbbbbb001111100ccccccccccccc00111100eeeeeeeeeeeee001111111111111
1111111111111008888888888888001111104aaaaaaaaaaaa001111100bbbbbbbbbbbb001111100ccccccccccccc00111100eeeeeeeeeeeee001111111111111
11111111111111000888888888801111111005aaaaaaaaaa01111111000bbbbbbbbbb011111110011ccccccccc001111110012eeeeeeeee00111111111111111
11111111111111100888888888801111111100aaaaaaaaaa011111111103bbbbbbbbb011111111100ccccccccc001111111100eeeeeeeee00111111111111111
1111111111111111000888888000111111111000aaaaaa000111111111100bbbbbb0011111111111001ccccc0011111111111100eeeee2011111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
