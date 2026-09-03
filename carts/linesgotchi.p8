pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- linesgotchi mvp

scr=0
menu_i=1
msg=""
result_reason=""
new_best=false

-- screens
s_pet=0
s_lines=1
s_result=2
s_stats=3
s_records=4

-- lines config
bs=8
cs=8
ox=7
oy=26
colors={8,10,11,12,14}
dxs={1,0,1,1}
dys={0,1,1,-1}

-- gotchi state
pet={
 hunger=15,
 happy=55,
 health=100,
 discipline=45,
 weight=10,
 age=0
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

function _init()
 cartdata("linesgotchi")
 load_records()
 show_pet()
end

function _update()
 if scr==s_pet then update_pet()
 elseif scr==s_lines then update_lines()
 elseif scr==s_result then update_result()
 elseif scr==s_stats then update_back_screen()
 elseif scr==s_records then update_back_screen()
 end
end

function _draw()
 cls(1)
 if scr==s_pet then draw_pet_screen()
 elseif scr==s_lines then draw_lines_screen()
 elseif scr==s_result then draw_result_screen()
 elseif scr==s_stats then draw_stats_screen()
 elseif scr==s_records then draw_records_screen()
 end
end

function show_pet()
 scr=s_pet
 msg=""
end

function load_records()
 hi_score=dget(0)
 games_played=dget(1)
 total_lines=dget(2)
 best_line=dget(3)
end

function save_records()
 dset(0,hi_score)
 dset(1,games_played)
 dset(2,total_lines)
 dset(3,best_line)
end

function clamp(v,lo,hi)
 return max(lo,min(hi,v))
end

function full()
 return 100-pet.hunger
end

function update_pet()
 if btnp(0) then menu_i=max(1,menu_i-1) end
 if btnp(1) then menu_i=min(4,menu_i+1) end
 if btnp(4) then
  if menu_i==1 then feed_pet()
  elseif menu_i==2 then start_lines()
  elseif menu_i==3 then scr=s_stats
  elseif menu_i==4 then scr=s_records
  end
 end
end

function feed_pet()
 pet.hunger=clamp(pet.hunger-25,0,100)
 pet.weight=clamp(pet.weight+1,1,99)
 msg="fed +full"
end

function start_lines()
 scr=s_lines
 cx=1
 cy=1
 sel=0
 score=0
 session_lines=0
 session_best=0
 moves=0
 game_over=false
 new_best=false
 for i=1,bs*bs do b[i]=0 end
 add_balls(5)
 clear_lines()
 msg=""
end

function update_lines()
 if game_over then
  finish_lines("game over")
  return
 end
 if btnp(0) then cx=max(1,cx-1) end
 if btnp(1) then cx=min(bs,cx+1) end
 if btnp(2) then cy=max(1,cy-1) end
 if btnp(3) then cy=min(bs,cy+1) end
 if btnp(5) then
  if sel>0 then
   sel=0
   msg="cancel"
  else
   finish_lines("quit")
   return
  end
 end
 if btnp(4) then lines_action() end
end

function lines_action()
 local i=idx(cx,cy)
 if sel==0 then
  if b[i]>0 then
   sel=i
   msg="selected"
  end
 else
  if i==sel then
   sel=0
   msg="cancel"
  elseif b[i]>0 then
   sel=i
   msg="selected"
  elseif can_reach(sel,i) then
   b[i]=b[sel]
   b[sel]=0
   sel=0
   moves+=1
   tick_pet_play()
   local cleared,best=clear_lines()
   if cleared==0 then
    add_balls(3)
    cleared,best=clear_lines()
   end
   game_over=is_full()
  else
   msg="no path"
  end
 end
end

function tick_pet_play()
 if moves%3==0 then
  pet.happy=clamp(pet.happy+1,0,100)
  pet.hunger=clamp(pet.hunger+2,0,100)
 end
 if moves%8==0 and pet.weight>8 then
  pet.weight-=1
 end
end

function finish_lines(reason)
 result_reason=reason
 games_played+=1
 new_best=score>hi_score
 if new_best then hi_score=score end
 total_lines+=session_lines
 if session_best>best_line then best_line=session_best end
 local gain=flr(session_lines/2)+2
 if pet.hunger>85 then gain=1 end
 pet.happy=clamp(pet.happy+gain,0,100)
 pet.hunger=clamp(pet.hunger+5,0,100)
 save_records()
 scr=s_result
 msg=""
end

function update_result()
 if btnp(4) or btnp(5) then show_pet() end
end

function update_back_screen()
 if btnp(4) or btnp(5) then show_pet() end
 if scr==s_stats then
  if btnp(1) then scr=s_records end
 elseif scr==s_records then
  if btnp(0) then scr=s_stats end
 end
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

function add_balls(n)
 for k=1,n do
  local empties={}
  for i=1,bs*bs do
   if b[i]==0 then add(empties,i) end
  end
  if #empties==0 then
   game_over=true
   return
  end
  local spot=empties[flr(rnd(#empties))+1]
  b[spot]=flr(rnd(#colors))+1
 end
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
  msg="line +"..cleared
 end
 return cleared,best
end

function is_full()
 for i=1,bs*bs do
  if b[i]==0 then return false end
 end
 return true
end

function draw_pet_screen()
 cls(6)
 title("linesgotchi")
 panel(7,15,120,96,7,5)
 rectfill(13,21,114,90,3)
 rect(13,21,114,90,0)
 draw_pet(45,25)
 print("full",21,71,7)
 print("mood",21,81,7)
 draw_bar(46,71,49,4,full(),11)
 draw_bar(46,81,49,4,pet.happy,10)
 print(full(),99,71,11)
 print(pet.happy,99,81,10)
 local items={"feed","play","stat","rec"}
 for i=1,4 do
  local x=5+(i-1)*31
  local c=i==menu_i and 10 or 0
  local tc=i==menu_i and 0 or 7
  rectfill(x,105,x+27,118,c)
  rect(x,105,x+27,118,7)
  print(items[i],x+5,110,tc)
 end
 if msg~="" then print(msg,42,96,0) end
 print("left/right  o ok",22,122,1)
end

function draw_lines_screen()
 cls(6)
 title("play lines")
 panel(4,18,73,91,7,5)
 rectfill(8,23,70,86,0)
 panel(78,18,123,102,7,5)
 print("score",85,23,6)
 print(score,85,31,0)
 print("full",85,45,6)
 print(full(),106,45,11)
 print("mood",85,55,6)
 print(pet.happy,106,55,10)
 draw_mini_pet(101,75)
 print("x end",89,94,5)
 print(msg,84,106,0)
 for y=1,bs do
  for x=1,bs do
   local px=ox+(x-1)*cs
   local py=oy+(y-1)*cs
   rect(px,py,px+6,py+6,5)
   local i=idx(x,y)
   if b[i]>0 then
    circfill(px+3,py+3,3,colors[b[i]])
    pset(px+2,py+2,7)
    pset(px+4,py+2,7)
   end
   if i==sel then rect(px-1,py-1,px+7,py+7,10) end
  end
 end
 local cp_x=ox+(cx-1)*cs
 local cp_y=oy+(cy-1)*cs
 rect(cp_x-2,cp_y-2,cp_x+8,cp_y+8,7)
 print("o pick/move",6,121,1)
end

function draw_result_screen()
 cls(6)
 title("result")
 panel(15,20,112,104,7,5)
 rectfill(21,26,106,98,3)
 print(result_reason,42,30,10)
 print("score",28,46,7) print(score,72,46,10)
 print("lines",28,56,7) print(session_lines,72,56,10)
 print("best",28,66,7) print(session_best,72,66,10)
 print("full",28,80,7) print(full(),72,80,11)
 print("mood",28,90,7) print(pet.happy,72,90,10)
 if new_best then print("new best",45,101,10) end
 print("o/x: pet",42,118,1)
end

function draw_stats_screen()
 cls(6)
 title("stats")
 panel(12,19,115,104,7,5)
 rectfill(18,25,109,98,3)
 print("< stats      records >",8,15,1)
 stat_line("full",full(),32,11)
 stat_line("mood",pet.happy,44,10)
 stat_line("health",pet.health,56,12)
 stat_line("discip",pet.discipline,68,9)
 print("weight",23,83,7) print(pet.weight,83,83,9)
 print("age",23,93,7) print(pet.age,83,93,7)
 print("o/x: pet",42,118,1)
end

function draw_records_screen()
 cls(6)
 title("records")
 panel(12,19,115,104,7,5)
 rectfill(18,25,109,98,3)
 print("< stats      records >",8,15,1)
 print("hi-score",24,36,7) print(hi_score,76,36,10)
 print("games",24,50,7) print(games_played,76,50,10)
 print("lines",24,64,7) print(total_lines,76,64,10)
 print("best",24,78,7) print(best_line,76,78,10)
 print("hall/species later",22,94,13)
 print("o/x: pet",42,118,1)
end

function title(t)
 rectfill(0,0,127,11,0)
 line(0,12,127,12,5)
 print(t,4,4,7)
end

function panel(x0,y0,x1,y1,fill,edge)
 rectfill(x0+2,y0+2,x1+2,y1+2,5)
 rectfill(x0,y0,x1,y1,fill)
 rect(x0,y0,x1,y1,edge)
 rect(x0+1,y0+1,x1-1,y1-1,7)
end

function draw_bar(x,y,w,h,v,col)
 v=clamp(v,0,100)
 rectfill(x,y,x+w,y+h,0)
 rect(x,y,x+w,y+h,5)
 local fw=flr((w-2)*v/100)
 if fw>0 then
  rectfill(x+1,y+1,x+fw,y+h-1,col)
 end
end

function stat_line(name,v,y,col)
 print(name,19,y,7)
 print(v,62,y,col)
 draw_bar(82,y,28,4,v,col)
end

function draw_pet(x,y)
 local sad=pet.hunger>75 or pet.happy<25
 rectfill(x+11,y+10,x+29,y+28,12)
 rectfill(x+13,y+7,x+17,y+11,12)
 rectfill(x+23,y+7,x+27,y+11,12)
 rect(x+11,y+10,x+29,y+28,7)
 circfill(x+14,y+18,2,0)
 circfill(x+26,y+18,2,0)
 pset(x+14,y+17,7)
 pset(x+26,y+17,7)
 if sad then
  line(x+16,y+24,x+24,y+24,0)
 else
  line(x+16,y+23,x+20,y+26,0)
  line(x+20,y+26,x+24,y+23,0)
 end
 rectfill(x+14,y+29,x+26,y+40,12)
 rect(x+14,y+29,x+26,y+40,7)
 line(x+14,y+33,x+8,y+36,12)
 line(x+26,y+33,x+32,y+36,12)
 rectfill(x+15,y+41,x+18,y+43,5)
 rectfill(x+22,y+41,x+25,y+43,5)
end

function draw_mini_pet(x,y)
 local col=12
 if pet.hunger>80 then col=8 end
 rectfill(x-7,y-7,x+7,y+7,col)
 rect(x-7,y-7,x+7,y+7,7)
 pset(x-3,y-2,0)
 pset(x+3,y-2,0)
 if pet.hunger>80 then
  line(x-3,y+4,x+3,y+4,0)
 else
  line(x-4,y+3,x,y+5,0)
  line(x,y+5,x+4,y+3,0)
 end
end
